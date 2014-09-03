
define [ "ComplexResModel", "constant" ], ( ComplexResModel, ConnectionModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSHM
    newNameTmpl : "Pool-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id   : @get("appId")
          name : @get("name")
          delay          : ""
          timeout        : ""
          max_retries    : ""
          url_path       : ""
          expected_codes : ""

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSHM

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.id
      })
      return
  }

  Model
