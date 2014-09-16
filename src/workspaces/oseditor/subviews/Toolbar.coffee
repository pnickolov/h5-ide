
define [
  "OpsModel"
  "../template/TplToolbar"
  "ThumbnailUtil"
  "JsonExporter"
  "ApiRequest"
  "i18n!/nls/lang.js"
  "UI.modalplus"
  'kp_dropdown'
  "ResDiff"
  'constant'
  'event'
  'component/trustedadvisor/gui/main'
  "CloudResources"
  "appAction"
  "UI.notification"
  "backbone"
], ( OpsModel, ToolbarTpl, Thumbnail, JsonExporter, ApiRequest, lang, Modal, kpDropdown, ResDiff, constant, ide_event, TA, CloudResources, appAction )->

  Backbone.View.extend {

    events :
      "click .icon-save"        : "saveStack"
      "click .icon-delete"      : "deleteStack"
      "click .icon-duplicate"   : "duplicateStack"
      "click .icon-new-stack"   : "createStack"
      "click .icon-zoom-in"     : "zoomIn"
      "click .icon-zoom-out"    : "zoomOut"
      "click .icon-export-png"  : "exportPNG"
      "click .icon-export-json" : "exportJson"
      "click .runApp"           : 'runStack'

      "click .icon-stop"              : "stopApp"
      "click .startApp"               : "startApp"
      "click .icon-terminate"         : "terminateApp"
      "click .icon-forget-app"        : "forgetApp"
      "click .icon-refresh"           : "refreshResource"
      "click .icon-update-app"        : "switchToAppEdit"
      "click .icon-apply-app"         : "applyAppEdit"
      "click .icon-cancel-update-app" : "cancelAppEdit"
      'click .toolbar-visual-ops-switch' : 'opsOptionChanged'
      'click .reload-states'          : "reloadState"
      'click .icon-save-app'          : 'appToStack'
      'click .sidebar-title a'        : 'openOrHidePanel'

    initialize : ( options )->
      _.extend this, options

      opsModel = @workspace.opsModel

      # Toolbar
      if opsModel.isStack()
        btns = ["BtnRunStack", "BtnStackOps", "BtnZoom", "BtnExport", "PanelHeader", "BtnSwitchStates"]
      else
        btns = ["BtnEditApp", "BtnAppOps", "BtnZoom", "BtnPng", "BtnReloadRes", "PanelHeader"]

      tpl = ""
      for btn in btns
        attr = { stateOn: @workspace.design.get("agent").enabled }
        tpl += ToolbarTpl[ btn ]( attr )

      if @workspace.opsModel.isApp() and @workspace.design.get("agent").enabled
          tpl += ToolbarTpl.BtnReloadStates()

      @setElement @parent.$el.find(".OEPanelTop").html( tpl )
      @updateZoomButtons()
      @updateTbBtns()
      return

    openOrHidePanel: ( e ) -> @parent.propertyPanel.__openOrHidePanel.call @parent.propertyPanel, e

    updateTbBtns : ()->
      opsModel = @workspace.opsModel

      # App Run & Stop
      if opsModel.isApp()
        console.log "isApp"
        isAppEdit = @workspace.isAppEditMode and @workspace.isAppEditMode()
        @$el.children(".icon-update-app").toggle( not isAppEdit )
        @$el.children(".icon-apply-app, .icon-cancel-update-app").toggle( isAppEdit )

        if isAppEdit
          @$el.children(".icon-terminate, .icon-forget-app, .icon-stop, .icon-play, .icon-refresh, .icon-save-app, .icon-reload").hide()
          @$el.find(".icon-refresh").hide()
        else
          running = opsModel.testState(OpsModel.State.Running)
          stopped = opsModel.testState(OpsModel.State.Stopped)

          @$el.children(".icon-terminate, .icon-forget-app, .icon-refresh, .icon-save-app, .icon-reload").show()

          # @$el.children(".icon-stop").toggle( Design.instance().get("property").stoppable and opsModel.testState(OpsModel.State.Running) )
          # @$el.children(".icon-play").toggle( opsModel.testState( OpsModel.State.Stopped ) )

          @$el.children(".icon-stop").toggle( opsModel.get("stoppable") and running )
          @$el.children(".icon-play").toggle( stopped ).toggleClass("toolbar-btn-primary seperator", opsModel.testState(OpsModel.State.Stopped)).find("span").toggle( stopped )
          @$el.children('.icon-update-app').toggle( not stopped )
          @$el.find(".icon-refresh").toggle( running )
          ami = [].concat(
            @workspace.design.componentsOfType( constant.RESTYPE.INSTANCE ),
            @workspace.design.componentsOfType( constant.RESTYPE.LC )
          )
          hasState = _.find( ami, (comp)-> comp and (comp.attributes.state?.length>0) )
          @$el.find('.reload-states').toggle(!!hasState)

      if @__saving
        @$el.children(".icon-save").attr("disabled", "disabled")
      else
        @$el.children(".icon-save").removeAttr("disabled")

      @updateZoomButtons()
      return

    saveStack : ( evt )->
      $( evt.currentTarget ).attr("disabled", "disabled")

      self = @
      @__saving = true

      newJson = @workspace.design.serialize()

      Thumbnail.generate( @parent.getSvgElement() ).catch( ()->
        return null
      ).then ( thumbnail )->
        self.workspace.opsModel.save( newJson, thumbnail ).then ()->
          self.__saving = false
          $( evt.currentTarget ).removeAttr("disabled")
          notification "info", sprintf(lang.NOTIFY.ERR_SAVE_SUCCESS, newJson.name)
        , ( )->
          self.__saving = false
          $( evt.currentTarget ).removeAttr("disabled")
          notification "error", sprintf(lang.NOTIFY.ERR_SAVE_FAILED, newJson.name)
        return

    deleteStack    : ()-> appAction.deleteStack( @workspace.opsModel.cid, @workspace.design.get("name") )
    createStack    : ()->
      opsModel = @workspace.opsModel
      App.createOps( opsModel.get("region"), "openstack", opsModel.get("provider") )
      return

    duplicateStack : ()->
      newOps = App.model.createStackByJson( @workspace.design.serialize() )
      App.openOps newOps
      return

    zoomIn  : ()-> @parent.canvas.zoomIn();  @updateZoomButtons()
    zoomOut : ()-> @parent.canvas.zoomOut(); @updateZoomButtons()
    updateZoomButtons : ()->
      scale = if @parent.canvas then @parent.canvas.scale() else 1
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
        template      : ToolbarTpl.export.PNG()
        width         : "470"
        disableFooter : true
        compact       : true
        onClose : ()-> modal = null; return
      }

      design = @workspace.design
      name   = design.get("name")
      Thumbnail.exportPNG @parent.getSvgElement(), {
          isExport   : true
          createBlob : true
          name       : name
          id         : design.get("id")
          onFinish   : ( data ) ->
            if not modal then return
            modal.tpl.find(".loading-spinner").remove()
            modal.tpl.find("section").show().prepend("<img style='max-height:100%;display:inline-block;' src='#{data.image}' />")
            btn = modal.tpl.find("a.btn-blue").click ()-> modal.close()
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
          title         : lang.TOOLBAR.EXPORT_AS_JSON
          template      : ToolbarTpl.export.JSON( data )
          width         : "470"
          disableFooter : true
          compact       : true
        }

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
                    notification 'info', lang.NOTIFY.RELOAD_STATE_SUCCESS
                    ide_event.trigger ide_event.REFRESH_PROPERTY
                401: ->
                    notification 'error', lang.NOTIFY.RELOAD_STATE_INVALID_REQUEST
                404: ->
                    notification 'error', lang.NOTIFY.RELOAD_STATE_NETWORKERROR
                429: ->
                    notification 'error', lang.NOTIFY.RELOAD_STATE_NOT_READY
                500: ->
                    notification 'error', lang.NOTIFY.RELOAD_STATE_INTERNAL_SERVER_ERROR
            error: ->
                console.log 'Error while Reload State'
            success: ->
                console.debug 'Reload State Success!'
        .always ->
            window.setTimeout ->
                $target.removeClass 'disabled'
                .html $target.attr 'data-original'


    runStack: (event)->
        console.log Design.instance(), @workspace.opsModel, (Design.instance() is @workspace.opsModel)
        appAction.runStack(event, @workspace)
        return false
        that = @
        if $(event.currentTarget).attr('disabled')
            return false
        @modal = new Modal
            title: lang.IDE.RUN_STACK_MODAL_TITLE
            template: MC.template.modalRunStack
            disableClose: true
            width: '450px'
            confirm:
                text: if App.user.hasCredential() then lang.IDE.RUN_STACK_MODAL_CONFIRM_BTN else lang.IDE.RUN_STACK_MODAL_NEED_CREDENTIAL
                disabled: true
        @renderKpDropdown(@modal)
        cost = Design.instance().getCost()
        @modal.tpl.find('.modal-input-value').val @workspace.opsModel.get("name")
        @modal.tpl.find("#label-total-fee").find('b').text("$#{cost.totalFee}")

        # load TA
        TA.loadModule('stack').then ()=>
            @modal.resize()
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
            appNameRepeated = @checkAppNameRepeat(appNameDom.val())
            if not @defaultKpIsSet() or appNameRepeated
                return false

            @modal.tpl.find(".btn.modal-confirm").attr("disabled", "disabled")
            @json = @workspace.design.serialize usage: 'runStack'
            @json.usage = $("#app-usage-selectbox").find(".dropdown .item.selected").data('value')
            @json.name = appNameDom.val()
            @workspace.opsModel.run(@json, appNameDom.val()).then ( ops )->
                self.modal.close()
                App.openOps( ops )
            , (err)->
                self.modal.close()
                error = if err.awsError then err.error + "." + err.awsError else " #{err.error} : #{err.result || err.msg}"
                notification 'error', sprintf(lang.NOTIFY.FAILA_TO_RUN_STACK_BECAUSE_OF_XXX,self.workspace.opsModel.get('name'),error)
        App.user.on 'change:credential', ->
          console.log 'We got it.'
          if App.user.hasCredential() and that.modal.isOpen()
            that.modal.find(".modal-confirm").text lang.IDE.RUN_STACK_MODAL_CONFIRM_BTN
        @modal.on 'close', ->
          console.log 'We gave up.'
          App.user.off 'change:credential'

    appToStack: () ->
        name = @workspace.design.attributes.name
        newName = @getStackNameFromApp(name)
        stack = App.model.stackList().get(@workspace.design.attributes.stack_id)
        onConfirm = =>
            MC.Analytics.increase("app_to_stack")
            isNew = not (appToStackModal.tpl.find("input[name='save-stack-type']:checked").val() is "replace")
            if isNew
                newOps = App.model.createStackByJson( @workspace.design.serializeAsStack(appToStackModal.tpl.find('#modal-input-value').val()) )
                appToStackModal.close()
                App.openOps newOps
                return
            else
                newJson = Design.instance().serializeAsStack()
                newJson.id = @workspace.design.attributes.stack_id
                appToStackModal.close()
                newJson.name = stack.get("name")
                stack.save(newJson).then ()->
                    notification "info", sprintf lang.NOTIFY.INFO_HDL_SUCCESS, lang.IDE.TOOLBAR_HANDLE_SAVE_STACK, newJson.name
                    # refresh if this stack is open
                    App.openOps stack, true
                ,()->
                    notification 'error', sprintf lang.NOTIFY.ERR_SAVE_FAILED, newJson.name

        originStackExist = !!stack
        appToStackModal = new Modal
            title:  lang.TOOLBAR.POP_TIT_APP_TO_STACK
            template: ToolbarTpl.saveAppToStack {input: name, stackName: newName, originStackExist: originStackExist}
            confirm:
                text: lang.TOOLBAR.POP_BTN_SAVE_TO_STACK
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
          if app_name.charAt(app_name.length-1) is "-"
              #xxxx-
              copy_name = app_name.substr(0,app_name.length-1)
          else
              copy_name = app_name

        stack_reg = /.-stack+$/
        if stack_reg.test copy_name
          copy_name = copy_name
        else
          copy_name = copy_name + "-stack"
        name_list = App.model.stackList().pluck("name")||[]
        idx++
        while idx <= name_list.length
          if $.inArray( (copy_name + "-" + idx), name_list ) == -1
              break
          idx++

        copy_name + "-" + idx
    checkAppNameRepeat: (nameVal)->
        if App.model.appList().findWhere(name: nameVal)
            @showError('appname', lang.PROP.MSG_WARN_REPEATED_APP_NAME)
            return true
        else if not nameVal
            @showError('appname', lang.PROP.MSG_WARN_NO_APP_NAME)
            return true
        else
            @hideError('appname')
            return false

    renderKpDropdown: (modal)->
        if kpDropdown.hasResourceWithDefaultKp()
            keyPairDropdown = new kpDropdown()
            if modal then modal.tpl.find("#kp-runtime-placeholder").html keyPairDropdown.render().el else return false
            hideKpError = @hideError.bind @
            keyPairDropdown.dropdown.on 'change', ->
                hideKpError('kp')
            modal.tpl.find('.default-kp-group').show()
            if @modal then @modal.on 'close', ->
              keyPairDropdown.remove()
            if @updateModal then @updateModal.on 'close', ->
              keyPairDropdown.remove()
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
        if not defaultKP.get('isSet') or not ((@modal||@updateModal) and (@modal || @updateModal).tpl.find("#kp-runtime-placeholder .item.selected").size())
            @showError('kp', lang.IDE.RUN_STACK_MODAL_KP_WARNNING)
            return false

        true

    startApp  : ()-> appAction.startApp( @workspace.opsModel.id ); false
    stopApp   : ()-> appAction.stopApp( @workspace.opsModel.id );  false
    terminateApp    : ()-> appAction.terminateApp( @workspace.opsModel.id ); false
    forgetApp       : ()-> appAction.forgetApp( @workspace.opsModel.id ); false
    refreshResource : ()-> @workspace.reloadAppData(); false
    switchToAppEdit : ()-> @workspace.switchToEditMode(); false
    checkDBinstance : (oldDBInstanceList)->
      checkDB = new Q.defer()
      if oldDBInstanceList.length
        DBInstances = CloudResources(constant.RESTYPE.DBINSTANCE, Design.instance().get("region"))
        DBInstances.fetchForce().then ->
          checkDB.resolve(DBInstances)
      else
        checkDB.resolve([])
      checkDB.promise

    applyAppEdit    : ()->
      that = @
      oldJson = @workspace.opsModel.getJsonData()
      newJson = @workspace.design.serialize usage: 'updateApp'

      differ = new ResDiff({
        old : oldJson
        new : newJson
      })

      result = differ.getDiffInfo()
      if not result.compChange and not result.layoutChange and not result.stateChange
        return @workspace.applyAppEdit()

      removes = differ.removedComps
      console.log differ
      dbInstanceList = []
      console.log newJson
      components = newJson.component
      _.each components, (e)->
        dbInstanceList.push e.resource.DBInstanceIdentifier if e.type is constant.RESTYPE.DBINSTANCE

      @updateModal = new Modal
        title: lang.IDE.HEAD_INFO_LOADING
        template: MC.template.loadingSpiner
        disableClose: true
        hasScroll: true
        maxHeight: "450px"
        cancel: "Close"

      @updateModal.tpl.find(".modal-footer").hide()

      oldDBInstanceList = []
      _.each oldJson.component, (e)->
        oldDBInstanceList.push e.resource.DBInstanceIdentifier if e.type is constant.RESTYPE.DBINSTANCE

      @checkDBinstance(oldDBInstanceList).then (DBInstances)->

        notAvailableDB = DBInstances.filter (e)->
          e.attributes.DBInstanceIdentifier in dbInstanceList and e.attributes.DBInstanceStatus isnt "available"
        if (notAvailableDB.length)
          that.updateModal.find(".modal-footer").show().find(".modal-confirm").hide()
          that.updateModal.setContent MC.template.cantUpdateApp data:notAvailableDB
          that.updateModal.setTitle lang.IDE.UPDATE_APP_MODAL_TITLE
          return false

        removeList = []
        _.each removes, (e)->
          if e.type is constant.RESTYPE.DBINSTANCE
            dbModel = DBInstances.get(e.resource.DBInstanceIdentifier)
            removeList.push(DBInstances.get(e.resource.DBInstanceIdentifier)) if dbModel

        removeListNotReady = _.filter removeList, (e)->
          e.attributes.DBInstanceStatus isnt "available"

        that.updateModal.tpl.children().css 'width', "450px"
        .find(".modal-footer").show()
        that.updateModal.setContent( MC.template.updateApp {
          isRunning : that.workspace.opsModel.testState(OpsModel.State.Running)
          notReadyDB: removeListNotReady
          removeList: removeList
        })
        that.updateModal.tpl.find(".modal-header").find("h3").text(lang.IDE.UPDATE_APP_MODAL_TITLE)
        that.updateModal.tpl.find('.modal-confirm').prop("disabled", true).text (if App.user.hasCredential() then lang.IDE.UPDATE_APP_CONFIRM_BTN else lang.IDE.UPDATE_APP_MODAL_NEED_CREDENTIAL)
        that.updateModal.resize()
        window.setTimeout ->
          that.updateModal.resize()
        ,100

        if removeListNotReady?.length
          that.updateModal.tpl.find("#take-rds-snapshot").attr("checked", false).on "change", ->
            that.updateModal.tpl.find(".modal-confirm").prop 'disabled', $(this).is(":checked")

        that.updateModal.on 'confirm', ->
          if not App.user.hasCredential()
            App.showSettings App.showSettings.TAB.Credential
            return false

          if not that.defaultKpIsSet()
              return false
          newJson = that.workspace.design.serialize usage: 'updateApp'
          that.workspace.applyAppEdit( newJson, not result.compChange )
          that.updateModal?.close()

        if result.compChange
          $diffTree = differ.renderAppUpdateView()
          $('#app-update-summary-table').html $diffTree

        that.renderKpDropdown(that.updateModal)
        TA.loadModule('stack').then ->
          that.updateModal and that.updateModal.toggleConfirm false
          that.updateModal?.resize()
        , (err)->
          console.log err
          that.updateModal and that.updateModal.toggleConfirm true
          that.updateModal and that.updateModal.tpl.find("#take-rds-snapshot").off 'change'
          that.updateModal?.resize()
        return

    opsOptionChanged: ->
        $switcher = $(".toolbar-visual-ops-switch").toggleClass('on')
        stateEnabled = $switcher.hasClass("on")
        agent = @workspace.design.get('agent')
        if stateEnabled
            instancesNoUserData = @workspace.design.instancesNoUserData()
            workspace = @workspace
            if not instancesNoUserData
                $switcher.removeClass 'on'
                confirmModal = new Modal(
                    title: "Confirm to Enable VisualOps"
                    width: "420px"
                    template: ToolbarTpl.confirm.enableState()
                    confirm: text: "Enable VisualOps"
                    onConfirm: ->
                        agent.enabled = true
                        confirmModal.close()
                        $switcher.addClass 'on'
                        workspace.design.set('agent', agent)
                        ide_event.trigger ide_event.FORCE_OPEN_PROPERTY

                )
                null
            else
                agent.enabled = true
                @workspace.design.set("agent",agent)
                ide_event.trigger ide_event.REFRESH_PROPERTY
        else
            agent.enabled = false
            @workspace.design.set('agent', agent)
            ide_event.trigger ide_event.FORCE_OPEN_PROPERTY



    cancelAppEdit : ()->
      if not @workspace.cancelEditMode()
        self  = @
        modal = new Modal {
          title    : "Changes not applied"
          template : ToolbarTpl.modal.cancelUpdate()
          width    : "400"
          confirm  : { text : "Discard", color : "red" }
          onConfirm : ()->
            modal.close()
            self.workspace.cancelEditMode(true)
            return
        }
      return false
  }
