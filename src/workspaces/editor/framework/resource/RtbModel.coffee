
define [ "../ComplexResModel", "Design", "../connection/Route", "../connection/RtbAsso", "./VpcModel", "constant", "i18n!/nls/lang.js" ], ( ComplexResModel, Design, Route, RtbAsso, VpcModel, constant, lang )->

  Model = ComplexResModel.extend {

    defaults :
      main     : false
      x        : 50
      y        : 5
      width    : 8
      height   : 8
      implicit : false

    type : constant.RESTYPE.RT
    newNameTmpl : "RT-"

    initialize : ()->
      @draw(true)
      null

    isRemovable : ()->
      if @get("main")
        return { error : sprintf( lang.ide.CVS_MSG_ERR_DEL_MAIN_RT, @get("name") ) }

      true

    setMain : ()->
      if @get("main") then return

      old_main_rtb = Model.getMainRouteTable()

      old_main_rtb.set("main", false)
      old_main_rtb.draw()

      @set("main", true)
      @draw()

      # Update all implicitly association to subnets
      subnets = Design.modelClassForType( constant.RESTYPE.SUBNET ).allObjects()

      for sb in subnets
        asso = sb.connections("RTB_Asso")[0]
        console.assert( asso, "Subnet should at least associate to one RouteTable" )

        # The association is implicit, we transfer this to the new MainRT
        if asso.get("implicit")
          new RtbAsso( this, sb, { implicit : true } )

    addRoute : ( targetId, r, propagating )->

      # If the target is an ENI, and it's embeded.
      # We connect to its Instance
      component = Design.instance().component( targetId )

      # component might be null, because the targetId is not UUID
      # This happens in deserializing `Resource Import` data.
      if not component then return

      if component.type is constant.RESTYPE.ENI and component.embedInstance()
        component = component.embedInstance()

      # Find out if we already have one connection between this rtb to targetId
      connection = new Route( this, component )
      connection.addRoute( r )

      # Set propagating
      if propagating isnt undefined
        connection.setPropagate propagating
      null

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          PropagatingVgwSet : []
          RouteTableId      : @get("appId")
          VpcId             : @parent().createRef( "VpcId" )
          AssociationSet    : []
          RouteSet          : [{
            Origin               : "CreateRouteTable"
            DestinationCidrBlock : @parent().get("cidr")
            InstanceId           : ""
            NetworkInterfaceId   : ""
            GatewayId            : "local"
          }]

      if @get("main")
        component.resource.AssociationSet.push {
          Main     : "true" # Must be string.
          RouteTableAssociationId : ""
          SubnetId : ""
        }

      { component : component, layout : @generateLayout() }

  }, {

    getMainRouteTable : ()->
      _.find Model.allObjects(), ( obj )-> obj.get("main")

    handleTypes  : constant.RESTYPE.RT
    resolveFirst : true

    preDeserialize : ( data, layout_data )->

      if data.resource.AssociationSet
        ##move main to first
        found = -1
        for assoc,idx in data.resource.AssociationSet
          if assoc.Main and found is -1
            found = idx
        if found > 0
          main_rt = data.resource.AssociationSet.splice( found,1 )
          data.resource.AssociationSet.splice( 0, 0, main_rt[0] )

        if data.resource.AssociationSet[0]
          asso_main = "" + data.resource.AssociationSet[0].Main is "true"

      rtb = new Model({
        id   : data.uid
        appId: data.resource.RouteTableId
        name : data.name
        main : !!asso_main
        x    : layout_data.coordinate[0]
        y    : layout_data.coordinate[1]
      })
      null


    deserialize : ( data, layout_data, resolve )->

      rtb = resolve( data.uid )

      # A fix for subnet
      vpc = resolve( layout_data.groupUId )
      if not vpc then vpc = VpcModel.theVPC()
      vpc.addChild( rtb )
      null

    postDeserialize : ( data, layout_data )->

      design = Design.instance()

      rtb = design.component( data.uid )

      # Create asso between RTB and Subnet
      for r in data.resource.AssociationSet || []
        if not r.Main and r.SubnetId
          # The fact is subnet will automatically creates an RtbAsso to the MainRtb
          # So if this is mainRtb, the connection will exist, so we need to ensure the
          # line is implicit.
          # Ignoring the fact, we would still like to explicitly set the `implicit` to false.
          new RtbAsso rtb, design.component(MC.extractID(r.SubnetId)), {
            implicit : false
            assoId : r.RouteTableAssociationId
          }

      # Create routes between RTB and resources
      routes = data.resource.RouteSet
      if routes and routes.length > 1
        # Find out which route is propagating
        propagateMap = {}
        for ref in data.resource.PropagatingVgwSet || []
          propagateMap[ MC.extractID(ref) ] = true


        # The first RouteSet is always local, so we don't deserialize it
        i = 0
        while i < routes.length
          r  = routes[i]
          if r.GatewayId isnt "local"
            id = MC.extractID( r.GatewayId || r.InstanceId || r.NetworkInterfaceId )
            rtb.addRoute( id, r.DestinationCidrBlock, propagateMap[id] )
          ++i
      null
  }

  Model

