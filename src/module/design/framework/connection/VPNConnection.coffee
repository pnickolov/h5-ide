
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  C = ConnectionModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection

    defaults : ()->
      lineType : "vpn"
      routes   : []

    portDefs :
      port1 :
        name : "vgw-vpn"
        type : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway
      port2 :
        name : "cgw-vpn"
        type : constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway

    serialize : ( component_data )->
      vgw = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway )
      cgw = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway )

      if cgw.isDynamic()
        routes = []
      else
        routes = _.map @get("routes"), ( r )-> { DestinationCidrBlock : r }

      component_data[ @id ] =
        name : "vpn:" + cgw.get("name")
        type : @type
        uid  : @id
        resource :
          CustomerGatewayId : cgw.createRef( "CustomerGatewayId" )
          Options           : { StaticRoutesOnly : cgw.get("bgpAsn") is "" }
          Type              : "ipsec.1"
          Routes            : routes
          VpnConnectionId   : @get("appId")
          VpnGatewayId      : vgw.createRef( "VpnGatewayId" )

      null

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection

    deserialize : ( data, layout_data, resolve )->

      cgw = resolve MC.extractID( data.resource.CustomerGatewayId )
      vpn = resolve MC.extractID( data.resource.VpnGatewayId )

      if not cgw or not vpn
        return

      new C( cgw, vpn, {
        id     : data.uid
        appId  : data.resource.VpnConnectionId
        routes : _.map data.resource.Routes, ( r )-> r.DestinationCidrBlock
      } )
  }

  C
