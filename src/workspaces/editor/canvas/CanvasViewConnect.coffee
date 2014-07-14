
define [ "./CanvasView", "Design", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasView, Design, constant, CanvasManager, lang )->

  CanvasViewProto = CanvasView.prototype

  cancelConnect = ( evt )->
    $( document ).off(".drawline")

    data = evt.data

    data.context.__clearDragScroll()

    if data.marker
      data.marker.remove()
      data.lineSvg.remove()
      data.overlay.remove()

      for $el in data.highlightEls
        CanvasManager.removeClass $el, "connectable"
    return

  detectDrag = ( evt )->
    data = evt.data

    if Math.pow(evt.pageX - data.startX, 2) + Math.pow(evt.pageY - data.startY, 2) >= 4
      $( document )
        .off("mousemove.drawline")
        .off("mouseup.drawline")
        .on({
          "mousemove.drawline" : __drawLineMove
          "mouseup.drawline"   : __drawLineUp
        }, data)
      startDrag.call data.context, data
    false

  startDrag = ( d )->
    $port = d.source
    item  = d.startItem

    # StartPos
    portName  = $port.attr("data-name")
    portAlias = $port.attr("data-alias")
    pos       = item.pos( $port.closest("g")[0] )
    portPos   = item.portPosition( portAlias || portName )
    pos.x = pos.x * CanvasView.GRID_WIDTH  + portPos[0]
    pos.y = pos.y * CanvasView.GRID_HEIGHT + portPos[1]

    # Show element's line.
    for cn in item.connections()
      CanvasManager.addClass cn.$el, "hover"

    # Highlight connectable ports.
    highlightEls = []
    for type, data of Design.modelClassForType("Framework_CN").connectionData( item.type, portName )
      for comp in @design.componentsOfType( type )
        for toPort in data
          if item.isConnectable( portName, comp.id, toPort )
            ti = @getItem( comp.id )
            if ti
              ports = ti.$el.children("[data-name='#{toPort}']")
              CanvasManager.addClass ti.$el, "connectable"
              CanvasManager.addClass ports,  "connectable"
              highlightEls.push ports
              highlightEls.push ti.$el

    # Add temporary line.
    marker  = @svg.marker(3, 3).classes(portName).attr("id", "draw-line-marker").add( @svg.path( "M1.5,0 L1.5,3 L3,1.5 L1.5,0" ) )
    lineSvg = @svg.line(pos.x, pos.y, pos.x, pos.y).classes( "draw-line #{portName}" ).marker("end", marker)

    @svg.add( lineSvg )

    co = @$el.offset()
    dimension =
      x1 : co.left
      y1 : co.top
      x2 : co.left + @$el.outerWidth()
      y2 : co.top  + @$el.outerHeight()

    $.extend d, {
      marker        : marker
      lineSvg       : lineSvg
      zoneDimension : dimension
      highlightEls  : highlightEls
      portName      : portName
      startPos      : pos
      overlay       : $("<div></div>").appendTo( @$el ).css({
        "position" : "absolute"
        "left"     : "0"
        "top"      : "0"
        "bottom"   : "0"
        "right"    : "0"
      })
    }

    false

  CanvasViewProto.__connect = ( LineClass, comp1, comp2, startItem )->
    self = @
    c    = new LineClass( comp1, comp2, undefined, { createByUser : true } )
    if c.id then _.defer ()-> self.selectItem( c.id )
    @__connectInitItem = startItem
    return

  CanvasViewProto.__popLineInitiator = ()->
    i = @__connectInitItem
    @__connectInitItem = null
    i

  CanvasViewProto.__drawLineDown = ( evt )->
    if evt.which isnt 1 then return false

    $port = $( evt.currentTarget )
    $tgt  = $port.closest("g")
    item  = @getItem( $tgt.attr( "data-id" ) )
    if not item then return false

    scrollContent = @$el.children(":first-child")[0]

    $( document ).on({
      "mousemove.drawline" : detectDrag
      "mousedown.drawline" : cancelConnect  # Any other user mouse event will cause the drop to be canceld.
      "mouseup.drawline"   : cancelConnect  # Any other user mouse event will cause the drop to be canceld.
      "urlroute.drawline"  : cancelConnect
    }, {
      context       : @
      canvasScale   : @__scale
      source        : $port
      startItem     : item
      scrollContent : scrollContent
      pageX         : evt.pageX
      pageY         : evt.pageY
      startX        : evt.pageX + scrollContent.scrollLeft
      startY        : evt.pageY + scrollContent.scrollTop
    })

    false

  __drawLineMove = ( evt )->
    data = evt.data
    data.pageX = evt.pageX
    data.pageY = evt.pageY
    data.context.__scrollOnDrag( evt, data )

    offsetX = ( data.pageX + data.scrollContent.scrollLeft - data.startX ) * data.canvasScale
    offsetY = ( data.pageY + data.scrollContent.scrollTop  - data.startY ) * data.canvasScale

    data.lineSvg.plot( data.startPos.x, data.startPos.y, data.startPos.x + offsetX, data.startPos.y + offsetY )
    false

  __drawLineUp = ( evt )->
    data = evt.data

    # Find element
    canvasX = data.startPos.x + ( data.pageX + data.scrollContent.scrollLeft - data.startX ) * data.canvasScale
    canvasY = data.startPos.y + ( data.pageY + data.scrollContent.scrollTop  - data.startY ) * data.canvasScale
    item    = data.context.__itemAtPosForConnect(
      Math.round( canvasX / CanvasView.GRID_WIDTH ),
      Math.round( canvasY / CanvasView.GRID_HEIGHT )
    )

    # Find port
    if item.type is constant.RESTYPE.ELB and ( data.startItem.type is constant.RESTYPE.INSTANCE or data.startItem.type is constant.RESTYPE.INSTANCE )
      if canvasX < item.pos().x + item.size().width / 2
        toPort = "elb-sg-out"
      else
        toPort = "elb-sg-in"
    else if item.type is constant.RESTYPE.ASG or item.type is "ExpandedAsg"
      item = item.getLc()
      if item
        item = data.context.getItem( item.id )

    if not toPort and item
      toPort = item.$el.find(".connectable").attr("data-name")

    # Cleanup
    cancelConnect( evt )

    # Connect
    if not item or not toPort or item is data.startItem then return false

    C = Design.modelClassForPorts( data.portName, toPort )
    console.assert( C, "Cannot found Class for type: #{data.portName}>#{toPort}" )

    comp1 = data.startItem.model
    comp2 = item.model

    res = C.isConnectable( comp1, comp2 )

    if res is false then return
    if _.isString( res )
      notification "error", res
      return false

    if res is true
      data.context.__connect( C, comp1, comp2, data.startItem )
      return false

    if res.confirm
      self = @
      modal = new Modal {
        title    : res.title
        width    : "420"
        template : res.template
        confirm  : {text:res.action, color:"blue"}
        onConfirm  : ()->
          modal.close()
          data.context.__connect( C, comp1, comp2, data.startItem )
          return
      }
    false

  null
