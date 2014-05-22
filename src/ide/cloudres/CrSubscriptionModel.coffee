
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrSubscriptionModel"
    ### env:dev:end ###

    taggable : false

    isPending : ()-> @attributes.SubscriptionArn is "PendingConfirmation"

    doCreate  : ()->
    doDestroy : ()->
  }
