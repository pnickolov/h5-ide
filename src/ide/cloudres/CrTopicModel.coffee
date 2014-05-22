
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrTopicModel"
    ### env:dev:end ###

    defaults :
      Name        : ""
      DisplayName : ""

    doCreate : ()->
      ApiRequest("sns_CreateTopic",{
        region_name : @getCollection().category
        topic_name  : @get("Name")
      }).then ( res )->
        try
          id = res.CreateTopicResponse.CreateTopicResult.TopicArn
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Topic created but aws returns invalid ata." )

        self.set( "id", id )
        console.info "Topic Created", self

        if self.get("DisplayName")
          ApiRequest("sns_SetTopicAttributes", {
            region_name : self.getCollection().category
            topic_arn   : id
            attr_name   : "DisplayName"
            attr_value  : self.get("DisplayName")
          })

        self

    doUpdate : ( displayName )->
      self = @
      ApiRequest("sns_SetTopicAttributes", {
        region_name : @getCollection().category
        topic_arn   : @get("id")
        attr_name   : "DisplayName"
        attr_value  : displayName
      }).then ()->
        self.set "DisplayName", displayName
        self

    doDestroy : ()->
      ApiRequest("sns_DeleteTopic", {
        region_name : @getCollection().category
        topic_arn   : @get("id")
      })

  }
