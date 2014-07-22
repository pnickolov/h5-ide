define [ "CanvasManager", "event", "constant", "i18n!/nls/lang.js", "CloudResources", "MC.canvas.constant" ], ( CanvasManager, ide_event, constant, lang, CloudResources )->

  Design = null

  CanvasElementConstructors = {}

  ###
  # Canvas interface of CanvasElement
  ###
  CanvasElement = ( model, containerId )->
    @id         = model.id
    @model      = model
    @type       = model.type
    @containerId = containerId

    if model.parent
      @parentId = model.parent()
      @parentId = if @parentId then @parentId.id else ""
    else
      @parentId = ""

    if model.node_group is true
      @nodeType = "group"
    else if model.node_line is true
      @nodeType = "line"
    else
      @nodeType = "node"

    this

  CanvasElement.extend = ( Child, ElementType )->
    CanvasElementPrototype = ()-> null

    CanvasElementPrototype.prototype = this.prototype

    Child.prototype = new CanvasElementPrototype()
    Child.prototype.constructor = Child
    Child.super = this.prototype

    # Register ElementType so that we can create it.
    CanvasElementConstructors[ ElementType ] = Child
    null

  CanvasElement.createView = ( type, model, containerId )->
    CEC = CanvasElementConstructors[ type ]
    if not CEC
      CEC = CanvasElement
      m = {
        type : "Unknown"
        id   : model
      }

    new CEC( m or model, containerId )


  CanvasElement.prototype.constant =
    PATH_PORT_LEFT    : "M-8 0.5l6 -5.5l2 0 l0 11 l-2 0z" # ◀
    PATH_PORT_TOP     : "M0.5 0l5.5 0l0 -2l-5.5 -6l-5.5 6l0 2z" # ▲
    PATH_PORT_RIGHT   : "M8 0.5l-6 -5.5l-2 0 l0 11 l2 0z" # ▶
    PATH_PORT_BOTTOM  : "M0.5 0l5.5 0l0 2l-5.5 6l-5.5 -6l0 -2z" # ▼
    PATH_PORT_DIAMOND : "M-5 0.5l5.5 -5.5l5.5 5.5 l-5.5 5.5z" # ◆

  CanvasElement.constant =
    PORT_RIGHT_ANGLE  : 0
    PORT_UP_ANGLE     : 90
    PORT_LEFT_ANGLE   : 180
    PORT_DOWN_ANGLE   : 270


  ###
  # CanvasElement Interface
  ###
  CanvasElement.prototype.draw = ()-> null # do nothing

  CanvasElement.prototype.getModel = ()-> @model

  CanvasElement.prototype.element  = ( id )->
    id = @id if not id

    document.getElementById( id )

  CanvasElement.prototype.$element = ( id )->
    $ @element()

  CanvasElement.prototype.move = ( x, y )->
    if x is @model.x() and y is @model.y() then return
    MC.canvas.move( @element(), x, y )

  CanvasElement.prototype.position = ( x, y )->

    oldx = @model.x()
    oldy = @model.y()

    if (x is undefined or x is null) and (y is undefined or y is null)
      return [ oldx, oldy ]

    # Update data, svg
    if x is null or x is undefined then x = oldx
    if y is null or y is undefined then y = oldy

    if x is oldx and y is oldy then return

    @model.set { x : x, y : y }

    el = @element()
    if el
      MC.canvas.position( el, x, y )
    null

  CanvasElement.prototype.size = ( w, h )->

    oldw = @model.width()
    oldh = @model.height()

    if (w is undefined or w is null) and (h is undefined or h is null)
      return [ oldw, oldh ]

    if not @model.node_group then return

    if w is null or w is undefined then w = oldw
    if h is null or h is undefined then h = oldh

    # Only if the data is changed, we update data.
    # But either way, we still need to update svg.
    if w isnt oldw or h isnt oldh
      @model.set { width : w, height : h }

    el = @element()
    if el then MC.canvas.groupSize( el, w, h )
    null

  CanvasElement.prototype.offset = ()-> @element().getBoundingClientRect()

  CanvasElement.prototype.port = ()->
    if not @ports
      @ports = _.map @$element().children(".port"), ( el )-> el.getAttribute("data-name")

    @ports

  CanvasElement.prototype.isConnectable = ( fromPort, toId, toPort )->

    C = Design.modelClassForPorts( fromPort, toPort )

    if not C then return false

    p1Comp = @model
    p2Comp = @model.design().component(toId)

    # Don't allow connect to an resource that is already connected.
    for t in p1Comp.connectionTargets( C.prototype.type )
      if t is p2Comp
        return false

    C.isConnectable( p1Comp, p2Comp ) isnt false

  CanvasElement.prototype.isRemovable = ()->
    res = @model.isRemovable()
    if res isnt true then return res

    # Check children to see if they are deletable.
    if @nodeType is "group"
      for ch in @children()
        res = ch.isRemovable()
        if res isnt true
          break

    res

  CanvasElement.prototype.remove = ()->
    if @model.isRemoved() then return

    res = @isRemovable()
    comp = @model
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

      $("#canvas-op-confirm").one "click", ()->
        if not comp.isRemoved()
          comp.remove()
          $canvas.selected_node().length = 0
          ide_event.trigger ide_event.OPEN_PROPERTY
        null

    else if res.error
      # Error
      notification "error", res.error

    else if res is true
      # Do remove
      comp.remove()
      $canvas.selected_node().length = 0
      ide_event.trigger ide_event.OPEN_PROPERTY
      return true

    return false

  # Update Lines
  CanvasElement.prototype.reConnect = ()->
    for cn in @model.connections()
      v = cn.getCanvasView()
      if v then v.draw()
    null

  CanvasElement.prototype.select = ()->
    if @type is "Unknown" then return

    @doSelect( @type, @id, @id )
    true

  CanvasElement.prototype.doSelect = ( type, propertyId, canvasId )->
    ide_event.trigger ide_event.OPEN_PROPERTY, type, propertyId
    MC.canvas.select( canvasId )

  CanvasElement.prototype.connection = ()->
    cns = []

    for cn in @model.connections()
      if cn.get("lineType")
        cns.push {
          line   : cn.id
          target : @id
          port   : cn.port( @id, "name" )
        }
    cns

  CanvasElement.prototype.toggleEip = ()->
    console.assert( @model.setPrimaryEip, "The component doesn't support setting EIP" )

    toggle = !@model.hasPrimaryEip()
    @model.setPrimaryEip( toggle )

    if toggle
      Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()

    ide_event.trigger ide_event.PROPERTY_REFRESH_ENI_IP_LIST
    null

  CanvasElement.prototype.clone = ( parentId, x, y )->
    design = @model.design()
    if not design.modeIsStack() and not design.modeIsAppEdit()
      return

    parent = design.component( parentId )
    if not parent
      console.error "No parent is found when cloning object"
      return

    if @model.clone # If the model supports clone() interface, then clone the target.
      name = @model.get("name")
      nameMatch = name.match /(.+-copy)(\d*)$/
      if nameMatch
        name = nameMatch[1] + ((parseInt(nameMatch[2],10) || 0) + 1)
      else
        name += "-copy"
      attributes   = { parent : parent, name : name }
      pos          = { x : x, y : y }
      createOption = { cloneSource : @model }

      $canvas.add( @type, attributes, pos, createOption )

  CanvasElement.prototype.parent  = ()->
    p = @model.parent()
    if p then p.getCanvasView() else null

  CanvasElement.prototype.changeParent = ( parentId, execCB )->

    if parentId is "canvas" then parentId = ""

    oldPid = @model.parent()
    oldPid = if oldPid then oldPid.id else ""

    if oldPid is parentId
      execCB.call( this )
      return false

    # # #
    # Quick Hack for supporting AppEdit
    # Ask the component if it supports AppEdit Mode
    #
    if @model.design().modeIsAppEdit() and @model.get("appId")
      notification "error", lang.ide.NOTIFY_MSG_WARN_OPERATE_NOT_SUPPORT_YET
      return
    #
    # #
    # # #

    parent = @model.design().component( parentId )
    if not parent
      console.warn( "Cannot find parent when changing parent" )
      return false

    res = @model.isReparentable( parent )

    if _.isString( res )
      # Error
      notification "error", res

    else if res is true
      parent.addChild( @model )
      execCB.call( this )
      return true

    return false

  CanvasElement.prototype.children = ()->
    if @model.children
      _.map @model.children() || [], ( c )-> c.getCanvasView()
    else
      []

  # Return an connection of serverGroupMember
  CanvasElement.prototype.list = ()->
    component = @model
    members = if @model.members then @model.members() else @model.groupMembers()
    if members.length is 0 then return []

    id   = @id
    name = @model.get("name")

    resource_list = CloudResources(@model.type, @model.design().region())
    ###
    # Quick hack for Lc
    ###
    if @type isnt constant.RESTYPE.LC

      if @type is constant.RESTYPE.INSTANCE
        instance_data = resource_list.get(@model.get("appId"))?.toJSON()
        state = if instance_data then instance_data.instanceState.name else "unknown"

      list = [{
        id      : id
        name    : name
        appId   : @model.get("appId")
        state   : state || ""
        deleted : if resource_list.get(@model.get("appId")) then "" else " deleted"
      }]

      list.id   = id
      list.name = name
    else
      list = []
      list.id   = @model.parent().id
      list.name = @model.parent().get("name")
    for member, idx in @model.groupMembers()

      state = ""
      if @type is constant.RESTYPE.INSTANCE or @type is constant.RESTYPE.LC
        resource_list = CloudResources(constant.RESTYPE.INSTANCE, @model.design().region())
        instance_data = resource_list.get(member.appId)?.toJSON()
        state = if instance_data then instance_data.instanceState.name  else "unknown"

      list.push {
        id      : member.id
        name    : name
        appId   : member.appId
        state   : state
        deleted : if not @model.design().modeIsStack() and not resource_list.get(@model.get("appId")) then " deleted" else ""
      }

    list


  CanvasElement.prototype.connectionData = ( portName )->
    Design.modelClassForType("Framework_CN").connectionData( @type, portName )

  ###
  # Helper functions for rendering and for model
  ###
  CanvasElement.prototype.getLayer = ( layerName )-> $("##{layerName}")

  CanvasElement.prototype.portDirection = ( portName )->
    if this.portDirMap then this.portDirMap[ portName ] else null

  CanvasElement.prototype.portPosition = ( portName )->
    if this.portPosMap then this.portPosMap[ portName ] else null

  CanvasElement.prototype.initNode = ( node, x, y )->
    CanvasManager.position node, x, y

    if node.length then node = node[0]
    for child in node.children || node.childNodes
      if child.tagName is "PATH" or child.tagName is "path"
        name = child.getAttribute("data-alias") or child.getAttribute("data-name")
        if name
          pos = @portPosition( name )
          if pos
            CanvasManager.setPoisition( child, pos[0] / 10, pos[1] / 10 )
    null

  CanvasElement.prototype.createNode = ( option )->
    # A helper function to create a SVG Element to represent a group
    m = @model

    x      = m.x()
    y      = m.y()
    width  = m.width()  * MC.canvas.GRID_WIDTH
    height = m.height() * MC.canvas.GRID_HEIGHT

    node = Canvon.group().append(

      Canvon.rectangle(0,0,width,height).attr({'class':'node-background','rx':5,'ry':5}),
      Canvon.image( MC.IMG_URL+option.image, option.imageX, option.imageY, option.imageW, option.imageH )

    ).attr({
      'id'         : option.id or @id
      'class'      : 'dragable node ' + @type.replace(/\./g, "-")
      'data-type'  : 'node'
      'data-class' : @type
    })

    if option.labelBg
      node.append(
        Canvon.rectangle(2,76,86,13).attr({'class':'node-label-name-bg','rx':3,'ry':3})
      )

    if option.label
      node.append(
        Canvon.text( width/2, height-4, MC.truncate(option.label, 17) ).attr({
          'class' : 'node-label' + if option.labelBg then ' node-label-name' else ''
        })
      )

    if option.sg
      node.append(
        Canvon.group().append(
          Canvon.rectangle(10, 6, 7, 5).attr({'class' : 'node-sg-color-border tooltip'}),
          Canvon.rectangle(20, 6, 7, 5).attr({'class' : 'node-sg-color-border tooltip'}),
          Canvon.rectangle(30, 6, 7, 5).attr({'class' : 'node-sg-color-border tooltip'}),
          Canvon.rectangle(40, 6, 7, 5).attr({'class' : 'node-sg-color-border tooltip'}),
          Canvon.rectangle(50, 6, 7, 5).attr({'class' : 'node-sg-color-border tooltip'})
        ).attr({ 'class':'node-sg-color-group', 'transform':'translate(8, 62)' })
      )

    node

  CanvasElement.prototype.createGroup = ( name )->
    # A helper function to create a SVG Element to represent a group
    m = @model

    x      = m.x()
    y      = m.y()
    width  = m.width()  * MC.canvas.GRID_WIDTH
    height = m.height() * MC.canvas.GRID_HEIGHT

    text_pos = {
      'AWS.VPC.VPC'              : [6, 16]
      'AWS.EC2.AvailabilityZone' : [4, 14]
      'AWS.VPC.Subnet'           : [4, 14]
      'AWS.RDS.DBSubnetGroup'    : [20, 14]
      'AWS.AutoScaling.Group'    : [4, 14]
    }[ m.type ]

    pad = 10

    Canvon.group().append(
      Canvon.rectangle( 0, 0, width, height ).attr({ 'class':'group', 'rx':5, 'ry':5 }),

      Canvon.group().append(
        Canvon.rectangle( pad, 0, width - 2 * pad, pad )
              .attr({'class':'group-resizer resizer-top','data-direction':'top'}),

        Canvon.rectangle( 0, pad, pad, height - 2 * pad )
              .attr({'class':'group-resizer resizer-left', 'data-direction':'left'}),

        Canvon.rectangle( width - pad, pad, pad, height - 2 * pad )
              .attr({'class':'group-resizer resizer-right', "data-direction":"right"}),

        Canvon.rectangle( pad, height - pad, width - 2 * pad, pad )
              .attr({'class':'group-resizer resizer-bottom', "data-direction":"bottom"}),

        Canvon.rectangle( 0, 0, pad, pad )
              .attr({'class':'group-resizer resizer-topleft', "data-direction":"topleft"}),

        Canvon.rectangle( width - pad, 0, pad, pad )
              .attr({'class':'group-resizer resizer-topright',"data-direction":"topright"}),

        Canvon.rectangle( 0, height - pad, pad, pad )
              .attr({'class':'group-resizer resizer-bottomleft',"data-direction":"bottomleft"}),

        Canvon.rectangle( width - pad, height - pad, pad, pad )
              .attr({'class':'group-resizer resizer-bottomright',"data-direction":"bottomright"})

      ).attr({'class':'resizer-wrap'}),

      Canvon.text(text_pos[0], text_pos[1], name).attr({'class':'group-label name'})
    ).attr({
      'id'         : @id
      'class'      : 'dragable ' + @type.replace(/\./g, "-")
      'data-type'  : 'group'
      'data-class' : @type
    })

  #update deleted resource style
  CanvasElement.prototype.updateAppState = ()->
    m = @model
    design = m.design()

    if design.modeIsStack() or not m.get("appId")
      return

    CanvasManager.removeClass @element(), "deleted"

    # Get resource data
    if m.type and design.region()
      res_list = CloudResources( m.type, design.region() )
      data = res_list.get(m.get('appId'))
      if not data
        CanvasManager.addClass @element(), "deleted"
    null

  CanvasElement.prototype.updatexGWAppState = ()->
    m = @model
    design = m.design()

    if m.design().modeIsStack() or not m.get("appId")
      return

    # Init
    el = @element()
    CanvasManager.removeClass el, "deleted"

    # Get xGW state
    if m.type and design.region()
      res_list = CloudResources( m.type, design.region() )
      data = res_list.get(m.get('appId'))

    if data
      if m.get("appId").indexOf("igw-") is 0
        #igw attachment.state: available | unavailable
        if not ( data.get("state") is "available" and data.get("vpcId") is m.parent().get("appId") )
          CanvasManager.addClass el, "deleted"

      else if m.get("appId").indexOf("vgw-") is 0
        #vgw            state: pending | available | deleting | deleted
        #    attachment.state: attaching | attached | detaching | detached
        if not ( data.get("state") is "available" and data.get("attachmentState") in ["attaching","attached"] and data.get("vpcId") is m.parent().get("appId") )
          CanvasManager.addClass el, "deleted"

      else if m.get("appId").indexOf("cgw-") is 0
        #cgw state: pending | available | deleting | deleted
        if data.get("state") isnt "available"
          CanvasManager.addClass el, "deleted"
    else
      CanvasManager.addClass el, "deleted"

    null

  CanvasElement.prototype.detach = () ->
    MC.canvas.remove( @element() )

  CanvasElement.setDesign = ( design )->
    Design = design
    null

  CanvasElement
