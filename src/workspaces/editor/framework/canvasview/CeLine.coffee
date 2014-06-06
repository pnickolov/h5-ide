
define [ "./CanvasElement", "CanvasManager", "constant", "canvon" ], ( CanvasElement, CanvasManager, constant )->

  ### LEGACY CODE ###
  # This is required for drawing lines.
  window.MC.paper = Canvon($('<svg id="SvgLineHolder" xmlns="http://www.w3.org/2000/svg" version="1.2"></div>').appendTo("body").hide())

  CeLine = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeLine, "Line" )
  ChildElementProto = CeLine.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portName = ( targetId )-> @model.port( targetId, "name" )

  ChildElementProto.reConnect = ()-> @draw()

  ChildElementProto.select = ()->
    # QuickFix for Rtb_Asso
    if @type is "RTB_Route"
      @doSelect( @type, @model.getTarget( constant.RESTYPE.RT ).id, @id )
    else
      @doSelect( @type, @id, @id )
    true

  ChildElementProto.draw = ()->
    connection = @model

    # Calculate the ports
    item_from = connection.port1Comp().getCanvasView()
    item_to   = connection.port2Comp().getCanvasView()
    if not item_from or not item_to then return

    pos_from  = {
      left : connection.port1Comp().x() * 10
      top  : connection.port1Comp().y() * 10
    }
    pos_to  = {
      left : connection.port2Comp().x() * 10
      top  : connection.port2Comp().y() * 10
    }

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
    svg_line = document.getElementById( @id )
    if svg_line
      $( svg_line ).children().attr( 'd', path )
    else
      MC.paper.start()

      MC.paper.path(path)
      MC.paper.path(path).attr 'class', 'fill-line'

      if connection.get("dashLine")
        MC.paper.path(path).attr 'class', 'dash-line'

      svg_line = $(MC.paper.save()).attr({
        'class'     : 'line line-' + connection.get("lineType"),
        'data-type' : 'line'
        'id'        : @id
      })

      @getLayer("line_layer")[0].appendChild( svg_line[0] )
    null

  null
