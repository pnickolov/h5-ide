
define [ "./CanvasView", "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasView, CanvasElement, constant, CanvasManager, lang )->

  ###
  ________visualizeOnMove = ( data )->
    group = @__groupAtCoor( @__localToCanvasCoor(
      data.pageX - data.zoneDimension.x1,
      data.pageY - data.zoneDimension.y1
    ) )

    if group
      groupOffset = group.pos()
      groupSize   = group.size()
      groupRect =
        x1 : groupOffset.x
        y1 : groupOffset.y
        x2 : groupOffset.x + groupOffset.width
        y2 : groupOffset.y + groupOffset.height
      children = group.children()
    else
      groupRect =
        x1 : 5
        y1 : 3
        x2 : @size()[0] - 5
        y2 : @size()[1] - 3
      children = [].concat.apply [], ["CGW", "IGW", "VGW", "VPC"].map (type)=> @design.componentsOfType( constant.RESTYPE[ type ] )
      children = children.map (i)=> @getItem(i.id)

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

  ________visualizeBestfit = ( bestFit, detect, colliders, alignEdges, context )->
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
  ###

  CanvasViewProto = CanvasView.prototype

  # Add item by dnd
  CanvasViewProto.__addItemDragOver = ( evt, data )->
    @__scrollOnDrag( evt, data )

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

    #________visualizeOnMove.call this, data
    return

  CanvasViewProto.__addItemDragLeave = ( evt, data )->
    @__clearDragScroll()

    if @__dragHoverGroup
      CanvasManager.removeClass @__dragHoverGroup.$el, "droppable"
      @__dragHoverGroup = null

  CanvasViewProto.__addItemDrop = ( evt, data )->
    self           = @
    ItemClass      = CanvasElement.getClassByType( data.dataTransfer.type )
    ItemClassProto = ItemClass.prototype

    group = @__groupAtCoor( @__localToCanvasCoor( data.pageX - data.zoneDimension.x1, data.pageY - data.zoneDimension.y1 ) )

    # See if the element should be dropped
    parentType = ItemClassProto.parentType
    if parentType and parentType.indexOf( if group then group.type else "SVG" ) is -1
      switch ItemClassProto.type
        when constant.RESTYPE.VOL       then info = lang.ide.CVS_MSG_WARN_NOTMATCH_VOLUME
        when constant.RESTYPE.SUBNET    then info = lang.ide.CVS_MSG_WARN_NOTMATCH_SUBNET
        when constant.RESTYPE.INSTANCE  then info = lang.ide.CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET
        when constant.RESTYPE.ENI       then info = lang.ide.CVS_MSG_WARN_NOTMATCH_ENI
        when constant.RESTYPE.RT        then info = lang.ide.CVS_MSG_WARN_NOTMATCH_RTB
        when constant.RESTYPE.ELB       then info = lang.ide.CVS_MSG_WARN_NOTMATCH_ELB
        when constant.RESTYPE.CGW       then info = lang.ide.CVS_MSG_WARN_NOTMATCH_CGW
        when constant.RESTYPE.ASG       then info = lang.ide.CVS_MSG_WARN_NOTMATCH_ASG

      if info then notification 'warning', info , false
      return

    # Find best place to drop
    if group
      groupOffset = group.pos()
      groupSize   = group.size()
      groupRect =
        x1 : groupOffset.x
        y1 : groupOffset.y
        x2 : groupOffset.x + groupOffset.width
        y2 : groupOffset.y + groupOffset.height
      children = group.children()
    else
      groupRect =
        x1 : 5
        y1 : 3
        x2 : @size()[0] - 5
        y2 : @size()[1] - 3

      children = []
      children = children.concat.apply children, ["CGW", "IGW", "VGW", "VPC"].map (type)->
        self.design.componentsOfType( constant.RESTYPE[ type ] )
      children = children.map (i)-> self.getItem(i.id)

    dropPos = @__localToCanvasCoor(
      data.pageX - data.offsetX - data.zoneDimension.x1,
      data.pageY - data.offsetY - data.zoneDimension.y1
    )

    dropRect = @__bestFitRect({
      x1 : dropPos.x
      y1 : dropPos.y
      x2 : dropPos.x + ItemClassProto.defaultSize[0]
      y2 : dropPos.y + ItemClassProto.defaultSize[1]
    }, groupRect, children )

    if not dropRect
      notification "warning", "Not enough space.", false
      return

    # Create the model
    createOption = { createByUser : true }
    attributes   = $.extend {
      x : dropRect.x1 / CanvasView.GRID_WIDTH
      y : dropRect.y1 / CanvasView.GRID_HEIGHT
    }, data.dataTransfer
    delete attributes.type
    if group
      attributes.parent = group.model

    attributes.width  = ItemClassProto.defaultSize[0]
    attributes.height = ItemClassProto.defaultSize[1]

    model = ItemClass.createResource( ItemClassProto.type, attributes, createOption )

    if model
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
      #________visualizeBestfit( orignalRect, null, null, null, @ )
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

    #________visualizeBestfit( bestFit, rect, colliders, alignEdges, @ )
    return bestFit
  null
