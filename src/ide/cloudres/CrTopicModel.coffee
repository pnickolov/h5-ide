
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrTopicModel"
    ### env:dev:end ###

    taggable : false

    defaults :
      Name        : ""
      DisplayName : ""

    doCreate : ()->
      self = @

      ApiRequest("sns_CreateTopic",{
        region_name : @getCollection().region()
        topic_name  : @get("Name")
      }).then ( res )->
        try
          id = res.CreateTopicResponse.CreateTopicResult.TopicArn
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Topic created but aws returns invalid ata." )

        self.set( "id", id )
        console.info "Created topic resource", self

        if self.get("DisplayName")
          # Delay Modifying the display name, because sometimes
          # AWS might complain that the resource not found.
          setTimeout ()->
            ApiRequest("sns_SetTopicAttributes", {
              region_name : self.getCollection().region()
              topic_arn   : id
              attr_name   : "DisplayName"
              attr_value  : self.get("DisplayName")
            })
          , 1000

        self

    doUpdate : ( displayName )->
      self = @
      ApiRequest("sns_SetTopicAttributes", {
        region_name : @getCollection().region()
        topic_arn   : @get("id")
        attr_name   : "DisplayName"
        attr_value  : displayName
      }).then ()->
        self.set "DisplayName", displayName
        self

    doDestroy : ()->
      ApiRequest("sns_DeleteTopic", {
        region_name : @getCollection().region()
        topic_arn   : @get("id")
      })

  }
