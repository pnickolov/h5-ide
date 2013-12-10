
define [ "constant", "../ResourceModel"  ], ( constant, ResourceModel )->

  configNameMap = {
    "domain-name"          : "domainName"
    "domain-name-servers"  : "domainServers"
    "ntp-servers"          : "ntpServers"
    "netbios-name-servers" : "netbiosServers"
    "netbios-node-type"    : "netbiosType"
  }

  formatConfigSet = ( configSet )->
    config = {
      amazonDNS : false
    }

    for i in configSet

      if i.Key is "domain-name"
        config.domainName = i.ValueSet[0].Value
      else if i.Key is "netbios-node-type"
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
      dhcpType       : "" # "none" || "default" || ""
      amazonDNS      : true
      domainName     : ""
      netbiosType    : 0
      domainServers  : []
      ntpServers     : []
      netbiosServers : []

    isNone : ()->
      @attributes.dhcpType is "none"

    isDefault : ()->
      @attributes.dhcpType is "default"

    setNone    : ()-> @set "dhcpType", "none"
    setDefault : ()-> @set "dhcpType", "default"
    setCustom  : ()-> @set "dhcpType", ""

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions

    deserialize : ( data, layout_data )->

      attr = if data.resource.DhcpConfigurationSet then formatConfigSet( data.resource.DhcpConfigurationSet ) else {}

      attr.id = data.uid

      new Model( attr )
  }

  Model
