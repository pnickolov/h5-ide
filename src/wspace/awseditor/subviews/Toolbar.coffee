
define [
  "OpsModel"
  "../template/TplOpsEditor"
  "ThumbnailUtil"
  "JsonExporter"
  "ApiRequest"
  "i18n!/nls/lang.js"
  "UI.modalplus"
  'kp_dropdown'
  "ResDiff"
  'constant'
  'event'
  'TaGui'
  "CloudResources"
  "AppAction"
  "FilterInput"
  "UI.notification"
  "backbone"


], ( OpsModel, OpsEditorTpl, Thumbnail, JsonExporter, ApiRequest, lang, Modal, kpDropdown, ResDiff, constant, ide_event, TA, CloudResources, AppAction, FilterInput )->

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
      "click .icon-hide-sg"                : "toggleSgLine"

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

    initialize : ( options )->
      _.extend this, options

      @appAction = new AppAction workspace: @workspace
      opsModel = @workspace.opsModel

      # Toolbar
      if opsModel.isStack()
        btns = ["BtnRunStack", "BtnStackOps", "BtnZoom", "BtnExport", "BtnLinestyle"]
        unless opsModel.isMesos()
          btns.push "BtnSwitchStates"
      else
        btns = ["BtnEditApp", "BtnAppOps", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes"]

      tpl = ""
      for btn in btns
        attr = { stateOn: @workspace.design.get("agent").enabled }
        tpl += OpsEditorTpl.toolbar[ btn ]( attr )

      if @workspace.opsModel.isApp() and @workspace.design.attributes.agent.enabled
          tpl += OpsEditorTpl.toolbar.BtnReloadStates()

      @setElement @parent.$el.find(".OEPanelTop").html( tpl )

      #delay
      that = @
      setTimeout(() ->
        if not that.workspace.isRemoved() then that.updateTbBtns()
      , 1000)

      @updateZoomButtons()
      @updateTbBtns()
      @initFilter()

      @listenTo @workspace.opsModel, "change:state", @updateTbBtns
      return

    initFilter: ->
      ### env:dev ###
      # Need remove before deploy
      @filter = window.filter = new FilterInput()
      window.FilterInput = FilterInput
      #
      ### env:dev:end ###

      @listenTo @filter, 'change:filter', @highlightCanvas
      @$('.btn-toolbar').last().after @filter.render().el

    highlightCanvas: ( models, effect ) ->
      if effect
        @workspace.view.highLightModels(models, true)
      else
        @workspace.view.removeHighlight()

    updateTbBtns : ()->
      if @workspace.isRemoved() then return

      opsModel = @workspace.opsModel

      # LineStyle Btn
      @$el.children(".toolbar-line-style").children(".dropdown").children().eq(parseInt(localStorage.getItem("canvas/lineStyle"),10) || 2).click()

      # App Run & Stop
      if opsModel.isApp()
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

      if @workspace.opsModel.testState( OpsModel.State.Saving )
        @$el.children(".icon-save").attr("disabled", "disabled")
      else
        @$el.children(".icon-save").removeAttr("disabled")

      @updateZoomButtons()
      return

    setTbLineStyle : ( ls, attr )->
      localStorage.setItem("canvas/lineStyle", attr)
      if @parent.canvas
        @parent.canvas.updateLineStyle()
      return

    toggleSgLine : ()->
      sgBtn = $(".icon-hide-sg")
      show  = sgBtn.hasClass("selected")
      if show
        sgBtn.data("tooltip", lang.TOOLBAR.LBL_LINESTYLE_HIDE_SG).removeClass("selected")
      else
        sgBtn.data("tooltip", lang.TOOLBAR.LBL_LINESTYLE_SHOW_SG).addClass("selected")
      @parent.canvas.toggleSgLine( show )
      return

    saveStack : ( evt )->
      self = @
      @workspace.saveStack().then ()->
        notification "info", sprintf(lang.NOTIFY.ERR_SAVE_SUCCESS, self.workspace.opsModel.get("name"))
      , ( e )->
        if e.error is ApiRequest.Errors.StackConflict
          # There's another user already modified the stack before us.
          modal = new Modal {
            title         : lang.IDE.TITLE_OPS_CONFLICT
            width         : "420"
            disableClose  : true
            template      : OpsEditorTpl.modal.confliction()
            cancel        : {hide:true}
            confirm       : {color:"blue",text:lang.IDE.HEAD_BTN_DONE}
            onConfirm     : ()-> modal.close()
          }
        else
          notification "error", e.msg
      return

    deleteStack    : ()-> @appAction.deleteStack( @workspace.opsModel.cid, @workspace.opsModel.get("name"), @workspace )
    createStack    : ()-> App.loadUrl @workspace.scene.project.createStack(@workspace.design.region()).url()
    duplicateStack : ()-> App.loadUrl @workspace.scene.project.createStackByJson( @workspace.design.serialize() ).url()

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
        title         : lang.IDE.TITLE_EXPORT_PNG
        template      : OpsEditorTpl.export.PNG()
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
          template      : OpsEditorTpl.export.JSON( data )
          width         : "470"
          disableFooter : true
          compact       : true
        }

    exportCF : ()->
      design = @workspace.design
      hasCustomOG = false
      components = design.serialize(usage: 'runStack').component
      _.each components, (e)->
        if e.type is constant.RESTYPE.DBOG
          hasCustomOG = true

      modal = new Modal {
        title         : lang.TOOLBAR.POP_EXPORT_CF
        template      : OpsEditorTpl.export.CF({hasCustomOG})
        width         : "470"
        disableFooter : true
      }

      name = design.get("name")

      TAPromise = TA.loadModule('stack')
      ApiPromise = ApiRequest("stack_export_cloudformation", {
        region : design.get("region")
        stack  : design.serialize()
      })

      Q.spread [ TAPromise, ApiPromise ], ( taError, apiReturn  ) ->
        modal?.resize()
        btn = modal.tpl.find("a.btn-blue").text(lang.TOOLBAR.POP_BTN_EXPORT_CF).removeClass("disabled")
        JsonExporter.genericExport btn, apiReturn, "#{name}.json"
        btn.click ()-> modal.close()
        return

      , ( err ) ->
        modal?.resize()
        modal.tpl.find("a.btn-blue").text(lang.TOOLBAR.POP_BTN_EXPORT_CF)
        if err.error
          notification "error", sprintf lang.NOTIFY.FAIL_TO_EXPORT_TO_CLOUDFORMATION, err.error
        return

    reloadState: (event)->
        $target = $ event.currentTarget
        if $target.hasClass('disabled')
            return false
        $target.toggleClass('disabled').html($target.attr('data-disabled'))
        app_id = Design.instance().get('id')
        data =
            #'encoded_user': App.user.get('usercode')
            'user':     @workspace.opsModel.project().get("id")
            'token':    @workspace.opsModel.project().get('defaultToken')
        $.ajax
            url: window.MC_API_HOST + "/v1/apps/" + app_id
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
      that = @
      if $(event.currentTarget).attr 'disabled'
        return false
      @appAction.showPayment(null ,@workspace.opsModel).then ( result ) ->
        paymentUpdate = result.result
        paymentModal = result.modal
        that.appAction.runStack paymentUpdate, paymentModal, that.workspace

    appToStack: () ->
        name = @workspace.design.attributes.name
        newName = @getStackNameFromApp(name)
        stack = @workspace.opsModel.project().stacks().get(@workspace.design.attributes.stack_id)
        onConfirm = =>
            MC.Analytics.increase("app_to_stack")
            isNew = not (appToStackModal.tpl.find("input[name='save-stack-type']:checked").val() is "replace")
            if isNew
                newOps = @workspace.opsModel.project().createStackByJson( @workspace.design.serializeAsStack(appToStackModal.tpl.find('#modal-input-value').val()) )
                appToStackModal.close()
                App.loadUrl newOps.url()
                return
            else
                newJson = Design.instance().serializeAsStack()
                newJson.id = @workspace.design.attributes.stack_id
                appToStackModal.close()
                newJson.name = stack.get("name")
                stack.save(newJson).then ()->
                    notification "info", sprintf lang.NOTIFY.INFO_HDL_SUCCESS, lang.TOOLBAR.TOOLBAR_HANDLE_SAVE_STACK, newJson.name
                    # refresh if this stack is open
                    App.loadUrl stack.url()
                ,()->
                    notification 'error', sprintf lang.NOTIFY.ERR_SAVE_FAILED, newJson.name

        originStackExist = !!stack
        appToStackModal = new Modal
            title:  lang.TOOLBAR.POP_TIT_APP_TO_STACK
            template: OpsEditorTpl.saveAppToStack {input: name, stackName: newName, originStackExist: originStackExist}
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
        name_list = @workspace.opsModel.project().stacks().pluck("name")||[]
        idx++
        while idx <= name_list.length
          if $.inArray( (copy_name + "-" + idx), name_list ) == -1
              break
          idx++

        copy_name + "-" + idx
    checkAppNameRepeat: (nameVal)->
        if @workspace.scene.project.apps().findWhere(name: nameVal)
            @showError('appname', lang.PROP.MSG_WARN_REPEATED_APP_NAME)
            return true
        else if not nameVal
            @showError('appname', lang.PROP.MSG_WARN_NO_APP_NAME)
            return true
        else
            @hideError('appname')
            return false

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

    startApp  : ()-> @appAction.startApp( @workspace.opsModel.id ); false
    stopApp   : ()-> @appAction.stopApp( @workspace.opsModel.id );  false
    terminateApp    : ()-> @appAction.terminateApp( @workspace.opsModel.id, true); false
    forgetApp       : ()-> @appAction.forgetApp( @workspace.opsModel.id ); false
    refreshResource : ()-> @workspace.reloadAppData(); false
    switchToAppEdit : ()-> @workspace.switchToEditMode(); false
    checkDBinstance : (oldDBInstanceList)->
      checkDB = new Q.defer()
      if oldDBInstanceList.length
        DBInstances = CloudResources( @workspace.opsModel.credentialId() ,constant.RESTYPE.DBINSTANCE, Design.instance().get("region"))
        DBInstances.fetchForce().then ->
          checkDB.resolve(DBInstances)
      else
        checkDB.resolve([])
      checkDB.promise

    applyAppEdit    : ()->
      that = @
      taPassed = false

      oldJson = @workspace.opsModel.getJsonData()
      newJson = @workspace.design.serialize usage: 'updateApp'

      differ = new ResDiff({
        old : oldJson
        new : newJson
      })

      result = differ.getDiffInfo()
      usageChanged = oldJson.usage != newJson.usage
      if not result.compChange and not result.layoutChange and not result.stateChange and not usageChanged
        return @workspace.applyAppEdit()

      removes = differ.removedComps
      dbInstanceList = []
      console.log newJson
      components = newJson.component
      _.each components, (e)->
        dbInstanceList.push e.resource.DBInstanceIdentifier if e.type is constant.RESTYPE.DBINSTANCE

      DBInstances = CloudResources(that.workspace.opsModel.credentialId(),constant.RESTYPE.DBINSTANCE, Design.instance().get("region"))
      @updateModal = new Modal
        title: lang.IDE.HEAD_INFO_LOADING
        template: MC.template.loadingSpinner
        disableClose: true
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
        that.updateModal.find(".modal-wrapper-fix").width(665).find('.modal-body').css('padding', 0)
        that.updateModal.setContent( MC.template.updateApp {
          isRunning : that.workspace.opsModel.testState(OpsModel.State.Running)
          notReadyDB: removeListNotReady
          removeList: removeList
        })
        that.updateModal.tpl.find(".modal-header").find("h3").text(lang.IDE.UPDATE_APP_MODAL_TITLE)
        that.updateModal.tpl.find('.modal-confirm').prop("disabled", true).text (if Design.instance().credential() then lang.IDE.UPDATE_APP_CONFIRM_BTN else lang.IDE.UPDATE_APP_MODAL_NEED_CREDENTIAL)
        that.updateModal.resize()
        cost = Design.instance().getCost()
        currency = Design.instance().getCurrency()
        that.updateModal.find("#label-total-fee").find('b').text("#{currency + cost.totalFee}")
        that.updateModal.find("#label-visualops-fee").find('b').text("#{currency + cost.visualOpsFee}")
        window.setTimeout ->
          that.updateModal.resize()
        ,100

        if removeListNotReady?.length
          that.updateModal.tpl.find("#take-rds-snapshot").attr("checked", false).on "change", ->
            that.updateModal.tpl.find(".modal-confirm").prop 'disabled', $(this).is(":checked")

        $selectbox = that.updateModal.find("#app-usage-selectbox.selectbox")
        $selectbox.on "OPTION_CHANGE", (evt, _, result)->
          $selectbox.parent().find("input.custom-app-usage").toggleClass("show", result.value is "custom")
        if newJson.usage in ["testing", "development", "production", "others"]
          $selectbox.find(".dropdown li.item[data-value='"+newJson.usage+"']").click()
        else
          $selectbox.find(".dropdown li.item[data-value='custom']").click()
          $selectbox.parent().find("input.custom-app-usage").val(newJson.usage)

        that.updateModal.on 'confirm', ->
          unless taPassed then return

          if not Design.instance().credential()
            Design.instance().project().showCredential()
            return false

          if not that.defaultKpIsSet()
              return false
          newJson = that.workspace.design.serialize usage: 'updateApp'
          usage = $("#app-usage-selectbox").find(".dropdown .item.selected").data('value')
          if usage is "custom"
            usage = $.trim($selectbox.parent().find("input.custom-app-usage").val()) || "custom"
          newJson.usage = usage

          that.workspace.applyAppEdit( newJson, not result.compChange )
          that.updateModal?.close()

        if result.compChange
          $diffTree = differ.renderAppUpdateView()
          $('#app-update-summary-table').html $diffTree

        that.appAction.renderKpDropdown(that.updateModal)
        TA.loadModule('stack').then ->
          taPassed = true
        .catch (err)->
          console.log err
          that.updateModal?.tpl.find("#take-rds-snapshot").off 'change'
          that.updateModal?.find('.modal-confirm').addClass('disabled').addClass('tooltip').attr('data-tooltip', lang.TOOLBAR.FIX_THE_ERROR_TO_UPDATE)
        .fin ->
          that.updateModal?.resize()
          that.updateModal?.toggleConfirm false

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
                    title: lang.IDE.TITLE_CONFIRM_TO_ENABLE_VISUALOPS
                    width: "420px"
                    template: OpsEditorTpl.confirm.enableState()
                    confirm: text: lang.IDE.ENABLE_VISUALOPS
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
          title    : lang.IDE.TITLE_CHANGE_NOT_APPLIED
          template : OpsEditorTpl.modal.cancelUpdate()
          width    : "400"
          confirm  : { text : "Discard", color : "red" }
          onConfirm : ()->
            modal.close()
            self.workspace.cancelEditMode(true)
            return
        }
      return false


    xxxxxx : ()->
      @setElement @parent.$el.find(".OEPanelTop").html( OpsEditorTpl.toolbar.BtnActionPng() )

  }
