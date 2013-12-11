
define [ "../ComplexResModel", "../CanvasManager", "Design", "../connection/Route", "../connection/RtbAsso", "constant" ], ( ComplexResModel, CanvasManager, Design, Route, RtbAsso, constant )->

  Model = ComplexResModel.extend {

    defaults :
      main     : false
      x        : 50
      y        : 5
      width    : 8
      height   : 8

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

    setMain : ()->
      if @get("main") then return

      old_main_rtb = _.find Model.allObjects(), ( obj )-> obj.get("main")

      old_main_rtb.set("main", false)
      old_main_rtb.draw()

      @set("main", true)
      @draw()

      # Update all implicitly association to subnets
      for cn in old_main_rtb.connections()
        if cn.type is "RTB_ASSO" and cn.get("implicit")
          # Get the subnet that is previously asso-ed to the Main RouteTable
          subnet = cn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )
          new RtbAsso( this, subnet, { implicit : true } )
          cn.remove()

    addRoute : ( targetId, r, propagating )->

      # Find out if we already have one connection between this rtb to targetId
      connection = _.find @connections(), ( cn )->
        p1 = cn.port1Comp()
        p2 = cn.port2Comp()

        p1 && p2 && (p1.id is targetId or p2.id is targetId)

      # No connection found, create a new one.
      if not connection
        connection = new Route( this, Design.instance().component( targetId ) )
        # Set propagating
        if propagating
          connection.setPropagate true

      # Add the route to the connection
      connection.addRoute( r )

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
            'id'         : @id + '_port-rtb-tgt-left'
            'class'      : 'port port-blue port-rtb-tgt port-rtb-tgt-left'
            'transform'  : 'translate(2, 30)' + MC.canvas.PORT_LEFT_ROTATE
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
          }),

          # Right port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-rtb-tgt-right'
            'class'      : 'port port-blue  port-rtb-tgt port-rtb-tgt-right'
            'transform'  : 'translate(70, 30)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
          }),

          # Top port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-rtb-src-top'
            'class'      : 'port port-gray port-rtb-src port-rtb-src-top'
            'transform'  : 'translate(37, 2)' + MC.canvas.PORT_UP_ROTATE
            'data-angle' : MC.canvas.PORT_UP_ANGLE
          }),

          # Bottom port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-rtb-src-bottom'
            'class'      : 'port port-gray port-rtb-src port-rtb-src-bottom'
            'transform'  : 'translate(36, 69)' + MC.canvas.PORT_DOWN_ROTATE
            'data-angle' : MC.canvas.PORT_DOWN_ANGLE
          }),

          Canvon.text(41, 27, @get("name")).attr({
            'class' : 'node-label node-label-rtb-name'
          })
        )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()

      else
        node = $( document.getElementById( @id ) )
        # Update label
        CanvasManager.update node.children(".node-label"), @get("name")

        # Update Image
        CanvasManager.update node.children("image"), @iconUrl(), "href"

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
    resolveFirst : true

    deserialize : ( data, layout_data, resolve )->

      if data.resource.AssociationSet and data.resource.AssociationSet[0]
        asso_main = data.resource.AssociationSet[0].Main

      rtb = new Model({

        id   : data.uid
        name : data.name

        main : MC.getBoolean( asso_main )

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      # Create routes between RTB and other resources
      routes = data.resource.RouteSet
      if routes and routes.length > 1

        # Find out which route is propagating
        propagateMap = {}
        if data.resource.PropagatingVgwSet
          for ref in data.resource.PropagatingVgwSet
            propagateMap[ MC.extractID(ref) ] = true

        # The first RouteSet is always local, so we don't deserialize it
        i = 1
        while i < routes.length
          r  = routes[i]
          id = MC.extractID( r.GatewayId || r.InstanceId || r.NetworkInterfaceId )

          rtb.addRoute( id, r.DestinationCidrBlock, propagateMap[id] )
          ++i

      # Create asso between RTB and subnets
      routes = data.resource.AssociationSet
      _.each routes, ( r )->
        if r.Main isnt "true" and r.SubnetId
          id = MC.extractID( r.SubnetId )
          new RtbAsso( rtb, resolve( id ) )
  }

  Model

