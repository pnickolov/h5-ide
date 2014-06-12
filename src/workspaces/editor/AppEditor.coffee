
define [
  "./StackEditor"
  "./AppView"
  "OpsModel"
  "Design"
  "CloudResources"
  "constant"
], ( StackEditor, AppView, OpsModel, Design, CloudResources, constant )->

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

    isReady : ()->
      @opsModel.hasJsonData() && CloudResources( constant.RESTYPE.AZ, @opsModel.get("region") ).isReady() && CloudResources( constant.RESTYPE.SNAP, @opsModel.get("region") ).isReady()

    fetchAdditionalData : ()->
      region = @opsModel.get("region")
      jobs = [
        CloudResources( constant.RESTYPE.AZ,   region ).fetch()
        CloudResources( constant.RESTYPE.SNAP, region ).fetch()
      ]

      opsRes = CloudResources( "OpsResource", @opsModel.getVpcId() ).init( @opsModel.get("region") )
      if @opsModel.appHasChanged()
        @view.setText "Your app has been changed. Automatically sync-ing your changes."
        jobs.push opsRes.fetchForce()
      else
        jobs.push opsRes.fetch()

      # Hack, immediately apply changes when we get data if the app is changed.
      # Will move it to somewhere else if the process is upgraded.
      self = @
      Q.all(jobs).then ()->
        newJson = self.opsModel.generateJsonFromRes()
        self.opsModel.saveApp newJson

    isAppEditMode : ()-> !!@__appEdit

    initDesign : ()->
      if not @opsModel.appHasChanged()
        return StackEditor.prototype.initDesign.call this

      # The app has changed. We would want to apply changes.
      # Hot replace the @design.
      @design = new Design( @opsModel )
      MC.canvas.analysis()
      @design.finishDeserialization()

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
