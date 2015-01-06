
define [ "ComplexResModel", "Design", "./connection/Route", "./connection/RtbAsso", "constant", "i18n!/nls/lang.js" ], ( ComplexResModel, Design, Route, RtbAsso, constant, lang )->

  Model = ComplexResModel.extend {

    defaults :
      main     : false
      implicit : false

    type : constant.RESTYPE.RT
    newNameTmpl : "RT-"

    isRemovable : ()->
      if @get("main")
        return { error : sprintf( lang.CANVAS.ERR_DEL_MAIN_RT, @get("name") ) }

      true

    setMain : ()->
      if @get("main") then return

      Model.getMainRouteTable().set("main", false)
      @set("main", true)

      # Update all implicitly association to subnets
      subnets = Design.modelClassForType( constant.RESTYPE.SUBNET ).allObjects()

      for sb in subnets
        asso = sb.connections("RTB_Asso")[0]
        console.assert( asso, "Subnet should at least associate to one RouteTable" )

        # The association is implicit, we transfer this to the new MainRT
        if asso.get("implicit")
          new RtbAsso( this, sb, { implicit : true } )

    addRoute : ( targetId, r, propagating )->

      if _.isString targetId
        component = Design.instance().component( targetId )
      else
        component = new Route.VpcRouteTarget( targetId )

      if not component then return

      # Get the Route component between these two components.
      connection = new Route( this, component )
      connection.addRoute( r )

      # Set propagating
      if propagating isnt undefined
        connection.setPropagate propagating
      null

    serialize : ()->
      component =
        name : @get("name")
        description : @get("description") or ""
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
          Tags : [{
            Key   : "visops_default"
            Value : if @get("main") then "true" else "false"
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
        id          : data.uid
        appId       : data.resource.RouteTableId
        name        : data.name
        description : data.description or ""
        main        : !!asso_main
        x           : layout_data.coordinate[0]
        y           : layout_data.coordinate[1]
      })
      null


    deserialize : ( data, layout_data, resolve )->

      rtb = resolve( data.uid )

      # Because we don't know if the vpc is created prior to the rtb.preDeserialize()
      # So we add the rtb to vpc here.
      vpc = resolve( layout_data.groupUId )
      VpcModel = Design.modelClassForType( constant.RESTYPE.VPC )
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
          propagateMap[ ref ] = true

        for r in routes
          if r.GatewayId is "local" then continue
          rtb.addRoute( r, r.DestinationCidrBlock, propagateMap[ r.GatewayId ] )
      null
  }

  Model

