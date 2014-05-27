
define [ "constant", "../ResourceModel", "Design"  ], ( constant, ResourceModel, Design )->

  configNameMap = {
    "domain-name"          : "domainName"
    "domain-name-servers"  : "domainServers"
    "ntp-servers"          : "ntpServers"
    "netbios-name-servers" : "netbiosServers"
    "netbios-node-type"    : "netbiosType"
  }

  revertArray = ( array )->
    newArray = []
    for i in array
      newArray.push({ Value : i })

    newArray

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
    type : constant.RESTYPE.DHCP

    defaults : ()->
      dhcpType       : "" # "none" || "default" || ""
      amazonDNS      : true
      domainName     : ""
      netbiosType    : 0
      domainServers  : []
      ntpServers     : []
      netbiosServers : []

    isNone     : ()-> @attributes.dhcpType is "none"
    isDefault  : ()-> @attributes.dhcpType is "default"
    isCustom   : ()-> @attributes.dhcpType is ""

    setNone    : ()-> @set "dhcpType", "none"
    setDefault : ()-> @set "dhcpType", "default"
    setCustom  : ()-> @set "dhcpType", ""

    set : ()->
      if Array::slice.call(arguments)[1] is true
          @newId = @design().guid()
      if @design().modeIsAppEdit() and not @__newIdForAppEdit
        @__newIdForAppEdit = @design().guid()

      Backbone.Model.prototype.set.apply this, arguments

    createRef : ( refName, isResourceNS, id )->
      if not id
        id = @__newIdForAppEdit or @newId or @id

      ResourceModel.prototype.createRef.call this, refName, isResourceNS, id

    serialize : ()->

      if not @isCustom()
        return

      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).theVPC()

      configs = []
      attr    = @attributes

      if @__newIdForAppEdit
        id = @__newIdForAppEdit
        appId = ""
      else if @newId
          id = @newId
          appId = @get('appId')
      else
        id = @id
        appId = @get("appId")

      component =
        name : "DhcpOption"
        type : @type
        uid  : id
        resource :
          DhcpOptionsId        : if @newId then @id else appId
          VpcId                : vpc.createRef( "VpcId" )
          DhcpConfigurationSet : configs


      if attr.domainName
        configs.push({ Key : "domain-name", ValueSet :[{ Value : attr.domainName }] })

      if attr.ntpServers.length
        configs.push({
          Key : "ntp-servers"
          ValueSet : revertArray( attr.ntpServers )
        })

      if attr.netbiosServers.length
        configs.push({
          Key : "netbios-name-servers"
          ValueSet : revertArray( attr.netbiosServers )
        })

      if attr.domainServers.length or attr.amazonDNS
        values = revertArray( attr.domainServers )
        if attr.amazonDNS then values.splice( 0, 0, {Value:"AmazonProvidedDNS"} )
        configs.push({ Key : "domain-name-servers", ValueSet : values })

      if attr.netbiosType
        configs.push({ Key : "netbios-node-type", ValueSet:[{ Value : attr.netbiosType }] })

      { component : component }

  }, {

    handleTypes : constant.RESTYPE.DHCP

    deserialize : ( data, layout_data )->

      attr = if data.resource.DhcpConfigurationSet then formatConfigSet( data.resource.DhcpConfigurationSet ) else {}

      attr.id    = data.uid
      attr.appId = data.resource.DhcpOptionsId

      new Model( attr )
      null
  }

  Model
