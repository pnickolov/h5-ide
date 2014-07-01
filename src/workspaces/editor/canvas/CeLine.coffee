
define [ "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CeLine = CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeLine"
    ### env:dev:end ###
    type : "CeLine"

    portName : ( targetId )-> @model.port( targetId, "name" )

    # Update the svg element
    render : ()->
      @$el.remove()
      @$el = $()

      item1 = @canvas.getItem( @model.port1Comp().id )
      item2 = @canvas.getItem( @model.port2Comp().id )

      if item1.$el.length is 1 and item2.$el.length is 1
        @renderConnection( item1, item2 )
      else
        for el1 in item1.$el
          for el2 in item2.$el
            @renderConnection( item1, item2, el1, el2 )

      return

    createLine : ()->
      svg = @canvas.svg
      svg.group().add([
        svg.path()
        svg.path().classes("fill-line")
      ]).attr({"data-id":@cid}).classes("line #{@type}")

    renderConnection : ( item_from, item_to, element1, element2 )->
      connection = @model

      pos_from = item_from.pos( element1 )
      pos_to   = item_to.pos( element2 )

      from_port = connection.port1("name")
      to_port   = connection.port2("name")
      dirn_from = item_from.portDirection(from_port)
      dirn_to   = item_to.portDirection(to_port)

      if dirn_from and dirn_to
        if pos_from.left > pos_to.left
          from_port += "-left"
          to_port   += "-right"
        else
          from_port += "-right"
          to_port   += "-left"

        pos_port_from = item_from.portPosition( from_port )
        pos_port_to   = item_to.portPosition( to_port )

        pos_from.left += pos_port_from[0]
        pos_from.top  += pos_port_from[1]
        pos_to.left   += pos_port_to[0]
        pos_to.top    += pos_port_to[1]

      else if dirn_from

        pos_port_to = item_to.portPosition( to_port )
        pos_to.left += pos_port_to[0]
        pos_to.top  += pos_port_to[1]

        if dirn_from is "vertical"
          from_port += if pos_to.top > pos_from.top then "-bottom" else "-top"
        else if dirn_from is "horizontal"
          from_port += if pos_to.left > pos_from.left then "-right" else "-left"

        pos_port_from = item_from.portPosition( from_port )
        pos_from.left += pos_port_from[0]
        pos_from.top  += pos_port_from[1]

      else if dirn_to
        pos_port_from = item_from.portPosition( from_port )
        pos_from.left += pos_port_from[0]
        pos_from.top  += pos_port_from[1]

        if dirn_to is "vertical"
          to_port += if pos_from.top > pos_to.top then "-bottom" else "-top"
        else if dirn_to is "horizontal"
          to_port += if pos_from.left > pos_to.left then "-right" else "-left"

        pos_port_to = item_to.portPosition( to_port )
        pos_to.left += pos_port_to[0]
        pos_to.top  += pos_port_to[1]

      else
        pos_port_from = item_from.portPosition( from_port )
        pos_port_to   = item_to.portPosition( to_port )

        pos_from.left += pos_port_from[0]
        pos_from.top  += pos_port_from[1]
        pos_to.left   += pos_port_to[0]
        pos_to.top    += pos_port_to[1]

      start0 =
        x     : pos_from.left
        y     : pos_from.top
        angle : pos_port_from[2]
        type  : connection.port1Comp().type
        name  : from_port

      end0 =
        x     : pos_to.left
        y     : pos_to.top
        angle : pos_port_to[2]
        type  : connection.port2Comp().type
        name  : to_port


      # Calculate line path
      if start0.x is end0.x or start0.y is end0.y
        path = "M#{start0.x} #{start0.y} L#{end0.x} #{end0.y}"
      else
        controlPoints = MC.canvas.route2( start0, end0 )
        if controlPoints
          ls = if connection.get("lineType") is 'sg' then $canvas.lineStyle() else 777

          switch ls
            when 0
              path = "M#{controlPoints[0].x} #{controlPoints[0].y} L#{controlPoints[1].x} #{controlPoints[1].y} L#{controlPoints[controlPoints.length-2].x} #{controlPoints[controlPoints.length-2].y} L#{controlPoints[controlPoints.length-1].x} #{controlPoints[controlPoints.length-1].y}"
            when 1 then path = MC.canvas._round_corner(controlPoints)
            when 2 then path = MC.canvas._bezier_q_corner(controlPoints)
            when 3 then path = MC.canvas._bezier_qt_corner(controlPoints)
            when 777 then path = MC.canvas._round_corner(controlPoints)

      # Create or redraw line
      svgLine = @createLine()
      $( svgLine.node ).children().attr("d", path )
      @canvas.appendLine( svgLine )
      @addView svgLine
      return
  }


  CeLine.extend {
    ### env:dev ###
    ClassName : "EniAttachment"
    ### env:dev:end ###
    type : "EniAttachment"
  }
