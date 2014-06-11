
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
      Q.all [
        CloudResources( constant.RESTYPE.AZ,   region ).fetch()
        CloudResources( constant.RESTYPE.SNAP, region ).fetch()
      ]

    isAppEditMode : ()-> !!@__appEdit
    switchMode : ( toAppEdit )->
      if @isAppEditMode() is toAppEdit then return
      @__appEdit = toAppEdit
      @view.switchMode( toAppEdit )
      @design.setMode( if toAppEdit then Design.MODE.AppEdit else Design.MODE.App )
      return

    isModified : ()-> @isAppEditMode() && @design && @design.isModified()

    onOpsModelStateChanged : ()->
      if @isInited()
        @view.toggleProcessing()
        @updateTab()
        # Switch Mode

      StackEditor.prototype.onOpsModelStateChanged.call this

    refreshResource : ()->


  AppEditor
