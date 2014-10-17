
define [
  "CoreEditorViewApp"

  "./template/TplOsEditor"

  "./subviews/Panel"
  "./subviews/Toolbar"
  "./subviews/Statusbar"
  "./canvas/CanvasViewOs"

], ( CoreEditorViewApp, TplOsEditor, RightPanel, Toolbar, Statusbar, CanvasView )->

  CoreEditorViewApp.extend {
    template : TplOsEditor

    constructor : ( options )->
      _.extend options, {
        TopPanel    : Toolbar
        RightPanel  : RightPanel
        BottomPanel : Statusbar
        CanvasView  : CanvasView
      }
      CoreEditorViewApp.apply this, arguments

    initialize : ()->
      @panel = @propertyPanel

      @$el.addClass("openstack").find(".OEPanelLeft").addClass("force-hidden")

      CoreEditorViewApp.prototype.initialize.apply this, arguments
      return

    switchMode : ( mode )->
      @toolbar.updateTbBtns()
      @statusbar.update()
      @propertyPanel.openCurrent()
      return

    showProperty: () -> @panel.openProperty(); false
    showResource: () -> @panel.openResource(); false
    showGlobal  : () -> @panel.openConfig(); false
    showStateEditor : ()-> @panel.openState(); false
    onCanvasDoubleClick: () -> @panel.show().openCurrent()

    onItemSelected: ( type, id ) ->
      if not id and not type
        @panel.openConfig()
        return

      @panel.openProperty { uid: id, type: type }

  }
