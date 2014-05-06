
define [ "../ResourceModel", "constant" ], ( ResourceModel, constant ) ->

  TopicModel = ResourceModel.extend {
    type : constant.RESTYPE.TOPIC

    serialize : ()->

      useTopic = TopicModel.isTopicNeeded()

      if not useTopic
        useTopic = SubscriptionModel.allObjects().length > 0

      if not useTopic
        useTopic = !!@get("appId")

      if not useTopic
        console.debug( "Sns Topic is not serialized, because nothing use it and it doesn't have appId." )
        return

      name = "sns-topic"

      {
        component :
          name : "sns-topic"
          type : @type
          uid  : @id
          resource :
            DisplayName : name
            Name        : name
            TopicArn    : @get("appId")
      }

  }, {
    handleTypes  : constant.RESTYPE.TOPIC
    resolveFirst : true

    diffJson : ()-> # Disable diff for this Model

    isTopicNeeded : ()->
      ScalingPolicyModel = Design.modelClassForType( constant.RESTYPE.SP )
      for sp in ScalingPolicyModel.allObjects()
        if sp.get("sendNotification")
          useTopic = true
          break

      if not useTopic
        for n in Design.modelClassForType( constant.RESTYPE.NC ).allObjects()
          if n.isUsed()
            useTopic = true
            break

      useTopic

    ensureExistence : ()->
      if @allObjects().length is 0
        new TopicModel()
      @allObjects()[0]

    preDeserialize : ( data, layout_data ) ->
      new TopicModel({
        id    : data.uid
        appId : data.resource.TopicArn
        name  : data.resource.DisplayName or data.resource.Name
      })
      null

    deserialize : ()->
      # Does nothing
      null
  }



  SubscriptionModel = ResourceModel.extend {
    type : constant.RESTYPE.SUBSCRIPTION

    initialize : ()->
      TopicModel.ensureExistence()
      null

    serialize : ()->
      topic = TopicModel.ensureExistence()

      {
        component :
          name : "SnsSubscription"
          type : @type
          uid  : @id
          resource :
            Endpoint        : @get("endpoint")
            Protocol        : @get("protocol")
            SubscriptionArn : @get("appId")
            TopicArn        : TopicModel.ensureExistence().createRef( "TopicArn" )
      }

  }, {

    handleTypes : constant.RESTYPE.SUBSCRIPTION

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
