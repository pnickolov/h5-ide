
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant ) ->

  Model = ResourceModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic



  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

    deserialize : ( data, layout_data, resolve ) ->

      attr =
        id           : data.uid
        name         : data.name

      for key, value of data.resource
        attr[ key ] = value

      model = new Model( attr )


      null

  }

  Model

