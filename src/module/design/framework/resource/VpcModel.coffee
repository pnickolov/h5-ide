
define [ "constant", "../GroupModel", "./DhcpModel" ], ( constant, GroupModel, DhcpModel )->

  Model = GroupModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC

    defaults :
      dnsSupport   : true
      dnsHostnames : false
      tenancy      : "default"
      cidr         : "10.0.0.0/16"

      x      : 5
      y      : 3
      width  : 60
      height : 60

    initialize : ()->
      if not @attributes.dhcp
        @attributes.dhcp = new DhcpModel()

      @draw(true)
      null

    isRemovable : ()-> false # VPC is always undeletable

    isDefaultTenancy : ()-> @get("tenancy") isnt "dedicated"

    setTenancy : ( tenancy )->
      @set "tenancy", tenancy

      # Update all instance's tenancy
      if tenancy is "dedicated"
        for instance in Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance ).allObjects()
          instance.setTenancy( tenancy )

      null

    setCidr : ( cidr )->

      subnets = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet ).allObjects()
      shouldUpdateSubnetCidr = false
      subnetCidrAry = _.map subnets, ( sb )->
        subnetCidr = sb.get("cidr")
        if not MC.aws.subnet.isInVPCCIDR( cidr, subnetCidr )
          shouldUpdateSubnetCidr = true
        subnetCidr

      # Update all subnet's cidr
      if shouldUpdateSubnetCidr
        subnetCidrAry = @generateSubnetCidr( cidr, subnetCidrAry )
        if not subnetCidrAry then return false

        for sb, idx in subnets
          sb.setCidr( subnetCidrAry[idx] )

      @set("cidr", cidr)
      @draw()
      true

    generateSubnetCidr : ( newCidr, subnetCidrAry )->

      subnets = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet ).allObjects()

      subnetCidrAry = MC.aws.subnet.autoAssignSimpleCIDR( newCidr, subnetCidrAry, @get("cidr") )
      if not subnetCidrAry.length
        subnetCidrAry = MC.aws.subnet.autoAssignAllCIDR( newCidr, subnets.length )

      if subnetCidrAry.length != subnets.length
        return null

      return subnetCidrAry

    serialize : ()->
      console.assert( @get("tenancy") is "default" or @get("tenancy") is "dedicated", "Invalid value for Vpc.attributes.tenancy" )

      layout =
        size       : [ @width(), @height() ]
        coordinate : [ @x(), @y() ]
        uid        : @id

      dhcp = @get("dhcp")
      if dhcp.isNone()
        dhcp = "default"
      else if dhcp.isDefault()
        dhcp = ""
      else
        dhcp = dhcp.createRef( "DhcpOptionsId" )

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          EnableDnsSupport   : @get("dnsSupport")
          InstanceTenancy    : @get("tenancy")
          EnableDnsHostnames : @get("dnsHostnames")
          State              : ""
          DhcpOptionsId      : dhcp
          VpcId              : @get("appId")
          CidrBlock          : @get("cidr")
          IsDefault          : false

      { component : component, layout : layout }

  }, {

    handleTypes  : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC
    resolveFirst : true

    # Returns current VPC in this application.
    theVPC : ()->
      Design.instance().classCacheForCid( this.prototype.classId )[0]

    preDeserialize : ( data, layout_data )->

      # Create VPC
      vpc = new Model({

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

      # When creating a new VPC stack, the data has no id.
      # This is a hack, and it should be remove in the future.
      data.uid = vpc.id

      null

    deserialize : ( data, layout, resolve )->

      # The VPC has already created in preDeserialize().
      vpc = resolve( data.uid )

      # Create/Get a DHCP object for VPC

      # DhcpOptionsId is "default" means use no dhcp
      # DhcpOPtionsId is "" means use default dhcp
      dhcp = data.resource.DhcpOptionsId

      if not dhcp
        vpc.get("dhcp").setDefault()
      else if dhcp is "default"
        vpc.get("dhcp").setNone()
      else
        oldDhcp = vpc.get("dhcp")
        if oldDhcp then oldDhcp.remove()

        vpc.set( "dhcp", resolve( MC.extractID(dhcp) ) )
      null
  }

  Model
