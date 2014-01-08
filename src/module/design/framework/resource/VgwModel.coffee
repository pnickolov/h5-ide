
define [ "../ComplexResModel", "CanvasManager", "./VpcModel", "Design", "constant" ], ( ComplexResModel, CanvasManager, VpcModel, Design, constant )->

  Model = ComplexResModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 8
      height   : 8
      name     : "VPN-gateway"

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway

    initialize : ()->
      VpcModel.theVPC().addChild( this )

      @draw(true)
      null

    draw : ( isCreate )->

      if isCreate

        design = Design.instance()

        # Call parent's createNode to do basic creation
        node = @createNode({
          image   : "ide/icon/vgw-canvas.png"
          imageX  : 10
          imageY  : 16
          imageW  : 60
          imageH  : 46
          label   : @get("name")
        })

        node.append(
          # Left port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-vgw-tgt'
            'class'      : 'port port-blue port-vgw-tgt'
            'transform'  : 'translate(3, 30)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
            'data-name'     : 'vgw-tgt'
            'data-position' : 'left'
            'data-type'     : 'sg'
            'data-direction': 'in'
          }),

          # Right port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-vgw-vpn'
            'class'      : 'port port-purple port-vgw-vpn'
            'transform'  : 'translate(69, 30)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
            'data-name'     : 'vgw-vpn'
            'data-position' : 'right'
            'data-type'     : 'vpn'
            'data-direction': 'out'
          })
        )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()


    serialize : ()->

      layout =
        size       : [ @width(), @height() ]
        coordinate : [ @x(), @y() ]
        uid        : @id
        groupUId   : @parent().id

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          State            : "available"
          Type             : "ipsec.1"
          VpnGatewayId     : @get("appId")
          AvailabilityZone : ""
          Attachments      : [{
            State : "attached"
            VpcId : "@#{@parent().id}.resource.VpcId"
          }]

      { component : component, layout : layout }

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway

    deserialize : ( data, layout_data, resolve )->

      new Model({

        id    : data.uid
        name  : data.name
        appId : data.resource.VpnGatewayId

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      null

  }

  Model

