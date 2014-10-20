
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSRT
    newNameTmpl : "router"

    defaults:
      nat: true
      extNetworkId : ""

    isPublic : ()-> !!@get("extNetworkId")

    serialize : ()->
      if @get("extNetworkId")
        extNetwork = { network_id : @get("extNetworkId") }
      else
        extNetwork = {}

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
            external_gateway_info : extNetwork
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
        extNetworkId : data.resource.external_gateway_info.network_id || ""

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      # Router <=> Subnet
      Asso = Design.modelClassForType( "OsRouterAsso" )
      for subnet in data.resource.router_interface
        new Asso( router, resolve(MC.extractID( subnet.subnet_id )) )

      return
  }

  Model
