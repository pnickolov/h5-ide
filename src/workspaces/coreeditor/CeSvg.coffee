
define [
  "CanvasElement"
  "constant"
  "CanvasManager"
  "i18n!/nls/lang.js"
  "UI.modalplus"
], ( CanvasElement, constant, CanvasManager, lang, Modal )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeSvg"
    ### env:dev:end ###
    type : "SVG"

    initialize : ( options )->
      @canvas = options.canvas
      return

    hover    : ( evt )-> return
    hoverOut : ( evt )-> return

    pos  : ( el )-> { x : 0, y : 0 }
    size : ()->
      s = @canvas.size()
      {
        width  : s[0] - 4
        height : s[1] - 2
      }

    rect : ( el )->
      s = @canvas.size()
      {
        x1 : 4
        y1 : 2
        x2 : s[0]
        y2 : s[1]
      }

    effectiveRect : ()->
      s = @canvas.size()
      {
        x1 : 0
        y1 : 0
        x2 : s[0]
        y2 : s[1]
      }

    ensureStickyPos : ()-> return

    isGroup : ()-> true

    isTopLevel : ()-> false

    parent : ()-> null

    children : ()-> @canvas.__itemTopLevel.slice(0)

    siblings : ()-> []

    connections : ()-> []

    isConnectable : ( fromPort, toId, toPort )-> false

    select : ( selectedDomElement )-> return

    destroy : ( selectedDomElement )-> return

    doDestroyModel : ()-> return

    isDestroyable : ( selectedDomElement )-> false

    isClonable : ()-> false

    cloneTo : ( parent, x, y )-> return

    changeParent : ( newParent, x, y )-> return

    moveBy : ( deltaX, deltaY )-> return

    updateConnections : ()-> return

    applyGeometry : ( x, y, width, height, updateConnections = true )-> return

  }, {

    isDirectParentType : ( type )-> true

    createResource : ( type, attributes, options )-> return

  }
