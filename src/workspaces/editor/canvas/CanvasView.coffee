
define [
  "../template/TplOpsEditor"
  "./CanvasElement"
  "CanvasManager"
  "Design"
  "constant"

  "backbone"
  "UI.nanoscroller"
  "svgjs"
], ( OpsEditorTpl, CanvasElement, CanvasManager, Design, constant )->

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

      "dragover"  : "__addItemDragOver"
      "dragleave" : "__addItemDragLeave"

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
      if @__selected
        CanvasManager.removeClass @__selected, "selected"
        @__selected = null

      if _.isString( elementOrId )
        elementOrId = @getItem( elementOrId ).$el[0]

      @__selected = elementOrId
      CanvasManager.addClass @__selected, "selected"
      item = @getItem( @__selected.getAttribute("data-id") )
      item.select( @__selected )
      return

    selectItemByClick : ( evt )-> @selectItem( evt.currentTarget ); false

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

      @addItem(comp) for comp in lines
      return

    addItem : ( resourceModel )->
      ItemClass = CanvasElement.getClassByType( resourceModel.type )
      if not ItemClass then return

      if resourceModel.isVisual()
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

    __addItemDragOver  : ( evt, data )->
      @__scrollOnDrag( evt, data )

      group = @__groupAtCoor( @__localToCanvasCoor(data.pageX - data.zoneDimension.x1, data.pageY - data.zoneDimension.y1) )
      if group
        pg = CanvasView.PARENT_TYPE[ data.dataTransfer.type ]
        if not pg or pg.indexOf( group.type ) is -1
          group = null

      if group isnt @__dragHoverGroup
        if @__dragHoverGroup
          CanvasManager.removeClass @__dragHoverGroup.$el, "droppable"
        if group
          CanvasManager.addClass group.$el, "droppable"
        @__dragHoverGroup = group

    __addItemDragLeave : ( evt, data )->
      @__clearDragScroll()

      if @__dragHoverGroup
        CanvasManager.removeClass @__dragHoverGroup.$el, "droppable"
        @__dragHoverGroup = null


  }, {
    GRID_WIDTH  : 10
    GRID_HEIGHT : 10
    PARENT_TYPE : {
      'AWS.EC2.AvailabilityZone' : ['AWS.VPC.VPC']
      'AWS.VPC.RouteTable'       : ['AWS.VPC.VPC']
      'AWS.ELB'                  : ['AWS.VPC.VPC']

      'AWS.VPC.Subnet'           : ['AWS.EC2.AvailabilityZone']
      'AWS.AutoScaling.Group'    : ['AWS.VPC.Subnet']
      'AWS.VPC.NetworkInterface' : ['AWS.VPC.Subnet']
      'AWS.EC2.Instance'         : ['AWS.AutoScaling.Group', 'AWS.VPC.Subnet']
    }
  }

  CanvasElement.setCanvasViewClass CanvasView

  CanvasView
