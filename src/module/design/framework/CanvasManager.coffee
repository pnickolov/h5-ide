
define [ "./Design" ], ( Design )->

  CanvasManager = {

    move : ( compUid, x, y ) ->

      design = Design.instance()
      component = design.getComponent compUid

      component.set "x", x
      component.set "y", y

      @position document.getElementById( compUid ), x, y
      null

    resize : ( compUid, w, h ) ->

      design = Design.instance()
      component = design.getComponent compUid

      component.set "width", w
      component.set "height", h

      # TODO : Update SVG
      null

    position : ( node, x, y )->

      if node.length then node = node[0]

      if x < 0 then x = 0
      if y < 0 then y = 0

      transformVal = node.transform.baseVal

      x *= MC.canvas.GRID_WIDTH
      y *= MC.canvas.GRID_HEIGHT

      if transformVal.numberOfItems is 1
        transformVal.getItem(0).setTranslate(x, y)

      else
        translateVal = node.ownerSVGElement.createSVGTransform()
        translateVal.setTranslate(x, y)
        transformVal.appendItem(translateVal)
  }

  CanvasManager
