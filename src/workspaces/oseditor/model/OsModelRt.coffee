
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

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
      new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.id
      })
      return
  }

  Model
