
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrKeypairModel"
    ### env:dev:end ###

    defaults :
      keyName        : ""
      keyData        : "" # If keyData is not null, it will use kp_ImportKeyPair to create the keypair.
      keyMaterial    : "" # When a keypair is created, this might contain the private key data.
      keyFingerprint : ""

    idAttribute : "keyName"
    taggable: false

    doCreate : ()->
      self = @
      if @get("keyData")
        promise = ApiRequest("kp_ImportKeyPair", {
          region_name : @getCollection().region()
          key_name    : @get("keyName")
          key_data    : @get("keyData")
        })
      else
        promise = ApiRequest("kp_CreateKeyPair", {
          region_name : @getCollection().region()
          key_name    : @get("keyName")
        })

      promise.then ( res )->
        try
          res = res.CreateKeyPairResponse || res.ImportKeyPairResponse
          self.set res
          keyName = res.keyName
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Keypair created but aws returns invalid data." )

        self.set 'keyName', keyName
        console.log "Created keypair resource", self
        self

    doDestroy : ()->
      ApiRequest("kp_DeleteKeyPair", {
        region_name : @getCollection().region()
        key_name    : @get("id")
      })

  }
