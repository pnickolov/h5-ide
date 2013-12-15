
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
  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection

    deserialize : ( data, layout_data, resolve )->

      cgw = resolve MC.extractID( data.resource.CustomerGatewayId )
      vpn = resolve MC.extractID( data.resource.VpnGatewayId )

      if not cgw or not vpn
        return

      new C( cgw, vpn, {
        id     : data.uid
        routes : _.map data.resource.Routes, ( r )-> r.DestinationCidrBlock
      } )
  }

  C
