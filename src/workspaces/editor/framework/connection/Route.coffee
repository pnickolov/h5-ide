
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  C = ConnectionModel.extend {

    type : "RTB_Route"

    defaults : ()->
      lineType : "rtb-target"
      dashLine : true
      routes   : []

    initialize : ( attr, option )->
      igw = @getTarget( constant.RESTYPE.IGW )

      if igw and not attr.routes
        # By default add an "0.0.0.0/0" route for IGW
        @get("routes").push "0.0.0.0/0"
      null

    addRoute : ( route )->
      routes = @get("routes")

      idx = _.indexOf routes, route

      if idx != -1 then return false

      routes.push route
      @set "routes", routes
      true

    removeRoute : ( route )->
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
  }

  C
