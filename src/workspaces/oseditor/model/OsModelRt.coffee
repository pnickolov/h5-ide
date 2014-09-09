
define [ "ComplexResModel", "constant", "Design" ], ( ComplexResModel, constant, Design )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSRT
    newNameTmpl : "Router-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id                    : @get("appId")
          name                  : @get("name")
          external_gateway_info : {}
          admin_state_up        : true
          router_interface      : []

      { component : component }

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

      Asso = Design.modelClassForType( "OsRouterAsso" )
      for subnet in data.resource.router_interface
        new Asso( router, resolve(MC.extractID( subnet.subnet_id )) )

      return
  }

  Model