
define [
  "Design"
  "CanvasView"
  "CanvasManager"
  "CanvasElement"
  "i18n!/nls/lang.js"
], ( Design, CanvasView, CanvasManager, CanvasElement, lang )->

  CanvasViewProto = CanvasView.prototype

  cancelConnect = ( evt )->
    $( document ).off(".drawline")

    data = evt.data

    data.context.__clearDragScroll()

    data.context.removeHightLight()
    data.context.hideHintMessage()

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
    pos       = item.pos( $port.closest(".canvasel")[0] )
    portPos   = item.portPosition( portAlias || portName )
    pos.x = pos.x * CanvasView.GRID_WIDTH  + portPos[0]
    pos.y = pos.y * CanvasView.GRID_HEIGHT + portPos[1]

    # Show element's line.
    for cn in item.connections()
      CanvasManager.addClass cn.$el, "hover"

    # Highlight connectable ports.
    highlightEls = []
    targetItems  = []
    for type, data of Design.modelClassForType("Framework_CN").connectionData( item.type, portName )
      for comp in @design.componentsOfType( type )
        for toPort in data
          if comp isnt item.model and item.isConnectable( portName, comp.id, toPort )
            ti = @getItem( comp.id )
            if ti
              ports = ti.$el.children("[data-name='#{toPort}']")
              CanvasManager.addClass ports,  "connectable"
              highlightEls.push ports
              targetItems.push ti

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

    @hightLightItems( targetItems )
    @showHintMessage( $port.attr("data-tooltip") )

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
    LineItemClass = CanvasElement.getClassByType( LineClass.prototype.type )
    c = LineItemClass.connect( LineClass, comp1, comp2 )
    if c and c.id then _.defer ()-> self.selectItem( c.id )
    @__connectInitItem = startItem
    return

  CanvasViewProto.__popLineInitiator = ()->
    i = @__connectInitItem
    @__connectInitItem = null
    i

  CanvasViewProto.__drawLineDown = ( evt )->
    if evt.which isnt 1 then return false

    $port = $( evt.currentTarget )
    $tgt  = $port.closest(".canvasel")
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
    data.context.__scrollOnDrag( data )

    newX = data.startPos.x + ( data.pageX + data.scrollContent.scrollLeft - data.startX ) * data.canvasScale
    newY = data.startPos.y + ( data.pageY + data.scrollContent.scrollTop  - data.startY ) * data.canvasScale

    data.lineSvg.plot( data.startPos.x, data.startPos.y, newX, newY )
    false

  __drawLineUp = ( evt )->
    data = evt.data

    # Find element
    offset = $( data.scrollContent ).offset()
    coord  = data.context.__localToCanvasCoor( data.pageX - offset.left, data.pageY - offset.top )
    item   = data.context.__itemAtPos( coord )

    # Find port
    if item
      fixed  = data.context.fixConnection( coord, data.startItem, item )
      if fixed
        toPort = fixed.toPort
        item   = fixed.target

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
