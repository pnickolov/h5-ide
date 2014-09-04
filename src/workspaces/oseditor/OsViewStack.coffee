
define [
  "CoreEditorView"

  "./subviews/Panel"
  "./subviews/Toolbar"
  "./subviews/Statusbar"
  "./canvas/CanvasViewOs"

], ( CoreEditorView, RightPanel, Toolbar, Statusbar, CanvasView )->

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

  }
