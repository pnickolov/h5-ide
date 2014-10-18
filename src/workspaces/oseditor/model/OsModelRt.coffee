
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSRT
    newNameTmpl : "router"

    defaults:
      nat: true

    connect : ( cn )->
      if cn.type is 'OsExtRouterAttach'
        @set "public", true
      return

    disconnect : ( cn )->
      if cn.type is 'OsExtRouterAttach'
        @set "public", false
      return

    unattachToExt : () ->

        @connections('OsExtRouterAttach')[0]?.remove()

    attachToExt : () ->

        # get ext network in stack
        extNetwork = @getDefaultExt()
        if extNetwork
            Attach = Design.modelClassForType( "OsExtRouterAttach" )
            new Attach( @, extNetworks[0] )

    getDefaultExt : () ->

        # get ext network in stack
        extNetworks = Design.modelClassForType(constant.RESTYPE.OSEXTNET).allObjects()
        if extNetworks and extNetworks[0]
            return extNetworks[0]
        return null

    serialize : ()->
      extNetwork = @connectionTargets( "OsExtRouterAttach" )[0]
      if extNetwork
        extNetwork = { network_id : extNetwork.createRef("id") }

      {
        layout    : @generateLayout()
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            id                    : @get("appId")
            name                  : @get("name")
            nat                   : @get("nat")
            external_gateway_info : extNetwork || {}
            router_interface : @connectionTargets("OsRouterAsso").map ( subnet )->
              { subnet_id : subnet.createRef("id") }
      }

  }, {

    handleTypes  : constant.RESTYPE.OSRT

    deserialize : ( data, layout_data, resolve )->
      router = new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id
        nat   : data.resource.nat

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      # Router <=> Subnet
      Asso = Design.modelClassForType( "OsRouterAsso" )
      for subnet in data.resource.router_interface
        new Asso( router, resolve(MC.extractID( subnet.subnet_id )) )

      # ExtNetwork <=> Router
      externalNetwork = data.resource.external_gateway_info
      if externalNetwork and externalNetwork.network_id
        Attach = Design.modelClassForType( "OsExtRouterAttach" )
        new Attach( router, resolve(MC.extractID( externalNetwork.network_id )) )
      return
  }

  Model
