
define [ "../ComplexResModel", "CanvasManager", "Design", "constant" ], ( ComplexResModel, CanvasManager, Design, constant )->

  Model = ComplexResModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 17
      height   : 10
      bgpAsn   : ""

    newNameTmpl : "customer-gateway-"

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway

    isDynamic : ()->
      !!@get("bgpAsn")

    draw : ( isCreate )->

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
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-cgw-vpn',
            'class'      : 'port port-purple port-cgw-vpn',
            'transform'  : 'translate(6, 40)' + MC.canvas.PORT_RIGHT_ROTATE,
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
            'data-name'     : 'cgw-vpn'
            'data-position' : 'left'
            'data-type'     : 'vpn'
            'data-direction': 'in'
          }),

          Canvon.text(100, 95, MC.canvasName( @get("name") ) ).attr({'class': 'node-label'})
        )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()

      else
        node = $( document.getElementById( @id ) )
        # Update label
        CanvasManager.update node.children(".node-label"), @get("name")

    serialize : ()->
      layout =
        uid        : @id
        coordinate : [ @x(), @y() ]

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          CustomerGatewayId : @get("appId")
          BgpAsn            : @get("bgpAsn")
          State             : "available"
          Type              : "ipsec.1"
          IpAddress         : @get("ip")

      { component : component, layout : layout }

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway

    deserialize : ( data, layout_data, resolve )->

      new Model({

        id     : data.uid
        name   : data.name
        appId  : data.resource.CustomerGatewayId
        bgpAsn : data.resource.BgpAsn
        ip     : data.resource.IpAddress

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

  }

  Model

