
define [ "CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang, SGRulePopup )->

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
          x        : port_from.pos[0]
          y        : port_from.pos[1]
          angle    : port_from.pos[2]
          type     : connection.port1Comp().type
          name     : port_from.name
          itemCX   : pos_from.x + size_from.width  / 2 * 10
          itemCY   : pos_from.y + size_from.height / 2 * 10
          item     : item_from
          itemRect :
            x1 : pos_from.x
            x2 : pos_from.x + size_from.width * 10
            y1 : pos_from.y
            y2 : pos_from.y + size_from.height * 10
        }
        end : {
          x     : port_to.pos[0]
          y     : port_to.pos[1]
          angle : port_to.pos[2]
          type  : connection.port2Comp().type
          name  : port_to.name
          itemCX : pos_to.x + size_to.width  / 2 * 10
          itemCY : pos_to.y + size_to.height / 2 * 10
          item   : item_to
          itemRect :
            x1 : pos_to.x
            x2 : pos_to.x + size_to.width * 10
            y1 : pos_to.y
            y2 : pos_to.y + size_to.height * 10
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

      return @generateElbowPath( start, end )

    lineStyle : ()-> 4

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


    generateElbowPath : ( start, end )->
      # 1. Find out the area we want our line to fit in.
      lineData = @getElbowBounds( start, end )

      # 2. Find out all the area that we might go through
      lineData.areas = @getElbowAreas( start, end )

      console.log "=========== #{@type}", lineData

      lineData.result  = []
      lineData.current = { x:lineData.start.x, y:lineData.start.y }
      lineData.target  = {}
      lineData.test    = 0

      # 3. Search best points for each area
      @getNextElbowTarget( lineData )
      while not lineData.done
        @proceedElbowTarget( lineData )
        @getNextElbowTarget( lineData )

        if lineData.inFinalArea
          @proceedElbowLastArea( lineData )
          break

        ++lineData.test
        if lineData.test >= 50
          lineData.failure = true
          break

      # 3.1 If it fails, fallback to old strategy to generate the line
      if lineData.failure
        @getElbowFallback( lineData )

      lineData.result.unshift( { x:lineData.start.x, y:lineData.start.y } )
      lineData.result.unshift( { x:start.x, y:start.y } )
      lineData.result.push( { x:lineData.end.x, y:lineData.end.y } )
      lineData.result.push( { x:end.x, y:end.y } )

      # 4. Optimize points
      @optimizeElbowPoints( lineData )

      # 5. Generate Path
      @getElbowPathFromPoints( lineData.result )

    getElbowFallback : ( lineData )->
      start = lineData.start
      end   = lineData.end
      if lineData.start.angle is CanvasElement.constant.PORT_UP_ANGLE or lineData.start.angle is CanvasElement.constant.PORT_DOWN_ANGLE
        lineData.result = [ {x:start.x,y:lineData.preferY}, {x:lineData.preferX,y:lineData.preferY} ]
      else
        lineData.result = [ {y:start.y,x:lineData.preferX}, {y:lineData.preferY,x:lineData.preferX} ]
      return

    getNextElbowTarget : ( lineData )->
      if lineData.current.x is lineData.end.x and lineData.current.y is lineData.end.y
        lineData.done = true
        return

      lastArea = lineData.areas[ lineData.areas.length - 1 ]
      if lastArea.x1 <= lineData.current.x <= lastArea.x2 and lastArea.y1 <= lineData.current.y <= lastArea.y2
        lineData.done = true
        lineData.inFinalArea = true
        return

      lineData.target.x = lineData.current.x
      lineData.target.y = lineData.current.y

      if lineData.start.angle is CanvasElement.constant.PORT_RIGHT_ANGLE or lineData.start.angle is CanvasElement.constant.PORT_LEFT_ANGLE
        if lineData.start.angle is CanvasElement.constant.PORT_RIGHT_ANGLE
          left  = lineData.current.x
          right = lineData.preferX
        else
          left  = lineData.preferX
          right = lineData.current.x

        if left < right
          lineData.target.x = lineData.preferX
        else if lineData.current.y isnt lineData.end.y
          lineData.target.y = lineData.end.y
        else
          lineData.target.x = lineData.end.x
      else
        if lineData.start.angle is CanvasElement.constant.PORT_DOWN_ANGLE
          top  = lineData.current.y
          down = lineData.preferY
        else
          top  = lineData.preferY
          down = lineData.current.y
        if top < down
          lineData.target.y = lineData.preferY
        else if lineData.current.x isnt lineData.end.x
          lineData.target.x = lineData.end.x
        else
          lineData.target.y = lineData.end.y

      return

    proceedElbowTarget : ( lineData )->
      # 0. Find out which area we are in
      target  = $.extend {}, lineData.target
      current = lineData.current

      for thearea, idx in lineData.areas
        if area and area.depth < thearea.depth then continue

        xRange = thearea.x1 < current.x and current.x < thearea.x2
        yRange = thearea.y1 < current.y and current.y < thearea.y2
        xSide  = thearea.x1 is current.x or thearea.x2 is current.x
        ySide  = thearea.y1 is current.y or thearea.y2 is current.y
        if ( xRange and yRange ) or ( thearea.endParent and (( xRange and ySide ) or (yRange and xSide)) )
          area     = thearea
          nextArea = lineData.areas[ idx + 1 ]

      if nextArea
        if nextArea.endParent
          if nextArea.x1 < target.x < nextArea.x2 and nextArea.y1 < target.y < nextArea.y2
            if current.x > nextArea.x2
              target.x = nextArea.x2
            else if current.x < nextArea.x1
              target.x = nextArea.x1
            else if current.y > nextArea.y2
              target.y = nextArea.y2
            else if current.y < nextArea.y1
              target.y = nextArea.y1
        else
          if not (area.x1 < target.x < area.x2 and area.y1 < target.y < area.y2 )
            if target.x > area.x2
              target.x = area.x2
            else if target.x < area.x1
              target.x = area.x1
            else if target.y > area.y2
              target.y = area.y2
            else if target.y < area.y1
              target.y = area.y1

      # 1. See if that point is blocked.
      cross = []
      if target.x < current.x
        linex1 = target.x
        linex2 = current.x
      else
        linex1 = current.x
        linex2 = target.x
      if target.y < current.y
        liney1 = target.y
        liney2 = current.y
      else
        liney1 = current.y
        liney2 = target.y

      for ch in area.children
        if not ( ch.x1 >= linex2 or ch.x2 <= linex1 or ch.y1 >= liney2 or ch.y2 <= liney1 )
          # This children cross the line
          cross.push ch


      # 2. Find out which block comes first
      if current.x > target.x
        currentAngle = CanvasElement.constant.PORT_LEFT_ANGLE
      else if current.x < target.x
        currentAngle = CanvasElement.constant.PORT_RIGHT_ANGLE
      else if current.y > target.y
        currentAngle = CanvasElement.constant.PORT_UP_ANGLE
      else
        currentAngle = CanvasElement.constant.PORT_DOWN_ANGLE

      minCross = -1
      theCross = null
      for ch in cross
        if currentAngle is CanvasElement.constant.PORT_LEFT_ANGLE or currentAngle is CanvasElement.constant.PORT_RIGHT_ANGLE
          dis = Math.abs( ch.x1 - current.x )
        else
          dis = Math.abs( ch.y1 - current.y )

        if dis < minCross or minCross is -1
          theCross = ch
          minCross = dis

      if not theCross
        lineData.result.push target
        lineData.current.x = target.x
        lineData.current.y = target.y
        return

      # 3 Stop at the cloest block. And find next point.
      if currentAngle is CanvasElement.constant.PORT_UP_ANGLE or currentAngle is CanvasElement.constant.PORT_DOWN_ANGLE
        if currentAngle is CanvasElement.constant.PORT_UP_ANGLE
          theCrossY   = theCross.y2
          theCrossEnd = theCross.y1
        else
          theCrossY   = theCross.y1
          theCrossEnd = theCross.y2

        lineData.result.push { x : lineData.current.x, y : theCrossY }

        # Choose left or right
        if theCross.x2 < lineData.end.x
          theCrossX = theCross.x2
        else if theCross.x1 > lineData.end.x
          theCrossX = theCross.x1
        else if (theCross.x2 - lineData.current.x) <= (lineData.current.x - theCross.x1)
          theCrossX = theCross.x2
        else
          theCrossX = theCross.x1

        lineData.result.push { x : theCrossX, y : theCrossY }

        if Math.abs(theCrossEnd - theCrossY) > Math.abs(lineData.preferY - theCrossY)
          lineData.result.push { x : theCrossX, y : lineData.preferY }
        else
          lineData.result.push { x : theCrossX, y : theCrossEnd }

      else
        if currentAngle is CanvasElement.constant.PORT_LEFT_ANGLE
          theCrossX   = theCross.x2
          theCrossEnd = theCross.x1
        else
          theCrossX   = theCross.x1
          theCrossEnd = theCross.x2

        lineData.result.push { x : theCrossX, y : lineData.current.y }

        # Choose top or bottom
        if theCross.y2 < lineData.end.y
          theCrossY = theCross.y2
        else if theCross.y1 > lineData.end.y
          theCrossY = theCross.y1
        else if (theCross.y2 - lineData.current.y) <= (lineData.current.y - theCross.y1)
          theCrossY = theCross.y2
        else
          theCrossY = theCross.y1

        lineData.result.push { x : theCrossX, y : theCrossY }

        if Math.abs(theCrossEnd - theCrossX) > Math.abs(lineData.preferX - theCrossX)
          lineData.result.push { y : theCrossY, x : lineData.preferX }
        else
          lineData.result.push { y : theCrossY, x : theCrossEnd }


      lineData.current = $.extend {}, lineData.result[ lineData.result.length - 1 ]
      return

    proceedElbowLastArea : ( lineData )->

      end      = lineData.end
      lastArea = lineData.areas[ lineData.areas.length - 1 ]
      target   = lineData.target
      toX      = target.x
      toY      = target.y
      current  = lineData.result[ lineData.result.length - 1 ]

      if end.angle is CanvasElement.constant.PORT_UP_ANGLE or end.angle is CanvasElement.constant.PORT_DOWN_ANGLE
        if Math.abs( target.y - lastArea.y1 ) < Math.abs( target.y - lastArea.y2 )
          toY = lastArea.y1
          otherSide = lastArea.y2
        else
          toY = lastArea.y2
          otherSide = lastArea.y1

        if current.y is otherSide
          if Math.abs( current.x - lastArea.x1 ) < Math.abs( current.x - lastArea.x2 )
            nextX = lastArea.x1
          else
            nextX = lastArea.x2
          lineData.result.push { x : nextX, y : current.y }
          lineData.result.push { x : nextX, y : toY }
        else
          lineData.result.push { x : current.x, y : toY }

        lineData.result.push { x : toX, y : toY }
        lineData.result.push { x : lineData.end.x, y : toY }
      else
        if Math.abs( target.x - lastArea.x1 ) < Math.abs( target.x - lastArea.x2 )
          toX = lastArea.x1
          otherSide = lastArea.x2
        else
          toX = lastArea.x2
          otherSide = lastArea.x1

        if current.x is otherSide
          if Math.abs( current.y - lastArea.y1 ) < Math.abs( current.y - lastArea.y2 )
            nextY = lastArea.y1
          else
            nextY = lastArea.y2
          lineData.result.push { x : current.x, y : nextY }
          lineData.result.push { x : toX, y : nextY }
        else
          lineData.result.push { x : toX, y : current.y }

        lineData.result.push { x : toX, y : toY }
        lineData.result.push { x : toX, y : lineData.end.y }


    optimizeElbowPoints : ( lineData )->
      optPoints = []
      idx = 0
      while idx < lineData.result.length
        pt0 = lineData.result[ idx ]
        pt1 = lineData.result[ idx+1 ]
        pt2 = lineData.result[ idx+2 ]

        if pt1 and pt1.y is pt0.y and pt0.x is pt1.x
          # Ignore the point, because the point is the same as the next one.
          idx += 1
          continue

        optPoints.push pt0
        if pt1 and pt2
          if ( pt1.x is pt2.x and pt0.x is pt1.x ) or ( pt1.y is pt2.y and pt0.y is pt1.y )
            # Ignore the useless point.
            idx += 2
            continue
        ++idx
      lineData.result = optPoints
      return


    getElbowPathFromPoints : ( newPoints )->
      path = ""
      for p, idx in newPoints
        if idx is 0
          path = "M#{p.x} #{p.y}"
          continue

        lastPt = newPoints[ idx-1 ]
        nextPt = newPoints[ idx+1 ]
        if lastPt and nextPt
          x = 0
          y = 0
          if lastPt.y is p.y and nextPt.x is p.x
            x = p.x + ( if lastPt.x > p.x then 5 else -5 )
            y = p.y + ( if nextPt.y > p.y then 5 else -5 )
            path += "L#{x} #{p.y} Q#{p.x} #{p.y} #{p.x} #{y}"
            continue
          else if lastPt.x is p.x and nextPt.y is p.y
            x = p.x + ( if nextPt.x > p.x then 5 else -5 )
            y = p.y + ( if lastPt.y > p.y then 5 else -5 )
            path += "L#{p.x} #{y} Q#{p.x} #{p.y} #{x} #{p.y}"
            continue

        path += "L#{p.x} #{p.y}"

      path

    __fixElbowEndpoint : ( point, relative )->
      p = $.extend {}, point

      if point.angle is CanvasElement.constant.PORT_2D_H_ANGLE or point.angle is CanvasElement.constant.PORT_4D_ANGLE
        if point.x >= relative.x
          p.angle = CanvasElement.constant.PORT_LEFT_ANGLE
        else
          p.angle = CanvasElement.constant.PORT_RIGHT_ANGLE

      if point.angle is CanvasElement.constant.PORT_2D_V_ANGLE
        if point.y >= relative.y
          p.angle = CanvasElement.constant.PORT_UP_ANGLE
        else
          p.pointangle = CanvasElement.constant.PORT_DOWN_ANGLE

      if (p.angle is CanvasElement.constant.PORT_LEFT_ANGLE and p.x < relative.x) or (p.angle is CanvasElement.constant.PORT_RIGHT_ANGLE and p.x > relative.x)
        angle = if relative.y >= p.y then CanvasElement.constant.PORT_DOWN_ANGLE else CanvasElement.constant.PORT_UP_ANGLE

      else if (p.angle is CanvasElement.constant.PORT_UP_ANGLE and p.y < relative.y) or (p.angle is CanvasElement.constant.PORT_DOWN_ANGLE and p.y > relative.y )
        angle = if relative.x >= p.x then CanvasElement.constant.PORT_RIGHT_ANGLE else CanvasElement.constant.PORT_LEFT_ANGLE

      if angle
        switch p.angle
          when CanvasElement.constant.PORT_LEFT_ANGLE
            p.x = Math.floor( (p.x - 1) / 5 ) * 5
          when CanvasElement.constant.PORT_RIGHT_ANGLE
            p.x = Math.ceil(  (p.x + 1) / 10 ) * 10
          when CanvasElement.constant.PORT_UP_ANGLE
            p.y = Math.floor( (p.y - 1) / 10 ) * 10
          when CanvasElement.constant.PORT_DOWN_ANGLE
            p.y = Math.ceil(  (p.y + 1) / 10 ) * 10

        p.angle = angle
      p

    __ensurePointInParent : ( point, parentRect )->
      point.x = Math.max( point.x, parentRect.x1 * 10 )
      point.x = Math.min( point.x, parentRect.x2 * 10 )
      point.y = Math.max( point.y, parentRect.y1 * 10 )
      point.y = Math.min( point.y, parentRect.y2 * 10 )
      point

    getElbowBounds : ( start, end ) ->
      start0 = @__fixElbowEndpoint( start, end )
      end0   = @__fixElbowEndpoint( end, start )

      bound = {}
      if (start0.angle + end0.angle) % 180 is 0
        if start.item.sticky
          sticky = start
        else if end.item.sticky
          sticky = end

        if start0.angle is CanvasElement.constant.PORT_UP_ANGLE or start0.angle is CanvasElement.constant.PORT_DOWN_ANGLE
          bound.preferX = end0.x

          if sticky
            bound.preferY = sticky.y + (if sticky.angle is CanvasElement.constant.PORT_UP_ANGLE then -10 else 10)
          else
            bound.preferY = Math.round( (start0.y + end0.y) / 20 ) * 10
            if start.itemRect.y1 < bound.preferY < start.itemRect.y2 or end.itemRect.y1 < bound.preferY < end.itemRect.y2
              y1 = Math.min( start.itemRect.y1, end.itemRect.y1 )
              y2 = Math.max( start.itemRect.y2, end.itemRect.y2 )
              if Math.abs( y1-start0.y ) + Math.abs( y1-end0.y ) < Math.abs( y2-start0.y ) + Math.abs( y2-end0.y )
                bound.preferY = y1 - 5
              else
                bound.preferY = y2 + 5

              start0.angle = if start0.y <= bound.preferY then CanvasElement.constant.PORT_DOWN_ANGLE else CanvasElement.constant.PORT_UP_ANGLE
              end0.angle   = if end0.y   <= bound.preferY then CanvasElement.constant.PORT_DOWN_ANGLE else CanvasElement.constant.PORT_UP_ANGLE

        else
          bound.preferY = end0.y
          if sticky
            bound.preferX = sticky.x + (if sticky.angle is CanvasElement.constant.PORT_LEFT_ANGLE then -10 else 10)
          else
            bound.preferX = Math.round( (start0.x + end0.x) / 20 ) * 10
            if start.itemRect.x1 < bound.preferX < start.itemRect.x2 or end.itemRect.x1 < bound.preferX < end.itemRect.x2
              x1 = Math.min( start.itemRect.x1, end.itemRect.x1 )
              x2 = Math.max( start.itemRect.x2, end.itemRect.x2 )
              if Math.abs( x1-start0.x ) + Math.abs( x1-end0.x ) < Math.abs( x2-start0.x ) + Math.abs( x2-end0.x )
                bound.preferX = x1 - 5
              else
                bound.preferX = x2 + 5
              start0.angle = if start0.x <= bound.preferX then CanvasElement.constant.PORT_RIGHT_ANGLE else CanvasElement.constant.PORT_LEFT_ANGLE
              end0.angle   = if end0.x   <= bound.preferX then CanvasElement.constant.PORT_RIGHT_ANGLE else CanvasElement.constant.PORT_LEFT_ANGLE
      else
        if start0.angle is CanvasElement.constant.PORT_UP_ANGLE or start0.angle is CanvasElement.constant.PORT_DOWN_ANGLE
          bound.preferX = start0.x
          bound.preferY = end0.y
        else
          bound.preferX = end0.x
          bound.preferY = start0.y

      bound.x1 = Math.min( start0.x, end0.x )
      bound.x2 = Math.max( start0.x, end0.x )
      bound.y1 = Math.min( start0.y, end0.y )
      bound.y2 = Math.max( start0.y, end0.y )
      bound.start = @__ensurePointInParent( start0, start.item.parent().rect() )
      bound.end   = @__ensurePointInParent( end0,   end.item.parent().rect() )

      bound

    __getElbowChildRect : ( p )->
      children = []
      for ch in p.children()
        rect = ch.rect()
        rect.item = ch
        rect.x1 *= 10
        rect.y1 *= 10
        rect.x2 *= 10
        rect.y2 *= 10
        if ch.isGroup()
          rect.x1 -= 5
          rect.y1 -= 5
          rect.x2 += 5
          rect.y2 += 5
        children.push rect
      children

    __getElbowParentRect : ( ch, depth, endParent )->
      rect = ch.rect()
      rect.item = ch
      factor = if ch.isGroup() then 5 else 0
      rect.x1 = rect.x1 * 10 - factor
      rect.y1 = rect.y1 * 10 - factor
      rect.x2 = rect.x2 * 10 + factor
      rect.y2 = rect.y2 * 10 + factor
      rect.children = @__getElbowChildRect( ch )
      rect.depth = depth
      rect.endParent = endParent
      rect

    getElbowAreas : ( start, end )->
      p1 = start.item
      p2 = end.item

      p2Parents = []
      while p2
        p2Parents.push p2
        p2 = p2.parent()

      areas = []
      depth = 0
      while p1
        ++depth

        p2Index = p2Parents.indexOf( p1 )
        if p2Index is -1
          areas.push @__getElbowParentRect( p1, depth )
        else
          endParent = false
          while p2Index >= 0
            areas.push @__getElbowParentRect( p2Parents[p2Index], depth, endParent )
            endParent = true
            --p2Index
            --depth
          break

        p1 = p1.parent()

      areas

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

    connect : ( LineClass, comp1, comp2 )-> new LineClass( comp1, comp2, undefined, { createByUser : true } )
  }

  CeLine

