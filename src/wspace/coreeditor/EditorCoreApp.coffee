
define [
  "CoreEditor"
  "CoreEditorViewApp"
  "ResDiff"
  "OpsModel"
  "Design"
  "CloudResources"
  "constant"
  "ApiRequest"
  "i18n!/nls/lang.js"

  "wspace/coreeditor/EditorDeps"
], ( StackEditor, AppView, ResDiff, OpsModel, Design, CloudResources, constant, ApiRequest, lang )->

  StackEditor.extend {

    type : "CoreEditorApp"

    viewClass : AppView

    title    : ()-> ((@design || @opsModel).get("name") || @opsModel.getMsrId()) + " - app"
    tabClass : ()->
      switch @opsModel.get("state")
        when OpsModel.State.Running
          return "icon-app-running"
        when OpsModel.State.Stopped
          return "icon-app-stopped"
        else
          return "icon-app-pending"

    isReady       : ()-> !!@__hasAdditionalData
    isAppEditMode : ()-> @design?.modeIsAppEdit()
    isModified    : ()-> @design and @design.modeIsAppEdit() and @design.isModified()

    initEditor : ()->
      self = @
      @listenTo @opsModel, "change:progress", ()-> self.view?.updateProgress()

      # Special treatment for import app
      if @opsModel.isImported()
        @updateTab()
        @view.canvas.autoLayout()
        @view.confirmImport()
        return

      if @scene.project.shouldPay() and @opsModel.isPMRestricted()
         @view.showUnpayUI()
      else
         @diff()
      @view.listenToPayment()
      return

    diff : ()->
      if not @opsModel.testState( OpsModel.State.Running ) then return

      newJson = @opsModel.generateJsonFromRes()

      self = @
      differ = new ResDiff({
        old : @opsModel.getJsonData()
        new : newJson
        callback : ( confirm )->
          if confirm
            return self.applyDiff( newJson, differ.getChangeInfo().needUpdateLayout )

          self.remove()
          return
      })

      if differ.getChangeInfo().hasResChange
        differ.render()
        return true

      false

    applyDiff : ( newJson, autoLayout )->
      try
        # It seems like these process will throw some unkown error
        @opsModel.__setJsonData( newJson )
        @design.reload()

        if autoLayout
          @view.canvas.autoLayout()

      catch e
        console.error e

      @opsModel.saveApp( @design.serialize() )

    reloadAppData : ()->
      @view.showUpdateStatus("", true)
      self = @
      @loadVpcResource().then ()->
        self.__onReloadDone()
      , ()->
        self.view.toggleProcessing()
      return

    __onReloadDone : ()->
      if @isRemoved() then return
      @view.toggleProcessing()

      if not @diff()
        @view.canvas.update()
        @view.propertyPanel.refresh()
      return

    loadVpcResource : ()->
      CloudResources( @opsModel.credentialId(), "OpsResource", @opsModel.getMsrId() ).init({
        region   : @opsModel.get("region")
        provider : @opsModel.get("provider")
        project  : @scene.project.id
      }).fetchForce()

    ###
     AppEdit
    ###
    switchToEditMode : ()-> @design.setMode( Design.MODE.AppEdit )
    cancelEditMode : ( force )->
      # If force, it means that the design is probably modified.
      # So we can save the time for checking if it's modified.
      modfied = force || @design.isModified()
      if modfied and not force then return false

      @design.setMode( Design.MODE.App )
      if modfied then @design.reload()
      true

    applyAppEdit : ( newJson, fastUpdate, attributes )->
      console.assert( @isAppEditMode(), "Cannot apply app update while it's not in app edit mode." )

      if not newJson
        @design.setMode( Design.MODE.App )
        return

      @__applyingUpdate = true
      fastUpdate = fastUpdate and not @opsModel.testState( OpsModel.State.Stopped )

      self = @
      #@view.listenTo @opsModel, "change:progress", @view.updateProgress
      @opsModel.update( newJson, fastUpdate, attributes).then ()->
        if fastUpdate
          self.__onAppEditDidDone()
        else
          self.__onAppEditDone()
      , ( err )->
        self.__onAppEditFail( err )
      true

    __onAppEditFail : ( err )->
      if @isRemoved() then return

      @__applyingUpdate = false
      #@view.stopListening @opsModel, "change:progress", @view.updateProgress

      if err.error is ApiRequest.Errors.AppConflict
        msg = lang.NOTIFY.ERR_APP_UPDATE_FAILED_CONFLICT
      else
        msg = err.msg
        if err.result then msg += "\n" + err.result
        msg = msg.replace(/\n/g, "<br />")

      @view.showUpdateStatus( msg )
      return

    __onAppEditDone : ()->
      if @isRemoved() then return

      self = @
      @view.showUpdateStatus( "", true )
      @loadVpcResource().then ()-> self.__onAppEditDidDone()
      return

    __onAppEditDidDone : ()->
      if @isRemoved() then return

      @__applyingUpdate = false

      #@view.stopListening @opsModel, "change:progress", @view.updateProgress
      @view.showUpdateStatus()

      @design.setMode Design.MODE.App
      @design.reload()
      @saveThumbnail()
      return

    onOpsModelStateChanged : ()->
      if not @isInited() then return

      if @opsModel.testState( OpsModel.State.Destroyed )
        if not @opsModel.isLastActionTriggerByUser()
          notification "info", "The app has been removed by other team."
        @remove()
        return

      # Saving state only exist in IDE ( after the user saving the app directly into the database )
      # We don't have to mask the editor while we are saving.
      if @opsModel.testState( OpsModel.State.Saving ) or @opsModel.previous("state") is OpsModel.State.Saving
        return

      @updateTab()

      if @isAppEditMode()
        # When the opsmodel state changes in app edit mode.
        # If the change doesn't cause by current user.
        # We should ask the user to save the edit state, and then quit the app.
        if @opsModel.isLastActionTriggerByUser()
          @view.toggleProcessing()
        else
          @view.showAEConflictConfirm()
          return
      else
        # When we are not in app edit mode, editor only have react as the opsmodel state changes.
        if @opsModel.isProcessing()
          @view.toggleProcessing()
        else
          @view.showUpdateStatus( "", true )
          @loadVpcResource().then ()=> @__onVpcResLoaded()
        return


      return

    __onVpcResLoaded : ()->
      if @isRemoved() then return
      @view.canvas.update()
      @view.toggleProcessing()
      return
  }
