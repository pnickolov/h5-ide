
define [
  "OpsModel"
  "../template/TplOpsEditor"
  "component/exporter/Thumbnail"
  "component/exporter/JsonExporter"
  "ApiRequest"
  "i18n!nls/lang.js"
  "UI.modalplus"
  'kp_dropdown'
  "UI.notification"
  "backbone"
], ( OpsModel, OpsEditorTpl, Thumbnail, JsonExporter, ApiRequest, lang, Modal, kpDropdown )->

  Backbone.View.extend {

    events :
      "click .icon-save"                   : "saveStack"
      "click .icon-delete"                 : "deleteStack"
      "click .icon-duplicate"              : "duplicateStack"
      "click .icon-new-stack"              : "createStack"
      "click .icon-zoom-in"                : "zoomIn"
      "click .icon-zoom-out"               : "zoomOut"
      "click .icon-export-png"             : "exportPNG"
      "click .icon-export-json"            : "exportJson"
      "click .icon-toolbar-cloudformation" : "exportCF"
      "click .runApp"                      : 'runStack'
      "OPTION_CHANGE .toolbar-line-style"  : "setTbLineStyle"

      "click .icon-stop"              : "stopApp"
      "click .startApp"               : "startApp"
      "click .icon-terminate"         : "terminateApp"
      "click .icon-refresh"           : "refreshResource"
      "click .icon-update-app"        : "switchToAppEdit"
      "click .icon-apply-app"         : "applyAppEdit"
      "click .icon-cancel-update-app" : "cancelAppEdit"

    render : ()->
      opsModel = @workspace.opsModel

      # Toolbar
      if opsModel.isImported()
        btns = ["BtnActionPng", "BtnZoom", "BtnLinestyle"]
      else if opsModel.isStack()
        btns = ["BtnRunStack", "BtnStackOps", "BtnZoom", "BtnExport", "BtnLinestyle"]
      else
        if @__editMode
          btns = ["BtnApply", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes"]
        else
          btns = ["BtnEditApp", "BtnAppOps", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes"]

      tpl = ""
      for btn in btns
        tpl += OpsEditorTpl.toolbar[ btn ]()

      @setElement $("#OEPanelTop").html( tpl )

      @updateTbBtns()
      @updateZoomButtons()
      return

    clearDom : ()->
      @$el = null
      return

    updateTbBtns : ()->
      opsModel = @workspace.opsModel

      # LineStyle Btn
      @$el.children(".toolbar-line-style").children(".dropdown").children().eq(parseInt(localStorage.getItem("canvas/lineStyle"),10) || 2).click()

      # App Run & Stop
      if opsModel.isApp()
        @$el.children(".icon-update-app").toggle( not @workspace.isAppEditMode() )
        @$el.children(".icon-apply-app, .icon-cancel-update-app").toggle( @workspace.isAppEditMode() )
        if @workspace.isAppEditMode()
          @$el.children(".icon-terminate, .icon-stop, .icon-play").hide()
        else
          @$el.children(".icon-terminate").show()
          @$el.children(".icon-stop").toggle( opsModel.get("stoppable") and opsModel.testState(OpsModel.State.Running) )
          @$el.children(".icon-play").toggle( opsModel.testState( OpsModel.State.Stopped ) )

      if @__saving
        @$el.children(".icon-save").attr("disabled", "disabled")
      else
        @$el.children(".icon-save").removeAttr("disabled")

      @updateZoomButtons()
      return

    setTbLineStyle : ( ls )->
      localStorage.setItem("canvas/lineStyle", ls)
      $canvas.updateLineStyle( ls )

    hideError: (type)->
        selector = if type then "#runtime-error-#{type}" else ".runtime-error"
        $(selector).hide()

    showError: (id, msg)->
        $("#runtime-error-#{id}").text(msg).show()

    runStack: (event)->
        console.debug "Run Stack Start.", new Date()
        console.debug 'CurrentTarget', event.currentTarget
        if $(event.currentTarget).attr('disabled')
            console.debug 'Target Disabled, Can not run.'
            return false
        options =
            title: lang.ide.RUN_STACK_MODAL_TITLE
            template: MC.template.modalRunStack
            disableClose: true
            width: '450px'
            height: '515px'
            confirm:
                text: if App.user.hasCredential() then lang.ide.RUN_STACK else lang.ide.RUN_STACK_MODAL_NEED_CREDENTIAL
                disabled: true
        @modal = new Modal(options)

        # render KPDropDown after the modal has shown
        @renderKpDropdown()
        event.preventDefault()
        @modal.tpl.find('.modal-input-value').val MC.common.other.canvasData.get 'name'

        cost = Design.instance().getCost()

        $('#label-total-fee').find('b').text "$#{cost.totalFee}"

        # insert TA component
        require ['component/trustedadvisor/main'], (trustedadvisor_main)->
            trustedadvisor_main.loadModule('stack').then ()->
                @modal and @modal.toggleConfirm(false)

        # click Logic
        @modal.on 'confirm', ()=>
            @hideError()

            if not App.user.hasCredential()
                App.showSettings(App.showSettings.TAB.Credential)
                return false

            app_name = $('.modal-input-value').val()

            if not app_name
                @showError 'appname', lang.ide.PROP_MSG_WARN_NO_APP_NAME
                return false

            if not MC.validate 'awsName', app_name
                @showError 'appname', lang.ide.PROP_MSG_WARN_INVALID_APP_NAME
                return false

            process_tab_name = "process-" + MC.common.other.canvasData.get('region') + "-" + app_name

            obj = MC.common.other.getProcess process_tab_name
            if obj and obj.flag_list and obj.flag_list.is_failed is true and obj.flag_list.flat is "RUN_STACK"

                MC.common.other.deleteProcess process_tab_name

                ide_event.trigger ide_event.CLOSE_DESIGN_TAB, process_tab_name

            appNameRepeated = (not MC.aws.aws.checkAppName app_name) or (_.contains(_.key(MC.process), process_tab_name))
            if appNameRepeated
                @showError 'appname', lang.ide.PROP_MSG_WARN_REPEATED_APP_NAME

            if not @defaultKpIsSet()  or appNameRepeated
                return false

            @modal.toggleConfirm true
            @modal.tpl.find('.modal-header .modal-close').hide()
            @modal.tpl.find('#run-stack-cancel').attr 'disabled', true

            region = MC.common.other.canvasData.get('region')
            canvasData = MC.common.other.canvasData.data()
            @model.syncSaveStack( region , canvasData ).then (stackId)=>
                if not @modal or not @modal.isOpen()
                    return
                data = canvasData
                data.name = app_name

                data.usage = 'others'
                usage = @modal.tpl.find('#app-usage-selectbox .selected').data 'value'
                if usage
                    data.usage = usage

                data.id = stackId
                @model.runStack data

                MC.data.app_list[region].push(app_name)
                @modal? @modal.close()
        , @
        null

    renderKpDropdown: ->
        if kpDropdown.hasResourceWithDefaultKp()
            kpDrop = new kpDropdown()
            $('#kp-runtime-placeholder').html kpDrop.render().el
            removeNoKpError = ()=>
                @hideError('kp')
            kpDrop.on 'change', removeNoKpError
            $(".default-kp-group").show()
        null

    saveStack : ( evt )->
      $( evt.currentTarget ).attr("disabled", "disabled")

      self = @
      @__saving = true

      newJson = @workspace.design.serialize()

      Thumbnail.generate( $("#svg_canvas") ).catch( ()->
        return null
      ).then ( thumbnail )->
        self.workspace.opsModel.save( newJson, thumbnail ).then ()->
          self.__saving = false
          $( evt.currentTarget ).removeAttr("disabled")
          notification "info", sprintf(lang.ide.TOOL_MSG_ERR_SAVE_SUCCESS, newJson.name)
        , ( err )->
          self.__saving = false
          $( evt.currentTarget ).removeAttr("disabled")
          notification "error", sprintf(lang.ide.TOOL_MSG_ERR_SAVE_FAILED, newJson.name)
        return

    deleteStack    : ()-> App.deleteStack( @workspace.opsModel.cid, @workspace.design.get("name") )
    createStack    : ()-> App.createOps( @workspace.opsModel.get("region") )
    duplicateStack : ()->
      newOps = App.model.createStackByJson( @workspace.design.serialize() )
      App.openOps newOps
      return

    zoomIn  : ()-> MC.canvas.zoomIn();  @updateZoomButtons()
    zoomOut : ()-> MC.canvas.zoomOut(); @updateZoomButtons()
    updateZoomButtons : ()->
      scale = $canvas.scale()
      if scale <= 1
        @$el.find(".icon-zoom-in").attr("disabled", "disabled")
      else
        @$el.find(".icon-zoom-in").removeAttr("disabled")

      if scale >= 1.6
        @$el.find(".icon-zoom-out").attr("disabled", "disabled")
      else
        @$el.find(".icon-zoom-out").removeAttr("disabled")
      return

    exportPNG : ()->
      modal = new Modal {
        title         : "Export PNG"
        template      : OpsEditorTpl.export.PNG()
        width         : "470"
        disableFooter : true
        compact       : true
        onClose : ()-> modal = null; return
      }

      design = @workspace.design
      name   = design.get("name")
      Thumbnail.exportPNG $("#svg_canvas"), {
          isExport   : true
          createBlob : true
          name       : name
          id         : design.get("id")
          onFinish   : ( data ) ->
            if not modal then return
            modal.tpl.find(".loading-spinner").remove()
            modal.tpl.find("section").show().prepend("<img style='max-height:100%;display:inline-block;' src='#{data.image}' />")
            btn = modal.tpl.find("a.btn-blue")
            if data.blob
              btn.click ()-> JsonExporter.download( data.blob, "#{name}.png" ); false
            else
              btn.attr {
                href     : data.image
                download : "#{name}.png"
              }
            modal.resize()
            return
      }
      return

    exportJson : ()->
      design   = @workspace.design
      username = App.user.get('username')
      date     = MC.dateFormat(new Date(), "yyyy-MM-dd")
      name     = [design.get("name"), username, date].join("-")

      data = JsonExporter.exportJson design.serialize(), "#{name}.json"
      if data
        # The browser doesn't support Blob. Fallback to show a dialog to
        # allow user to download the file.
        new Modal {
          title         : lang.ide.TOOL_EXPORT_AS_JSON
          template      : OpsEditorTpl.export.JSON( data )
          width         : "470"
          disableFooter : true
          compact       : true
        }

    exportCF : ()->
      modal = new Modal {
        title         : lang.ide.TOOL_POP_EXPORT_CF
        template      : OpsEditorTpl.export.CF()
        width         : "470"
        disableFooter : true
      }

      design = @workspace.design
      name   = design.get("name")

      ApiRequest("stack_export_cloudformation", {
        region : design.get("region")
        stack  : design.serialize()
      }).then ( data )->
        btn = modal.tpl.find("a.btn-blue").text(lang.ide.TOOL_POP_BTN_EXPORT_CF).removeClass("disabled")
        JsonExporter.genericExport btn, data, "#{name}.json"
        return
      , ( err )->
        modal.tpl.find("a.btn-blue").text("Fail to export...")
        notification "error", "Fail to export to AWS CloudFormation Template, Error code:#{err.error}"
        return

    startApp        : ()-> App.startApp( @workspace.opsModel.id ); false
    stopApp         : ()-> App.stopApp( @workspace.opsModel.id );  false
    terminateApp    : ()-> App.terminateApp( @workspace.opsModel.id ); false
    refreshResource : ()-> @workspace.refreshResource(); false
    switchToAppEdit : ()-> @workspace.switchMode( true ); false
    applyAppEdit    : ()-> @workspace.applyAppEdit(); false
    cancelAppEdit   : ()-> @workspace.switchMode( false ); false
  }
