
define [
  "CanvasView"
  "CanvasElement"
  "CanvasManager"
  "constant"
  "i18n!/nls/lang.js"
], ( CanvasView, CanvasElement, CanvasManager, constant, lang )->

  CanvasViewProto = CanvasView.prototype

  # Add item by dnd
  CanvasViewProto.hightLightItems  = ( items )->
  CanvasViewProto.removeHightLight = ( items )->


  return
