
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
        region_name : @getCollection().region()
        keypair_name    : @get("name")
        key_data    : @get("public_key")
      })

      promise.then ( res )->
        console.log res
        try
          res = res.CreateKeyPairResponse || res.ImportKeyPairResponse
          self.set res
          keyName = res.keyName
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Keypair created but aws returns invalid data." )

        self.set 'name', keyName
        console.log "Created keypair resource", self
        self


    doDestroy : ()->
      #TO-DO
      null

  }
