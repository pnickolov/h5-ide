
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSVOL
    newNameTmpl : "Volume-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id   : @get("appId")
          name : @get("name")
          availability_zone   : ""
          source_volid        : ""
          display_description : ""
          snapshot_id         : ""
          size                : ""
          display_name        : ""
          imageRef            : ""
          olume_type          : ""
          bootable            : ""
          server_id           : ""

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSVOL

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id
      })
      return
  }

  Model
