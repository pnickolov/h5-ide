
define [
  "CoreEditorView"

  "./subviews/Panel"
  "./subviews/Toolbar"
  "./subviews/Statusbar"
  "./canvas/CanvasViewOs"

  "event"

], ( CoreEditorView, RightPanel, Toolbar, Statusbar, CanvasView, ide_event )->

  CoreEditorView.extend {
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

    showProperty   : ()->
      @panel.openProperty()
      return

    onItemSelected : ( type, id )->
      @panel.openProperty { uid: id, type: type }
      return

  }
