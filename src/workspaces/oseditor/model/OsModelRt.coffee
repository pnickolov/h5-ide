
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSRT
    newNameTmpl : "router"

    connect : ( cn )->
      if cn.type is 'OsExtRouterAttach'
        @set "public", true
      return

    disconnect : ( cn )->
      if cn.type is 'OsExtRouterAttach'
        @set "public", false
      return

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

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      # Router <=> Subnet
      Asso = Design.modelClassForType( "OsRouterAsso" )
      for subnet in data.resource.router_interface
        new Asso( router, resolve(MC.extractID( subnet.subnet_id )) )

      # ExtNetwork <=> Router
      Attach = Design.modelClassForType( "OsExtRouterAttach" )
      new Attach( router, resolve(MC.extractID( data.resource.external_gateway_info.network_id )) )
      return
  }

  Model
