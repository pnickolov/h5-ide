
define [ "constant", "../ResourceModel"  ], ( constant, ResourceModel )->

  configNameMap = {
    "domain-name"          : "domainName"
    "domain-name-servers"  : "domainNameServers"
    "ntp-servers"          : "ntpServers"
    "netbios-name-servers" : "netbiosServers"
    "netbios-node-type"    : "netbiosType"
  }

  formatConfigSet = ( configSet )->
    config = {
      amazonDNS : false
    }

    for i in configSet

      if key is "domain-name"
        config.domainName = i.ValueSet[0].Value
      else if key is "netbios-node-type"
        config.netbiosType = i.ValueSet[0].Value
      else

        value = []
        for v in i.ValueSet
          if v.Value is "AmazonProvidedDNS"
            config.amazonDNS = true
          else
            value.push v.Value

        config[ configNameMap[ i.Key ] ] = value

    config


  Model = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions

    defaults :
      amazonDNS  : true
      domainName : ""

    isNone : ()->
      @attributes.dhcpType is "none"

    isDefault : ()->
      @attributes.dhcpType is "default"


  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions

    deserialize : ( data, layout_data )->

      attr = if data.resource.DhcpConfigurationSet then formatConfigSet( data.resource.DhcpConfigurationSet ) else {}

      attr.id = data.uid

      new Model( attr )
  }

  Model
