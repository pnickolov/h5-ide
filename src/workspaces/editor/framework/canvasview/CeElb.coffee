
define [ "./CanvasElement", "constant", "CanvasManager","i18n!nls/lang.js" ], ( CanvasElement, constant, CanvasManager,lang )->

  CeElb = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeElb, constant.RESTYPE.ELB )
  ChildElementProto = CeElb.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosMap = {
    "elb-sg-in"  : [ 2,  35, CanvasElement.constant.PORT_LEFT_ANGLE  ]
    "elb-assoc"  : [ 79, 50, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    "elb-sg-out" : [ 79, 20, CanvasElement.constant.PORT_RIGHT_ANGLE ]
  }

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
        sg     : true
      })

      node.append(
        # Left
        Canvon.path(this.constant.PATH_PORT_RIGHT).attr({
            'class'      : 'port port-blue port-elb-sg-in tooltip'
            'data-name'     : 'elb-sg-in'
            'data-position' : 'left'
            'data-type'     : 'sg'
            'data-direction': "in"
            'data-tooltip'  : lang.ide.PORT_TIP_D
          }),
        # Right gray
        Canvon.path(this.constant.PATH_PORT_RIGHT).attr({
            'class'      : 'port port-gray port-elb-assoc tooltip'
            'data-name'     : 'elb-assoc'
            'data-position' : 'right'
            'data-type'     : 'association'
            'data-direction': 'out'
            'data-tooltip'  : lang.ide.PORT_TIP_K
          })

        Canvon.path(this.constant.PATH_PORT_RIGHT).attr({
          'class'      : 'port port-blue port-elb-sg-out tooltip'
          'data-name'     : 'elb-sg-out'
          'data-position' : 'right'
          'data-type'     : 'sg'
          'data-direction': 'out'
          'data-tooltip'  : lang.ide.PORT_TIP_J
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
