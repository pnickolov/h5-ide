
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant ) ->

  Model = ComplexResModel.extend {

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
      delete attr.AutoScalingGroupName

      model = new Model( attr )

      asg.scalingPolicies.add model




      model

  }

  Model

