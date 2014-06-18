
define [ "../ResourceModel", "../ComplexResModel", "constant", "../ConnectionModel" ], ( ResourceModel, ComplexResModel, constant, ConnectionModel ) ->

  TopicUsage = ConnectionModel.extend {
    type : "TopicUsage"
    oneToMany : constant.RESTYPE.TOPIC
  }

  TopicModel = ComplexResModel.extend {
    type : constant.RESTYPE.TOPIC

    isVisual: () -> false

    serialize : ()->

      useTopic = !! @connections().length

      if not useTopic
        console.debug( "Sns Topic is not serialized, because nothing use it and it doesn't have appId." )
        return

      {
        component :
          name        : @get( "name" )
          type        : @type
          uid         : @id
          resource :
            TopicArn    : @get( "appId" )
      }

    assignTo: ( target ) ->
      if @get 'appId'
        new TopicUsage( @, target )

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

    get: ( appId, name ) ->
      topic = _.first _.filter @allObjects(), ( m ) -> m.get('appId') is appId
      topic or new TopicModel appId: appId, name: name




    preDeserialize : ( data, layout_data ) ->
      new TopicModel({
        id          : data.uid
        appId       : data.resource.TopicArn
        name        : data.resource.Name or data.name
      })
      null

    deserialize : ()->
      # Does nothing
      null
  }

  ###

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

  ###

  null
