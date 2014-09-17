
define [
  "./AwsEditorStack"
  "./AwsViewApp"
  "ResDiff"
  "OpsModel"
  "./model/DesignAws"
  "CloudResources"
  "constant"
], ( StackEditor, AppView, ResDiff, OpsModel, Design, CloudResources, constant )->

  class AppEditor extends StackEditor

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


    fetchAdditionalData : ()->
      self = @

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      Q.all([
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
        CloudResources( constant.RESTYPE.AZ,       region ).fetch()
        CloudResources( constant.RESTYPE.SNAP,     region ).fetch()
        CloudResources( constant.RESTYPE.DHCP,     region ).fetch()
        CloudResources( "QuickStartAmi",           region ).fetch()
        CloudResources( "MyAmi",                   region ).fetch()
        CloudResources( "FavoriteAmi",             region ).fetch()
        @loadVpcResource()
        @fetchAmiData()
        @fetchRdsData( false )
      ]).fail ( err )-> self.__handleDataError( err )

    __handleDataError : ( err )->
      if err.error is 286 # VPC not exist
        @view.showVpcNotExist @opsModel.get("name"), ()=> @opsModel.terminate( true )
        @remove()
        return

      throw err

    initEditor : ()->
      # Special treatment for import app
      if @opsModel.isImported()
        @updateTab()
        @view.canvas.autoLayout()
        @view.confirmImport()
        return

      @diff()
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
      return

    loadVpcResource : ()->
      CloudResources( "OpsResource", @opsModel.getMsrId() )
        .init( @opsModel.get("region"), @opsModel.get("provider") )
        .fetchForce()

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

    applyAppEdit : ( newJson, fastUpdate )->
      if not newJson
        @design.setMode( Design.MODE.App )
        return

      @__applyingUpdate = true
      fastUpdate = fastUpdate and not @opsModel.testState( OpsModel.State.Stopped )

      self = @
      @view.listenTo @opsModel, "change:progress", @view.updateProgress
      @opsModel.update( newJson, fastUpdate ).then ()->
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
      @view.stopListening @opsModel, "change:progress", @view.updateProgress
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

      @view.stopListening @opsModel, "change:progress", @view.updateProgress
      @view.showUpdateStatus()

      @design.setMode Design.MODE.App
      @design.reload()
      @saveThumbnail()
      return

    onOpsModelStateChanged : ()->
      if not @isInited() then return

      if @opsModel.testState( OpsModel.State.Saving ) or @opsModel.previous("state") is OpsModel.State.Saving
        return

      @updateTab()

      if @opsModel.isProcessing()
        @view.toggleProcessing()
      else if @opsModel.testState( OpsModel.State.Destroyed )
        @remove()
      else if not @__applyingUpdate
        self = @
        @view.showUpdateStatus( "", true )
        @loadVpcResource().then ()-> self.__onVpcResLoaded()
      return

    __onVpcResLoaded : ()->
      if @isRemoved() then return
      @view.canvas.update()
      @view.toggleProcessing()
      return

  AppEditor
