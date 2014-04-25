
define [ "./CanvasElement", "constant" ], ( CanvasElement, constant )->

  CeVgw = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeVgw, constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway )
  ChildElementProto = CeVgw.prototype


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
          'class'          : 'port port-blue port-vgw-tgt tooltip'
          'data-name'      : 'vgw-tgt'
          'data-position'  : 'left'
          'data-type'      : 'sg'
          'data-direction' : 'in'
          'data-tooltip'   : 'Connect to route table to create route'
        }),

        # Right port
        Canvon.path(MC.canvas.PATH_PORT_RIGHT).attr({
          'class'          : 'port port-purple port-vgw-vpn tooltip'
          'data-name'      : 'vgw-vpn'
          'data-position'  : 'right'
          'data-type'      : 'vpn'
          'data-direction' : 'out'
          'data-tooltip'   : 'Connect to Customer Gateway to create VPN'
        })
      )

      # Move the node to right place
      @getLayer("node_layer").append node
      @initNode node, m.x(), m.y()


    # Update Resource State in app view
    #@updateAppState()

    # Update xGW Resource Attachment State in app view
    @updatexGWAppState()


    null

  null
