
###
  This file is used to include all the core functionality of the editor
###
define [
  "Design"
  "ResourceModel"
  "ComplexResModel"
  "ConnectionModel"
  "GroupModel"

  "CoreEditor"

  "CoreEditorView"
  "ProgressViewer"

  "CanvasManager"
  "CanvasView"
  "CanvasElement"
  "CanvasPopup"
  "CanvasViewLayout"
  "./coreeditor/CanvasViewConnect"
  "./coreeditor/CanvasViewDnd"
  "./coreeditor/CanvasViewGResizer"

  "./coreeditor/TplOpsEditor"
  "./coreeditor/TplSvgDef"
], ( Design )->

  ### env:dev ###
  require ["workspaces/coreeditor/DesignDebugger"], ()->
  ### env:dev:end ###
  ### env:debug ###
  require ["workspaces/coreeditor/DesignDebugger"], ()->
  ### env:debug:end ###

  window.Design = Design
  return

