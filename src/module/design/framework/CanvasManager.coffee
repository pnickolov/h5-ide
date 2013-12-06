
define [ "./Design" ], ( Design )->

  CanvasManager = {

    move : ( compUid, x, y ) ->

      design = Design.instance()
      component = design.component compUid

      component.set "x", x
      component.set "y", y

      @position document.getElementById( compUid ), x, y
      null

    resize : ( compUid, w, h ) ->

      design = Design.instance()
      component = design.component compUid

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

    drawLine : ( connection )->
      from_node        = $( '#' + connection.__port1Comp.id )
      from_target_port = connection.__port1
      to_node          = $( '#' + connection.__port2Comp.id )
      to_target_port   = connection.__port2
      line_option      = null
      from_data        = {
        uid        : connection.__port1Comp.id
        type       : connection.__port1Comp.type
        coordinate : [connection.__port1Comp.x(), connection.__port1Comp.y()]
        groupUId   : ''
        connection : []
      }
      to_data          = {
        uid        : connection.__port2Comp.id
        type       : connection.__port2Comp.type
        coordinate : [connection.__port2Comp.x(), connection.__port2Comp.y()]
        groupUId   : ''
        connection : []
      }

      MC.canvas.drawLine( from_node, from_target_port, to_node, to_target_port, line_option, from_data, to_data )
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
