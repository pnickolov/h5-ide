
define [ "i18n!/nls/lang.js", "UI.modalplus", "backbone", "svgjs" ], ( lang, Modal )->

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

    initialize : ( options )->
      @canvas = options.canvas
      @$el = $()
      @addView( @create() )
      @render()
      return

    addView    : ( dom )->
      if not dom then return @
      @$el = @$el.add if dom.node then dom.node else dom
      @

    remvoeView : ( dom )->
      if not dom then return @
      if dom.node then dom = dom.node
      @$el = @$el.not dom
      $(dom).remove()
      @

    portDirection : ( portName )->
      if this.portDirMap then this.portDirMap[ portName ] else null

    portPosition : ( portName )->
      if this.portPosMap then this.portPosMap[ portName ] else null

    create : ()->
    render : ()->

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
        left : x * 10
        top  : y * 10
      }

    initNode : ( node, x, y )->
      node.move( x * CanvasView.GRID_WIDTH, y * CanvasView.GRID_HEIGHT )

      for child in node.children()
        cc = child.node
        if cc.tagName.toLowerCase() isnt "use" then continue

        name = child.attr("data-alias") or child.attr("data-name")
        if name
          pos = @portPosition( name )
          if pos
            child.move( pos[0], pos[1] )
      null

    createNode : ( option )->
      # A helper function to create a SVG Element to represent a group
      m = @model

      x      = m.x()
      y      = m.y()
      width  = m.width()  * CanvasView.GRID_WIDTH
      height = m.height() * CanvasView.GRID_HEIGHT

      svg = @canvas.svg
      el  = svg.group()

      el.add([
        svg.rect(width, height).radius(5).classes("node-background")
        svg.image( MC.IMG_URL + option.image, option.imageW, option.imageH ).move( option.imageX, option.imageY )
      ]).attr({ "data-id" : @cid }).classes( 'canvasel ' + @type.replace(/\./g, "-") )

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

        svg.rect( pad, pad ).classes("group-resizer topleft")
        svg.rect( pad, pad ).x(width - pad).classes('group-resizer topright')
        svg.rect( pad, pad ).y(height - pad).classes("group-resizer bottomleft")
        svg.rect( pad, pad ).move(width - pad, height - pad).classes("group-resizer bottomright")

        svg.text("").move(5,15).classes("group-label")
      ]).attr({ "data-id" : @cid }).classes("canvasel group " + @type.replace(/\./g, "-") )

    children : ()->
      if not @model.node_group
        return []

      canvas = @canvas
      @model.children().map ( childModel )->
        @canvas.getItem( childModel.id )

    # Canvas Interaction
    select  : ( selectedDomElement )->

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
        result = sprintf lang.ide.CVS_CFM_DEL_GROUP, name

      if _.isString( result )
        # Confirmation
        modal = new Modal {
          title     : sprintf lang.ide.CVS_CFM_DEL, name
          template  : result
          confirm   : { text : lang.ide.CFM_BTN_DELETE, color : "red" }
          onConfirm : ()->
            model.remove()
            modal.close()
            return
        }

      else if result.error
        # Error
        notification "error", result.error

      else if result is true
        # Do remove
        model.remove()
      return

    isDestroyable : ( selectedDomElement )->
      result = @model.isRemovable()
      if result isnt true then return result

      if @model.node_group
        for ch in @children()
          result = ch.isDestroyable()
          if result isnt true
            break

      result

    move : ( newX, newY, newParent )->

  }, {

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
    PORT_RIGHT_ANGLE  : 0
    PORT_UP_ANGLE     : 90
    PORT_LEFT_ANGLE   : 180
    PORT_DOWN_ANGLE   : 270

  CanvasElement.setCanvasViewClass = ( c )-> CanvasView = c; return

  CanvasElement
