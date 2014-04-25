
define [ "./CanvasElement", "constant", "CanvasManager" ], ( CanvasElement, constant, CanvasManager )->

  CeElb = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeElb, constant.AWS_RESOURCE_TYPE.AWS_ELB )
  ChildElementProto = CeElb.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosMap = {
    "elb-sg-in"  : [ 2,  35, MC.canvas.PORT_LEFT_ANGLE  ]
    "elb-assoc"  : [ 79, 50, MC.canvas.PORT_RIGHT_ANGLE ]
    "elb-sg-out" : [ 79, 20, MC.canvas.PORT_RIGHT_ANGLE ]
  }

  ChildElementProto.portPosition = ( portName )->
    pos = @portPosMap[ portName ]

    if portName is "elb-sg-out" and @model.design().typeIsClassic()
      pos[1] = 35

    pos

  ChildElementProto.iconUrl = ()->
    if @model.get("internal")
      "ide/icon/elb-internal-canvas.png"
    else
      "ide/icon/elb-internet-canvas.png"

  ChildElementProto.draw = ( isCreate )->

    m = @model
    design = m.design()

    if isCreate

      # Call parent's createNode to do basic creation
      node = @createNode({
        image  : @iconUrl()
        imageX : 9
        imageY : 11
        imageW : 70
        imageH : 53
        label  : m.get "name"
        sg     : not design.typeIsClassic()
      })

      # Port
      if not design.typeIsClassic()
        node.append(
          # Left
          Canvon.path(MC.canvas.PATH_PORT_RIGHT).attr({
            'class'      : 'port port-blue port-elb-sg-in tooltip'
            'data-name'     : 'elb-sg-in'
            'data-position' : 'left'
            'data-type'     : 'sg'
            'data-direction': "in"
            'data-tooltip'  : 'Connect to instance, auto scaling group or network interface to create security group rule.'
          }),
          # Right gray
          Canvon.path(MC.canvas.PATH_PORT_RIGHT).attr({
            'class'      : 'port port-gray port-elb-assoc tooltip'
            'data-name'     : 'elb-assoc'
            'data-position' : 'right'
            'data-type'     : 'association'
            'data-direction': 'out'
            'data-tooltip'  : 'Connect a subnet for each Availability Zone'
          })
        )

      node.append(
        Canvon.path(MC.canvas.PATH_PORT_RIGHT).attr({
          'class'      : 'port port-blue port-elb-sg-out tooltip'
          'data-name'     : 'elb-sg-out'
          'data-position' : 'right'
          'data-type'     : 'sg'
          'data-direction': 'out'
          'data-tooltip'  : 'Connect to instance or launch conﬁguration to register behind load balancer'
        })
      )

      # Move the node to right place
      @getLayer("node_layer").append node
      @initNode node, m.x(), m.y()

    else
      node = @$element()
      # Update label
      CanvasManager.update node.children(".node-label"), m.get("name")

      # Update Image
      CanvasManager.update node.children("image"), @iconUrl(), "href"

    # Toggle left port
    CanvasManager.toggle node.children(".port-elb-sg-in"), m.get("internal")

    # Update Resource State in app view
    @updateAppState()
    null

  null
