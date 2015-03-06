
define [
  "OpsModel"
  "../template/TplOpsEditor"
  "ThumbnailUtil"
  "JsonExporter"
  "ApiRequest"
  "i18n!/nls/lang.js"
  "UI.modalplus"
  "ResDiff"
  'constant'
  'TaGui'
  "CloudResources"
  "AppAction"
  "UI.notification"
  "backbone"
], ( OpsModel, OpsEditorTpl, Thumbnail, JsonExporter, ApiRequest, lang, Modal, ResDiff, constant, TA, CloudResources, AppAction )->

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
      "click .runApp"                      : 'runStack'
      "OPTION_CHANGE .toolbar-line-style"  : "setTbLineStyle"

      "click .icon-terminate"         : "terminateApp"
      "click .icon-refresh"           : "refreshResource"
      "click .icon-update-app"        : "switchToAppEdit"
      "click .icon-cancel-update-app" : "cancelAppEdit"

    initialize : ( options )->
      _.extend this, options

      @appAction = new AppAction workspace: @workspace
      opsModel = @workspace.opsModel

      # Toolbar
      if opsModel.isStack()
        btns = ["BtnRunStack", "BtnStackOps", "BtnZoom", "BtnExport", "BtnLinestyle"]
      else
        btns = ["BtnEditApp", "BtnAppOps", "BtnReloadRes"]

      tpl = ""
      for btn in btns
        tpl += OpsEditorTpl.toolbar[btn]()

      @setElement @parent.$el.find(".OEPanelTop").html( tpl )

      @updateZoomButtons()
      @updateTbBtns()

      @listenTo @workspace.opsModel, "change:state", @updateTbBtns
      return

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

    runStack: (event)->
      that = @
      if $(event.currentTarget).attr 'disabled'
        return false

      @doRunStack()

    doRunStack: ()->
      cloudType = @workspace.opsModel.type
      self = @

      @modal = new Modal
        title: 'Run Marathon on Mesos Cluster'
        template: MC.template.modalRunMesos
        disableClose: true
        width: '465px'
        compact: true
        confirm:
          text: 'Run'
          disabled: true

      @modal.find('.modal-input-value').val @workspace.opsModel.get("name")

      appNameDom = @modal.find('#app-name')
      appUrlDom  = @modal.find('#app-url')

      checkAppNameRepeat = @checkAppNameRepeat.bind @
      validate = ->
        nameValid = !checkAppNameRepeat(appNameDom.val())
        urlValid = appUrlDom.length > 0

        if nameValid and urlValid
          self.modal.toggleConfirm false
        else
          self.modal.toggleConfirm true

      appNameDom.keyup validate
      appUrlDom.keyup validate

      @modal.on 'confirm', ()=>
        if self.checkAppNameRepeat(appNameDom.val())
          return false

        @modal.toggleConfirm true
        @json = @workspace.design.serialize usage: 'runStack'
        @json.name = appNameDom.val()
        @json.host = appUrlDom.val()

        @workspace.opsModel.run(@json, appNameDom.val()).then ( ops )->
          self.modal.close()
          App.loadUrl ops.url()
        , (err)->
          self.modal.close()
          error = if err.awsError then err.error + "." + err.awsError else " #{err.error} : #{err.result || err.msg}"
          notification 'error', sprintf(lang.NOTIFY.FAILA_TO_RUN_STACK_BECAUSE_OF_XXX,self.workspace.opsModel.get('name'),error)

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

    hideError: (type)->
        selector = if type then $("#runtime-error-#{type}") else $(".runtime-error")
        selector.hide()

    showError: (id, msg)->
        $("#runtime-error-#{id}").text(msg).show()

    terminateApp    : ()-> @appAction.terminateApp( @workspace.opsModel.id, true); false
    refreshResource : ()-> @workspace.reloadAppData(); false
    switchToAppEdit : ()-> @workspace.switchToEditMode(); false

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
  }
