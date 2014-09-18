
define [
  "./OsEditorStack"
  "./OsViewStack"
  "./model/DesignOs"
  "CloudResources"
  "constant"
], ( StackEditor, StackView, DesignOs, CloudResources, constant )->

  class AppEditor extends StackEditor

    title : ()-> (@design || @opsModel).get("name") + " - app"

    isModified : ()-> @design and @design.modeIsAppEdit() and @design.isModified()

    switchToEditMode : ()-> @design.setMode( Design.MODE.AppEdit )

    reloadAppData : ()->
      #@view.showUpdateStatus("", true)
      self = @
      @loadNetworkResource().then ()->
        self.__onReloadDone()
      , ()->
        #self.view.toggleProcessing()
      return

    __onReloadDone : ()->
      if @isRemoved() then return
      #@view.toggleProcessing()

      # if not @diff()
      #   @view.canvas.update()
      return

    loadNetworkResource : ()->
      CloudResources( "OpsResource", @opsModel.getMsrId() )
        .init( @opsModel.get("region"), @opsModel.get("provider") )
        .fetchForce()


  AppEditor
