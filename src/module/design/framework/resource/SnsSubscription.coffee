
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant ) ->

  AsgNotifyModel = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration
  }, {
    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration
    deserialize : ( data, layout_data, resolve ) ->
      new AsgNotifyModel( data )
      null
  }



  TopicModel = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic
    defaults :
      name : "sns-topic"
  }, {
    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic
    deserialize : ( data, layout_data, resolve ) ->
      new TopicModel({
        id    : data.uid
        appId : data.resource.TopicArn
      })
      null
  }



  SubscriptionModel = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription

    deserialize : ( data, layout_data, resolve ) ->
      new SubscriptionModel({
        id       : data.uid
        appId    : data.resource.SubscriptionArn
        endpoint : data.resource.Endpoint
        protocol : data.resource.Protocol
      })
      null
  }

  null
