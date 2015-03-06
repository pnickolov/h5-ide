define [
  "../CrCollection"
  "constant"
  "ApiRequest"
], ( CrCollection, constant )->

  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrMarathonGroupCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.MRTHGROUP

    __selfParseData : true

    doFetch : ()->
      self = @
      @sendRequest("marathon_group_list", {
        region_name : "us-east-1"
        app_id      : @category
      }).then ( data )->
        self.set data[1].groups
        []
  }
