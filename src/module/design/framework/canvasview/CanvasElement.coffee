define [ "CanvasManager", "event", "constant", "i18n!nls/lang.js" ], ( CanvasManager, ide_event, constant, lang )->

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

      p = component.parent()
      this.parentId = if p then p.id else ""

    this

  CanvasElement.prototype.element = ()->
    if not this.el
      this.el = document.getElementById( this.id )

    this.el

  CanvasElement.prototype.$element = ()->
    if not this.$el
      this.$el = $( document.getElementById( this.id ) )

    this.$el

  CanvasElement.prototype.move = ( x, y )->
    pos = @position()
    if pos.x is x and pos.y is y then return

    MC.canvas.move( this.element(), x, y )


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

    # CanvasManager.size this.element(), w, h, oldw, oldh
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

    MC.canvas.position( this.element(), x, y )
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

    if not C then return false

    p1Comp = design.component(@id)
    p2Comp = design.component(toId)

    # Don't allow connect to an resource that is already connected.
    for t in p1Comp.connectionTargets( C.prototype.type )
      if t is p2Comp
        return false

    C.isConnectable( p1Comp, p2Comp ) isnt false

  CanvasElement.prototype.isRemovable = ()->
    res = Design.instance().component( @id ).isRemovable()
    if res isnt true then return res

    # If the object is ASG, we consider it as an node
    # Doesn't check its children.
    if @nodeType is "group" and @type isnt constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
      for ch in @children()
        res = ch.isRemovable()
        if res isnt true
          break

    res

  CanvasElement.prototype.remove = ()->
    comp = Design.instance().component( this.id )
    if comp.isRemoved() then return

    res = @isRemovable()
    comp_name = comp.get("name")

    # Ask user to confirm to delete an non-empty group
    if res is true and comp.children and comp.children().length > 0
      res = sprintf lang.ide.CVS_CFM_DEL_GROUP, comp_name

    if _.isString( res )
      # Confirmation
      template = MC.template.canvasOpConfirm {
        title   : sprintf lang.ide.CVS_CFM_DEL, comp_name
        content : res
      }
      modal template, true
      theID = this.id

      $("#canvas-op-confirm").one "click", ()->
        comp = Design.instance().component( theID )
        if comp and not comp.isRemoved()
          comp.remove()
          ide_event.trigger ide_event.OPEN_PROPERTY
        null

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

  CanvasElement.prototype.toggleEip = ()->
    comp = Design.instance().component( this.id )
    if not comp.setPrimaryEip then return

    toggle = !comp.hasPrimaryEip()

    comp.setPrimaryEip( toggle )

    if toggle
      Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway ).tryCreateIgw()

    ide_event.trigger ide_event.PROPERTY_REFRESH_ENI_IP_LIST
    null

  CanvasElement.prototype.asgExpand = ( parentId, x, y )->
    # This method contains some logic to determine if the ASG is expandab
    comp   = Design.instance().component( @id )
    target = Design.instance().component(parentId)
    if target and comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
      ExpandedAsgModel = Design.modelClassForType( "ExpandedAsg" )
      res = new ExpandedAsgModel({
        x : x
        y : y
        originalAsg : comp
        parent : target
      })

    if res and res.id
      return true

    notification 'error', sprintf lang.ide.CVS_MSG_ERR_DROP_ASG, comp.get("name"), target.get("name")

    return false

  CanvasElement.prototype.volume = ()->
    vl = []
    for v in Design.instance().component( @id ).get("volumeList") or vl
      vl.push {
        deleted    : not v.hasAppResource()
        name       : v.get("name")
        snapshotId : v.get("snapshotId")
        size       : v.get("volumeSize")
      }

    vl

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

  CanvasElement.line.prototype.remove      = CanvasElement.prototype.remove
  CanvasElement.line.prototype.isRemovable = CanvasElement.prototype.isRemovable
  CanvasElement.line.prototype.element     = CanvasElement.prototype.element
  CanvasElement.line.prototype.$element    = CanvasElement.prototype.$element

  CanvasElement.setDesign = ( design )->
    Design = design
    null

  CanvasElement
