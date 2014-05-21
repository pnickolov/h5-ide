
define [ "./CrModel", "constant" ], ( CrModel, constant )->

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

  }
