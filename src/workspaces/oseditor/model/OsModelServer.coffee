
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSSERVER
    newNameTmpl : "Server-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id        : @get("appId")
          name      : @get("name")
          flavor    : ""
          image     : ""
          meta      : ""
          NICS      : []
          userdata  : ""
          adminPass : ""
          availabilityZone   : ""
          blockDeviceMapping : []

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSSERVER

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.id
      })
      return
  }

  Model
