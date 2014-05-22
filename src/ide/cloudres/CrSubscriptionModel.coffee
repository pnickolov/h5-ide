
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrSubscriptionModel"
    ### env:dev:end ###

    doCreate  : ()->
    doUpdate  : ( displayName )->
    doDestroy : ()->
  }
