
define [ "../CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrEipModel"
    ### env:dev:end ###

    defaults :
      "publicIp": "",
      "allocationId": "",
      "domain": "",
      "instanceId": "",
      "associationId": "",
      "networkInterfaceId": "",
      "networkInterfaceOwnerId": "",
      "privateIpAddress": ""
      "canRelease": false

    idAttribute : "publicIp"
    taggable: false

    doCreate : ()->
      self = @
      @sendRequest("eip_AllocateAddress", { domain : @get("domain"), region_name: @get("region") }).then ( res )->
        try
          res = res.AllocateAddressResponse
          self.set res
          publicIp = res.publicIp
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Elastic IP created but aws returns invalid data." )

        self.set 'publicIp', publicIp
        self.set 'id', publicIp
        self.set 'category', self.get("region")
        self.set "canRelease", not res.associationId
        console.log "Created EIP resource", self
        self

    doDestroy : ()->
      ip = @get("id")
      allocation_id = @get("allocationId")
      if allocation_id then ip = undefined
      @sendRequest("eip_ReleaseAddress", {ip, allocation_id})

  }
