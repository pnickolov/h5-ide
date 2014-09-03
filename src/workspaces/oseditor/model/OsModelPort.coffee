
define [ "ComplexResModel", "constant" ], ( ComplexResModel, ConnectionModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSPORT
    newNameTmpl : "Port-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id   : @get("appId")
          name : @get("name")

          admin_state_up  : ""
          mac_address     : ""
          fixed_ips       : []
          security_groups : []
          network_id      : ""

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSPORT

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.id
      })
      return
  }

  Model
