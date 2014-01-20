
define [ "./CanvasElement", "constant", "CanvasManager" ], ( CanvasElement, constant, CanvasManager )->

  ChildElement = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( ChildElement, constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )
  ChildElementProto = ChildElement.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosition = ( portName )->
    m = @model
    portY = m.height() * MC.canvas.GRID_HEIGHT / 2 - 5

    if portName is "subnet-assoc-in"
      [ -12, portY, MC.canvas.PORT_LEFT_ANGLE ]
    else
      [ m.width()  * MC.canvas.GRID_WIDTH + 4, portY, MC.canvas.PORT_RIGHT_ANGLE ]


  ChildElementProto.draw = ( isCreate )->

    m = @model

    label = "#{m.get('name')} (#{ m.get('cidr')})"

    if isCreate
      node = @createGroup( label )

      node.append( Canvon.path( MC.canvas.PATH_PORT_RIGHT ).attr({
        'class'      : 'port port-gray port-subnet-assoc-in'
        'data-name'     : 'subnet-assoc-in'
        'data-position' : 'left'
        'data-type'     : 'association'
        'data-direction': 'in'
      }) )

      node.append( Canvon.path( MC.canvas.PATH_PORT_RIGHT ).attr({
        'class'      : 'port port-gray port-subnet-assoc-out'
        'data-name'     : 'subnet-assoc-out'
        'data-position' : 'right'
        'data-type'     : 'association'
        'data-direction': 'out'
      }) )

      $('#subnet_layer').append node

      # Move the group to right place
      @initNode node, m.x(), m.y()

    else
      CanvasManager.update( @$element().children("text"), label )

    null

  null
