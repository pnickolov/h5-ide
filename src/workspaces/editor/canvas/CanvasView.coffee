
define [
  "../template/TplOpsEditor"
  "./CanvasElement"
  "CanvasManager"
  "Design"
  "constant"
  "i18n!/nls/lang.js"
  "UI.modalplus"

  "backbone"
  "UI.nanoscroller"
  "svg"
], ( OpsEditorTpl, CanvasElement, CanvasManager, Design, constant, lang, Modal )->

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

    appendVpc    : ( svgEl )-> @__appendSvg(svgEl, ".layer_vpc")
    appendAz     : ( svgEl )-> @__appendSvg(svgEl, ".layer_az")
    appendSubnet : ( svgEl )-> @__appendSvg(svgEl, ".layer_subnet")
    appendLine   : ( svgEl )-> @__appendSvg(svgEl, ".layer_line")
    appendNode   : ( svgEl )-> @__appendSvg(svgEl, ".layer_node")
    appendAsg    : ( svgEl )-> @__appendSvg(svgEl, ".layer_asg")
    appendSgline : ( svgEl )-> @__appendSvg(svgEl, ".layer_sgline")

    switchMode : ( mode )->
      console.assert( "stack app appedit".indexOf( mode ) >= 0 )
      @__getCanvasView().removeClass("stack app appedit").addClass( mode )
      return

    moveSelectedItem : ( deltaX, deltaY )->
      item = @getSelectedItem()
      if not item then return
      pos = item.pos()
      item.move( pos.x + deltax, pos.y + deltaY )

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

    expandHeight : ()-> @resize( "height", 60  )
    shrinkHeight : ()-> @resize( "height", -60 )
    expandWidth  : ()-> @resize( "width",  60  )
    shrinkWidth  : ()-> @resize( "width", -60  )
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

      @svg.clear().add([
        @svg.group().classes("layer_vpc")
        @svg.group().classes("layer_az")
        @svg.group().classes("layer_line")
        @svg.group().classes("layer_subnet")
        @svg.group().classes("layer_asg")
        @svg.group().classes("layer_sgline")
        @svg.group().classes("layer_node")
      ])

      @__itemMap = {}
      @__itemGroupMap = {}
      @__itemLineMap  = {}
      @__itemNodeMap  = {}

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

      if resourceModel.node_line
        @__itemLineMap[ item.cid ] = item
      else if resourceModel.node_group or resourceModel.type is constant.RESTYPE.ASG
        @__itemGroupMap[ item.cid ] = item
      else
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
      delete @__itemGroupMap[ item.cid ]
      delete @__itemNodeMap[ item.cid ]
      item.remove()
      return

    getItem : ( id )-> @__itemMap[ id ]

    update : ()->
      for id, item of @__itemNodeMap
        item.render()
      return

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
    __itemAtPos : ( x, y )->
      self = @
      children = []
      children = children.concat.apply children, ["CGW", "IGW", "VGW", "VPC"].map (type)->
        self.design.componentsOfType( constant.RESTYPE[ type ] )

      context = null

      while children
        chs      = children
        children = null

        for child in chs
          childItem = @getItem( child.id )
          if not childItem then continue

          childPos  = childItem.pos()
          childSize = childItem.size()

          if childPos.x <= x and
             childPos.y <= y and
             childPos.x + childSize.width >= x and
             childPos.y + childSize.height >= y

            if not childItem.isGroup()
              return childItem

            context  = @getItem( child.id )
            children = childItem.model.children()
            break

      context

    __itemAtPosForConnect : ( x, y )->
      item = @__itemAtPos( x, y )
      if not item then return
      if item.type isnt constant.RESTYPE.AZ then return item

      # Enlarge subnet area.
      for subnet in item.children()
        childPos  = subnet.pos()
        childSize = subnet.size()
        childPos.x      -= 2
        childSize.width += 4

        if childPos.x <= x and
           childPos.y <= y and
           childPos.x + childSize.width >= x and
           childPos.y + childSize.height >= y

          return subnet
      item

    __localToCanvasCoor : ( x, y )->
      sc = @$el.children(":first-child")[0]
      {
        x : Math.round( (x+sc.scrollLeft) / CanvasView.GRID_WIDTH  * @__scale )
        y : Math.round( (y+sc.scrollTop)  / CanvasView.GRID_HEIGHT * @__scale )
      }

    __groupAtCoor : ( coord )->
      group = null

      for id, item of @__itemGroupMap
        if not item.model.width then continue

        x = item.model.x()
        y = item.model.y()
        w = item.model.width()
        h = item.model.height()

        if coord.x >= x and coord.y >= y and coord.x <= x+w and coord.y <= y + h
          if not group or group.model.width() > w and group.model.height() > h
            group = item

      group

    # Scroll on drag
    __clearDragScroll : ()->
      if @__dragScrollInt
        console.info "Removed drag scroll timer"
        clearInterval @__dragScrollInt
        @__dragScrollInt = null
      return

    __scrollOnDrag : ( evt, data )->
      dimension     = data.zoneDimension
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
            self.__scrollOnDrag( evt, data )
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
    __addItemDragOver : ( evt )->
    __addItemDragLeave : ( evt )->
    __addItemDrop : ( evt )->
    ###

  }, {
    GRID_WIDTH  : 10
    GRID_HEIGHT : 10
  }

  CanvasElement.setCanvasViewClass CanvasView

  CanvasView
