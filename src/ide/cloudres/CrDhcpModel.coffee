
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrDhcpModel"
    ### env:dev:end ###

    constructor : ( attr, options )->
      attr = @tryParseDhcpAttr( attr )
      CrModel.call this, attr, options

    tryParseDhcpAttr : ( attr )->
      if attr.dhcpConfigurationSet
        # This is something that's returned from AWS
        try
          for item in attr.dhcpConfigurationSet.item
            attr[ item.key ] = item.valueSet
          delete attr.dhcpConfigurationSet
        catch e

      attr

    toAwsAttr : ()->
      awsAttr = []
      for key, value of @attributes
        if key isnt "id" and key isnt "tagSet"
          awsAttr.push {
            Name  : key
            Value : value
          }
      awsAttr

    doCreate : ()->
      self = @
      ApiRequest("dhcp_CreateDhcpOptions", {
        region_name  : @getCollection().category
        dhcp_configs : @toAwsAttr()
      }).then ( res )->
        try
          id = res.CreateDhcpOptionsResponse.dhcpOptions.dhcpOptionsId
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Dhcp created but aws returns invalid ata." )
        self.set( "id", id )
        return

    doDestroy : ()->
      ApiRequest("dhcp_DeleteDhcpOptions", {
        region_name : @getCollection().category
        dhcp_id : @get("id")
      })

  }
