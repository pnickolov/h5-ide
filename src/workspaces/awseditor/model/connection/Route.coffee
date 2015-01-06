
define [ "constant", "ConnectionModel", "ComplexResModel", "Design" ], ( constant, ConnectionModel, ComplexResModel, Design )->

  # This model is used to represent objects that are outside of this vpc.
  VpcRouteTarget = ComplexResModel.extend {

    type : "ExternalVpcRouteTarget"

    defaults :
      targetId   : ""
      targetType : ""

    ###
    This model is initialized by a something like:
    {
      GatewayId              : ""
      InstanceId             : ""
      NetworkInterfaceId     : ""
      VpcPeeringConnectionId : ""
    }
    If either of above attributes is reference, make sure the referencing
    component has already been created ( a.k.a can be retrieve by Design.instance().component() )
    ###
    constructor : ( attr )->

      console.assert(
        attr.GatewayId || attr.InstanceId || attr.NetworkInterfaceId || attr.VpcPeeringConnectionId,
        "Invalid attributes for creating Route Target"
      )

      id = MC.extractID( attr.GatewayId || attr.InstanceId || attr.NetworkInterfaceId )
      if id
        # If we can find a existing component for this attr, return it instead of creating a new VpcRouteTarget
        internalVpcRouteTarget = Design.instance().component( id )
        if internalVpcRouteTarget
          return internalVpcRouteTarget

      for i in ["GatewayId", "InstanceId", "NetworkInterfaceId", "VpcPeeringConnectionId"]
        if attr[ i ]
          realAttr =
            name       : attr[i]
            targetId   : attr[i]
            targetType : i
          break

      if realAttr
        # Find if there's a VpcRouteTarget that is already represent the id.
        for vrt in VpcRouteTarget.allObjects()
          if vrt.get("targetId") is realAttr.targetId and vrt.get("targetType") is realAttr.targetType
            return vrt

        # Create a new object
        return ComplexResModel.call this, realAttr
  }


  C = ConnectionModel.extend {

    type : "RTB_Route"

    # The route is only visible if it is not routing to external resources.
    isVisual : ()-> !@getTarget( "ExternalVpcRouteTarget" )

    constructor : ( p1Comp, p2Comp, attr, option )->
      # If the target is an ENI, and it's embeded. Rtb will connect to its Instance
      if p1Comp.type is constant.RESTYPE.ENI
        eniComp = p1Comp
        rtbComp = p2Comp
      else if p2Comp.type is constant.RESTYPE.ENI
        eniComp = p2Comp
        rtbComp = p1Comp

      if eniComp and eniComp.embedInstance()
        p1Comp = eniComp.embedInstance()
        p2Comp = rtbComp

      ConnectionModel.call this, p1Comp, p2Comp, attr, option

    defaults : ()->
      routes : []

    initialize : ( attr, option )->
      igw = @getTarget( constant.RESTYPE.IGW )

      if igw and option and option.createByUser
        # By default add an "0.0.0.0/0" route for IGW
        @get("routes").push "0.0.0.0/0"
      null

    addRoute : ( route )->
      if not route then return
      routes = @get("routes")

      idx = _.indexOf routes, route

      if idx != -1 then return false

      routes.push route
      @set "routes", routes
      true

    removeRoute : ( route )->
      if not route then return
      routes = @get("routes")

      idx = _.indexOf routes, route

      if idx != -1 then return false

      routes.splice idx, 1
      @set "routes", routes
      true

    setPropagate : ( propagate )->
      console.assert( (@port1Comp().type is constant.RESTYPE.VGW) or (@port2Comp().type is constant.RESTYPE.VGW), "Propagation can only be set to VPN<==>RTB connection." )

      @set "propagate", propagate

    serialize : ( components )->
      rtb = @getTarget( constant.RESTYPE.RT )
      otherTarget = @getOtherTarget( rtb )

      rtb_data = components[ rtb.id ]

      if @get("propagate")
        rtb_data.resource.PropagatingVgwSet.push otherTarget.createRef( "VpnGatewayId" )

      r_temp = {
        Origin : ""
        InstanceId : ""
        NetworkInterfaceId : ""
        GatewayId : ""
      }

      TYPE = constant.RESTYPE

      switch otherTarget.type
        when TYPE.ENI
          r_temp.NetworkInterfaceId = otherTarget.createRef( "NetworkInterfaceId" )

        when TYPE.IGW
          r_temp.GatewayId = otherTarget.createRef( "InternetGatewayId" )

        when TYPE.VGW
          r_temp.GatewayId = otherTarget.createRef( "VpnGatewayId" )

        when TYPE.INSTANCE
          r_temp.NetworkInterfaceId = otherTarget.getEmbedEni().createRef( "NetworkInterfaceId" )

        when "ExternalVpcRouteTarget"
          r_temp[ otherTarget.get("targetType") ] = otherTarget.get("targetId")

      for r in @get("routes")
        d = { "DestinationCidrBlock" : r }
        rtb_data.resource.RouteSet.push $.extend( d, r_temp )

      null

    portDefs : [
      {
        port1 :
          name : "igw-tgt"
          type : constant.RESTYPE.IGW
        port2 :
          name : "rtb-tgt"
          type : constant.RESTYPE.RT
      }
      {
        port1 :
          name : "instance-rtb"
          type : constant.RESTYPE.INSTANCE
        port2 :
          name : "rtb-tgt"
          type : constant.RESTYPE.RT
      }
      {
        port1 :
          name : "eni-rtb"
          type : constant.RESTYPE.ENI
        port2 :
          name : "rtb-tgt"
          type : constant.RESTYPE.RT
      }
      {
        port1 :
          name : "vgw-tgt"
          type : constant.RESTYPE.VGW
        port2 :
          name : "rtb-tgt"
          type : constant.RESTYPE.RT
      }
      {
        port1 :
          name : ""
          type : constant.RESTYPE.RT
        port2 :
          name : ""
          type : "ExternalVpcRouteTarget"
      }
    ]


  }, {
    isConnectable : ( p1Comp, p2Comp )->
      if p1Comp.type is constant.RESTYPE.INSTANCE
        instance = p1Comp
      else if p2Comp.type is constant.RESTYPE.INSTANCE
        instance = p2Comp

      if instance and instance.get("count") > 1
        return false

      true

    VpcRouteTarget : VpcRouteTarget
  }

  C
