define [ "CanvasManager", "event" ], ( CanvasManager, ide_event )->

  Design = null

  ###
  CanvasElement is intent to be an adaptor for MC.canvas.js to use ResourceModel.
  But in the future, this class can be upgrade to ResourceModel's view on canvas.
  ###

  CanvasElement = ( component, quick )->

    this.id = component.id

    if quick isnt true
      this.type = @element().getAttribute("data-class") or component.type

      this.nodeType   = if component.node_group is true then "group" else if component.node_line then "line" else "node"

      this.parentId = component.parent()
      this.parentId = if this.parent then "" else this.parentId.id

    this

  CanvasElement.prototype.element = ()->
    if not this.el
      this.el = document.getElementById( this.id )

    this.el

  CanvasElement.prototype.$element = ()->
    if not this.$el
      this.$el = $( document.getElementById( this.id ) )

    this.$el

  CanvasElement.prototype.size = ( w, h )->

    component = Design.instance().component( this.id )

    if (w is undefined or w is null) and (h is undefined or h is null)
      attr = Design.instance().component( this.id ).attributes
      return [ attr.width, attr.height ]

    if @nodeType isnt "group" then return

    oldw = component.attributes.width
    oldh = component.attributes.height

    if w is null or w is undefined then w = oldw
    if h is null or h is undefined then h = oldh

    if w is oldw and h is oldh then return

    component.set {
      width  : w
      height : h
    }

    CanvasManager.size document.getElementById( this.id ), w, h, oldw, oldh
    null


  CanvasElement.prototype.position = ( x, y )->

    component = Design.instance().component( this.id )

    if (x is undefined or x is null) and (y is undefined or y is null)
      attr = component.attributes
      return [ attr.x, attr.y ]

    # Update data, svg
    oldx = component.attributes.x
    oldy = component.attributes.y

    if x is null or x is undefined then x = oldx
    if y is null or y is undefined then y = oldy

    if x is oldx and y is oldy then return

    component.set {
      x : x
      y : y
    }

    MC.canvas.position( document.getElementById( @id ), x, y )
    null


  CanvasElement.prototype.offset = ()->
    this.element().getBoundingClientRect()

  CanvasElement.prototype.port = ()->
    if not this.ports
      this.ports = _.map this.$element().children(".port"), ( el )->
        el.getAttribute("data-name")

    this.ports

  CanvasElement.prototype.isConnectable = ( fromPort, toId, toPort )->
    design = Design.instance()

    C = Design.modelClassForPorts( fromPort, toPort )
    C and C.isConnectable( design.component(@id), design.component(toId) )

  CanvasElement.prototype.remove = ()->
    comp = Design.instance().component( this.id )
    if comp.isRemoved() then return

    res = comp.isRemovable()

    if _.isString( res )
      # Confirmation
      template = MC.template.canvasOpConfirm {
        operation : sprintf lang.ide.CVS_CFM_DEL, comp.get("name")
        content   : res
        color     : "red"
        proceed   : lang.ide.CFM_BTN_DELETE
        cancel    : lang.ide.CFM_BTN_CANCEL
      }
      modal template, true
      theID = this.id

      $("#canvas-op-confirm").one "click", ()->
        comp = Design.instance().component( theID )
        if comp and not comp.isRemoved()
          comp.remove()
          ide_event.trigger ide_event.OPEN_PROPERTY

    else if res.error
      # Error
      notification "error", res.error

    else if res is true
      # Do remove
      comp.remove()
      ide_event.trigger ide_event.OPEN_PROPERTY
      return true

    return false

  # Update Lines
  CanvasElement.prototype.reConnect = ()->
    for cn in Design.instance().component( this.id ).connections()
      if cn.get("lineType")
        cn.draw()
    null

  CanvasElement.prototype.select = ()->
    ide_event.trigger ide_event.OPEN_PROPERTY, this.type, this.id
    MC.canvas.select( this.id )
    true

  CanvasElement.prototype.show = ()->
    CanvasManager.toggle this.$element(), true
    null

  CanvasElement.prototype.hide = ()->
    CanvasManager.toggle this.$element(), false
    null

  CanvasElement.prototype.connection = ()->
    comp = Design.instance().component( this.id )
    connections = comp.connections()

    cns = []

    for cn in connections
      if cn.get("lineType")
        cns.push {
          line   : cn.id
          target : this.id
          port   : cn.port( this.id, "name" )
        }
    cns

  CanvasElement.prototype.parent  = ()->
    if this.parent is undefined
      this.parent = if this.parentId then new CanvasElement( Design.instance().component( this.parentId ) ) else null

    this.parent

  CanvasElement.prototype.changeParent = ( parentId, execCB )->

    if parentId is "canvas" then parentId = ""

    if this.parentId is parentId
      execCB.call( this )
      return false

    parent = Design.instance().component( parentId )
    if not parent
      console.warn( "Cannot find parent when changing parent" )
      return false

    child = Design.instance().component( this.id )
    res   = child.isReparentable( parent )

    parentComp = Design.instance().component( this.id )
    res = childComp.isReparentable( parentComp )

    if _.isString( res )
      # Error
      notification "error", res

    else if res is true
      parent.addChild( child )
      execCB.call( this )
      return true

    return false

  CanvasElement.prototype.children = ()->
    _.map Design.instance().component( this.id ).children() || [], ( c )->
        new CanvasElement( c )

  CanvasElement.line = ( component )->
    this.id   = component.id
    this.type = component.get("lineType")
    @id

  CanvasElement.line.prototype.portName = ( targetId )->
    Design.instance().component( this.id ).port( targetId, "name" )

  CanvasElement.line.prototype.reConnect = ()->
    Design.instance().component( this.id ).draw()
    null

  CanvasElement.line.prototype.select = ()->
    MC.canvas.select( this.id )
    ide_event.trigger ide_event.OPEN_PROPERTY, Design.instance().component( this.id ).type, this.id

  CanvasElement.line.prototype.remove   = CanvasElement.prototype.remove
  CanvasElement.line.prototype.element  = CanvasElement.prototype.element
  CanvasElement.line.prototype.$element = CanvasElement.prototype.$element

  CanvasElement.setDesign = ( design )->
    Design = design
    null

  CanvasElement
