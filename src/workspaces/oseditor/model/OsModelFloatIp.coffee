
define [ "ComplexResModel", "constant" ], ( ComplexResModel, ConnectionModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSFIP
    newNameTmpl : "FloatIp-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id : @get("appId")
          router_id           : ""
          floating_network_id : ""
          fixed_ip_address    : ""
          floating_ip_address : ""
          port_id             : ""

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSFIP

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.id
      })
      return
  }

  Model
