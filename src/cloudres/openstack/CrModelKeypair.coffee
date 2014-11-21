
define [ "../CrModel", "ApiRequestOs" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrOsModelKeypair"
    ### env:dev:end ###

    defaults :
      name        : ""
      public_key  : ""
      fingerprint : ""

    idAttribute : "name"
    taggable: false

    doCreate : ()->
      self = @
      promise = ApiRequest("os_keypair_Create", {
        region : @getCollection().region()
        keypair_name : @get("name")
        public_key   : @get("public_key")
      })

      promise.then ( res )->
        console.log res
        try
          res = res.keypair
          self.set res
          keyName = res.name
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Keypair created but aws returns invalid data." )

        self.set 'name', keyName
        console.log "Created keypair resource", self
        self


    doDestroy : ()->
      ApiRequest("os_keypair_Delete", {
        region : @getCollection().region()
        keypair_name: @get("name")
      })
  }
