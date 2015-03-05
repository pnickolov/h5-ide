
define [ "ComplexResModel", "constant", "i18n!/nls/lang.js" ], ( ComplexResModel, constant, lang )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.MRTHAPP
    newNameTmpl : "app"

    serialize : ()->
      component =
        uid      : @id
        type     : @type
        toplevel : !@parent()
        resource :
          id : @get("name")

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.MRTHAPP

    deserialize : ( data, layout_data, resolve )->

      new Model({
        id     : data.uid
        name   : data.resource.id
        parent : if layout_data.groupUId then resolve( layout_data.groupUId ) else null

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

  }

  Model

