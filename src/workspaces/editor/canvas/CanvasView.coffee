
define [
  "../template/TplOpsEditor"
  "./CanvasElement"
  "CanvasManager"
  "Design"
  "i18n!/nls/lang.js"
  "UI.modalplus"

  "backbone"
  "UI.nanoscroller"
  "svg"
], ( OpsEditorTpl, CanvasElement, CanvasManager, Design, lang, Modal )->

  # Insert svg defs template.
  $( OpsEditorTpl.svgDefs() ).appendTo("body")

  CanvasView = Backbone.View.extend {

    events :
      "click .icon-resize-down"  : "expandHeight"
      "click .icon-resize-up"    : "shrinkHeight"
      "click .icon-resize-right" : "expandWidth"
      "click .icon-resize-left"  : "shrinkWidth"
      "click .canvasel"          : "selectItemByClick"
      "click .line"              : "selectItemByClick"
      "click svg"                : "deselectItem"

      "addItem_dragover"  : "__addItemDragOver"
      "addItem_dragleave" : "__addItemDragLeave"
      "addItem_drop"      : "__addItemDrop"

      "mousedown .canvasel"    : "__moveItemMouseDown"
      "mousedown .group-label" : "__moveItemMouseDown"

      "mousedown .group-resizer" : "__resizeGroupDown"
      "mousedown .port"          : "__drawLineDown"

      "mouseenter .canvasel" : "__hoverEl"
      "mouseleave .canvasel" : "__hoverOutEl"

    initialize : ( options )->
      @workspace = options.workspace
      @design    = @workspace.design
      @parent    = options.parent

      @listenTo @design, Design.EVENT.Deserialized,   @reload
      @listenTo @design, Design.EVENT.AddResource,    @addItem
      @listenTo @design, Design.EVENT.RemoveResource, @removeItem

      @setElement @parent.$el.find(".OEPanelCenter")
      @svg = SVG( @$el.find("svg")[0] )
      canvasSize = @size()

      @__getCanvasView().css({
        width : canvasSize[0] * CanvasView.GRID_WIDTH
        height: canvasSize[1] * CanvasView.GRID_HEIGHT
      })

      @__scale = 1

      @$el.nanoScroller()

      @reload()
      return

    updateSize : ()->
      self = @
      setTimeout ()->
        self.$el.nanoScroller()
      , 150

    __appendSvg : ( svgEl, layer )->
      svgEl.node.instance = svgEl
      $( @svg.node ).children(layer).append( svgEl.node )
      svgEl

    __getCanvasView : ()-> @$el.children().children(".canvas-view")

    appendLine   : ( svgEl )-> @__appendSvg(svgEl, ".layer_line")
    appendNode   : ( svgEl )-> @__appendSvg(svgEl, ".layer_node")

    switchMode : ( mode )->
      console.assert( "stack app appedit".indexOf( mode ) >= 0 )
      @__getCanvasView().removeClass("stack app appedit").addClass( mode )
      return

    canvasRect : ()->
      s = @size()
      {
        x1 : 5
        y1 : 3
        x2 : s[0] - 5
        y2 : s[1] - 3
      }

    isRectAvailableForItem : ( subRect, item )->
      if item.parent()
        parentRect = item.parent().rect()
        children   = item.parent().children()
      else
        parentRect = @canvasRect()
        children   = @__itemTopLevel.slice(0)

      if parentRect.x1 >= subRect.x1 or parentRect.y1 >= subRect.y1 or parentRect.x2 <= subRect.x2 or parentRect.y2 <= subRect.y2
        return false

      for ch in children
        if ch is item then continue
        parentRect = ch.effectiveRect()
        if not ( parentRect.x1 >= subRect.x2 or parentRect.x2 <= subRect.x1 or parentRect.y1 >= subRect.y2 or parentRect.y2 <= subRect.y1 )
          return false

      true

    moveSelectedItem : ( deltaX, deltaY )->
      item = @getSelectedItem()
      if not item then return
      rect = item.effectiveRect()
      rect.x1 += deltaX
      rect.y1 += deltaY
      rect.x2 += deltaX
      rect.y2 += deltaY
      if @isRectAvailableForItem( rect, item )
        item.moveBy( deltaX, deltaY )
      return

    getSelectedItem : ()->
      if not @__selected then return null
      @getItem( @__selected.getAttribute("data-id") )

    delSelectedItem : ()-> @deleteItem( @getSelectedItem() )
    deleteItem : ( itemOrId )->
      if _.isString( itemOrId )
        itemOrId = @getItem( itemOrId )

      if not itemOrId then return
      itemOrId.destroy()

    selectPrevItem : ()->
      nodes =  $( @svg.node ).find(".canvasel:not(.group)")
      idx = if @__selected then [].indexOf.call( nodes, @__selected ) - 1 else null

      if idx is null or idx < 0
        idx = nodes.length - 1

      @selectItem nodes[ idx ]

    selectNextItem : ()->
      nodes =  $( @svg.node ).find(".canvasel:not(.group)")
      idx = if @__selected then [].indexOf.call( nodes, @__selected ) + 1 else null

      if idx is null or idx >= nodes.length
        idx = 0

      @selectItem nodes[ idx ]

    selectItem : ( elementOrId )->

      if _.isString( elementOrId )
        elementOrId = @getItem( elementOrId ).$el[0]

      if not elementOrId then return

      if @__selected
        CanvasManager.removeClass @__selected, "selected"
        @__selected = null

      @__selected = elementOrId
      CanvasManager.addClass @__selected, "selected"
      item = @getItem( @__selected.getAttribute("data-id") )
      item.select( @__selected )
      return

    selectItemByClick : ( evt )-> @selectItem( evt.currentTarget ); false
    deselectItem : ()->
      if @__selected
        CanvasManager.removeClass @__selected, "selected"
        @__selected = null
      return

    zoomOut : ()-> @zoom(  0.2 )
    zoomIn  : ()-> @zoom( -0.2 )

    zoom : ( delta )->
      scale = Math.round( (@__scale + delta) * 10 ) / 10
      if scale < 1 or scale > 1.6
        return

      @__scale = scale

      size = @size()
      realW = size[0] * CanvasView.GRID_WIDTH
      realH = size[1] * CanvasView.GRID_HEIGHT

      @__getCanvasView().css({
        width  : size[0] * CanvasView.GRID_WIDTH  / scale
        height : size[1] * CanvasView.GRID_HEIGHT / scale
      })
      .attr("data-scale", scale)
      .children("svg")[0].setAttribute( "viewBox", "0 0 #{realW} #{realH}" )

      @$el.nanoScroller()
      return

    size  : ()-> @design.get("canvasSize")
    scale : ()-> @__scale

    expandHeight : ()-> @resize( "height",  60 )
    shrinkHeight : ()-> @resize( "height", -60 )
    expandWidth  : ()-> @resize( "width",   60 )
    shrinkWidth  : ()-> @resize( "width",  -60 )
    resize : ( dimension, delta )->
      size  = @size()
      scale = @scale()

      size[ if dimension is "width" then 0 else 1 ] += delta

      wrapper = @__getCanvasView()

      realW = size[0] * CanvasView.GRID_WIDTH
      realH = size[1] * CanvasView.GRID_HEIGHT

      if delta > 0
        wrapper.children(".icon-resize-up, .icon-resize-left").show()
      else
        bbox = wrapper.children("svg")[0].getBBox()
        if bbox.width + bbox.x + 20 >= realW
          realW   = bbox.width + bbox.x + 20
          size[0] = realW / CanvasView.GRID_WIDTH
          wrapper.children(".icon-resize-left").hide()
        if bbox.height + bbox.y + 20 >= realH
          realH   = bbox.height + bbox.y + 20
          size[1] = realH / CanvasView.GRID_HEIGHT
          wrapper.children(".icon-resize-up").hide()

      @design.set("canvasSize", size)

      wrapper.css({
        width  : realW / scale
        height : realH / scale
      })
      .children("svg")[0].setAttribute( "viewBox", "0 0 #{realW} #{realH}" )

      @$el.nanoScroller()
      return

    reload : ()->
      console.log "Reloading svg canvas."

      @initializing = true

      @recreateStructure()

      @__itemMap = {}
      @__itemLineMap  = {}
      @__itemNodeMap  = {}
      @__itemTopLevel = []

      lines = []
      types = {}
      @design.eachComponent ( comp )->
        if comp.node_line
          lines.push comp
        else
          @addItem(comp)
        types[ comp.type ] = true
        return
      , @

      for t of types
        ItemClass = CanvasElement.getClassByType( t )
        if ItemClass and ItemClass.render
          ItemClass.render( this )

      @addItem(comp, true) for comp in lines

      @initializing = false
      return

    __batchAddLines : ()->
      for lineModel in @__toAddLines
        try
          @addItem( lineModel, true )
        catch e
          console.error e
      @__toAddLines = null
      return

    addItem : ( resourceModel, isScheduled )->
      ItemClass = CanvasElement.getClassByType( resourceModel.type )
      if not ItemClass then return
      if not resourceModel.isVisual() then return

      # Delay drawing the line until next event loop
      if resourceModel.node_line and not isScheduled
        if not @__toAddLines
          @__toAddLines = [ resourceModel ]
          self = @
          _.defer ()-> self.__batchAddLines()
        else
          @__toAddLines.push resourceModel
        return

      item = new ItemClass({
        model  : resourceModel
        canvas : @
      })

      if not item.cid then return

      @__itemMap[ resourceModel.id ] = item
      @__itemMap[ item.cid ] = item

      if resourceModel.parent and not resourceModel.parent()
        # Make sure group is after item.
        @__itemTopLevel[ if item.isGroup() then "push" else "unshift"]( item )

      if resourceModel.node_line
        @__itemLineMap[ item.cid ] = item
      else if not resourceModel.node_group
        @__itemNodeMap[ item.cid ] = item
      return

    removeItem : ( resourceModel )->
      item = @getItem( resourceModel.id )
      if not item then return

      if @getSelectedItem() is item
        @__selected = null
        # ide_event.trigger ide_event.OPEN_PROPERTY

      delete @__itemMap[ resourceModel.id ]
      delete @__itemMap[ item.cid ]
      delete @__itemLineMap[ item.cid ]
      delete @__itemNodeMap[ item.cid ]

      idx = @__itemTopLevel.indexOf( item )
      if idx >= 0 then @__itemTopLevel.splice( idx, 1 )

      item.remove()
      return

    getItem : ( id )-> @__itemMap[ id ]

    update : ()-> item.render() for id, item of @__itemNodeMap; return

    # Hover effect
    __hoverEl : ( evt )->
      item = @getItem( evt.currentTarget.getAttribute( "data-id" ) )
      if not item then return
      for cn in item.connections()
        CanvasManager.addClass cn.$el, "hover"
      return

    __hoverOutEl : ( evt )->
      item = @getItem( evt.currentTarget.getAttribute( "data-id" ) )
      if not item then return
      for cn in item.connections()
        CanvasManager.removeClass cn.$el, "hover"
      return

    # Find item by position
    __localToCanvasCoor : ( x, y )->
      sc = @$el.children(":first-child")[0]
      {
        x : Math.round( (x+sc.scrollLeft) / CanvasView.GRID_WIDTH  * @__scale )
        y : Math.round( (y+sc.scrollTop)  / CanvasView.GRID_HEIGHT * @__scale )
      }

    __itemAtPos : ( coord )->
      children = @__itemTopLevel
      context  = null

      while children
        chs      = children
        children = null

        for child in chs
          if not child.containPoint( coord.x, coord.y )
            continue

          if not child.isGroup() then return child

          context  = child
          children = child.children()
          break

      context

    __groupAtCoor : ( coord, excludeSubject )->

      children = @__itemTopLevel
      context  = null

      while children
        chs      = children
        children = null

        for child in chs
          if not child.isGroup()
            continue
          if child is excludeSubject
            continue
          if not child.containPoint( coord.x, coord.y )
            continue

          context  = child
          children = child.children()
          break

      context

    # Scroll on drag
    __clearDragScroll : ()->
      if @__dragScrollInt
        console.info "Removed drag scroll timer"
        clearInterval @__dragScrollInt
        @__dragScrollInt = null
      return

    __scrollOnDrag : ( data )->
      dimension     = data.zoneDimension
      if not dimension then return
      scrollContent = @$el.children(":first-child")[0]

      scrollLeft = scrollContent.scrollLeft
      scrollTop  = scrollContent.scrollTop

      DETECT_SIZE = 50
      SCROLL_SIZE = 10

      if data.pageX - dimension.x1 <= DETECT_SIZE
        if scrollLeft > SCROLL_SIZE
          continuous  = true
          scrollX = scrollLeft - SCROLL_SIZE
        else if scrollLeft > 0
          scrollX = "0"
      else if dimension.x2 - data.pageX <= DETECT_SIZE
        continuous = true
        scrollX = scrollLeft + SCROLL_SIZE


      if data.pageY - dimension.y1 <= DETECT_SIZE
        if scrollTop > SCROLL_SIZE
          continuous  = true
          scrollY = scrollTop - SCROLL_SIZE
        else if scrollTop > 0
          scrollY = "0"
      else if dimension.y2 - data.pageY <= DETECT_SIZE
        continuous = true
        scrollY = scrollTop + SCROLL_SIZE


      if scrollX isnt undefined
        @$el.nanoScroller({ scrollLeft : scrollX })
      if scrollY isnt undefined
        @$el.nanoScroller({ scrollTop : scrollY })


      if continuous
        if not @__dragScrollInt
          self = @
          console.info "Added drag scroll timer"
          @__dragScrollInt = setInterval ()->
            self.__scrollOnDrag( data )
          , 50
      else
        @__clearDragScroll()
      return

    ###
    # Connect lines ( Implemented in CanvasViewConnect )
    __drawLineDown : ( evt )->
    __connect : ( LineClass, comp1, comp2, startItem )->
    __popLineInitiator : ()->
    ###

    ###
    # Resize ( Implemented in CanvasViewGResizer )
    __resizeGroupDown : ( evt )->
    ###

    ###
    # Drop to add ( Implemented in CanvasViewDnd )
    dragItem : ()->
    __addItemDragOver : ( evt )->
    __addItemDragLeave : ( evt )->
    __addItemDrop : ( evt )->
    __bestFitRect : ()->
    __moveItemMouseDown : ( evt )->
    ###

  }, {
    GRID_WIDTH  : 10
    GRID_HEIGHT : 10
  }

  CanvasElement.setCanvasViewClass CanvasView

  CanvasView
