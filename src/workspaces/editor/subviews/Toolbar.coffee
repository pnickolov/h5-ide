
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
  'event'
  'component/trustedadvisor/main'
  "UI.notification"
  "backbone"
], ( OpsModel, OpsEditorTpl, Thumbnail, JsonExporter, ApiRequest, lang, Modal, kpDropdown, constant, ide_event, TA )->

  # Set domain and set http
  API_HOST       = "api.visualops.io"

  ### env:debug ###
  API_HOST = "api.mc3.io"
  ### env:debug:end ###

  ### env:dev ###
  API_HOST = "api.mc3.io"
  ### env:dev:end ###
  API_URL = "https://" + API_HOST + "/v1/apps/"

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
      'click .toolbar-visual-ops-switch' : 'opsOptionChanged'
      'click .reload-states'          : "reloadState"
      'click .icon-save-app'          : 'appToStack'

    render : ()->
      opsModel = @workspace.opsModel

      # Toolbar
      if opsModel.isImported()
        btns = ["BtnActionPng", "BtnZoom", "BtnLinestyle"]
      else if opsModel.isStack()
        btns = ["BtnRunStack", "BtnStackOps", "BtnZoom", "BtnExport", "BtnLinestyle", "BtnSwitchStates"]
      else
        if @__editMode
          btns = ["BtnApply", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes", "BtnSwitchStates"]
        else
          btns = ["BtnEditApp", "BtnAppOps", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes", 'BtnReloadStates']

      tpl = ""
      workspace = @workspace
      reloadOn = _.find Design.modelClassForType(constant.RESTYPE.INSTANCE).allObjects(), (comp)->
          if (comp.attributes.state?.length>0)
              return true
      for btn in btns
        tpl += OpsEditorTpl.toolbar[ btn ]
            stateOn: workspace.design.attributes.agent.enabled
            reloadOn: reloadOn

      @setElement @workspace.view.$el.find(".OEPanelTop").html( tpl )

      @updateTbBtns()
      @updateZoomButtons()
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
          @$el.children(".icon-terminate, .icon-stop, .icon-play, .icon-refresh, .icon-save-app, .icon-reload").hide()
        else
          @$el.children(".icon-terminate, .icon-refresh, .icon-save-app, .icon-reload").show()
          @$el.children(".icon-stop").toggle( opsModel.get("stoppable") and opsModel.testState(OpsModel.State.Running) )
          @$el.children(".icon-play").toggle( opsModel.testState( OpsModel.State.Stopped ) )

      if @__saving
        @$el.children(".icon-save").attr("disabled", "disabled")
      else
        @$el.children(".icon-save").removeAttr("disabled")

      @updateZoomButtons()
      return

    setTbLineStyle : ( ls, attr )->
      localStorage.setItem("canvas/lineStyle", attr[0] )
      $canvas.updateLineStyle( attr[0] )

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

    reloadState: (event)->
        $target = $ event.currentTarget
        if $target.hasClass('disabled')
            return false
        $target.toggleClass('disabled').html($target.attr('data-disabled'))
        app_id = Design.instance().get('id')
        data =
            'encoded_user': App.user.get('usercode')
            'token':    App.user.get('defaultToken')
        $.ajax
            url: API_URL + app_id
            method: "POST"
            data: JSON.stringify data
            dataType: 'json'
            statusCode:
                200: ->
                    notification 'info', lang.ide.RELOAD_STATE_SUCCESS
                    ide_event.trigger ide_event.REFRESH_PROPERTY
                401: ->
                    notification 'error', lang.ide.RELOAD_STATE_INVALID_REQUEST
                404: ->
                    notification 'error', lang.ide.RELOAD_STATE_NETWORKERROR
                429: ->
                    notification 'error', lang.ide.RELOAD_STATE_NOT_READY
                500: ->
                    notification 'error', lang.ide.RELOAD_STATE_INTERNAL_SERVER_ERROR
            error: ->
                console.log 'Error while Reload State'
            success: ->
                console.debug 'Reload State Success!'
        .always ->
            window.setTimeout ->
                $target.removeClass 'disabled'
                .html $target.attr 'data-original'


    runStack: (event)->
        if $(event.currentTarget).attr('disabled')
            return false
        @json = @workspace.design.serialize()
        @modal = new Modal
            title: lang.ide.RUN_STACK_MODAL_TITLE
            template: MC.template.modalRunStack
            disableClose: true
            width: '450px'
            height: "515px"
            confirm:
                text: if App.user.hasCredential() then lang.ide.RUN_STACK_MODAL_CONFIRM_BTN else lang.ide.RUN_STACK_MODAL_NEED_CREDENTIAL
                disabled: true
        @renderKpDropdown()
        cost = Design.instance().getCost()
        @modal.tpl.find('.modal-input-value').val @workspace.opsModel.get("name")
        @modal.tpl.find("#label-total-fee").find('b').text("$#{cost.totalFee}")

        # load TA
        TA.loadModule('stack').then ()=>
            @modal?.toggleConfirm false

        appNameDom = @modal.tpl.find('#app-name')
        checkAppNameRepeat = @checkAppNameRepeat.bind @
        appNameDom.keyup ->
            checkAppNameRepeat(appNameDom.val())

        self = @
        @modal.on 'confirm', ()=>
            @hideError()
            if not App.user.hasCredential()
                App.showSettings App.showSettings.TAB.Credential
                return false
            # setUsage
            @json.usage = $("#app-usage-selectbox").find(".dropdown .item.selected").data('value')
            appNameRepeated = @checkAppNameRepeat(appNameDom.val())
            if not @defaultKpIsSet() or appNameRepeated
                return false

            @modal.tpl.find(".btn.modal-confirm").attr("disabled", "disabled")
            @workspace.opsModel.run(@json, appNameDom.val()).then ( ops )->
                self.modal.close()
                App.openOps( ops )
            , (err)->
                self.modal.close()
                error = if err.awsError then err.error + "." + err.awsError else " #{err.error} : #{err.result || err.msg}"
                notification 'error', sprintf(lang.ide.PROP_MSG_WARN_FAILA_TO_RUN_BECAUSE,self.workspace.opsModel.get('name'),error)

    appToStack: (event) ->
        name = @workspace.design.attributes.name
        newName = @getStackNameFromApp(name)
        onConfirm = =>
            isNew = appToStackModal.tpl.find("input[name='save-stack-type']:checked").attr('id') is "radio-new-stack"
            if isNew
                newOps = App.model.createStackByJson( @workspace.design.serializeAsStack(appToStackModal.tpl.find('#modal-input-value').val()) )
                appToStackModal.close()
                console.debug "newOps", newOps
                App.openOps newOps
                return
            else
                newJson = Design.instance().serializeAsStack()
                newJson.id = @workspace.design.attributes.stack_id
                appToStackModal.close()
                stack = App.model.stackList().get(@workspace.design.attributes.stack_id)
                ApiRequest("stack_save",
                    region: newJson.region
                    spec: newJson
                ).then ()->
                    notification "info", sprintf lang.ide.TOOL_MSG_INFO_HDL_SUCCESS, lang.ide.TOOLBAR_HANDLE_SAVE_STACK, newJson.name
                    App.openOps stack, true # refresh if this stack is open
                ,(err)->
                    notification 'error', sprintf lang.ide.TOOL_MSG_ERR_SAVE_FAILED, newJson.name


        appToStackModal = new Modal
            title:  lang.ide.TOOL_POP_TIT_APP_TO_STACK
            template: OpsEditorTpl.saveAppToStack {input: name, stackName: newName}
            confirm:
                text: lang.ide.TOOL_POP_BTN_SAVE_TO_STACK
            onConfirm: onConfirm
        appToStackModal.tpl.find("input[name='save-stack-type']").change ->
            appToStackModal.tpl.find(".radio-instruction").toggleClass('hide')


    getStackNameFromApp : (app_name) ->

        if not app_name
          app_name = "untitled"

        idx = 0
        reg_name = /.*-\d+$/
        if reg_name.test app_name
          #xxx-n
          prefix = app_name.substr(0,app_name.lastIndexOf("-"))
          idx = Number(app_name.substr(app_name.lastIndexOf("-") + 1))
          copy_name = prefix
        else
          if app_name.charAt(name.length-1) is "-"
              #xxxx-
              copy_name = app_name.substr(0,app_name.length-1)
          else
              copy_name = app_name

        stack_reg = /.-stack+$/
        if stack_reg.test copy_name
          copy_name = copy_name
        else
          copy_name = copy_name + "-stack"
        name_list   = []
        stacks      = _.flatten _.values MC.data.stack_list

        name_list.push i.name for i in stacks when i.name.indexOf(copy_name) == 0

        idx++
        while idx <= name_list.length
          if $.inArray( (copy_name + "-" + idx), name_list ) == -1
              break
          idx++

        copy_name + "-" + idx
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
    applyAppEdit    : ()->
      result = @workspace.applyAppEdit()
      console.debug result
      if result isnt true
        # Show popup dialog
        console.debug result
        @updateModal = new Modal
            title: lang.ide.UPDATE_APP_MODAL_TITLE
            template: MC.template.updateApp result
            disableClose: true
            width: '450px'
            height: "515px"
            confirm:
                text: if App.user.hasCredential() then lang.ide.UPDATE_APP_CONFIRM_BTN else lang.ide.UPDATE_APP_MODAL_NEED_CREDENTIAL
                disabled: true

        @updateModal.on 'confirm', =>
            if not @defaultKpIsSet()
                return false
            @workspace.applyAppEdit( result, true )
            @updateModal?.close()

        @renderKpDropdown()
        TA.loadModule('stack').then =>
            @updateModal and @updateModal.toggleConfirm false
        # Call this method when user confirm to update

        return

    opsOptionChanged: -> #todo: Almost Done.
        $switcher = $(".toolbar-visual-ops-switch").toggleClass('on')
        stateEnabled = $switcher.hasClass("on")
        agent = @workspace.design.get('agent')
        if stateEnabled
            instancesNoUserData = @workspace.design.instancesNoUserData()
            workspace = @workspace
            if not instancesNoUserData
                $switcher.removeClass 'on'
                confirmModal = new Modal(
                    title: "Conﬁrm to Enable VisualOps"
                    width: "420px"
                    template: OpsEditorTpl.confirm.enableState()
                    confirm: text: "Enable VisualOps"
                    onConfirm: ->
                        agent.enabled = true
                        confirmModal.close()
                        $switcher.addClass 'on'
                        workspace.design.set('agent', agent)
                        ide_event.trigger ide_event.REFRESH_PROPERTY

                )
                null
            else
                agent.enabled = true
                @workspace.design.set("agent",agent)
                ide_event.trigger ide_event.REFRESH_PROPERTY
        else
            agent.enabled = false
            @workspace.design.set('agent', agent)
            ide_event.trigger ide_event.REFRESH_PROPERTY



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
