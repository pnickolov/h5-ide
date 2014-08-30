
define [
  "CoreEditorView"

  "./subviews/PropertyPanel"
  "./subviews/Toolbar"
  "./subviews/ResourcePanel"
  "./subviews/Statusbar"
  "./canvas/CanvasViewAws"

], ( CoreEditorView, PropertyPanel, Toolbar, ResourcePanel, Statusbar, CanvasView )->

  CoreEditorView.extend {
    constructor : ( options )->
      _.extend options, {
        Toolbar       : Toolbar
        PropertyPanel : PropertyPanel
        ResourcePanel : ResourcePanel
        Statusbar     : Statusbar
        CanvasView    : CanvasView
      }
      CoreEditorView.apply this, arguments
  }
