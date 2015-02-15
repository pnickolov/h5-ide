
define [
  "CoreEditorView"

  "./subviews/PropertyPanel"
  "./subviews/Toolbar"
  "./subviews/ResourcePanel"
  "./subviews/Statusbar"
  "./canvas/CanvasViewAws"

  "event"

], ( CoreEditorView, PropertyPanel, Toolbar, ResourcePanel, Statusbar, CanvasView, ide_event )->

  CoreEditorView.extend {
    constructor : ( options )->
      _.extend options, {
        TopPanel    : Toolbar
        RightPanel  : PropertyPanel
        LeftPanel   : ResourcePanel
        BottomPanel : Statusbar
        CanvasView  : CanvasView
      }
      CoreEditorView.apply this, arguments

    showProperty   : ()-> ide_event.trigger ide_event.FORCE_OPEN_PROPERTY; return
    onItemSelected : ( type, id )-> ide_event.trigger ide_event.OPEN_PROPERTY, type, id; return
    showStateEditor : ()->
      com = @workspace.getSelectedComponent()
      if com
        ide_event.trigger ide_event.SHOW_STATE_EDITOR, com.id
      return
  }
