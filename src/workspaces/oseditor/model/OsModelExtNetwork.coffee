
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    type : "OS::ExternalNetwork"

    defaults :
      name : "ExtNetwork"

    serialize : ()-> { layout : @generateLayout() }

  }, {

    handleTypes  : "OS::ExternalNetwork"
    resolveFirst : true

    preDeserialize : ( data, layout_data )->
      new Model({
        id : data.uid
        x  : layout_data.coordinate[0]
        y  : layout_data.coordinate[1]
      })

    deserialize : ()->
  }

  Model
