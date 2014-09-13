
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSSG
    newNameTmpl : "SecurityGroup-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id   : @get("appId")
          name : @get("name")

          description : @get("description")
          rules       : []

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSSG

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id
        description : data.resource.description
      })
      return
  }

  Model
