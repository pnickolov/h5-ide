
define [
  "OpsModel"
  "../template/TplOpsEditor"
  "component/exporter/Thumbnail"
  "component/exporter/JsonExporter"
  "ApiRequest"
  "i18n!nls/lang.js"
  "UI.modalplus"
  'kp_dropdown'
  'constant'
  "UI.notification"
  "backbone"
], ( OpsModel, OpsEditorTpl, Thumbnail, JsonExporter, ApiRequest, lang, Modal, kpDropdown, constant )->

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
        isAppEdit = @workspace.isAppEditMode and @workspace.isAppEditMode()
        @$el.children(".icon-update-app").toggle( not isAppEdit )
        @$el.children(".icon-apply-app, .icon-cancel-update-app").toggle( isAppEdit )
        if isAppEdit
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

    runStack: (event)->
        if $(event.currentTarget).attr('disabled')
            return false
        @modal = new Modal
            title: lang.ide.RUN_STACK_MODAL_TITLE
            template: MC.template.modalRunStack
            disableClose: true
            width: '450px'
            height: "515px"
            confirm:
                text: if App.user.hasCredential() then lang.ide.RUN_STACK else lang.ide.RUN_STACK_MODAL_NEED_CREDENTIAL
                disabled: true
        @renderKpDropdown()
        cost = Design.instance().getCost()
        @modal.tpl.find('.modal-input-value').val @workspace.opsModel.get("name")
        @modal.tpl.find("#label-total-fee").find('b').text("$#{cost.totalFee}")

        # load TA
        require ['component/trustedadvisor/main'], (trustedadvisor_main)=>
            trustedadvisor_main.loadModule('stack').then ()=>
                @modal?.toggleConfirm false
        appNameDom = @modal.tpl.find('#app-name')
        checkAppNameRepeat = @checkAppNameRepeat.bind @
        appNameDom.keyup ->
            checkAppNameRepeat(appNameDom.val())
        @modal.on 'confirm', ()=>
            @hideError()
            if not App.user.hasCredential()
                App.showSettings App.showSettings.TAB.Credential
                return false
            appNameRepeated = @checkAppNameRepeat(appNameDom.val())
            if not @defaultKpIsSet() or appNameRepeated
                return false
            @modal.close()
            @workspace.opsModel.run().fail (err)=>
                error = if err.awsError then err.error + "." + err.awsError else "#{err.error} - #{err.result}"
                notification 'error', sprintf(lang.ide.PROP_MSG_WARN_FAILA_TO_RUN_BECAUSE,@workspace.opsModel.get('name'),error)

    checkAppNameRepeat: (nameVal)->
        if App.model.appList().findWhere(name: nameVal)
            @showError('appname', lang.ide.PROP_MSG_WARN_REPEATED_APP_NAME)
            return true
        else if not nameVal
            @showError('appname', lang.ide.PROP_MSG_WARN_NO_APP_NAME)
            return true
        else
            @hideError('appname')
            return false

    renderKpDropdown: ()->
        if kpDropdown.hasResourceWithDefaultKp()
            keyPairDropdown = new kpDropdown()
            @modal.tpl.find("#kp-runtime-placeholder").html keyPairDropdown.render().el
            hideKpError = @hideError.bind @
            keyPairDropdown.dropdown.on 'change', ->
                hideKpError('kp')
            @modal.tpl.find('.default-kp-group').show()
        null

    hideDefaultKpError: (context)->
        context.hideError 'kp'

    hideError: (type)->
        selector = if type then $("#runtime-error-#{type}") else $(".runtime-error")
        selector.hide()

    showError: (id, msg)->
        $("#runtime-error-#{id}").text(msg).show()

    defaultKpIsSet: ->
        if not kpDropdown.hasResourceWithDefaultKp()
            return true
        kpModal = Design.modelClassForType( constant.RESTYPE.KP )
        defaultKP = kpModal.getDefaultKP()
        if not defaultKP.get('isSet') or not @modal.tpl.find("#kp-runtime-placeholder .item.selected").size()
            @showError('kp', lang.ide.RUN_STACK_MODAL_KP_WARNNING)
            return false

        true

    startApp        : ()-> App.startApp( @workspace.opsModel.id ); false
    stopApp         : ()-> App.stopApp( @workspace.opsModel.id );  false
    terminateApp    : ()-> App.terminateApp( @workspace.opsModel.id ); false
    refreshResource : ()-> @workspace.refreshResource(); false
    switchToAppEdit : ()-> @workspace.switchToEditMode(); false
    applyAppEdit    : ()-> @workspace.applyAppEdit(); false

    cancelAppEdit : ()->
      if not @workspace.cancelEditMode()
        self  = @
        modal = new Modal {
          title    : "Changes not applied"
          template : OpsEditorTpl.modal.cancelUpdate()
          width    : "400"
          confirm  : { text : "Discard", color : "red" }
          onConfirm : ()->
            modal.close()
            self.workspace.cancelEditMode(true)
            return
        }
      return false
  }
