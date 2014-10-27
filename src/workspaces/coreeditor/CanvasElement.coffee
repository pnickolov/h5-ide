
define [
  "Design"
  "CanvasManager"
  "i18n!/nls/lang.js"
  "UI.modalplus"
  "backbone"
  "svg"
], ( Design, CanvasManager, lang, Modal )->

  CanvasView = null

  __detailExtend = Backbone.Model.extend
  ### env:dev ###
  __detailExtend = ( protoProps, staticProps )->
    ### jshint -W061 ###

    parent = this

    funcName = protoProps.ClassName || protoProps.type.split(".").pop()
    childSpawner = eval( "(function(a) { var #{funcName} = function(){ return a.apply( this, arguments ); }; return #{funcName}; })" )

    if protoProps and protoProps.hasOwnProperty "constructor"
      cstr = protoProps.constructor
    else
      cstr = ()-> return parent.apply( this, arguments )

    child = childSpawner( cstr )

    _.extend(child, parent, staticProps)

    funcName = "PROTO_" + funcName
    prototypeSpawner = eval( "(function(a) { var #{funcName} = function(){ this.constructor = a }; return #{funcName}; })" )

    Surrogate = prototypeSpawner( child )
    Surrogate.prototype = parent.prototype
    child.prototype = new Surrogate()

    if protoProps
      _.extend(child.prototype, protoProps)

    child.__super__ = parent.prototype
    ### jshint +W061 ###

    child
  ### env:dev:end ###


  SubElements = {}
  CanvasElement = Backbone.View.extend {

    # Override Backbone.View._ensureElement
    _ensureElement : ()->
      if not @$el
        @$el = $()
      return

    initialize : ( options )->
      @canvas = options.canvas
      @addView( @create() )
      @render()

      # Watch model's change
      @listenTo @model, "change:name", @render

      @listenModelEvents()

      @ensureStickyPos()
      return

    listenModelEvents : ()->

    addView    : ( dom )->
      if not dom then return @
      @$el = @$el.add if dom.node then dom.node else dom
      @delegateEvents()
      @

    removeView : ( dom )->
      if not dom then return @
      if dom.node then dom = dom.node
      @undelegateEvents()
      @$el = @$el.not dom
      $(dom).remove()
      @delegateEvents()
      @

    portDirection : ( portName )->
      if this.portDirMap then this.portDirMap[ portName ] else null

    portPosition : ( portName, isAtomic )->
      if not this.portPosMap then return null
      p = this.portPosMap[ portName ]
      if isAtomic and p.length >= 5
        return [ p[3], p[4], p[2] ]
      p

    isPortSignificant : ( portName )-> false

    hover    : ( evt )-> CanvasManager.addClass(cn.$el, "hover") for cn in @connections(); return
    hoverOut : ( evt )-> CanvasManager.removeClass(cn.$el, "hover") for cn in @connections(); return

    create : ()->
    render : ()->

    size : ()->
      if @model.width and @model.width()
        {
          width  : @model.width()
          height : @model.height()
        }
      else if @defaultSize
        {
          width  : @defaultSize[0]
          height : @defaultSize[1]
        }
      else
        bbox = @$el[0].getBBox()
        console.warn "Accessing CanvasElement's size by getBBox(), should implement defaultSize", @
        {
          width  : bbox.width
          height : bbox.height
        }

    pos : ( el )->
      x = @model.x()
      y = @model.y()

      if el
        el = el.parentNode
        while el
          elId = el.getAttribute("data-id")
          item = @canvas.getItem( elId )
          if item
            x += item.model.x()
            y += item.model.y()
          else
            break
          el = el.parentNode
      {
        x : x
        y : y
      }

    containPoint : ( px, py, includeStickyChildren )->
      testRects = [ @rect() ]

      if includeStickyChildren
        for i in @children( true )
          testRects.push i.rect() if i.sticky

      for rect in testRects
        if rect.x1 <= px and rect.y1 <= py and rect.x2 >= px and rect.y2 >= py
          return true

      false

    rect : ( el )->
      size = @size()
      pos  = @pos( el )

      {
        x1 : pos.x
        y1 : pos.y
        x2 : pos.x + size.width
        y2 : pos.y + size.height
      }

    effectiveRect : ()->
      rect = @rect()

      if @isGroup()
        rect.x1 -= 1
        rect.y1 -= 1
        rect.x2 += 1
        rect.y2 += 1

      rect

    ensureStickyPos : ( newX, newY )->
      if not @sticky then return

      size  = @size()
      prect = @parent().rect()

      constrain = ( v, v1, v2 )->
        return v1 if v <= v1
        return v2 if v >= v2
        v

      x = newX || @model.x()
      y = newY || @model.y()

      # If x,y < 0, it means auto layout
      if x < 0 then x = Math.round((prect.x2 - prect.x1 - size.width) / 2)
      if y < 0 then y = Math.round((prect.y2 - prect.y1 - size.height) / 2)

      x = constrain( x, prect.x1, prect.x2 - size.width )
      y = constrain( y, prect.y1, prect.y2 - size.height )

      switch @sticky
        when "left"   then x = prect.x1 - Math.round( size.width  / 2 )
        when "right"  then x = prect.x2 - Math.round( size.width  / 2 )
        when "top"    then y = prect.y1 - Math.round( size.height / 2 )
        when "bottom" then y = prect.y2 - Math.round( size.height / 2 )

      if @model.attributes.x is x and @model.attributes.y is y then return

      @model.attributes.x = x
      @model.attributes.y = y

      @$el[0].instance.move( x * CanvasView.GRID_WIDTH, y * CanvasView.GRID_HEIGHT )
      @updateConnections()
      return


    initNode : ( node, x, y )->
      node.move( x * CanvasView.GRID_WIDTH, y * CanvasView.GRID_HEIGHT )

      for child in node.children()
        cc = child.node
        if cc.tagName.toLowerCase() isnt "path" then continue

        name = child.attr("data-alias") or child.attr("data-name")
        if name
          pos = @portPosition( name )
          if pos
            child.move( pos[0], pos[1] )
      null

    createRawNode : ()->
      svg = @canvas.svg
      svg.group()
        .attr({ "data-id" : @cid })
        .classes( 'canvasel ' + @type.replace(/\.|:/g, "-") )
        .add([
          svg.rect(80,80).radius(16,16).classes('node-background')
          svg.text("").move(40, 90).classes('node-label')
        ])

    createNode : ( option )->
      # A helper function to create a SVG Element to represent a group
      m = @model

      size = @size()

      x      = m.x()
      y      = m.y()
      width  = size.width  * CanvasView.GRID_WIDTH
      height = size.height * CanvasView.GRID_HEIGHT

      svg = @canvas.svg
      el  = svg.group()

      el.add([
        svg.rect(width-1, height-1).move(0.5,0.5).radius(5).classes("node-background")
        svg.image( MC.IMG_URL + option.image, option.imageW, option.imageH ).move( option.imageX, option.imageY )
      ]).attr({ "data-id" : @cid }).classes( 'canvasel ' + @type.replace(/\.|:/g, "-") )

      if option.labelBg
        el.add( svg.use("label_path").classes("node-label-name-bg") )

      if option.label
        el.add( svg.plain(option.label).move( width/2, height-4 ).classes( "node-label" ) )

      if option.sg
        el.add(
          svg.group().add([
            svg.rect(7, 5).move(10, 6).classes('node-sg-color-border tooltip')
            svg.rect(7, 5).move(20, 6).classes('node-sg-color-border tooltip')
            svg.rect(7, 5).move(30, 6).classes('node-sg-color-border tooltip')
            svg.rect(7, 5).move(40, 6).classes('node-sg-color-border tooltip')
            svg.rect(7, 5).move(50, 6).classes('node-sg-color-border tooltip')
          ]).classes("node-sg-color-group").move(8,63)
        )

      el

    createGroup : ()->
      # A helper function to create a SVG Element to represent a group
      m = @model

      x      = m.x()
      y      = m.y()
      width  = m.width()  * CanvasView.GRID_WIDTH
      height = m.height() * CanvasView.GRID_HEIGHT

      pad = 10

      svg = @canvas.svg
      el  = svg.group()

      el.add([
        svg.rect(width, height).radius(5).classes("group")

        svg.rect( width - 2*pad, pad  ).x(pad).classes("group-resizer top")
        svg.rect( pad, height - 2*pad ).y(pad).classes("group-resizer left")
        svg.rect( pad, height - 2*pad ).move(width - pad, pad).classes("group-resizer right")
        svg.rect( width - 2*pad, pad  ).move(pad, height - pad).classes("group-resizer bottom")

        svg.rect( pad, pad ).classes("group-resizer top-left")
        svg.rect( pad, pad ).x(width - pad).classes('group-resizer top-right')
        svg.rect( pad, pad ).y(height - pad).classes("group-resizer bottom-left")
        svg.rect( pad, pad ).move(width - pad, height - pad).classes("group-resizer bottom-right")

        svg.text("").move(5,15).classes("group-label")
      ]).attr({ "data-id" : @cid }).classes("canvasel group " + @type.replace(/\.|:/g, "-") )

    label      : ()-> @model.get("name")
    labelWidth : ( width )-> (width || @size().width * CanvasView.GRID_WIDTH) - 8

    isGroup : ()-> !!@model.node_group

    # If true, it means the item is a children of the CeSvg
    isTopLevel : ()->
      if not @model.parent then return false
      if @model.parent() then return false

      true

    parent : ()->
      p = @model.parent()
      if p
        @canvas.getItem( p.id )
      else
        @canvas.getSvgItem()

    children : ( includeStickyChildren )->
      if not @model.node_group
        return []

      canvas = @canvas
      items  = []
      for ch in @model.children()
        i = canvas.getItem( ch.id )
        if not i then continue
        if i.sticky and not includeStickyChildren then continue
        items.push i

      items

    siblings : ( includeStickyChildren )->
      s = @parent().children( includeStickyChildren )
      idx = s.indexOf( this )
      if idx >= 0
        s.splice( idx, 1)
      s

    connections : ()->
      cnns = []
      for cn in @model.connections()
        cn = @canvas.getItem( cn.id )
        if cn and cn.node_line then cnns.push cn

      cnns

    isConnectable : ( fromPort, toId, toPort )->
      C = Design.modelClassForPorts( fromPort, toPort )
      if not C then return false

      p1Comp = @model
      p2Comp = @model.design().component(toId)

      # Don't allow connect to an resource that is already connected.
      for t in p1Comp.connectionTargets( C.prototype.type )
        if t is p2Comp
          return false

      C.isConnectable( p1Comp, p2Comp ) isnt false

    # Canvas Interaction
    select : ( selectedDomElement )->
      @canvas.triggerSelected @type, @model.id
      return

    destroy : ( selectedDomElement )->
      if @model.isRemoved()
        @$el.remove()
        @$el = $()
        return

      canvas = @canvas
      result = @isDestroyable()
      model  = @model
      name   = model.get("name")

      # Ask user to confirm to delete an non-empty group
      if result is true and model.node_group and model.children().length > 0
        result = sprintf lang.CANVAS.CVS_CFM_DEL_GROUP, name

      if _.isString( result )
        # Confirmation
        self  = @
        modal = new Modal {
          title     : sprintf lang.CANVAS.CVS_CFM_DEL, name
          template  : result
          confirm   : { text : lang.IDE.CFM_BTN_DELETE, color : "red" }
          onConfirm : ()->
            self.doDestroyModel()
            modal.close()
            return
        }

      else if result.error
        # Error
        notification "error", result.error

      else if result is true
        @doDestroyModel()
      return

    doDestroyModel : ()-> @model.remove()

    isDestroyable : ( selectedDomElement )->
      result = @model.isRemovable()
      if result isnt true then return result

      if @model.node_group
        for ch in @children()
          result = ch.isDestroyable()
          if result isnt true
            break

      result

    isClonable : ()-> !!@model.clone

    cloneTo : ( parent, x, y )->
      if not @model.clone then return

      # If the model supports clone() interface, then clone the target.
      name = @model.get("name")
      nameMatch = name.match /(.+-copy)(\d*)$/
      if nameMatch
        name = nameMatch[1] + ((parseInt(nameMatch[2],10) || 0) + 1)
      else
        name += "-copy"

      model = CanvasElement.getClassByType(@type).createResource( @type, {
        parent : parent.model,
        name   : name
        x      : x
        y      : y
      }, { cloneSource : @model })

      if model and model.id
        self = @
        _.defer ()-> self.canvas.selectItem( model.id )
      return


    changeParent : ( newParent, x, y )->

      if newParent is @parent() or newParent is null
        if @model.x() is x and @model.y() is y then return
        @moveBy( x - @model.x(), y - @model.y() )
        return

      # Do not support changing existing resource's parent.
      if @model.get("appId")
        notification "error", lang.NOTIFY.WARN_OPERATE_NOT_SUPPORT_YET
        return

      if not @parent() and newParent then return

      parentModel = newParent.model
      res = @model.isReparentable( parentModel )

      if _.isString( res )
        # Error
        notification "error", res
        return

      if res is true
        parentModel.addChild( @model )
        @moveBy( x - @model.x(), y - @model.y() )
      return

    moveBy : ( deltaX, deltaY )->
      if @isGroup()
        for ch in @children( true )
          ch.moveBy( deltaX, deltaY )

      deltaX += @model.x()
      deltaY += @model.y()
      @model.set { x : deltaX, y : deltaY }
      @$el[0].instance.move( deltaX * CanvasView.GRID_WIDTH, deltaY * CanvasView.GRID_HEIGHT )

      @updateConnections()
      return

    updateConnections : ()-> cn.update() for cn in @connections(); return

    applyGeometry : ( x, y, width, height, updateConnections = true )->
      if x isnt undefined or y isnt undefined
        @model.set { x : x, y : y }
        @$el[0].instance.move( x * CanvasView.GRID_WIDTH, y * CanvasView.GRID_HEIGHT )

      if @isGroup() and width isnt undefined and height isnt undefined
        @model.set { width : width, height : height }

        # ensure sticky
        for ch in @children( true )
          if ch.sticky then ch.ensureStickyPos()

      width  = ( width  || @model.get("width")  ) * CanvasView.GRID_WIDTH
      height = ( height || @model.get("height") ) * CanvasView.GRID_HEIGHT

      pad  = 10
      pad2 = 20

      ports = []

      for ch in @$el[0].instance.children()

        classes = ch.classes()

        if classes.indexOf("group") >= 0
          ch.size( width, height )
        else if classes.indexOf("top") >= 0
          ch.size( width - pad2, pad  ).x(pad)
        else if classes.indexOf("left") >= 0
          ch.size( pad, height - pad2 ).y(pad)
        else if classes.indexOf("right") >= 0
          ch.size( pad, height - pad2 ).move(width - pad, pad)
        else if classes.indexOf("bottom") >= 0
          ch.size( width - pad2, pad  ).move(pad, height - pad)
        else if classes.indexOf("top-right") >= 0
          ch.x(width - pad)
        else if classes.indexOf("bottom-left") >= 0
          ch.y(height - pad)
        else if classes.indexOf("bottom-right") >= 0
          ch.move(width - pad, height - pad)
        else if classes.indexOf("port") >= 0
          ports.push ch
        else if classes.indexOf("group-label") >= 0
          CanvasManager.setLabel( @, ch.node )

      # Update groups port
      for p in ports
        name = p.attr("data-alias") or p.attr("data-name")
        if name
          pos = @portPosition( name )
          if pos then p.move( pos[0], pos[1] )

      if updateConnections
        cn.update() for cn in @connections()
      return

  }, {

    isDirectParentType : ( type )-> true

    createResource : ( type, attributes, options )->
      Model = Design.modelClassForType type
      new Model( attributes, options )

    getClassByType : ( type )-> SubElements[ type ]

    extend : ( protoProps, staticProps ) ->
      console.assert protoProps.type, "Subclass of CanvasElement does not specifying a type"

      staticProps = staticProps || {}
      staticProps.type = protoProps.type

      # Create subclass
      subClass = __detailExtend.call( this, protoProps, staticProps )

      SubElements[ protoProps.type ] = subClass
      subClass
  }

  CanvasElement.constant =
    PORT_4D_ANGLE    : -1
    PORT_2D_H_ANGLE  : -2
    PORT_2D_V_ANGLE  : -3
    PORT_RIGHT_ANGLE : 0
    PORT_UP_ANGLE    : 90
    PORT_LEFT_ANGLE  : 180
    PORT_DOWN_ANGLE  : 270

  CanvasElement.setCanvasViewClass = ( c )-> CanvasView = c; return

  CanvasElement
