
define [ "../CrModel", "ApiRequestOs" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrOsModelSnapshot"
    ### env:dev:end ###

    defaults :
      status        : ""
      description   : ""
      created_at    : ""
      name          : ""
      volume_id     : ""
      size          : ""
      id            : ""
      metadata      : ""

    #idAttribute : "id"
    taggable: false

    doCreate : ()->
      self = @
      promise = ApiRequest("os_snapshot_Create", {
        region : @getCollection().region()
        display_name: @get("name")
        volume_id:  @get('volume_id')
        display_description: @get("description")
        is_force: true
      })

      promise.then ( res )->
        console.log res
        try
          res = res.snapshot
          self.set res
          name = res.name
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Keypair created but aws returns invalid data." )

        self.set 'name', name
        console.log "Created keypair resource", self
        self



    doDestroy : ()->
      ApiRequest("os_snapshot_Delete", {
        region : @getCollection().region()
        snapshot_id: @get("id")
      })

  }
