
define [ "../ComplexResModel", "CanvasManager", "Design", "../connection/Route", "../connection/RtbAsso", "./VpcModel", "constant" ], ( ComplexResModel, CanvasManager, Design, Route, RtbAsso, VpcModel, constant )->

  Model = ComplexResModel.extend {

    defaults :
      main     : false
      x        : 50
      y        : 5
      width    : 8
      height   : 8

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
    newNameTmpl : "RT-"

    initialize : ()->
      # Add RouteTable to CurrentVPC
      # When deserializing() the VPC might not be available.
      vpc = VpcModel.theVPC()
      if vpc
        vpc.addChild( @ )
      null

    setMain : ()->
      if @get("main") then return

      old_main_rtb = Model.getMainRouteTable()

      old_main_rtb.set("main", false)
      old_main_rtb.draw()

      @set("main", true)
      @draw()

      # Update all implicitly association to subnets
      subnets = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet ).allObjects()

      for sb in subnets
        asso = sb.getAssociation()
        console.assert( asso, "Subnet should at least associate to one RouteTable" )

        # The association is implicit, we transfer this to the new MainRT
        if asso.get("implicit")
          new RtbAsso( this, sb, { implicit : true } )

    addRoute : ( targetId, r, propagating )->

      # If the target is an ENI, and it's embeded.
      # We connect to its Instance
      component = Design.instance().component( targetId )
      if component.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and component.embedInstance()
        component = component.embedInstance()

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

    getMainRouteTable : ()->
      _.find Model.allObjects(), ( obj )-> obj.get("main")

    handleTypes  : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
    resolveFirst : true

    preDeserialize : ( data, layout_data )->

      if data.resource.AssociationSet
        if data.resource.AssociationSet[0]
          asso_main = data.resource.AssociationSet[0].Main

      rtb = new Model({
        id   : data.uid
        name : data.name
        main : !!asso_main
        x    : layout_data.coordinate[0]
        y    : layout_data.coordinate[1]
      })

      null


    deserialize : ( data, layout_data, resolve )->

      rtb = resolve( data.uid )

      # A fix for subnet
      if not rtb.parent()
        VpcModel.theVPC().addChild( rtb )
      null

    postDeserialize : ( data, layout_data )->

      design = Design.instance()

      rtb = design.component( data.uid )

      # Create asso between RTB and Subnet
      for r in data.resource.AssociationSet || []
        if not r.Main and r.SubnetId
          new RtbAsso( rtb, design.component( MC.extractID( r.SubnetId ) ) )

      # Create routes between RTB and resources
      routes = data.resource.RouteSet
      if routes and routes.length > 1
        # Find out which route is propagating
        propagateMap = {}
        for ref in data.resource.PropagatingVgwSet || []
          propagateMap[ MC.extractID(ref) ] = true


        # The first RouteSet is always local, so we don't deserialize it
        i = 1
        while i < routes.length
          r  = routes[i]
          id = MC.extractID( r.GatewayId || r.InstanceId || r.NetworkInterfaceId )
          rtb.addRoute( id, r.DestinationCidrBlock, propagateMap[id] )
          ++i
      null
  }

  Model

