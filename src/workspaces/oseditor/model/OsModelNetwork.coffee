
define [ "ComplexResModel", "constant" ], ( ComplexResModel, ConnectionModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSNETWORK
    newNameTmpl : "Network-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id             : @get("appId")
          name           : @get("name")
          admin_state_up : ""
          shared         : ""

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSNETWORK

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.id
      })
      return
  }

  Model
