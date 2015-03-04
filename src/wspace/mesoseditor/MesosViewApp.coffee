
define [
  "CoreEditorViewApp"

  "./subviews/ResourcePanel"
  "./subviews/PropertyPanel"
  "./subviews/Toolbar"
  "./canvas/CanvasViewMesos"

  "event"

], ( CoreEditorViewApp, ResourcePanel, PropertyPanel, Toolbar, CanvasView, ide_event )->

  CoreEditorViewApp.extend {

    constructor : ( options )->
      _.extend options, {
        TopPanel    : Toolbar
        RightPanel  : PropertyPanel
        LeftPanel   : ResourcePanel
        CanvasView  : CanvasView
      }
      CoreEditorViewApp.apply this, arguments

    showProperty   : ()-> ide_event.trigger ide_event.FORCE_OPEN_PROPERTY; return
    onItemSelected : ( type, id )-> ide_event.trigger ide_event.OPEN_PROPERTY, type, id; return
    showStateEditor : ()->
  }
