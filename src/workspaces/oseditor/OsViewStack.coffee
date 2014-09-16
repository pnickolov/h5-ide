
define [
  "CoreEditorView"

  "./template/TplOsEditor"

  "./subviews/Panel"
  "./subviews/Toolbar"
  "./subviews/Statusbar"
  "./canvas/CanvasViewOs"

  "event"

], ( CoreEditorView, TplOsEditor, RightPanel, Toolbar, Statusbar, CanvasView, ide_event )->

  CoreEditorView.extend {
    template : TplOsEditor

    constructor : ( options )->
      _.extend options, {
        TopPanel    : Toolbar
        RightPanel  : RightPanel
        BottomPanel : Statusbar
        CanvasView  : CanvasView
      }
      CoreEditorView.apply this, arguments

    initialize : ()->
      @panel = @propertyPanel

      @$el.addClass("openstack").find(".OEPanelLeft").addClass("force-hidden")
      return

    showProperty: () -> @panel.openProperty()
    onCanvasDoubleClick: () -> @panel.show().openCurrent()

    onItemSelected: ( type, id ) ->
      if not id and not type
        @panel.openConfig()
        return

      @panel.openProperty { uid: id, type: type }


  }
