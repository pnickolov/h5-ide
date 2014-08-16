
define [ "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  LineMaskToClear = null

  rotate = ( point, angle )->
    a = Math.PI / 180 * angle
    c = Math.cos a
    s = Math.sin a

    point.y = -point.y

    x = Math.round( point.x * c - point.y * s )
    y = Math.round( point.x * s + point.y * c )
    point.x = x
    point.y = -y
    return

  __determineAngle = ( target, endpoint )->
    a = target[2]
    if a is CanvasElement.constant.PORT_4D_ANGLE
      if Math.abs(endpoint[0] - target[0]) - Math.abs(endpoint[1] - target[1]) > 0
        a = CanvasElement.constant.PORT_2D_H_ANGLE
      else
        a = CanvasElement.constant.PORT_2D_V_ANGLE

    if a is CanvasElement.constant.PORT_2D_H_ANGLE
      target[2] = if endpoint[0] >= target[0] then CanvasElement.constant.PORT_RIGHT_ANGLE else CanvasElement.constant.PORT_LEFT_ANGLE

    else if a is CanvasElement.constant.PORT_2D_V_ANGLE
      target[2] = if endpoint[1] >= target[1] then CanvasElement.constant.PORT_DOWN_ANGLE else CanvasElement.constant.PORT_UP_ANGLE
    return

  determineAngle = ( p1, p2 )->
    if p1[2] < 0 then __determineAngle( p1, p2 )
    if p2[2] < 0 then __determineAngle( p2, p1 )
    return

  CeLine = CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeLine"
    ### env:dev:end ###
    type : "CeLine"

    node_line : true

    portName : ( targetId )-> @model.port( targetId, "name" )

    # Update the svg element
    render : ()->
      @$el.remove()
      @$el = $()

      item1 = @canvas.getItem( @model.port1Comp().id )
      item2 = @canvas.getItem( @model.port2Comp().id )

      initiator = @canvas.__popLineInitiator() || item1

      if item1.$el.length is 1 and item2.$el.length is 1
        @renderConnection( item1, item2, undefined, undefined, initiator )
      else
        for el1 in item1.$el
          for el2 in item2.$el
            @renderConnection( item1, item2, el1, el2, initiator )

      return

    update : ()->
      item1 = @canvas.getItem( @model.port1Comp().id )
      item2 = @canvas.getItem( @model.port2Comp().id )

      if item1.$el.length is 1 and item2.$el.length is 1
        @$el.children().attr( "d", @generatePath( item1, item2, undefined, undefined ) )
      else
        newLength = item1.$el.length * item2.$el.length
        if @$el.length < newLength
          while @$el.length < newLength
            svgEl = @createLine( "M0 0Z" )
            @addView svgEl

        else if @$el.length > newLength
          @$el.slice( newLength ).remove()
          @$el = @$el.slice( 0, newLength )

        i = 0
        for el1 in item1.$el
          for el2 in item2.$el
            @$el.eq(i).children().attr( "d", @generatePath( item1, item2, el1, el2 ) )
            ++i
      return

    createLine : ( pd )->
      svg = @canvas.svg
      svgEl = svg.group().add([
        svg.path(pd)
        svg.path(pd).classes("fill-line")
      ]).attr({"data-id":@cid}).classes("line " + @type.replace(/\./g, "-") )
      @canvas.appendLine( svgEl )

      svgEl

    renderConnection : ( item_from, item_to, element1, element2, initiator )->
      path = @generatePath( item_from, item_to, element1, element2 )
      # Create or redraw line
      svgEl = @createLine( path )
      @addView svgEl

      if not @canvas.initializing and initiator
        svg = @canvas.svg
        maskPath = svg.path( path )
        length = parseFloat(maskPath.node.getTotalLength()).toFixed(2)

        dirt = (if initiator is item_from then 1 else -1) * (@__lastDir || 1)

        maskPath.style({
          "stroke-dasharray"  : length + " " + length
          "stroke-dashoffset" : length * dirt
        })

        setTimeout ()->
          maskPath.classes("mask-line")
        , 20

        CeLine.cleanLineMask svgEl.maskWith( maskPath )
      return

    # Find out which port we should use to draw the line.
    # The port we need is the closest port.
    getConnectPorts : ( item_from, item_to, element1, element2 )->
      connection = @model

      pos_to   = item_to.pos   element2
      pos_from = item_from.pos element1

      pos_to.x *= 10; pos_from.x *= 10
      pos_to.y *= 10; pos_from.y *= 10

      from_port = connection.port1("name")
      to_port   = connection.port2("name")
      dirn_from = item_from.portDirection(from_port)
      dirn_to   = item_to.portDirection(to_port)

      possiblePortFrom = [ from_port ]
      possiblePortTo   = [ to_port ]

      if dirn_from
        possiblePortFrom = if dirn_from is "horizontal" then [ from_port + "-right", from_port + "-left" ] else [ from_port + "-top", from_port + "-bottom" ]
      if dirn_to
        possiblePortTo = if dirn_to is "horizontal" then [ to_port + "-right", to_port + "-left" ] else [ to_port + "-top", to_port + "-bottom" ]

      for i, idx in possiblePortFrom
        possiblePortFrom[ idx ] =
          name : i
          pos  : item_from.portPosition( i, true ).slice(0)
        possiblePortFrom[ idx ].pos[0] += pos_from.x
        possiblePortFrom[ idx ].pos[1] += pos_from.y

      for i, idx in possiblePortTo
        possiblePortTo[ idx ] =
          name : i
          pos  : item_to.portPosition( i, true ).slice(0)
        possiblePortTo[ idx ].pos[0] += pos_to.x
        possiblePortTo[ idx ].pos[1] += pos_to.y

      distance = -1

      for i in possiblePortFrom
        for j in possiblePortTo
          d = Math.pow( i.pos[0] - j.pos[0], 2 ) + Math.pow( i.pos[1] - j.pos[1], 2 )
          if distance is -1 or distance > d
            distance  = d
            port_from = i
            port_to   = j

      size_to   = item_to.size()
      size_from = item_from.size()

      determineAngle( port_from.pos, port_to.pos )

      {
        start : {
          x     : port_from.pos[0]
          y     : port_from.pos[1]
          angle : port_from.pos[2]
          type  : connection.port1Comp().type
          name  : port_from.name
          itemCX : pos_from.x + size_from.width  / 2 * 10
          itemCY : pos_from.y + size_from.height / 2 * 10
        }
        end : {
          x     : port_to.pos[0]
          y     : port_to.pos[1]
          angle : port_to.pos[2]
          type  : connection.port2Comp().type
          name  : port_to.name
          itemCX : pos_to.x + size_to.width  / 2 * 10
          itemCY : pos_to.y + size_to.height / 2 * 10
        }
      }

    generatePath : ( item_from, item_to, element1, element2 )->

      ports = @getConnectPorts( item_from, item_to, element1, element2 )
      start = ports.start
      end   = ports.end

      @__lastDir = 1
      # Calculate line path
      if @lineStyle() is 0 # Straight
        return "M#{start.x} #{start.y} L#{end.x} #{end.y}"
      if @lineStyle() is 2 or @lineStyle() is 3 # Curve
        return @generateCurvePath( ports.start, ports.end )

      if start.x is end.x or start.y is end.y
        return "M#{start.x} #{start.y} L#{end.x} #{end.y}"

      @__lastDir = if start.y >= end.y then 1 else -1
      MC.canvas._round_corner( MC.canvas.route2(start, end, @lineStyle()) )

    lineStyle : ()-> @canvas.lineStyle()

    generateCurvePath : ( start, end )->
      # 1. Origin
      origin =
        x : start.x
        y : start.y

      originalEndAngle = end.angle

      # 2. Use the origin to calc the offset of each point
      start.x = start.y = 0
      end.x -= origin.x
      end.y -= origin.y

      # 3. Rotate to make start.angle to be 0
      if start.angle isnt 0
        rotate(end, -start.angle)
        end.angle -= start.angle
        if end.angle < 0 then end.angle += 360

      # 4. Flip end, if end is in Quadrant 3 or Quadrant 4
      fliped = false
      if end.y > 0
        fliped = true
        end.y = -end.y
        if end.angle is 90 then end.angle = 270
        else if end.angle is 270 then end.angle = 90

      # 5. Pick the curve algorithm we want
      result = @["generateCurvePath" + end.angle ]( start, end )

      # 6. Flip and rotate back.
      result.push end
      if fliped
        point.y = -point.y for point in result

      for point in result
        rotate( point, start.angle )
        point.x += origin.x
        point.y += origin.y

      # offset = ( dir, match )->
      #   for point in result
      #     if point[dir] is match
      #       point[dir] += 0.5
      #   return

      # endX = result[result.length - 1].x
      # endY = result[result.length - 1].y
      # if start.angle % 180 is 0
      #   offset( "y", origin.y )
      #   origin.y += 0.5
      # else
      #   offset( "x", origin.x )
      #   origin.x += 0.5

      # if originalEndAngle % 180 is 0
      #   offset( "y", endY )
      # else
      #   offset( "x", endX )

      # 7. Generate SVG Path
      if result.length is 3
        "M#{origin.x} #{origin.y}C#{result[0].x} #{result[0].y} #{result[1].x} #{result[1].y} #{result[2].x} #{result[2].y}"
      else
        "M#{origin.x} #{origin.y}L#{result[0].x} #{result[0].y}C#{result[1].x} #{result[1].y} #{result[2].x} #{result[2].y} #{result[3].x} #{result[3].y}L#{result[4].x} #{result[4].y}"

    generateCurvePath0  : ( start, end )->
      x   = end.x
      y   = Math.abs(end.y)
      dis = Math.sqrt( Math.pow(x,2) + Math.pow(y,2) ) / 4
      rad = Math.PI / 180 * 30
      cos = dis * Math.cos( rad )
      sin = dis * Math.sin( rad )
      if x > 0
        [{x:cos,y:-sin},{x:end.x+sin,y:end.y+cos}]
      else if x is 0
        [{x:cos,y:-sin},{x:end.x+cos,y:end.y+sin}]
      else
        [{x:sin,y:-cos},{x:end.x+cos,y:end.y+sin}]

    generateCurvePath90 : ( start, end )->
      x   = end.x
      y   = Math.abs(end.y)
      dis = Math.sqrt( Math.pow(x,2) + Math.pow(y,2) )
      rad = Math.PI / 180 * 30
      dis /= if x > 0 then 4 else 2
      c2x = dis * Math.cos( rad )
      c2y = dis * Math.sin( rad )
      if x > 0
        [{x:end.x/2,y:0},{x:end.x-c2x,y:end.y-c2y}]
      else
        [{x:sin,y:-cos},{x:end.x+cos,y:end.y-sin}]

    generateCurvePath180 : ( start, end )->
      if end.x > 0
        return [{x:end.x/2,y:0},{x:end.x/2,y:end.y}]

      x   = end.x
      y   = Math.abs(end.y)
      dis = Math.sqrt( Math.pow(x,2) + Math.pow(y,2) ) / 3
      rad = Math.PI / 180 * 40
      sin = dis * Math.sin( rad )
      cos = dis * Math.cos( rad )
      [{x:sin,y:-cos},{x:end.x-sin,y:end.y+cos}]

    generateCurvePath270 : ( start, end )->
      x = end.x
      y = Math.abs(end.y)

      if x > 0
        if Math.abs(x - y) < 10
          return [{x:x,y:0},{x:x,y:end.y}]

        if x < 20
          return [{x:0,y:0},{x:0,y:0},{x:x,y:0},{x:x,y:-x}]
        else if y < 20
          return [{x:x-y,y:0},{x:x-y,y:0},{x:x,y:0},{x:x,y:end.y}]

        if x < y
          return [{x:x,y:0},{x:x,y:end.y/2}]
        else
          return [{x:x/2,y:0},{x:x,y:0}]

      dis = Math.sqrt( Math.pow(x,2) + Math.pow(y,2) ) / 4
      rad = Math.PI / 180 * 30
      c1x = dis * Math.cos( rad )
      c1y = dis * Math.sin( rad )
      [{x:c1x,y:-c1y},{x:end.x,y:end.y/2}]

  }, {
    cleanLineMask : ( line )->
      if not LineMaskToClear
        LineMaskToClear = [ line ]
        setTimeout ()->
          CeLine.__cleanLineMask()
        , 340
      else
        LineMaskToClear.push line

    __cleanLineMask : ()->
      for line in LineMaskToClear
        if line.masker
          line.masker.remove()
      LineMaskToClear = null
      return
  }


  CeLine.extend {
    ### env:dev ###
    ClassName : "CeEniAttachment"
    ### env:dev:end ###
    type : "EniAttachment"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeElbAsso"
    ### env:dev:end ###
    type : "ElbAsso"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeRtbAsso"
    ### env:dev:end ###
    type : "RTB_Asso"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeRtbRoute"
    ### env:dev:end ###
    type : "RTB_Route"

    lineStyle : ()-> 1

    createLine : ( pd )->
      svg   = @canvas.svg
      svgEl = CeLine.prototype.createLine.call this, pd
      svgEl.add( svg.path(pd).classes("dash-line") )
      svgEl
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeVpn"
    ### env:dev:end ###
    type : constant.RESTYPE.VPN
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeElbSubnetAsso"
    ### env:dev:end ###
    type : "ElbSubnetAsso"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeElbAmiAsso"
    ### env:dev:end ###
    type : "ElbAmiAsso"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeDbReplication"
    ### env:dev:end ###
    type : "DbReplication"

    select : ()-> # Disable selection

    createLine : ( pd )->
      svg   = @canvas.svg
      svgEl = CeLine.prototype.createLine.call this, pd
      svgEl.add( svg.path(pd).classes("dash-line") )
      svgEl
  }

  CeLine
