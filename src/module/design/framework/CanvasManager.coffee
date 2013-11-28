
define [ "./Design" ], ( Design )->

  CanvasManager = {

    move : ( compUid, x, y ) ->

      design = Design.instance()
      component = design.getComponent compUid

      console.assert component.ctype != "Framework_CR", "CanvasManager can only move ComplexResModel"

      component.set "__x", x
      component.set "__y", y

      # TODO : Update SVG
      null

    resize : ( compUid, w, h ) ->

      design = Design.instance()
      component = design.getComponent compUid

      console.assert component.ctype != "Framework_G", "CanvasManager can only resize GroupModel"

      component.set "__w", w
      component.set "__h", h

      # TODO : Update SVG
      null
  }

  CanvasManager
