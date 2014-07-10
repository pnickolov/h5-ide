
define [ "./CanvasView" ], ( CanvasView )->

  CanvasViewProto = CanvasView.prototype

  CanvasViewProto.__resizeGroupDown = ( evt )->
    $resizer  = $( evt.currentTarget )
    $group    = $resizer.closest("g")
    item      = @getItem( $group.attr("data-id") )
    direction = $resizer.attr("class").replace("group-resizer ", "").split("-")

    parent = item.parent()
    if parent
      pos  = parent.pos()
      size = parent.size()
      parent =
        x1 : pos.x + 2
        y1 : pos.y + 2
        x2 : pos.x - 2 + size.width
        y2 : pos.y - 2 + size.height
    else
      size = @size()
      parent =
        x1 : 5
        y1 : 3
        x2 : size[0] - 5
        y2 : size[1] - 3

    pos  = item.pos()
    size = item.size()
    target =
      x1 : pos.x
      y1 : pos.y
      x2 : pos.x + size.width
      y2 : pos.y + size.height

    data =
      pageX     : evt.pageX
      pageY     : evt.pageY
      direction : direction
      context   : @

      innerBound : __childrenBound( item, target )
      target     : target
      parent     : parent
      siblings   : item.siblings().map ( si )-> si.effectiveRect()

      overlay : $("<div></div>").appendTo( @$el ).css({"position":"absolute","left":"0","top":"0","bottom":"0","right":"0"})

    # Update ranges of the resize
    for dirt in direction
      __updateRange( dirt, data )

    $( document ).on({
      'mousemove.resizegroup' : __resizeMove
      'mouseup.resizegroup'   : __resizeUp
    }, data)

    ________visualizeResize( data )
    false

  ________visualizeResize = ( data )->
    svg = data.context.svg

    if not $("#ResizeBound").length
      group = svg.group().attr({
        "id":"ResizeBound",
        "pointer-events":"none"
      }).style("fill-opacity", "0.5")
      group.node.instance = group

    $("#ResizeBound")[0].instance.clear()

    x1 = data.innerBound.x1 * 10
    x2 = data.innerBound.x2 * 10
    y1 = data.innerBound.y1 * 10
    y2 = data.innerBound.y2 * 10

    group = $("#ResizeBound")[0].instance.add(
      svg.rect( x2 - x1, y2 - y1 ).move( x1, y1 ).style("fill","red")
    )
    if data.rangeX
      group.add(
        svg.rect( (data.rangeX[1] - data.rangeX[0]) * 10, "100%" ).move( data.rangeX[0]*10, 0 ).style("fill", "yellow")
      )
    if data.rangeY
      group.add(
        svg.rect( "100%", (data.rangeY[1] - data.rangeY[0]) * 10 ).move( 0, data.rangeY[0]*10 ).style("fill", "blue")
      )
    return

  __updateRange = ( direction, data )->

    target   = data.target

    left  = direction is "left"
    right = direction is "right"
    top   = direction is "top"
    down  = direction is "down"

    blocks = [{
      x1: data.parent.x2
      y1: data.parent.y2
      x2: data.parent.x1
      y2: data.parent.y1
    }]

    if left or right
      key = "rangeX"

      for sibling in data.siblings
        if sibling.y1 > target.y2 or sibling.y2 < target.y1
          continue
        if left
          if sibling.x1 > target.x1 then continue
        else if sibling.x2 < target.x2 then continue
        blocks.push sibling
    else
      key = "rangeY"

      for sibling in data.siblings
        if sibling.x1 > target.x2 or sibling.x2 < target.x1
          continue
        if top
          if sibling.y1 > target.y1 then continue
        else if sibling.y2 < target.y2 then continue
        blocks.push sibling

    if left
      range = [ __max( blocks, "x2" ), data.innerBound.x1 ]
    else if right
      range = [ data.innerBound.x2, __min( blocks, "x1" ) ]
    else if top
      range = [ __max( blocks, "y2" ), data.innerBound.y1 ]
    else
      range = [ data.innerBound.y2, __min( blocks, "y1" ) ]

    data[ key ] = range
    return

  __childrenBound = ( item, bound )->
    bound = {
      x1 : bound.x2 - 11
      y1 : bound.y2 - 11
      x2 : bound.x1 + 11
      y2 : bound.y1 + 11
    }

    for ch in item.children()
      bb = ch.effectiveRect()

      if bound.x1 > bb.x1 then bound.x1 = bb.x1
      if bound.y1 > bb.y1 then bound.y1 = bb.y1
      if bound.x2 < bb.x2 then bound.x2 = bb.x2
      if bound.y2 < bb.y2 then bound.y2 = bb.y2

    bound.x1 -= 1
    bound.y1 -= 1
    bound.x2 += 1
    bound.y2 += 1

    bound

  __min = ( array, key )->
    min = array[0][key]
    for i in array
      if i[key] < min
        min = i[key]
    min

  __max = ( array, key )->
    max = array[0][key]
    for i in array
      if i[key] > max
        max = i[key]
    max

  __resizeMove = ( evt )->

  __resizeUp = ( evt )->
    data = evt.data
    data.overlay.remove()
