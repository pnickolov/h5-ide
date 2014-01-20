define [ "CanvasManager", "event", "constant", "i18n!nls/lang.js", "MC.canvas.constant" ], ( CanvasManager, ide_event, constant, lang )->

  Design = null

  CanvasElementConstructors = {}

  ###
  # Canvas interface of CanvasElement
  ###
  CanvasElement = ( model )->
    @model = model
    @type  = model.type
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

  CanvasElement.createView = ( type, model )->
    CEC = CanvasElementConstructors[ type ]
    if CEC
      new CEC( model )
    else
      null


  ###
  # CanvasElement Interface
  ###
  CanvasElement.prototype.getModel = ()-> @model

  CanvasElement.prototype.element  = ()-> document.getElementById( @model.id )
  CanvasElement.prototype.$element = ()-> $( document.getElementById( @model.id ) )

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

    component.set { x : x, y : y }

    el = this.element()
    if el
      MC.canvas.position( el, x, y )
    null

  CanvasElement.prototype.size = ( w, h )->

    component = Design.instance().component( this.id )

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

    # # #
    # Quick Hack for supporting AppEdit
    # Ask the component if it supports AppEdit Mode
    #
    if Design.instance().modeIsAppEdit() and not @model.get("supportAppEdit")
        notification "error", "This operation is not supported yet."
        return false
    #
    # #
    # # #


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
    for cn in @model.connections()
      v = cn.getCanvasView()
      if v then v.draw()
    null

  CanvasElement.prototype.select = ()->
    @doSelect( @model.type, @model.id, @model.id )
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
          target : @model.id
          port   : cn.port( @model.id, "name" )
        }
    cns

  CanvasElement.prototype.toggleEip = ()->
    console.assert( @model.setPrimaryEip, "The component doesn't support setting EIP" )

    toggle = !comp.hasPrimaryEip()
    @model.setPrimaryEip( toggle )

    if toggle
      Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway ).tryCreateIgw()

    ide_event.trigger ide_event.PROPERTY_REFRESH_ENI_IP_LIST
    null

  CanvasElement.prototype.parent  = ()->
    p = @model.parent()
    if p then p.getCanvasView() else null

  CanvasElement.prototype.changeParent = ( parentId, execCB )->

    if parentId is "canvas" then parentId = ""

    if this.parentId is parentId
      execCB.call( this )
      return false

    # # #
    # Quick Hack for supporting AppEdit
    # Ask the component if it supports AppEdit Mode
    #
    if Design.instance().modeIsAppEdit()
      notification "error", "This operation is not supported yet."
      return
    #
    # #
    # # #

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
    _.map @model.children() || [], ( c )-> c.getCanvasView()

  # Return an connection of serverGroupMember
  CanvasElement.prototype.list = ()->
    component = Design.instance().component( this.id )
    members = component.groupMembers()
    if members.length is 0 then return []

    id   = component.id
    name = component.get("name")

    resource_list = MC.data.resource_list[ Design.instance().region() ]

    ###
    # Quick hack for Lc
    ###
    if component.type isnt constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

      state = ""
      if component.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        instance_data = MC.data.resource_list[ Design.instance().get('region') ][ component.get("appId") ]
        state = if instance_data then instance_data.instanceState.name  else "unknown"

      list = [{
        id      : id
        name    : name
        appId   : component.get("appId")
        state   : state
        deleted : if resource_list[ component.get("appId") ] then "" else " deleted"
      }]

      list.id   = id
      list.name = name
    else
      list = []
      list.id   = component.parent().id
      list.name = component.parent().get("name")

    for member, idx in component.groupMembers()

      state = ""
      if component.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance or component.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        instance_data = MC.data.resource_list[ Design.instance().get('region') ][ member.appId ]
        state = if instance_data then instance_data.instanceState.name  else "unknown"

      list.push {
        id      : member.id
        name    : name
        appId   : member.appId
        state   : state
        deleted : if not Design.instance().modeIsStack() and not resource_list[ component.get("appId") ] then " deleted" else ""
      }

    list





  ###
  # Helper functions for rendering and for model
  ###
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
      'id'         : m.id
      'class'      : 'dragable node ' + m.type.replace(/\./g, "-")
      'data-type'  : 'node'
      'data-class' : m.type
    })

    if option.labelBg
      node.append(
        Canvon.rectangle(2,76,86,13).attr({'class':'node-label-name-bg','rx':3,'ry':3})
      )

    if option.label
      node.append(
        Canvon.text( width/2, height-4, MC.canvasName(option.label) ).attr({
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

    text_pos = MC.canvas.GROUP_LABEL_COORDINATE[ m.type ]

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
      'id'         : m.id
      'class'      : 'dragable ' + m.type.replace(/\./g, "-")
      'data-type'  : 'group'
      'data-class' : m.type
    })

  #update deleted resource style
  CanvasElement.prototype.updateAppState = ()->
    m = @model

    if m.design().modeIsStack() or not m.get("appId")
      return

    CanvasManager.removeClass @element(), "deleted"

    # Get resource data
    if not MC.data.resource_list[ m.design().region() ][ m.get("appId") ]
      CanvasManager.addClass @element(), "deleted"
    null

  CanvasElement.prototype.detach = ()-> CanvasManager.remove( @element() )

  CanvasElement.setDesign = ( design )->
    Design = design
    null

  CanvasElement
