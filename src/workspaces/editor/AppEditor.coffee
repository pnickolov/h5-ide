
define [
  "./StackEditor"
  "./AppView"
  "ResDiff"
  "OpsModel"
  "Design"
  "CloudResources"
  "constant"
], ( StackEditor, AppView, ResDiff, OpsModel, Design, CloudResources, constant )->

  class AppEditor extends StackEditor

    title      : ()-> ((@design || @opsModel).get("name") || @opsModel.get("importVpcId")) + " - app"
    createView : ()-> new AppView({workspace:this})
    tabClass   : ()->
      switch @opsModel.get("state")
        when OpsModel.State.Running
          return "icon-app-running"
        when OpsModel.State.Stopped
          return "icon-app-stopped"
        else
          return "icon-app-pending"

    isReady : ()-> !!@__hasAdditionalData

    fetchAdditionalData : ()->
      self = @

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      Q.all([
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
        CloudResources( constant.RESTYPE.AZ,   region ).fetch()
        CloudResources( constant.RESTYPE.SNAP, region ).fetch()
        CloudResources( constant.RESTYPE.DHCP, region ).fetch()
        CloudResources( constant.RESTYPE.DBENGINE, region ).fetch()
        CloudResources( constant.RESTYPE.DBSNAP,   region ).fetch()
        CloudResources( "QuickStartAmi",       region ).fetch()
        CloudResources( "MyAmi",               region ).fetch()
        CloudResources( "FavoriteAmi",         region ).fetch()
        @loadVpcResource()
        @fetchAmiData()
      ]).then ()->
        # Hack, immediately apply changes when we get data if the app is changed.
        # Will move it to somewhere else if the process is upgraded.

        if self.isRemoved() then return

        if self.opsModel.isImported() then return

        if not self.opsModel.testState( OpsModel.State.Running ) then return

        oldJson = self.opsModel.getJsonData()
        newJson = self.opsModel.generateJsonFromRes()

        self.differ = new ResDiff({
          old : oldJson
          new : newJson
          callback : ( confirm )->
            if confirm
              self.opsModel.saveApp( self.design.serialize() )
            else
              self.opsModel.__setJsonData( oldJson )
              self.remove()
        })

        if self.differ.getChangeInfo().hasResChange
          self.opsModel.__setJsonData( newJson )
        return

      , ( err )->
        if err.error is 286 # VPC not exist
          self.view.showVpcNotExist self.opsModel.get("name"), ()-> self.opsModel.terminate( true )
          self.remove()
          return
        throw err


    delayUntilAwake : ( method )->
      if @isAwake()
        method.call this
      else
        console.info "AppEditor's action is delayed until wake up."
        @__calledUponWakeup = method
      return

    awake : ()->
      StackEditor.prototype.awake.call this
      if @__calledUponWakeup
        @__calledUponWakeup.call this
        @__calledUponWakeup = null

      return

    isModified : ()-> @isAppEditMode() && @design && @design.isModified()

    isAppEditMode : ()-> !!@__appEdit

    initDesign : ()->
      if @opsModel.isImported() or (@differ && @differ.getChangeInfo().needUpdateLayout)
        MC.canvas.analysis()
        # Clear the thumbnail of the opsmodel, then it will be re-generated.
        @opsModel.saveThumbnail()

      @design.finishDeserialization()
      return

    initEditor : ()->
      # Try show differ dialog
      if @differ and @differ.getChangeInfo().hasResChange
        @differ.render()
        @differ = null

      # Try show import dialog
      if @opsModel.isImported()
        @updateTab()
        @view.confirmImport()
      return

    refreshResource : ()->

    switchToEditMode : ()->
      if @isAppEditMode() then return
      @__appEdit = true
      @design.setMode( Design.MODE.AppEdit )
      @view.switchMode( true )
      return

    cancelEditMode : ( force )->
      modfied = if force then true else @design.isModified()

      if modfied and not force then return false

      @__appEdit = false
      if modfied
        @recreateDesign()
      else
        @design.setMode( Design.MODE.App )

      @view.switchMode( false )
      true

    recreateDesign : ()->
      # Layout and component changes, need to construct a new Design.
      @view.emptyCanvas()
      @design.reload( @opsModel )
      @design.finishDeserialization()
      return

    loadVpcResource : ()->
      CloudResources( "OpsResource", @opsModel.getVpcId() ).init( @opsModel.get("region") ).fetchForce()

    applyAppEdit : ( newJson, fastUpdate )->
      if not newJson
        @__appEdit = false
        @design.setMode( Design.MODE.App )
        @view.switchMode( false )
        return

      self = @
      @__applyingUpdate = true
      fastUpdate = fastUpdate and not @opsModel.testState( OpsModel.State.Stopped )

      @opsModel.update( newJson, fastUpdate ).then ()->
        if fastUpdate
          self.onAppEditDone()
        else
          self.view.showUpdateStatus( "", true )
          self.loadVpcResource().then ()-> self.onAppEditDone()

      , ( err )->
        self.__applyingUpdate = false
        self.view.stopListening self.opsModel, "change:progress", self.view.updateProgress

        msg = err.msg
        if err.result then msg += "<br />" + err.result

        self.view.showUpdateStatus( msg )
        return

      @view.listenTo @opsModel, "change:progress", @view.updateProgress

      true

    onAppEditDone   : ()-> @delayUntilAwake @__onAppEditDone
    __onAppEditDone : ()->
      if @isRemoved() then return

      @__appEdit = @__applyingUpdate = false

      @view.stopListening @opsModel, "change:progress", @view.updateProgress
      @recreateDesign()

      @design.setMode( Design.MODE.App )
      @design.renderNode()
      @view.showUpdateStatus()
      @view.switchMode( false )

      @saveThumbnail()

      @view.showUpdateStatus()
      return

    onOpsModelStateChanged : ()->
      if not @isInited() then return

      if @opsModel.testState( OpsModel.State.Saving ) then return

      @updateTab()

      if @opsModel.isProcessing()
        @view.toggleProcessing()
      else if not @__applyingUpdate and not @opsModel.testState( OpsModel.State.Destroyed )
        self = @
        @view.showUpdateStatus( "", true )
        @loadVpcResource().then ()-> self.delayUntilAwake self.onVpcResLoaded

      StackEditor.prototype.onOpsModelStateChanged.call this

    onVpcResLoaded : ()->
      if @isRemoved() then return
      @design.renderNode()
      @view.toggleProcessing()
      return


  AppEditor
