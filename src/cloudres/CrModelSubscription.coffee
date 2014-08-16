
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrSubscriptionModel = CrModel.extend {

    ### env:dev ###
    ClassName : "CrSubscriptionModel"
    ### env:dev:end ###

    taggable : false

    defaults :
      Endpoint        : ""
      Protocol        : ""
      TopicName       : ""
      TopicArn        : ""
      SubscriptionArn : ""

    initialize : ( attributes )->
      if attributes.TopicArn
        @attributes.TopicName = attributes.TopicArn.split(":").pop()
      return

    isRemovable : ()->
      @attributes.SubscriptionArn isnt "PendingConfirmation" and @attributes.SubscriptionArn isnt "Deleted"

    set : ( key, value, options )->
      if key is "TopicArn"
        @attributes.TopicName = value.split(":").pop()
      else if key.TopicArn
        @attributes.TopicName = key.TopicArn.split(":").pop()

      Backbone.Model.prototype.set.apply this, arguments
      return

    doCreate  : ()->
      self = @
      ApiRequest("sns_Subscribe", {
        region_name : @getCollection().region()
        topic_arn   : @get("TopicArn")
        protocol    : @get("Protocol")
        endpoint    : @get("Endpoint")
      }).then ( res )->
        try
          res = res.SubscribeResponse.SubscribeResult
          arn = res.SubscriptionArn
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Subscription created but aws returns invalid ata." )

        if arn is "pending confirmation" then arn = "PendingConfirmation"

        self.set {
          id : CrSubscriptionModel.getIdFromData( self.attributes )
          SubscriptionArn : arn
        }
        console.log "Created subscription resource", self

        self

    doDestroy : ()->
      if @isRemovable()
        return ApiRequest("sns_Unsubscribe", {
          region_name : @getCollection().region()
          sub_arn     : @get("SubscriptionArn")
        })

      defer = Q.defer()
      defer.resolve McError( ApiRequest.Errors.InvalidMethodCall, "Cannot unsubscribe pending subscription.", self )
      return defer.promise
  }, {
    getIdFromData : ( res )-> "#{res.TopicArn}:#{res.Protocol}:#{res.Endpoint}".replace("arn:aws:sns:","")
  }

  CrSubscriptionModel
