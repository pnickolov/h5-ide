
define [
  "CoreEditorView"

  "./subviews/RightPanel"
  "./subviews/Toolbar"
  "./subviews/Statusbar"
  "./canvas/CanvasViewAws"

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
  }
