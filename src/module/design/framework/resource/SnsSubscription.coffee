
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant ) ->

  TopicModel = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic
    defaults :
      name : "sns-topic"

    serialize : ()->
      n = @get("name")

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
      if @allObjects().length = 0
        new TopicModel()
      null

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
      {
        component :
          name : ""
          type : @type
          uid  : @id
          resource :
            DeliveryPolicy  : ""
            Endpoint        : @get("endpoint")
            Protocol        : @get("protocol")
            SubscriptionArn : @get("appId")
            TopicArn        : "@#{TopicModel.allObjects()[0].id}.resource.TopicArn"
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
