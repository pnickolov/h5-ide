
define [ "ComplexResModel", "constant", "i18n!/nls/lang.js" ], ( ComplexResModel, constant, lang )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.MRTHAPP
    newNameTmpl : "app"
    defaults:
      container: { docker: {}, volumes: [] }

    path : ()->
      path = []
      t = @
      while t
        path.unshift( t.get("name") )
        t = t.parent()
      ("/" + path.join("/")).replace(/\/+/g,"/")

    serialize : ()->
      component =
        uid      : @id
        type     : @type
        toplevel : !@parent()
        resource :
          id : @get("name")
          container: _.extend { type: 'DOCKER' }, @get("container")

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.MRTHAPP

    deserialize : ( data, layout_data, resolve )->

      new Model({
        id     : data.uid
        name   : data.resource.id
        parent : if layout_data.groupUId then resolve( layout_data.groupUId ) else null

        container: data.resource.containers

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

  }

  Model

