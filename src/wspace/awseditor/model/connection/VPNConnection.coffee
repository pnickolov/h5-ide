
define [ "constant", "ConnectionModel", "ComplexResModel" ], ( constant, ConnectionModel, ComplexResModel )->

  VpnModel = ComplexResModel.extend {
    type: 'VpnResource'
    isVisual: -> false
    createRef: -> ComplexResModel.prototype.createRef.call @getRealBody(), 'VpnConnectionId'
    setRealBody: (realbody) -> @__realbody = realbody
    getRealBody: -> @__realbody
  }

  C = ConnectionModel.extend {

    type : constant.RESTYPE.VPN

    defaults : ()->
      routes   : []

    portDefs :
      port1 :
        name : "vgw-vpn"
        type : constant.RESTYPE.VGW
      port2 :
        name : "cgw-vpn"
        type : constant.RESTYPE.CGW

    initialize: ->
      @__resource = new VpnModel()
      @__resource.setRealBody @

    getResourceModel: -> @__resource
    connectionTargets: -> @__resource.connectionTargets.apply @__resource, arguments
    tags: -> @__resource.tags.apply @__resource, arguments

    serialize : ( component_data )->
      vgw = @getTarget( constant.RESTYPE.VGW )
      cgw = @getTarget( constant.RESTYPE.CGW )

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
          Options           : { StaticRoutesOnly : not cgw.isDynamic() }
          Type              : "ipsec.1"
          Routes            : routes
          VpnConnectionId   : @get("appId")
          VpnGatewayId      : vgw.createRef( "VpnGatewayId" )

      null

    remove: ->
      @getResourceModel().remove()
      ConnectionModel.prototype.remove.apply @, arguments

  }, {

    handleTypes : constant.RESTYPE.VPN

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
