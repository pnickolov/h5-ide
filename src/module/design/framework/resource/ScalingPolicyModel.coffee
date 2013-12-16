
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant ) ->

  Model = ResourceModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy



  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy

    deserialize : ( data, layout_data, resolve ) ->

      attr =
        id           : data.uid
        name         : data.name

      for key, value of data.resource
        attr[ key ] = value

      asgUid = MC.extractID attr.AutoScalingGroupName
      asg = resolve asgUid

      model = new Model( attr )

      asg.addToStorage model




      model

  }

  Model

