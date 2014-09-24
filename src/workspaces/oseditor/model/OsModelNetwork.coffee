
define [ "GroupModel", "constant" ], ( GroupModel, constant )->

  Model = GroupModel.extend {

    type : constant.RESTYPE.OSNETWORK
    newNameTmpl : "Network-"

    isRemovable : ()-> false

    serialize : ()->
      {
        layout : @generateLayout()
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            id     : @get("appId")
            name   : @get("name")
      }

  }, {

    handleTypes  : constant.RESTYPE.OSNETWORK

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]
      })
      return
  }

  Model
