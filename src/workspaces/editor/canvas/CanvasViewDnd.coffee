
define [ "./CanvasView", "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasView, CanvasElement, constant, CanvasManager, lang )->

  ________visualizeOnMove = ()->
  ________visualizeBestfit = ()->

  ### env:dev ###
  ________visMove = ( data )->
    group = @__groupAtCoor @__localToCanvasCoor(data.pageX-data.zoneDimension.x1, data.pageY-data.zoneDimension.y1)

    if group
      groupOffset = group.pos()
      groupSize   = group.size()
      groupRect =
        x1 : groupOffset.x
        y1 : groupOffset.y
        x2 : groupOffset.x + groupSize.width
        y2 : groupOffset.y + groupSize.height
      children = group.children()
    else
      groupRect =
        x1 : 5
        y1 : 3
        x2 : @size()[0] - 5
        y2 : @size()[1] - 3
      children = data.context.__itemTopLevel

    dropPos = @__localToCanvasCoor(
      data.pageX - data.offsetX - data.zoneDimension.x1,
      data.pageY - data.offsetY - data.zoneDimension.y1
    )

    @__bestFitRect( {
      x1 : dropPos.x
      y1 : dropPos.y
      x2 : dropPos.x + CanvasElement.getClassByType( data.dataTransfer.type ).prototype.defaultSize[0]
      y2 : dropPos.y + CanvasElement.getClassByType( data.dataTransfer.type ).prototype.defaultSize[1]
    }, groupRect, children )

  ________visBestfit = ( bestFit, detect, colliders, alignEdges, context )->
    svg = context.svg

    if not $("#BestFitVis").length
      group = svg.group().attr({
        "id":"BestFitVis",
        "pointer-events":"none"
      }).style("fill-opacity", "0.5")
      group.node.instance = group

    fitsvg = $("#BestFitVis")[0].instance.clear()

    if bestFit
      bestFit.x1 *= 10
      bestFit.x2 *= 10
      bestFit.y1 *= 10
      bestFit.y2 *= 10

      fitsvg.add(
        svg.rect( bestFit.x2 - bestFit.x1, bestFit.y2 - bestFit.y1 ).move( bestFit.x1, bestFit.y1 ).style("fill", "#27ae60")
      )

    if not detect
      return

    detect.x1 *= 10
    detect.x2 *= 10
    detect.y1 *= 10
    detect.y2 *= 10

    fitsvg.add(
      svg.rect( detect.x2 - detect.x1, detect.y2 - detect.y1 ).move( detect.x1, detect.y1 ).style("fill", "#3498db")
    )

    for co in colliders
      x1 = co.x1 * 10
      x2 = co.x2 * 10
      y1 = co.y1 * 10
      y2 = co.y2 * 10

      fitsvg.add(
        svg.rect( x2 - x1, y2 - y1 ).move( x1, y1 ).style("fill", "#f39c12")
      )
      for aex1 in alignEdges.x1
        if aex1 is co.x1
          fitsvg.add( svg.rect( 2, y2 - y1 ).move( x1 - 1, y1 ).style("fill", "#2c3e50") )
      for aex2 in alignEdges.x2
        if aex2 is co.x2
          fitsvg.add( svg.rect( 2, y2 - y1 ).move( x2 - 1, y1 ).style("fill", "#2c3e50") )
      for aey1 in alignEdges.y1
        if aey1 is co.y1
          fitsvg.add( svg.rect( x2 - x1, 2 ).move( x1, y1 - 1 ).style("fill", "#2c3e50") )
      for aey2 in alignEdges.y2
        if aey2 is co.y2
          fitsvg.add( svg.rect( x2 - x1, 2 ).move( x1, y2 - 1 ).style("fill", "#2c3e50") )

    return

  #________visualizeOnMove  = ________visMove
  #________visualizeBestfit = ________visBestfit
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
      data.shadow.toggleClass( "autoparent", group and not ItemClass.isDirectParentType( group.type ) )

    ________visualizeOnMove.call this, data
    return

  CanvasViewProto.__addItemDragLeave = ()->
    @__clearDragScroll()

    if @__dragHoverGroup
      CanvasManager.removeClass @__dragHoverGroup.$el, "droppable"
      @__dragHoverGroup = null

  CanvasViewProto.__handleDropData = ( data, excludeChild, parentMustBeDirect )->
    ItemClass      = CanvasElement.getClassByType( data.dataTransfer.type )
    ItemClassProto = ItemClass.prototype

    group = @__groupAtCoor( @__localToCanvasCoor(
      data.pageX - data.zoneDimension.x1,
      data.pageY - data.zoneDimension.y1
    ), excludeChild )

    # See if the element should be dropped
    parentType = ItemClassProto.parentType
    groupType  = if group then group.type else "SVG"

    if parentMustBeDirect and not ItemClass.isDirectParentType( groupType )
      return ""

    if parentType and parentType.indexOf( groupType ) is -1
      switch ItemClassProto.type
        when constant.RESTYPE.VOL       then return lang.ide.CVS_MSG_WARN_NOTMATCH_VOLUME
        when constant.RESTYPE.SUBNET    then return lang.ide.CVS_MSG_WARN_NOTMATCH_SUBNET
        when constant.RESTYPE.INSTANCE  then return lang.ide.CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET
        when constant.RESTYPE.ENI       then return lang.ide.CVS_MSG_WARN_NOTMATCH_ENI
        when constant.RESTYPE.RT        then return lang.ide.CVS_MSG_WARN_NOTMATCH_RTB
        when constant.RESTYPE.ELB       then return lang.ide.CVS_MSG_WARN_NOTMATCH_ELB
        when constant.RESTYPE.CGW       then return lang.ide.CVS_MSG_WARN_NOTMATCH_CGW
        when constant.RESTYPE.ASG       then return lang.ide.CVS_MSG_WARN_NOTMATCH_ASG
      return ""

    # Find best place to drop
    if group
      groupOffset = group.pos()
      groupSize   = group.size()
      groupRect =
        x1 : groupOffset.x
        y1 : groupOffset.y
        x2 : groupOffset.x + groupSize.width
        y2 : groupOffset.y + groupSize.height
      children = group.children()
      idx = children.indexOf( excludeChild )
      if idx >= 0 then children.splice( idx, 1 )
    else
      groupRect =
        x1 : 5
        y1 : 3
        x2 : @size()[0] - 5
        y2 : @size()[1] - 3

      children = []
      for type in ["CGW", "IGW", "VGW", "VPC"]
        children.push(@getItem(i.id)) for i in @design.componentsOfType( constant.RESTYPE[type] )

    dropPos = @__localToCanvasCoor(
      data.pageX - data.offsetX - data.zoneDimension.x1,
      data.pageY - data.offsetY - data.zoneDimension.y1
    )

    # If we need to auto add a parent, then we need to enlarge the drop rectangle.
    if group and not ItemClass.isDirectParentType( group.type )
      dropRect = {
        x1 : dropPos.x - 2
        y1 : dropPos.y - 2
        x2 : dropPos.x + data.itemWidth  + 4
        y2 : dropPos.y + data.itemHeight + 4
      }
    else
      dropRect = {
        x1 : dropPos.x
        y1 : dropPos.y
        x2 : dropPos.x + data.itemWidth
        y2 : dropPos.y + data.itemHeight
      }

    dropRect = @__bestFitRect(dropRect, groupRect, children )

    if not dropRect
      return "Not enough space."

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
      if result
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
    if rect.x1 <= parentRect.x1
      rect.x2 -= rect.x1 - parentRect.x1 - 1
      rect.x1  = parentRect.x1 + 1
    else if rect.x2 >= parentRect.x2
      rect.x1 += parentRect.x2 - 1 - rect.x2
      rect.x2  = parentRect.x2 - 1

    if rect.y1 <= parentRect.y1
      rect.y2 -= rect.y1 - parentRect.y1 - 1
      rect.y1  = parentRect.y1 + 1
    else if rect.y2 >= parentRect.y2
      rect.y1 += parentRect.y2 - 1 - rect.y2
      rect.y2  = parentRect.y2 - 1
    return rect

  __isOverlap = ( rect1, rect2 )->
    not ( rect1.x1 >= rect2.x2 or rect1.x2 <= rect2.x1 or rect1.y1 >= rect2.y2 or rect1.y2 <= rect2.y1 )

  __isRectEmpty = ( rect, testArray )->
    for a in testArray
      if not ( rect.x1 >= a.x2 or rect.x2 <= a.x1 or rect.y1 >= a.y2 or rect.y2 <= a.y1 )
        return false
    true

  __findBestFit = ( alignEdges, isRightEdge, xAttr, rect, colliders )->
    y1 = rect.y1
    y2 = rect.y2
    x1 = rect.x1
    x2 = rect.x2

    if isRightEdge
      if xAttr is null then return
      rect.x1 = xAttr
      rect.x2 = xAttr + rect.width
    else
      if xAttr is null then return
      rect.x2 = xAttr
      rect.x1 = xAttr - rect.width

    if __isRectEmpty( rect, colliders ) then return rect

    for yyy, idx in alignEdges.y2
      if yyy isnt null
        rect.y1 = yyy
        rect.y2 = yyy + rect.height
        if __isRectEmpty( rect, colliders ) then return rect

      rect.y2 = alignEdges.y1[ idx ]
      if rect.y2 isnt null
        rect.y1 = rect.y2 - rect.height
        if __isRectEmpty( rect, colliders ) then return rect

    rect.y1 = y1
    rect.y2 = y2
    rect.x1 = x1
    rect.x2 = x2
    null

  CanvasViewProto.__bestFitRect = ( rect, parentRect, children )->

    width  = rect.x2 - rect.x1
    height = rect.y2 - rect.y1

    if width >= parentRect.x2 - parentRect.x1 or height >= parentRect.y2 - parentRect.y1 then return null

    halfW  = Math.round( width / 2 )
    halfH  = Math.round( height / 2 )

    # Detect Area
    orignalRect = __parentBorderLimit( $.extend({}, rect), parentRect )
    rect.x1 -= halfW
    rect.x2 += halfW
    rect.y1 -= halfH
    rect.y2 += halfH
    rect     = __parentBorderLimit( rect, parentRect )

    # Find colliders
    available    = true
    colliders    = []
    farColliders = []

    for ch in children
      bb = ch.effectiveRect()

      if __isOverlap( bb, orignalRect )
        colliders.push bb
      else if __isOverlap( bb, rect )
        farColliders.push bb

    if not colliders.length
      ________visualizeBestfit( orignalRect, null, null, null, @ )
      return orignalRect

    colliders = colliders.concat farColliders

    alignEdges = {
      x1 : []
      x2 : []
      y1 : []
      y2 : []
    }
    # Find possible edge to align
    for ch in colliders
      alignEdges.x1.push if ch.x1 - width  >= rect.x1 then ch.x1 else null
      alignEdges.y1.push if ch.y1 - height >= rect.y1 then ch.y1 else null
      alignEdges.x2.push if ch.x2 + width  <= rect.x2 then ch.x2 else null
      alignEdges.y2.push if ch.y2 + height <= rect.y2 then ch.y2 else null

    # Find which best fit rect
    fit =
      x1     : orignalRect.x1
      y1     : orignalRect.y1
      x2     : orignalRect.x2
      y2     : orignalRect.y2
      width  : orignalRect.x2 - orignalRect.x1
      height : orignalRect.y2 - orignalRect.y1

    bestFit = __findBestFit( alignEdges, true, fit.x1, fit, colliders )
    if not bestFit
      i = 0
      while i < colliders.length
        bestFit = __findBestFit( alignEdges, true,  alignEdges.x2[i], fit, colliders )
        if bestFit
          break
        bestFit = __findBestFit( alignEdges, false, alignEdges.x1[i], fit, colliders )
        if bestFit
          break
        ++i

    ________visualizeBestfit( bestFit, rect, colliders, alignEdges, @ )
    return bestFit


  # Move item by dnd
  CanvasViewProto.__moveItemMouseDown = ( evt )->
    @dragItem( evt, {
      onDragEnd : __moveItemDrop
      altState  : true
    } )

  CanvasViewProto.dragItem = ( evt, options )->

    if evt.which isnt 1 then return false

    ###
     options = {
        altState : false
        onDrop   : ()->
     }
    ###
    $tgt = $( evt.currentTarget )
    if $tgt.hasClass("group") or $tgt.hasClass("fixed") then return

    $tgt = $tgt.closest("g")
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
      onDrop      : __moveItemDidDrop
    }
    $tgt.dnd( evt, options )
    false

  __moveItemStart = ( data )->
    svg           = data.context.svg
    targetSvg     = data.targetSvg.attr("id", "svgDragTarget")
    data.cloneSvg = svg.group().add(
      svg.use("svgDragTarget").move( -targetSvg.x(), -targetSvg.y() )
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

    data.cloneSvg.move(
      Math.round( mousePos.x ) * CanvasView.GRID_WIDTH,
      Math.round( mousePos.y ) * CanvasView.GRID_HEIGHT
    )

    if data.altState
      stateIcn = data.cloneSvg.get(1)
      if evt.altKey
        stateIcn.show()
      else
        stateIcn.hide()

    return

  __moveItemDrop = ( evt )->
    data = evt.data

    # Cleanup
    data.context.__addItemDragLeave()
    data.targetSvg.attr("id", "")
    if data.cloneSvg then data.cloneSvg.remove()

    # Drop
    # Offset the group by -10, -10. So that it will not be dropped overlapping the parent.
    size = data.item.size()
    data.itemWidth  = size.width
    data.itemHeight = size.height

    if data.item.isGroup()
      data.pageX      -= CanvasView.GRID_WIDTH
      data.pageY      -= CanvasView.GRID_HEIGHT
      data.itemWidth  += 2
      data.itemHeight += 2

    result = data.context.__handleDropData( data, data.item, true )
    if _.isString( result ) then return

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

  null
