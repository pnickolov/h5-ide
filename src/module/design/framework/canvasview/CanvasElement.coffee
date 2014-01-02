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
    if (w is undefined or w is null) and (h is undefined or h is null)
      attr = Design.instance().component( this.id ).attributes
      return [ attr.width, attr.height ]

    if @nodeType is "group"
      CanvasManager.resize( this.id, w, h )
    null


  CanvasElement.prototype.position = ( x, y )->
    if (x is undefined or x is null) and (y is undefined or y is null)
      attr = Design.instance().component( this.id ).attributes
      return [ attr.x, attr.y ]

    CanvasManager.move( this.id, x, y )
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

  CanvasElement.prototype.hover = ()->
    comp = Design.instance().component( this.id )
    connections = comp.connections()

    for cn in connections
      el = document.getElementById( cn.id )
      if not el
        continue

      CanvasManager.addClass( el, "view-hover" )
    null

  CanvasElement.prototype.hoverOut = ()->
    comp = Design.instance().component( this.id )
    connections = comp.connections()

    for cn in connections
      el = document.getElementById( cn.id )
      if not el
        continue

      CanvasManager.removeClass( el, "view-hover" )
    null

  CanvasElement.prototype.parent  = ()->
    if this.parent is undefined
      this.parent = if this.parentId then new CanvasElement( Design.instance().component( this.parentId ) ) else null

    this.parent

  CanvasElement.prototype.changeParent = ( parentId, x, y )->

    if parentId is "canvas" then parentId = ""

    if this.parentId is parentId
      this.position( x, y )
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
      this.position( x, y )
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
