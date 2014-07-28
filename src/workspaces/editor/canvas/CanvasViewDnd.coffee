
define [ "./CanvasView", "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js" ], ( CanvasView, CanvasElement, constant, CanvasManager, lang )->

  ________visualizeOnMove = ()->
  ________visualizeBestfit = ()->

  ### env:dev ###
  ________visMove = ( data, excludeChild )->
    group = @__groupAtCoor @__localToCanvasCoor(data.pageX-data.zoneDimension.x1, data.pageY-data.zoneDimension.y1), excludeChild

    ItemClassProto = CanvasElement.getClassByType( data.dataTransfer.type ).prototype

    if (ItemClassProto.parentType || []).indexOf( if group then group.type else "SVG" ) is -1
      return

    dropPos = @__localToCanvasCoor(
      data.pageX - data.offsetX - data.zoneDimension.x1,
      data.pageY - data.offsetY - data.zoneDimension.y1
    )

    @__bestFitRect( {
      x1 : dropPos.x
      y1 : dropPos.y
      x2 : dropPos.x + if excludeChild then excludeChild.size().width  else ItemClassProto.defaultSize[0]
      y2 : dropPos.y + if excludeChild then excludeChild.size().height else ItemClassProto.defaultSize[1]
    }, group, excludeChild )

  ________visBestfit = ( bestFit, fits, colliders, alignEdges, detect )->
    svg = @svg

    if not $("#BestFitVis").length
      group = svg.group().attr({"id":"BestFitVis", "pointer-events":"none"}).style("fill-opacity", "0.5")
      group.node.instance = group
      svg.node.insertBefore(group.node, svg.node.childNodes[0])

    fitsvg = $("#BestFitVis")[0].instance.clear()

    for fit in fits || []
      fitsvg.add(
        svg.rect( (fit.x2 - fit.x1)*10, (fit.y2 - fit.y1)*10 ).move( fit.x1*10, fit.y1*10 ).style("fill", "#3498db").style("stroke","#333")
      )

    if bestFit
      fitsvg.add(
        svg.rect( (bestFit.x2 - bestFit.x1)*10, (bestFit.y2 - bestFit.y1)*10 ).move( bestFit.x1*10, bestFit.y1*10 ).style("fill", "#27ae60").style("stroke","#111")
      )

    colliders = colliders || []
    if not colliders.length then return

    fitsvg.add(
      svg.rect( (detect.x2 - detect.x1)*10, (detect.y2 - detect.y1)*10 ).move( detect.x1*10, detect.y1*10 ).style("fill", "#34495e")
    )

    for co in colliders
      x1 = co.x1 * 10
      x2 = co.x2 * 10
      y1 = co.y1 * 10
      y2 = co.y2 * 10

      fitsvg.add( svg.rect( x2 - x1, y2 - y1 ).move( x1, y1 ).style("fill", "#e67e22") )
      for aex1 in alignEdges.x1
        fitsvg.add( svg.rect( 2, y2 - y1 ).move( x2 - 1, y1 ).style("fill", "#222") ) if aex1 is co.x2
      for aex2 in alignEdges.x2
        fitsvg.add( svg.rect( 2, y2 - y1 ).move( x1 - 1, y1 ).style("fill", "#222") ) if aex2 is co.x1
      for aey1 in alignEdges.y1
        fitsvg.add( svg.rect( x2 - x1, 2 ).move( x1, y2 - 1 ).style("fill", "#222") ) if aey1 is co.y2
      for aey2 in alignEdges.y2
        fitsvg.add( svg.rect( x2 - x1, 2 ).move( x1, y1 - 1 ).style("fill", "#222") ) if aey2 is co.y1

    return

  # ________visualizeOnMove  = ________visMove
  # ________visualizeBestfit = ________visBestfit
  ### env:dev:end ###

  CanvasViewProto = CanvasView.prototype

  # Add item by dnd
  CanvasViewProto.__addItemDragOver = ( evt, data )->
    @__scrollOnDrag( data )

    group = @__groupAtCoor( @__localToCanvasCoor(data.pageX - data.zoneDimension.x1, data.pageY - data.zoneDimension.y1) )
    if group
      ItemClass  = CanvasElement.getClassByType( data.dataTransfer.type )
      parentType = ItemClass.prototype.parentType
      if not parentType or parentType.indexOf( group.type ) is -1
        group = null

    # HoverEffect
    if group isnt @__dragHoverGroup
      if @__dragHoverGroup
        CanvasManager.removeClass @__dragHoverGroup.$el, "droppable"
      if group
        CanvasManager.addClass group.$el, "droppable"
      @__dragHoverGroup = group

      # Fancy auto add subnet effect for instance
      data.shadow.toggleClass( "autoparent", !!(group and not ItemClass.isDirectParentType( group.type )) )

    ________visualizeOnMove.call this, data
    return

  CanvasViewProto.__addItemDragLeave = ()->
    @__clearDragScroll()

    if @__dragHoverGroup
      CanvasManager.removeClass @__dragHoverGroup.$el, "droppable"
      @__dragHoverGroup = null

  CanvasViewProto.__handleDropData = ( data, excludeChild, parentMustBeDirect )->

    if not data.zoneDimension then return ""

    ItemClass      = CanvasElement.getClassByType( data.dataTransfer.type )
    ItemClassProto = ItemClass.prototype

    group = @__groupAtCoor( @__localToCanvasCoor(
      data.pageX - data.zoneDimension.x1,
      data.pageY - data.zoneDimension.y1
    ), excludeChild )

    # See if the element can be dropped
    groupType = if group then group.type else "SVG"

    if ( parentMustBeDirect and not ItemClass.isDirectParentType( groupType ) ) or (ItemClassProto.parentType || []).indexOf( groupType ) is -1
      return @errorMessageForDrop( ItemClassProto.type ) || ""

    dropPos = @__localToCanvasCoor(
      data.pageX - data.offsetX - data.zoneDimension.x1,
      data.pageY - data.offsetY - data.zoneDimension.y1
    )

    dropRect =
      x1 : dropPos.x
      y1 : dropPos.y
      x2 : dropPos.x + data.itemWidth
      y2 : dropPos.y + data.itemHeight

    if group and not ItemClass.isDirectParentType( group.type )
      # If we need to auto add a parent, then we need to enlarge the drop rectangle.
      dropRect.x1 -= 2
      dropRect.y1 -= 2
      dropRect.x2 += 2
      dropRect.y2 += 2

    if not ItemClassProto.sticky
      # Caculate best drop rect for non-sticky item
      dropRect = @__bestFitRect( dropRect, group, excludeChild )
      if not dropRect then return lang.ide.CVS_MSG_WARN_NO_ENOUGH_SPACE

    {
      group    : group
      dropRect : dropRect
    }

  CanvasViewProto.__addItemDrop = ( evt, data )->
    ItemClass      = CanvasElement.getClassByType( data.dataTransfer.type )
    ItemClassProto = ItemClass.prototype

    data.itemWidth  = ItemClassProto.defaultSize[0]
    data.itemHeight = ItemClassProto.defaultSize[1]
    result = @__handleDropData( data )

    if _.isString( result )
      notification 'warning', result, false
      return

    # Create the model
    attributes = $.extend {
      x      : result.dropRect.x1
      y      : result.dropRect.y1
      width  : ItemClassProto.defaultSize[0]
      height : ItemClassProto.defaultSize[1]
    }, data.dataTransfer

    # Shrink drop rect if the item is a group
    if Design.modelClassForType( attributes.type ).prototype.node_group
      attributes.x += 1
      attributes.y += 1
      attributes.width  -= 2
      attributes.height -= 2

    delete attributes.type
    if result.group
      attributes.parent = result.group.model

    model = ItemClass.createResource( ItemClassProto.type, attributes, { createByUser : true } )
    if model and model.id
      self = @
      _.defer ()-> self.selectItem( model.id )
    return

  __parentBorderLimit = ( rect, parentRect )->
    r = $.extend {}, rect
    if rect.x1 <= parentRect.x1
      r.x2 -= rect.x1 - parentRect.x1 - 1
      r.x1  = parentRect.x1 + 1
    else if rect.x2 >= parentRect.x2
      r.x1 += parentRect.x2 - 1 - rect.x2
      r.x2  = parentRect.x2 - 1

    if rect.y1 <= parentRect.y1
      r.y2 -= rect.y1 - parentRect.y1 - 1
      r.y1  = parentRect.y1 + 1
    else if rect.y2 >= parentRect.y2
      r.y1 += parentRect.y2 - 1 - rect.y2
      r.y2  = parentRect.y2 - 1
    return r

  __isOverlap = ( rect1, rect2 )->
    not ( rect1.x1 >= rect2.x2 or rect1.x2 <= rect2.x1 or rect1.y1 >= rect2.y2 or rect1.y2 <= rect2.y1 )

  __isRectEmpty = ( rect, testArray )->
    for a in testArray
      if not ( rect.x1 >= a.x2 or rect.x2 <= a.x1 or rect.y1 >= a.y2 or rect.y2 <= a.y1 )
        return false
    true

  __isContain = ( subRect, parentRect )->
    parentRect.x1 <= subRect.x1 and parentRect.y1 <= subRect.y1 and parentRect.x2 >= subRect.x2 and parentRect.y2 >= subRect.y2

  __rectWidth  = ( rect )-> rect.x2 - rect.x1
  __rectHeight = ( rect )-> rect.y2 - rect.y1
  __expandRect = ( rect, dx, dy )->
    rect.x1 -= dx
    rect.x2 += dx
    rect.y1 -= dy
    rect.y2 += dy
    rect

  __findFits = ( rect, height, alignEdges, colliders )->
    fits = []
    for yyy in alignEdges.y1
      rect.y1 = yyy
      rect.y2 = yyy + height
      if __isRectEmpty( rect, colliders ) then fits.push $.extend({}, rect)

    for yyy in alignEdges.y2
      rect.y2 = yyy
      rect.y1 = yyy - height
      if __isRectEmpty( rect, colliders ) then fits.push $.extend({}, rect)

    fits

  CanvasViewProto.__bestFitRect = ( rect, group, item )->

    # Prepare
    if group
      children   = group.children()
      parentRect = group.rect()
    else
      children  = @__itemTopLevel.slice(0)
      parentRect = @canvasRect()
    idx = children.indexOf( item )
    if idx >= 0 then children.splice( idx, 1 )

    if item and item.isGroup()
      rect.x1 -= 1
      rect.y1 -= 1
      rect.x2 += 1
      rect.y2 += 1

    # Expand the detect area by 12 at most
    width  = __rectWidth( rect )
    height = __rectHeight( rect )
    halfW  = Math.round( width / 2 )
    halfH  = Math.round( height / 2 )
    if halfW > 12 then halfW = 12
    if halfH > 12 then halfH = 12

    # Detect Area
    orignalRect = __parentBorderLimit( rect, parentRect )
    rect        = __parentBorderLimit( __expandRect( rect, halfW, halfH ), parentRect )

    # Find colliders
    colliders    = []
    farColliders = []

    for ch in children
      bb = ch.rect()
      if __isOverlap( bb, orignalRect )
        colliders.push bb
      else if __isOverlap( bb, rect )
        farColliders.push bb

    # If the drop rect is occuplied by someone
    if not colliders.length
      if __isContain( orignalRect, parentRect )
        bestFit = orignalRect
    else
      colliders  = colliders.concat farColliders
      alignEdges =
        x1 : [ orignalRect.x1 ]
        x2 : [ orignalRect.x2 ]
        y1 : [ orignalRect.y1 ]
        y2 : [ orignalRect.y2 ]

      # Find possible edge to align
      for ch in colliders
        if ch.x1 - width  >= rect.x1 then alignEdges.x2.push(ch.x1)
        if ch.y1 - height >= rect.y1 then alignEdges.y2.push(ch.y1)
        if ch.x2 + width  <= rect.x2 then alignEdges.x1.push(ch.x2)
        if ch.y2 + height <= rect.y2 then alignEdges.y1.push(ch.y2)

      # Find possible drop rect
      fits = []
      ox   = orignalRect.x1
      oy   = orignalRect.y1
      for x1 in alignEdges.x1
        orignalRect.x1 = x1
        orignalRect.x2 = x1 + width
        fits = fits.concat __findFits( orignalRect, height, alignEdges, colliders )

      for x2 in alignEdges.x2
        orignalRect.x2 = x2
        orignalRect.x1 = x2 - width
        fits = fits.concat __findFits( orignalRect, height, alignEdges, colliders )

      # Get the closest drop rect.
      minDistance = 0
      for fit in fits
        if not __isContain( fit, parentRect ) then continue

        dis = Math.pow( fit.x1 - ox, 2 ) + Math.pow( fit.y1 - oy, 2 )
        if not bestFit or minDis > dis
          bestFit = fit
          minDis  = dis

    ________visualizeBestfit.call @, bestFit, fits, colliders, alignEdges, rect

    bestFit

  # Move item by dnd
  CanvasViewProto.__moveItemMouseDown = ( evt )->
    if evt.metaKey
      @__dragCanvasMouseDown( evt )
    else
      if not @isReadOnly()
        @dragItem( evt, { onDrop : __moveItemDidDrop, altState  : true } )
    false


  CanvasViewProto.dragItem = ( evt, options )->
    console.assert options.onDrop, "Drop handler is not specified."

    if evt.which isnt 1 then return false

    ###
     options = {
        altState : false
        onDrop   : ()->
     }
    ###
    $tgt = $( evt.currentTarget ).closest("g")
    if CanvasManager.hasClass( $tgt, "fixed" ) then return
    item = @getItem( $tgt.attr("data-id") )
    if not item then return

    @selectItem( $tgt[0] )

    canvasOffset = @$el.offset()

    options = $.extend options, {
      dropTargets  : $( "#OpsEditor .OEPanelCenter" )
      dataTransfer : { type : item.type }
      item         : item
      targetSvg    : $tgt[0].instance
      context      : @
      eventPrefix  : "moveItem_"
      noShadow     : true
      lockToCenter : false
      canvasX      : canvasOffset.left
      canvasY      : canvasOffset.top

      onDragStart : __moveItemStart
      onDrag      : __moveItemDrag
      onDragEnd   : __moveItemDrop
    }

    if item.sticky
      options.onDragStart = __moveStickyItemStart
      options.onDrag      = __moveStickyItemDrag
      options.onDragEnd   = __moveStickyItemDrop

    # ui.dnd will use the $tgt to calculate the offset of the item.
    # If the item is subnet, we might get a wrong offset.
    # In order to avoid that, we need to use the `rect.group` as $tgt.

    (if item.isGroup() then $tgt.children(".group") else $tgt).dnd( evt, options )
    false

  __moveItemStart = ( data )->
    svg           = data.context.svg
    targetSvg     = data.targetSvg.attr("id", "svgDragTarget")
    data.cloneSvg = svg.group().add(
      svg.use("svgDragTarget", true).move( -targetSvg.x(), -targetSvg.y() )
    )
    .classes("shadow")
    .move( targetSvg.x(), targetSvg.y() )

    if data.altState
      size = data.item.size()
      data.cloneSvg.add(
        svg.use("clone_indicator").move(
          size.width  * CanvasView.GRID_WIDTH  - 12,
          size.height * CanvasView.GRID_HEIGHT - 12
        ).classes("indicator").hide()
      )
    return

  __moveItemDrag = ( evt )->
    data = evt.data

    if not data.zoneDimension
      # The dragging is not within the canvas.
      return

    ctx = data.context

    # Drag Effects
    ctx.__scrollOnDrag( data )

    group = ctx.__groupAtCoor(
      ctx.__localToCanvasCoor( data.pageX - data.zoneDimension.x1, data.pageY - data.zoneDimension.y1 )
    , data.item )

    if group
      ItemClass  = CanvasElement.getClassByType( data.dataTransfer.type )
      parentType = ItemClass.prototype.parentType
      if not parentType or parentType.indexOf( group.type ) is -1 or not ItemClass.isDirectParentType( group.type )
        group = null

    # HoverEffect
    if group isnt ctx.__dragHoverGroup
      if ctx.__dragHoverGroup
        CanvasManager.removeClass ctx.__dragHoverGroup.$el, "droppable"
      if group
        CanvasManager.addClass group.$el, "droppable"
      ctx.__dragHoverGroup = group

    mousePos = data.context.__localToCanvasCoor(
      data.pageX - data.canvasX - data.offsetX,
      data.pageY - data.canvasY - data.offsetY
    )

    data.cloneSvg.move( mousePos.x * CanvasView.GRID_WIDTH, mousePos.y * CanvasView.GRID_HEIGHT )

    if data.altState
      data.cloneSvg.get(1)[ if evt.altKey then "show" else "hide" ]()

    ________visualizeOnMove.call ctx, data, data.item
    return

  __moveItemDrop = ( evt )->
    data = evt.data

    # Cleanup
    data.context.__addItemDragLeave()
    data.targetSvg.attr("id", "")
    if data.cloneSvg then data.cloneSvg.remove()

    # Drop
    size = data.item.size()
    data.itemWidth  = size.width
    data.itemHeight = size.height

    result = data.context.__handleDropData( data, data.item, true )
    if _.isString( result )
      if result is lang.ide.CVS_MSG_WARN_NO_ENOUGH_SPACE
        notification "warning", result
      return

    data.dataTransfer.item   = data.item
    data.dataTransfer.parent = result.group
    data.dataTransfer.x      = result.dropRect.x1
    data.dataTransfer.y      = result.dropRect.y1

    if data.item.isGroup()
      data.dataTransfer.x += 1
      data.dataTransfer.y += 1

    data.onDrop( evt, data.dataTransfer )
    return

  __moveItemDidDrop = ( evt, dataTransfer )->
    dataTransfer.item[ if evt.altKey then "cloneTo" else "changeParent" ]( dataTransfer.parent, dataTransfer.x, dataTransfer.y )
    return


  __moveStickyItemStart = ( evt )->

  __moveStickyItemDrag = ( evt )->
    data = evt.data

    if not data.zoneDimension
      # The dragging is not within the canvas.
      return

    ctx = data.context

    # Drag Effects
    ctx.__scrollOnDrag( data )

    mousePos = data.context.__localToCanvasCoor(
      data.pageX - data.canvasX - data.offsetX,
      data.pageY - data.canvasY - data.offsetY
    )

    data.item.ensureStickyPos( mousePos.x, mousePos.y )
    return

  __moveStickyItemDrop = ( evt )-> evt.data.context.__clearDragScroll()


  CanvasViewProto.__dragCanvasMouseDown = ( evt )->
    if not evt.metaKey or evt.which isnt 1 then return false

    scrollContent = @$el.children(":first-child")[0]

    $( document ).on({
      "mousemove.dragcanvas" : __canvasDrag
      "mousedown.dragcanvas" : __cancelCanvasDrag  # Any other user mouse event will cause the drop to be canceld.
      "mouseup.dragcanvas"   : __cancelCanvasDrag  # Any other user mouse event will cause the drop to be canceCanvasDrag
      "urlroute.dragcanvas"  : __cancelCanvasDrag
    }, {
      context    : @
      startX     : evt.pageX
      startY     : evt.pageY
      scrollLeft : scrollContent.scrollLeft
      scrollTop  : scrollContent.scrollTop

      overlay : $("<div id='overlayer' class='grabbing'></div>").appendTo( "body" )
    } )
    false

  __canvasDrag = ( evt )->
    data = evt.data
    data.context.$el.nanoScroller({ "scrollLeft" : data.scrollLeft - evt.pageX + data.startX })
    data.context.$el.nanoScroller({ "scrollTop"  : data.scrollTop  - evt.pageY + data.startY })
    false

  __cancelCanvasDrag = ( evt )->
    $( document ).off( ".dragcanvas" )
    evt.data.overlay.remove()
    false

  null
