
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

  "CanvasManager"
  "CanvasView"
  "CanvasElement"
  "CanvasPopup"
  "CanvasViewLayout"
  "./CeSvg"
  "./CanvasViewConnect"
  "./CanvasViewDnd"
  "./CanvasViewGResizer"
  "./CanvasViewEffect"

  "./TplOpsEditor"
  "./TplSvgDef"
], ( Workspace, Design )->

  window.Design = Design
  return

