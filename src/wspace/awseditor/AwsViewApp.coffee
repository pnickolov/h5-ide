
define [
  "CoreEditorViewApp"

  "./subviews/ResourcePanel"
  "./subviews/PropertyPanel"
  "./subviews/Toolbar"
  "./subviews/Statusbar"
  "./canvas/CanvasViewAws"

  "event"

], ( CoreEditorViewApp, ResourcePanel, PropertyPanel, Toolbar, Statusbar, CanvasView, ide_event )->

  CoreEditorViewApp.extend {

    constructor : ( options )->
      _.extend options, {
        TopPanel    : Toolbar
        RightPanel  : PropertyPanel
        LeftPanel   : ResourcePanel
        BottomPanel : Statusbar
        CanvasView  : CanvasView
      }
      CoreEditorViewApp.apply this, arguments

    showProperty   : ()-> ide_event.trigger ide_event.FORCE_OPEN_PROPERTY; return
    onItemSelected : ( type, id )-> ide_event.trigger ide_event.OPEN_PROPERTY, type, id; return
    showStateEditor : ()->
      com = @workspace.getSelectedComponent()
      if com
        ide_event.trigger ide_event.SHOW_STATE_EDITOR, com.id
      return
  }
