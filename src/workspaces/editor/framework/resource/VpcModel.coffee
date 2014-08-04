
define [ "constant", "../GroupModel", "./DhcpModel" ], ( constant, GroupModel, DhcpModel )->

  Model = GroupModel.extend {

    type : constant.RESTYPE.VPC

    defaults :
      dnsSupport   : true
      dnsHostnames : false
      tenancy      : "default"
      cidr         : "10.0.0.0/16"

    initialize : ()->
      if not @attributes.dhcp
        @attributes.dhcp = new DhcpModel()
      null

    isRemovable : ()-> false # VPC is always undeletable

    isDefaultTenancy : ()-> @get("tenancy") isnt "dedicated"

    setTenancy : ( tenancy )->
      @set "tenancy", tenancy

      # Update all instance's tenancy
      if tenancy is "dedicated"
        for instance in Design.modelClassForType( constant.RESTYPE.INSTANCE ).allObjects()
          instance.setTenancy( tenancy )

      null

    setCidr : ( cidr )->
      SubnetModel = Design.modelClassForType(constant.RESTYPE.SUBNET)

      subnets = SubnetModel.allObjects()
      shouldUpdateSubnetCidr = false
      subnetCidrAry = _.map subnets, ( sb )->
        subnetCidr = sb.get("cidr")
        if not SubnetModel.isInVPCCIDR( cidr, subnetCidr )
          shouldUpdateSubnetCidr = true
        subnetCidr

      # Update all subnet's cidr
      if shouldUpdateSubnetCidr
        subnetCidrAry = @generateSubnetCidr( cidr, subnetCidrAry )
        if not subnetCidrAry then return false

        for sb, idx in subnets
          sb.setCidr( subnetCidrAry[idx] )

      validCIDR = MC.getValidCIDR(cidr)
      @set("cidr", validCIDR)
      true

    generateSubnetCidr : ( newCidr, subnetCidrAry )->

      SubnetModel = Design.modelClassForType( constant.RESTYPE.SUBNET )

      subnets = SubnetModel.allObjects()

      subnetCidrAry = SubnetModel.autoAssignSimpleCIDR( newCidr, subnetCidrAry, @get("cidr") )
      if not subnetCidrAry.length
        subnetCidrAry = SubnetModel.autoAssignAllCIDR( newCidr, subnets.length )

      if subnetCidrAry.length != subnets.length
        return null

      return subnetCidrAry

    serialize : ()->
      console.assert( @get("tenancy") is "default" or @get("tenancy") is "dedicated", "Invalid value for Vpc.attributes.tenancy" )

      dhcpModel = @get("dhcp")
      if dhcpModel.isAuto()
        dhcp = ""
      else if dhcpModel.isDefault()
        dhcp = "default"
      else
        dhcp = dhcpModel.getDhcp()
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          EnableDnsSupport   : @get("dnsSupport")
          InstanceTenancy    : @get("tenancy")
          EnableDnsHostnames : @get("dnsHostnames")
          DhcpOptionsId      : dhcp
          VpcId              : @get("appId")
          CidrBlock          : @get("cidr")

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes  : constant.RESTYPE.VPC
    resolveFirst : true

    # Returns current VPC in this application.
    theVPC : ()->
      Design.instance().classCacheForCid( this.prototype.classId )[0]

    preDeserialize : ( data, layout_data )->
      # Create VPC
      new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.VpcId

        cidr         : data.resource.CidrBlock
        dnsHostnames : data.resource.EnableDnsHostnames
        dnsSupport   : data.resource.EnableDnsSupport
        tenancy      : data.resource.InstanceTenancy

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]
      })
      null

    deserialize : ( data, layout, resolve )->

      # The VPC has already created in preDeserialize().
      vpc = resolve( data.uid )

      # Create/Get a DHCP object for VPC

      # DhcpOptionsId is "default" means use no dhcp
      # DhcpOPtionsId is "" means use default dhcp
      dhcp = data.resource.DhcpOptionsId
      if dhcp is undefined
        vpc.get('dhcp').setAuto()
      else if not dhcp
        vpc.get("dhcp").setAuto()
      else if dhcp is "default"
        vpc.get("dhcp").setDefault()
      else if dhcp[0] is "@"
        oldDhcp = vpc.get("dhcp")
        if oldDhcp then oldDhcp.remove()
        vpc.set( "dhcp", resolve( MC.extractID(dhcp) ) )
      else
        vpc.get("dhcp").setDhcp(dhcp)
      null
  }

  Model
