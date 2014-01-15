
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant ) ->

  TopicModel = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

    serialize : ()->

      ScalingPolicyModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy )
      for sp in ScalingPolicyModel.allObjects()
        if sp.get("sendNotification")
          useTopic = true
          break

      if not useTopic
        useTopic = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration ).allObjects().length > 0

      if not useTopic
        useTopic = SubscriptionModel.allObjects().length > 0

      if not useTopic
        useTopic = !!@get("appId")

      if not useTopic
        console.debug( "Sns Topic is not serialized, because nothing use it and it doesn't have appId." )
        return

      n = "sns-topic"

      {
        component :
          name : n
          type : @type
          uid  : @id
          resource :
            DeliveryPolicy : ""
            DisplayName    : n
            Name           : n
            Policy         : ""
            TopicArn       : @get("appId")
      }

  }, {
    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic

    ensureExistence : ()->
      if @allObjects().length is 0
        new TopicModel()
      @allObjects()[0]

    deserialize : ( data, layout_data, resolve ) ->
      new TopicModel({
        id    : data.uid
        appId : data.resource.TopicArn
        name  : data.resource.DisplayName or data.resource.Name
      })
      null
  }



  SubscriptionModel = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription

    serialize : ()->
      topic = TopicModel.ensureExistence()

      {
        component :
          name : "SnsSubscription"
          type : @type
          uid  : @id
          resource :
            DeliveryPolicy  : ""
            Endpoint        : @get("endpoint")
            Protocol        : @get("protocol")
            SubscriptionArn : @get("appId")
            TopicArn        : TopicModel.ensureExistence().createRef( "TopicArn" )
      }

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
