
define [ "./CanvasElement", "constant" ], ( CanvasElement, constant )->

  ChildElement = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( ChildElement, constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway )
  ChildElementProto = ChildElement.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosMap = {
    "vgw-tgt" : [ 3,  35, MC.canvas.PORT_LEFT_ANGLE ]
    "vgw-vpn" : [ 70, 35, MC.canvas.PORT_RIGHT_ANGLE ]
  }

  ChildElementProto.draw = ( isCreate ) ->

    m = @model

    if isCreate

      # Call parent's createNode to do basic creation
      node = @createNode({
        image   : "ide/icon/vgw-canvas.png"
        imageX  : 10
        imageY  : 16
        imageW  : 60
        imageH  : 46
        label   : m.get("name")
      })

      node.append(
        # Left port
        Canvon.path(MC.canvas.PATH_PORT_RIGHT).attr({
          'class'          : 'port port-blue port-vgw-tgt'
          'data-name'      : 'vgw-tgt'
          'data-position'  : 'left'
          'data-type'      : 'sg'
          'data-direction' : 'in'
        }),

        # Right port
        Canvon.path(MC.canvas.PATH_PORT_RIGHT).attr({
          'class'          : 'port port-purple port-vgw-vpn'
          'data-name'      : 'vgw-vpn'
          'data-position'  : 'right'
          'data-type'      : 'vpn'
          'data-direction' : 'out'
        })
      )

      # Move the node to right place
      $("#node_layer").append node
      @initNode node, m.x(), m.y()

    # Update Resource State in app view
    @updateAppState()
    null

  null
