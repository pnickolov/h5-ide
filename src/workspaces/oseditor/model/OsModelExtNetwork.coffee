
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    type : "OS::ExternalNetwork"

    defaults :
      name : "ExtNetwork"

    serialize : ()-> return

  }, {

    handleTypes  : "OS::ExternalNetwork"

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id : data.uid
        x  : layout_data.coordinate[0]
        y  : layout_data.coordinate[1]
      })
      return
  }

  Model
