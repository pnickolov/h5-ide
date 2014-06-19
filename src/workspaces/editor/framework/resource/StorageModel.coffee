define [ "Design", "../ResourceModel" ], ( Design, ResourceModel )->

  # This class is used to store a complete JSON data.
  # It reads the whole data from the JSON when deserializing.
  # And then writes the whole data back to the JSON when serializing.

  Model = ResourceModel.extend {

    type : "AWS.Tag"

    serialize : ()->
      { component : $.extend( true, {}, @get("data") ) }

  }, {

    diffJson : ()-> # Disable diff for thie Model

    handleTypes : ["AWS.EC2.Tag", "AWS.AutoScaling.Tag"]

    deserialize : ( data )->
      new Model({ id : data.uid, data : data })
      null
  }

  Model
