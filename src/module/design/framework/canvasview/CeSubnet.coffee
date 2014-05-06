
define [ "./CanvasElement", "constant", "CanvasManager","i18n!nls/lang.js" ], ( CanvasElement, constant, CanvasManager,lang )->

  CeSubnet = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeSubnet, constant.RESTYPE.SUBNET )
  ChildElementProto = CeSubnet.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosition = ( portName )->
    m = @model
    portY = m.height() * MC.canvas.GRID_HEIGHT / 2 - 5

    if portName is "subnet-assoc-in"
      [ -12, portY, CanvasElement.constant.PORT_LEFT_ANGLE ]
    else
      [ m.width() * MC.canvas.GRID_WIDTH + 10, portY, CanvasElement.constant.PORT_RIGHT_ANGLE ]


  ChildElementProto.draw = ( isCreate )->

    m = @model

    label = "#{m.get('name')} (#{ m.get('cidr')})"

    if isCreate
      node = @createGroup( label )

      node.append( Canvon.path( this.constant.PATH_PORT_RIGHT ).attr({
        'class'      : 'port port-gray port-subnet-assoc-in tooltip'
        'data-name'     : 'subnet-assoc-in'
        'data-position' : 'left'
        'data-type'     : 'association'
        'data-direction': 'in'
        'data-tooltip'  : lang.ide.PORT_TIP_L
      }) )

      # Offset the port, because line layer is on top of group layer.
      # Which requiring subnet's right port to be different than the others
      node.append( Canvon.path( "M2 0.5l-6 -5.5l-2 0 l0 11 l2 0z" ).attr({
        'class'      : 'port port-gray port-subnet-assoc-out tooltip'
        'data-name'     : 'subnet-assoc-out'
        'data-position' : 'right'
        'data-type'     : 'association'
        'data-direction': 'out'
        'data-tooltip'  : lang.ide.PORT_TIP_M
      }) )

      @getLayer("subnet_layer").append node

      # Move the group to right place
      @initNode node, m.x(), m.y()

    else
      CanvasManager.update( @$element().children("text"), label )

    null

  null
