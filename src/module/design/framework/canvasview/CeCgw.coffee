
define [ "./CanvasElement", "constant", "CanvasManager" ], ( CanvasElement, constant, CanvasManager )->

  ChildElement = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( ChildElement, constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway )
  ChildElementProto = ChildElement.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosMap = {
    "cgw-vpn" : [ 6, 45, MC.canvas.PORT_LEFT_ANGLE ]
  }

  ChildElementProto.draw = ( isCreate ) ->

    m = @model

    if isCreate

      # Call parent's createNode to do basic creation
      node = @createNode({
        image   : "ide/icon/cgw-canvas.png"
        imageX  : 13
        imageY  : 8
        imageW  : 151
        imageH  : 76
      })

      node.append(
        # Port
        Canvon.path(MC.canvas.PATH_PORT_RIGHT).attr({
          'class'      : 'port port-purple port-cgw-vpn',
          'data-name'     : 'cgw-vpn'
          'data-position' : 'left'
          'data-type'     : 'vpn'
          'data-direction': 'in'
        }),

        Canvon.text(100, 95, MC.canvasName( m.get("name") ) ).attr({'class': 'node-label'})
      )

      # Move the node to right place
      $("#node_layer").append node
      @initNode node, m.x(), m.y()

    else
      # Update label
      CanvasManager.update @element().children(".node-label"), @get("name")


    # Update Resource State in app view
    @updateAppState()
    null

  null
