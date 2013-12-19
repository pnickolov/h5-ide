
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant ) ->

  Model = ResourceModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration

    __asso: [
      {
        key: 'TopicARN'
        type: constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic
        suffix: 'TopicArn'
      }
      {
        key: 'AutoScalingGroupName'
        type: constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
        suffix: 'AutoScalingGroupName'
      }
    ]

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration

    deserialize : ( data, layout_data, resolve ) ->

      attr =
        id           : data.uid
        name         : data.name

      for key, value of data.resource
        attr[ key ] = value

      model = new Model( attr )

      model.associate resolve

      null

  }

  Model

