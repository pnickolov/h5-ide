
define [
  "CanvasView"
  "CanvasElement"
  "CanvasManager"
  "constant"
  "i18n!/nls/lang.js"
], ( CanvasView, CanvasElement, CanvasManager, constant, lang )->

  CanvasViewProto = CanvasView.prototype

  xThenY = ( a, b )->
    if a[0] < b[0] then return -1
    if a[0] > b[0] then return 1
    a[1] - b[1]

  yThenX = ( a, b )->
    if a[1] < b[1] then return -1
    if a[1] > b[1] then return 1
    a[0] - b[0]

  getPolygonsFromRect = ( rects )->
    points = []
    # 1. Remove shared points.
    uniquePoints = {}
    for r in rects
      for p in [ "#{r.x1},#{r.y1}", "#{r.x2},#{r.y1}", "#{r.x1},#{r.y2}", "#{r.x2},#{r.y2}" ]
        if uniquePoints[ p ]
          delete uniquePoints[ p ]
        else
          uniquePoints[ p ] = p

    for k, p of uniquePoints
      p = p.split(",")
      points.push [ parseInt(p[0], 10) * 10, parseInt(p[1], 10) * 10 ]

    vEdges = {}
    hEdges = {}
    # 2. Create edges
    plen = points.length
    points.sort xThenY
    i = 0
    while i < plen
      currentCoor = points[ i ][ 0 ]
      while i < plen && points[ i ][ 0 ] is currentCoor
        p1 = points[ i ]
        p2 = points[ i+1 ]
        e1 = "#{p1[0]},#{p1[1]}"
        e2 = "#{p2[0]},#{p2[1]}"
        vEdges[ e1 ] = e2
        vEdges[ e2 ] = e1
        i += 2

    points.sort yThenX
    i = 0
    while i < plen
      currentCoor = points[ i ][ 1 ]
      while i < plen && points[ i ][ 1 ] is currentCoor
        p1 = points[ i ]
        p2 = points[ i+1 ]
        e1 = "#{p1[0]},#{p1[1]}"
        e2 = "#{p2[0]},#{p2[1]}"
        hEdges[ e1 ] = e2
        hEdges[ e2 ] = e1
        i += 2

    results = []
    # 3. Connect edges
    hEdgesKeys = _.keys( hEdges )
    while hEdgesKeys.length > 0
      he = hEdgesKeys[0]
      firstPt = pt = hEdges[ he ]
      hEdgesKeys.splice( hEdgesKeys.indexOf( pt ), 1 )

      result = [ pt ]
      currentDir = 0
      while true
        if currentDir is 0
          currentDir = 1
          pt = vEdges[ pt ]
        else
          currentDir = 0
          hEdgesKeys.splice( hEdgesKeys.indexOf(pt), 1 )
          pt = hEdges[ pt ]
          hEdgesKeys.splice( hEdgesKeys.indexOf(pt), 1 )

        result.push pt
        if pt is firstPt then break

      for pt, idx in result
        pt = pt.split(",")
        pt[0] = parseInt( pt[0], 10 )
        pt[1] = parseInt( pt[1], 10 )
        result[ idx ] = pt

      results.push result

    results

  getPathFromPolygons = ( polygons )->
    for r, i in polygons
      path = ""
      for p, j in r
        if j is 0
          command = "M"
          lastPt  = r[ r.length - 2 ]
        else
          command = "L"
          lastPt  = r[ j-1 ]

        nextPt = r[ j+1 ]

        if lastPt and nextPt
          x = 0
          y = 0
          if lastPt[1] is p[1] and nextPt[0] is p[0]
            x = p[0] + ( if lastPt[0] > p[0] then 5 else -5 )
            y = p[1] + ( if nextPt[1] > p[1] then 5 else -5 )
            path += "#{command}#{x} #{p[1]} Q#{p[0]} #{p[1]} #{p[0]} #{y}"
            continue
          else if lastPt[0] is p[0] and nextPt[1] is p[1]
            x = p[0] + ( if nextPt[0] > p[0] then 5 else -5 )
            y = p[1] + ( if lastPt[1] > p[1] then 5 else -5 )
            path += "#{command}#{p[0]} #{y} Q#{p[0]} #{p[1]} #{x} #{p[1]}"
            continue

      polygons[i] = path + "Z"

    polygons.join("")

  getElbowPathFromPoints = ( newPoints )->
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

  __isOverlap = ( rect1, rect2 )->
    not ( rect1.x1 >= rect2.x2 or rect1.x2 <= rect2.x1 or rect1.y1 >= rect2.y2 or rect1.y2 <= rect2.y1 )

  getNonOverlapRects = ( items )->
    rects = []
    groupRects = []
    for it in items
      if it.isGroup()
        groupRects.push it.effectiveRect()
      else
        rects.push it.rect()

    if not groupRects.length then return rects

    i = 1
    cleanRects = [ groupRects[0] ]
    while i < groupRects.length
      j = i
      currentRect = groupRects[ i ]

      overlap = false
      for otherRect in cleanRects
        if not __isOverlap( currentRect, otherRect )
          continue

        if currentRect.y1 <= otherRect.y1 and otherRect.y2 <= currentRect.y2
          groupRects.push { x1:currentRect.x1, x2:currentRect.x2, y1:currentRect.y1, y2:otherRect.y1 }
          groupRects.push { x1:currentRect.x1, x2:currentRect.x2, y1:currentRect.y2, y2:otherRect.y2 }

          if currentRect.x1 <= otherRect.x1
            groupRects.push { x1:currentRect.x1, x2:otherRect.x1, y1:otherRect.y1, y2:otherRect.y2 }
          else
            groupRects.push { x1:otherRect.x2, x2:currentRect.x2, y1:otherRect.y1, y2:otherRect.y2 }

        else if currentRect.x1 <= otherRect.x1 and otherRect.x2 <= currentRect.x2
          groupRects.push { x1:currentRect.x1, x2:otherRect.x1, y1:currentRect.y1, y2:currentRect.y2 }
          groupRects.push { x1:otherRect.x2, x2:currentRect.x2, y1:currentRect.y1, y2:currentRect.y2 }

          if currentRect.y1 <= otherRect.y1
            groupRects.push { x1:otherRect.x1, x2:otherRect.x2, y1:currentRect.y1, y2:otherRect.y1 }
          else
            groupRects.push { x1:otherRect.x1, x2:otherRect.x2, y1:otherRect.y2, y2:currentRect.y2 }

        else if otherRect.y1 <= currentRect.y1 and currentRect.y2 <= otherRect.y2
          if currentRect.x1 <= otherRect.x1
            groupRects.push { x1:currentRect.x1, x2:otherRect.x1, y1:currentRect.y1, y2:currentRect.y2 }
          else
            groupRects.push { x1:otherRect.x2, x2:currentRect.x2, y1:currentRect.y1, y2:currentRect.y2 }

        else if otherRect.x1 <= currentRect.x1 and currentRect.x2 <= otherRect.x2
          if currentRect.y1 <= otherRect.y1
            groupRects.push { x1:currentRect.x1, x2:currentRect.x2, y1:currentRect.y1, y2:otherRect.y1 }
          else
            groupRects.push { x1:currentRect.x1, x2:currentRect.x2, y1:otherRect.y2, y2:currentRect.y2 }

        else if currentRect.y1 <= otherRect.y1
          groupRects.push { x1:currentRect.x1, x2:currentRect.x2, y1:currentRect.y1, y2:otherRect.y1 }
          if currentRect.x1 <= otherRect.x1
            groupRects.push { x1:currentRect.x1, x2:otherRect.x1, y1:otherRect.y1, y2:currentRect.y2 }
          else
            groupRects.push { x1:otherRect.x2, x2:currentRect.x2, y1:otherRect.y1, y2:currentRect.y2 }

        else
          groupRects.push { x1:currentRect.x1, x2:currentRect.x2, y1:otherRect.y2, y2:currentRect.y2 }
          if currentRect.x1 <= otherRect.x1
            groupRects.push { x1:currentRect.x1, x2:otherRect.x1, y1:currentRect.y1, y2:otherRect.y2 }
          else
            groupRects.push { x1:otherRect.x2, x2:currentRect.x2, y1:currentRect.y1, y2:otherRect.y2 }

        overlap = true
        break

      if not overlap then cleanRects.push currentRect
      ++i

    rects.concat cleanRects

  # Add item by dnd
  CanvasViewProto.hightLightItems  = ( items )->
    rects    = getNonOverlapRects( items )
    polygons = getPolygonsFromRect( rects )
    path     = getPathFromPolygons( polygons )

    canvasSize = @size()
    w = canvasSize[0] * 10
    h = canvasSize[1] * 10
    filler = "M0,0L#{w},0L#{w},#{h}L0,#{h}Z"

    @__highLightCliper = @svg.clip().attr("id", "hlClipper").add( @svg.path(filler+path).attr("clip-rule","evenodd") )
    @__highLightRect   = @svg.rect(0,0).attr({id:"hlArea",width:"100%", height:"100%"}).clipWith( @__highLightCliper )


  CanvasViewProto.removeHightLight = ( items )->
    if @__highLightRect then @__highLightRect.remove()
    if @__highLightCliper then @__highLightCliper.remove()
    @__highLightRect = @__highLightCliper = null
    return

  trackMMoveForHint = ( evt )->
    type = if evt.offsetY > evt.data.height then "top" else "bottom"
    $hint = $( evt.currentTarget ).find(".canvas-message")
    if $hint.attr("data-type") isnt type
      $hint.attr("data-type", type )
    return

  CanvasViewProto.showHintMessage = ( message )->
    height = @$el.find(".canvas-message").html( message ).outerHeight() + 20
    @$el.on { "mousemove.canvashint" : trackMMoveForHint }, { height : height }
    return

  CanvasViewProto.hideHintMessage = ()->
    @$el.find(".canvas-message").empty()
    @$el.off "mousemove.canvashint"
    return

  return
