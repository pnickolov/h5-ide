
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrKeypairModel"
    ### env:dev:end ###

    defaults :
      keyData     : "" # If keyData is not null, it will use kp_ImportKeyPair to create the keypair.
      keyMaterial : "" # When a keypair is created, this might contain the private key data.

    doCreate : ()->
      self = @
      ApiRequest("dhcp_CreateDhcpOptions", {
        region_name  : @getCollection().region()
        dhcp_configs : @toAwsAttr()
      }).then ( res )->
        try
          id = res.CreateDhcpOptionsResponse.dhcpOptions.dhcpOptionsId
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Dhcp created but aws returns invalid ata." )

        self.set( "id", id )
        console.log "Created dhcp resource", self

        self

    doDestroy : ()->
      ApiRequest("kp_DeleteKeyPair", {
        region_name : @getCollection().region()
        key_name    : @get("id")
      })

  }
