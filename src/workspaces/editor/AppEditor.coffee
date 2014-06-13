
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

    title      : ()-> @opsModel.get("name") + " - app"
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
      region = @opsModel.get("region")
      Q.all([
        CloudResources( constant.RESTYPE.AZ,   region ).fetch()
        CloudResources( constant.RESTYPE.SNAP, region ).fetch()
        CloudResources( "OpsResource", @opsModel.getVpcId() ).init( @opsModel.get("region") ).fetchForce()
      ]).then ()->
        # Hack, immediately apply changes when we get data if the app is changed.
        # Will move it to somewhere else if the process is upgraded.
        if self.isRemoved() then return

        newJson = self.opsModel.generateJsonFromRes()
        self.differ = new ResDiff({
          old : self.opsModel.getJsonData()
          new : newJson
        })
        result = self.differ.getChangeInfo()
        if result.hasResChange
          return self.opsModel.saveApp( newJson )
        else
          self.differ = undefined
        return

    isAppEditMode : ()-> !!@__appEdit

    initDesign : ()->
      StackEditor.prototype.initDesign.call this
      if @differ then @differ.popup()
      return

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
        # Layout and component changes, need to construct a new Design.
        @view.emptyCanvas()
        @design = new Design( @opsModel )
        @initDesign()
      else
        @design.setMode( Design.MODE.App )

      @view.switchMode( false )
      true

    isModified : ()-> @isAppEditMode() && @design && @design.isModified()

    applyAppEdit : ( modfiedData, force )->
      modfied = modfiedData or @design.isModified( undefined, true )

      if modfied and not force then return modfied

      @design.setMode( Design.MODE.App )
      @view.switchMode( false )

      @opsModel.update( modfiedData.newData, !modfiedData.component )
      true

    onOpsModelStateChanged : ()->
      if @isInited()
        @view.toggleProcessing()
        @updateTab()

      StackEditor.prototype.onOpsModelStateChanged.call this

    refreshResource : ()->

  AppEditor
