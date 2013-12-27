
define [ "constant", "../GroupModel", "CanvasManager", "./DhcpModel" ], ( constant, GroupModel, CanvasManager, DhcpModel )->

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
        null

    setCIDR : ( cidr )->

      # TODO : Update all subnet's cidr
      if not MC.aws.vpc.updateAllSubnetCIDR( cidr, @get("cidr") )
        return false

      @set("cidr", cidr)
      @draw()

      null

    draw : ( isCreate )->

      label = "#{@get('name')} (#{ @get('cidr')})"

      if isCreate
        node = @createNode( label )
        $('#vpc_layer').append node

        # Move the group to right place
        CanvasManager.position node, @x(), @y()

      else
        CanvasManager.update( $( document.getElementById( @id ) ).children("text"), label )

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
        vpc.set("dhcp", resolve( MC.extractID( dhcp ) ) )

      null
  }

  Model
