
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  __vgwTelemetry =
    AcceptRouteCount : ""
    LastStatusChange : ""
    OutsideIpAddress : ""
    Status           : ""
    StatusMessage    : ""


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

      if not cgw.isDynamic()
        routes = []
      else
        routes = _.map @get("routes"), ( r )->
          {
            DestinationCidrBlock : r
            Source               : ""
            State                : ""
          }

      component_data[ @id ] =
        name : @get("name")
        type : @type
        id   : @id
        resource :
          CustomerGatewayConfiguration : ""
          CustomerGatewayId : "@#{cgw.id}.resource.CustomerGatewayId"
          Options           : { StaticRoutesOnly : true }
          State             : ""
          Type              : "ipsec.1"
          Routes            : routes
          VgwTelemetry      : __vgwTelemetry
          VpnConnectionId   : @get("appId")
          VpnGatewayId      : "@#{vgw.id}.resource.VpnGatewayId"

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
