
define [ "ComplexResModel", "constant", "i18n!/nls/lang.js" ], ( ComplexResModel, constant, lang )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.MRTHAPP
    newNameTmpl : "app"

    serialize : ()->
      component =
        uid  : @get("name")
        name : @get("name")
        type : @type

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.MRTHAPP

    deserialize : ( data, layout_data, resolve )->

      new Model({
        id     : data.__uid
        name   : data.id
        parent : if data.__parentGroup then resolve( data.__parentGroup ) else null

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

  }

  Model

