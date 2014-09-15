
define [ "ComplexResModel", "constant", "CloudResources" ], ( ComplexResModel, constant, CloudResources )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSEXTNET

    defaults: ()->
      name : "ExtNetwork"

    getResourceId : ()->
      if @get("appId") then return @get("appId")
      CloudResources( @type, @design().region() ).models[0].id || ""

    serialize : ()->
      {
        layout : @generateLayout()
        component :
          uid  : @id
          type : @type
          resource :
            id : @getResourceId()
      }

  }, {

    handleTypes  : constant.RESTYPE.OSEXTNET
    resolveFirst : true

    preDeserialize : ( data, layout_data )->
      new Model({
        id : data.uid
        x  : layout_data.coordinate[0]
        y  : layout_data.coordinate[1]
        appId : data.resource.id
      })

    deserialize : ()-> # Empty function to suppress warning.
  }

  Model
