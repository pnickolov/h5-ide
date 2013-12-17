
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant ) ->

  Model = ResourceModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch

    __asso: [
      {
        key: 'AlarmActions'
        type: constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy
        suffix: 'PolicyARN'
      }
    ]


  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch

    deserialize : ( data, layout_data, resolve ) ->

      attr =
        id           : data.uid
        name         : data.name

      for key, value of data.resource
        attr[ key ] = value

      model = new Model( attr )
      ###
      for action in attr.AlarmActions
        policyUid = MC.extractID action
        policy = resolve policyUid
        policy.collection.add model
      ###
      model.associate resolve

      model

  }

  Model

