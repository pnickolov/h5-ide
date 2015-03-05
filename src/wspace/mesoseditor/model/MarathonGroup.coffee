
define [ "constant",
         "GroupModel",
         "i18n!/nls/lang.js"
], ( constant, GroupModel, lang )->

  Model = GroupModel.extend {

    type    : constant.RESTYPE.MRTHGROUP
    newNameTmpl : "group"

    serialize : ()->
      component =
        uid  : @get("name")
        id   : @get("name")
        type : @type

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.MRTHGROUP

    deserialize : ( data, layout_data, resolve )->

      new Model {

        id    : data.__uid
        name  : data.id
        parent : if data.__parentGroup then resolve( data.__parentGroup ) else null

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]

      }

      null
  }

  Model
