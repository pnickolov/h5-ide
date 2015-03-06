define [
  "../CrCollection"
  "constant"
  "ApiRequest"
], ( CrCollection, constant )->

  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrMarathonAppCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.MRTHAPP

    __selfParseData : true

    doFetch : ()->
      self = @
      @sendRequest("marathon_app_list", {
        region_name : "us-east-1"
        app_id      : @category
      }).then ( data )->

        self.set data[1].apps

        # Clear promise, so that next fetch() will send request.
        self.__fetchPromise = null
        []
  }
