
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

      "dragover"  : "__addItemDragOver"
      "dragleave" : "__addItemDragLeave"
      "drop"      : "__addItemDrop"

      "click .group-resizer" : "__resizeGroupDown"
      "mousedown .port"      : "__drawLineDown"

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
        height: canvasSize[1] * CanvasView.GRID_WIDTH
      })

      @__scale = 1

      @$el.nanoScroller()

      @reload()
      return

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
      .nanoScroller()
      .children("svg")[0].setAttribute( "viewBox", "0 0 #{realW} #{realH}" )

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
      .nanoScroller()
      .children("svg")[0].setAttribute( "viewBox", "0 0 #{realW} #{realH}" )
      return

    reload : ()->
      console.log "Reloading svg canvas."

      @initializing = true

      @svg.clear().add([
        @svg.group().classes("layer_vpc")
        @svg.group().classes("layer_az")
        @svg.group().classes("layer_subnet")
        @svg.group().classes("layer_line")
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

      @initializing = false

      for t of types
        ItemClass = CanvasElement.getClassByType( t )
        if ItemClass and ItemClass.render
          ItemClass.render( this )

      @addItem(comp, true) for comp in lines
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

    # Create Lines by dnd
    __drawLineDown : ( evt )->
      if evt.which isnt 1 then return false

      $port = $( evt.currentTarget )
      $tgt  = $port.closest("g")
      item  = @getItem( $tgt.attr( "data-id" ) )
      if not item then return

      # StartPos
      portName  = $port.attr("data-name")
      portAlias = $port.attr("data-alias")
      pos       = item.pos( $tgt[0] )
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

      scrollContent = @$el.children(":first-child")[0]

      $( document ).on({
        'mousemove.drawline' : @__drawLineMove
        'mouseup.drawline'   : @__drawLineUp
      }, {
        marker        : marker
        lineSvg       : lineSvg
        zoneDimension : dimension
        canvasScale   : @__scale
        context       : @
        highlightEls  : highlightEls
        scrollContent : scrollContent
        portName      : portName
        startItem     : item
        startPos      : pos
        pageX         : evt.pageX
        pageY         : evt.pageY
        startX        : evt.pageX + scrollContent.scrollLeft
        startY        : evt.pageY + scrollContent.scrollTop
        overlay       : $("<div></div>").appendTo( @$el ).css({
          "position" : "absolute"
          "left"     : "0"
          "top"      : "0"
          "bottom"   : "0"
          "right"    : "0"
        })
      })

      false

    __drawLineMove : ( evt )->
      data = evt.data
      data.pageX = evt.pageX
      data.pageY = evt.pageY
      data.context.__scrollOnDrag( evt, data )

      offsetX = ( data.pageX + data.scrollContent.scrollLeft - data.startX ) * data.canvasScale
      offsetY = ( data.pageY + data.scrollContent.scrollTop  - data.startY ) * data.canvasScale

      data.lineSvg.plot( data.startPos.x, data.startPos.y, data.startPos.x + offsetX, data.startPos.y + offsetY )
      false

    __drawLineUp : ( evt )->
      data = evt.data

      # Cleanup
      data.context.__clearDragScroll()
      data.marker.remove()
      data.lineSvg.remove()
      data.overlay.remove()
      $( document ).off(".drawline")

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

      # 2nd Cleanup
      for $el in data.highlightEls
        CanvasManager.removeClass $el, "connectable"

      # Connect
      if not item or not toPort then return

      C = Design.modelClassForPorts( data.portName, toPort )
      console.assert( C, "Cannot found Class for type: #{data.portName}>#{toPort}" )

      comp1 = data.startItem.model
      comp2 = item.model

      res = C.isConnectable( comp1, comp2 )

      if res is false then return
      if _.isString( res )
        notification "error", res
        return

      if res is true
        c = new C( comp1, comp2, undefined, { createByUser : true } )
        if c.id then _.defer ()-> data.context.selectItem( c.id )
        return

      if res.confirm
        self = @
        modal = new Modal {
          title    : res.title
          width    : "420"
          template : res.template
          confirm  : {text:res.action, color:"blue"}
          onConfirm  : ()->
            modal.close()
            c = new C( comp1, comp2, undefined, { createByUser : true } )
            if c.id then _.defer ()-> data.context.selectItem( c.id )
            return
        }
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
          , 100
      else
        @__clearDragScroll()
      return

    # Add item by dnd
    __addItemDragOver  : ( evt, data )->
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
      return

    __addItemDragLeave : ( evt, data )->
      @__clearDragScroll()

      if @__dragHoverGroup
        CanvasManager.removeClass @__dragHoverGroup.$el, "droppable"
        @__dragHoverGroup = null

    __addItemDrop : ( evt, data )->
      ItemClass = CanvasElement.getClassByType( data.dataTransfer.type )

      mousePos = @__localToCanvasCoor(
        data.pageX - data.zoneDimension.x1,
        data.pageY - data.zoneDimension.y1
      )

      dropPos = @__localToCanvasCoor(
        data.pageX - data.offsetX - data.zoneDimension.x1,
        data.pageY - data.offsetY - data.zoneDimension.y1
      )
      group       = @__groupAtCoor( mousePos )
      defaultSize = ItemClass.prototype.defaultSize

      groupType = if group then group.type else "SVG"

      # See if the element should be dropped
      parentType = ItemClass.prototype.parentType
      if parentType and parentType.indexOf( groupType ) is -1
        RT = constant.RESTYPE
        l  = lang.ide

        switch ItemClass.prototype.type
          when RT.VOL       then info = l.CVS_MSG_WARN_NOTMATCH_VOLUME
          when RT.SUBNET    then info = l.CVS_MSG_WARN_NOTMATCH_SUBNET
          when RT.INSTANCE  then info = l.CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET
          when RT.ENI       then info = l.CVS_MSG_WARN_NOTMATCH_ENI
          when RT.RT        then info = l.CVS_MSG_WARN_NOTMATCH_RTB
          when RT.ELB       then info = l.CVS_MSG_WARN_NOTMATCH_ELB
          when RT.CGW       then info = l.CVS_MSG_WARN_NOTMATCH_CGW
          when RT.ASG       then info = l.CVS_MSG_WARN_NOTMATCH_ASG

        if info then notification 'warning', info , false
        return

      if group and defaultSize
        groupOffset = group.pos()
        groupSize   = group.size()
        # If we drop near the edge of the group. Make sure the item is inside the group
        if groupOffset.x >= dropPos.x
          dropPos.x = groupOffset.x + 1
        else if groupOffset.x + groupSize.width <= dropPos.x + defaultSize[0]
          dropPos.x = groupOffset.x + groupSize.width - defaultSize[0] - 1
        if groupOffset.y  >= dropPos.y
          dropPos.y = groupOffset.y + 1
        else if groupOffset.y + groupSize.height <= dropPos.y + defaultSize[1]
          dropPos.y = groupOffset.y + groupSize.height - defaultSize[0] - 1

      # Find best position for the element
      dropPos = @__findEmptyDropPlace( dropPos, defaultSize, group )

      if not dropPos
        notification "warning", "Not enough space.", false
        return

      # Create attributes.
      createOption = { createByUser : true }
      attributes   = $.extend dropPos, data.dataTransfer
      delete attributes.type
      if group
        attributes.parent = group.model

      if defaultSize
        attributes.width  = defaultSize[0]
        attributes.height = defaultSize[1]


      model = ItemClass.createResource( ItemClass.prototype.type, attributes, createOption )

      if model
        self = @
        _.defer ()-> self.selectItem( model.id )
      return

    # Largest empty rectangle
    __findEmptyDropPlace : ( pos, size, group )->
      if not group then return pos
      return pos

      children = group.children()

      child = @__itemAtPos( pos, children )
      if not child
        if @__isRectEmpty( pos, size, children )
          return pos
        else
          return null

      # The position is occupied by someone else. Try offset to the left and top.
      childPos  = child.pos()
      childSize = child.size()
      childPos.x += childSize.width
      childPos.y += childSize.height
      if childPos.x - pos.x <= childPos.y - pos.y
        pos.x = childPos.x
      else
        pos.y = childPos.y

      if @__isRectEmpty( pos, size, children )
        return pos

      pos.x = childPos.x
      pos.y = childPos.y

      if @__isRectEmpty( pos, size, children )
        return pos

      null

    # Resize
    __resizeGroupDown : ( evt )->

  }, {
    GRID_WIDTH  : 10
    GRID_HEIGHT : 10
  }

  CanvasElement.setCanvasViewClass CanvasView

  CanvasView
