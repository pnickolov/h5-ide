
define [
  "CoreEditorView"

  "./subviews/PropertyPanel"
  "./subviews/Toolbar"
  "./subviews/ResourcePanel"
  "./canvas/CanvasViewMesos"

  "event"

], ( CoreEditorView, PropertyPanel, Toolbar, ResourcePanel, CanvasView, ide_event )->

  CoreEditorView.extend {
    constructor : ( options )->
      _.extend options, {
        TopPanel    : Toolbar
        RightPanel  : PropertyPanel
        LeftPanel   : ResourcePanel
        CanvasView  : CanvasView
      }
      CoreEditorView.apply this, arguments
      @$el.find(".OEPanelBottom").remove()
      return

    showProperty    : ()-> ide_event.trigger ide_event.FORCE_OPEN_PROPERTY; return
    onItemSelected  : ( type, id )-> ide_event.trigger ide_event.OPEN_PROPERTY, type, id; return
    showStateEditor : ()->
  }
