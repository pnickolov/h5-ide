
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSVOL
    newNameTmpl : "Volume-"

    getOwner : ()-> @get("owner")

    serialize : ()->
      {
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            id   : @get("appId")
            name : @get("name")

            snapshot_id : @get("snapshot")
            size        : @get("size")
            mount_point : @get("mountPoint")
            bootable    : @get("bootable")
            server_id   : @get("owner").createRef("id")

            display_description : @get("description")
            display_name        : @get("name")
      }

  }, {

    handleTypes  : constant.RESTYPE.OSVOL

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.resource.display_name
        appId : data.resource.id

        snapshot    : data.resource.snapshot_id
        size        : data.resource.size
        mountPoint  : data.resource.mount_point
        bootable    : data.resource.bootable
        owner       : resolve( MC.extractID(data.resource.server_id) )

        description : data.resource.description
      })
      return
  }

  Model
