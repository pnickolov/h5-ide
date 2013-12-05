
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

    drawLine : ()->
      null

    updateSGLabel : ( uid, sgLabelGroup )->
      # TODO : Change this function to use the framework

      # Prepare data
      labels = [{
        color : "#f26c4f"
        name  : "DefaultSG"
      }]

      # Update canvas sg label
      if not sgLabelGroup
        sgLabelGroup = $( uid + "_node-sg-color-group" ).children()
      else
        sgLabelGroup = sgLabelGroup.children()

      i = 0
      while i < MC.canvas.SG_MAX_NUM
        if i < labels.length and labels[i]
          Canvon( sgLabelGroup.eq(i).attr( "fill", labels[i].color ) )
            .addClass("tooltip").data("tooltip", labels[i].name )
            .attr("data-tooltip", labels[i].name )

        else
          Canvon( sgLabelGroup.eq(i).attr( "fill", "none" ) )
            .addClass("tooltip").data("tooltip", "" )
            .attr("data-tooltip", "" )

        ++i

  }

  CanvasManager
