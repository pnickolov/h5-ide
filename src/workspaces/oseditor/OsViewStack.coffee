
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
      @$el.addClass("openstack").find(".OEPanelLeft").addClass("force-hidden")
      return

    showProperty   : ()-> ide_event.trigger ide_event.FORCE_OPEN_PROPERTY; return
    onItemSelected : ( type, id )-> ide_event.trigger ide_event.OPEN_PROPERTY, type, id; return

  }
