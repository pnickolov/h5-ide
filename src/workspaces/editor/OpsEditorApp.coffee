
define [
  "./OpsEditorStack"
  "./OpsViewApp"
  "ResDiff"
  "OpsModel"
  "Design"
  "CloudResources"
  "constant"
], ( StackEditor, AppView, ResDiff, OpsModel, Design, CloudResources, constant )->

  class AppEditor extends StackEditor

    viewClass : AppView

    title    : ()-> ((@design || @opsModel).get("name") || @opsModel.get("importVpcId")) + " - app"
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
        CloudResources( constant.RESTYPE.DBENGINE, region ).fetch()
        CloudResources( constant.RESTYPE.DBOG,     region ).fetch()
        CloudResources( constant.RESTYPE.DBSNAP,   region ).fetch()
        CloudResources( "QuickStartAmi",           region ).fetch()
        CloudResources( "MyAmi",                   region ).fetch()
        CloudResources( "FavoriteAmi",             region ).fetch()
        @loadVpcResource()
        @fetchAmiData()
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
            self.opsModel.__setJsonData( newJson )
            self.design.reload()

            if differ.getChangeInfo().needUpdateLayout
              self.view.canvas.autoLayout()

            self.opsModel.saveApp( @design.serialize() )
          else
            self.remove()
      })

      if differ.getChangeInfo().hasResChange
        self.diff.render()
        return true

      false

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
      CloudResources( "OpsResource", @opsModel.getVpcId() ).init( @opsModel.get("region") ).fetchForce()

    ###
     AppEdit
    ###
    switchToEditMode : ()-> @design.setMode( Design.MODE.AppEdit )
    cancelEditMode : ( force )->
      # If force, it means that the design is probably modified.
      # So we can save the time for checking if it's modified.
      modfied = force || @design.isModified()
      if modfied and not force then return false

      if modfied
        @design.reload()
      else
        @design.setMode( Design.MODE.App )
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
      @view.stopListening self.opsModel, "change:progress", self.view.updateProgress
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

      if @opsModel.testState( OpsModel.State.Saving ) then return

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
