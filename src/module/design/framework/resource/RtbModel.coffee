
define [ "../ComplexResModel", "../CanvasManager", "../Design", "../connection/Route", "constant" ], ( ComplexResModel, CanvasManager, Design, Route, constant )->

  Model = ComplexResModel.extend {

    defaults :
      main     : false
      x        : 50
      y        : 5
      width    : 8
      height   : 8

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

    iconUrl : ()->
      if @get("main") then "ide/icon/rt-main-canvas.png" else "ide/icon/rt-canvas.png"

    draw : ( isCreate )->

      if isCreate

        design = Design.instance()

        # Call parent's createNode to do basic creation
        node = @createNode({
          image   : @iconUrl()
          imageX  : 10
          imageY  : 13
          imageW  : 60
          imageH  : 57
        })

        node.append(
          # Left port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'             : @id + '_port-rtb-tgt-left'
            'class'          : 'port port-blue port-rtb-tgt port-rtb-tgt-left'
            'transform'      : 'translate(2, 30)' + MC.canvas.PORT_LEFT_ROTATE
            'data-name'      : 'rtb-tgt'
            'data-position'  : 'left'
            'data-type'      : 'sg'
            'data-direction' : 'out'
            'data-angle'     : MC.canvas.PORT_LEFT_ANGLE
          }),

          # Right port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'             : @id + '_port-rtb-tgt-right'
            'class'          : 'port port-blue  port-rtb-tgt port-rtb-tgt-right'
            'transform'      : 'translate(70, 30)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-name'      : 'rtb-tgt'
            'data-position'  : 'right'
            'data-type'      : 'sg'
            'data-direction' : 'out'
            'data-angle'     : MC.canvas.PORT_RIGHT_ANGLE
          }),

          # Top port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'             : @id + '_port-rtb-src-top'
            'class'          : 'port port-gray port-rtb-src port-rtb-src-top'
            'transform'      : 'translate(37, 2)' + MC.canvas.PORT_UP_ROTATE
            'data-name'      : 'rtb-src'
            'data-position'  : 'top'
            'data-type'      : 'association'
            'data-direction' : 'in'
            'data-angle'     : MC.canvas.PORT_UP_ANGLE
          }),

          # Bottom port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'             : @id + '_port-rtb-src-bottom'
            'class'          : 'port port-gray port-rtb-src port-rtb-src-bottom'
            'transform'      : 'translate(36, 69)' + MC.canvas.PORT_DOWN_ROTATE
            'data-name'      : 'rtb-src'
            'data-position'  : 'bottom'
            'data-type'      : 'association'
            'data-direction' : 'in'
            'data-angle'     : MC.canvas.PORT_DOWN_ANGLE
          }),

          Canvon.text(41, 27, @get("name")).attr({
            'class' : 'node-label node-label-rtb-name'
          })
        )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

    deserialize : ( data, layout_data, resolve )->

      if data.resource.AssociationSet and data.resource.AssociationSet[0]
        asso_main =  data.resource.AssociationSet[0].Main

      rtb = new Model({

        id   : data.uid
        name : data.name

        main : MC.getBoolean( asso_main )

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      # Create routes between RTB and other resources
      routes = data.resource.RouteSet
      if routes.length > 1
        # The first RouteSet is always local, so we don't deserialize it
        i = 1
        while i < routes.length
          r = routes[i]
          id = MC.extractID( r.GatewayId || r.InstanceId || r.NetworkInterfaceId )
          new Route( rtb, resolve( id ) )
          ++i

  }

  Model

