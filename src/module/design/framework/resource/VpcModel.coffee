
define [ "constant", "../GroupModel", "../CanvasManager", "./DhcpModel" ], ( constant, GroupModel, CanvasManager, DhcpModel )->

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

    initalize : ()->
      if not @attributes.dhcp
        @attributes.dhcp = new DhcpModel()
        null

    setName : ( name )->
      @set("name", name)
      @draw()
      null


    setCIDR : ( cidr )->

      # TODO : Update all subnet's cidr
      if not MC.aws.vpc.updateAllSubnetCIDR( cidr, @get("cidr") )
        return

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
        CanvasManager.update( @id + "_label", label )

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC

    deserialize : ( data, layout_data, resolve )->

      # Create/Get a DHCP object for VPC

      # DhcpOptionsId is "default" means use no dhcp
      # DhcpOPtionsId is "" means use default dhcp
      dhcp = data.resource.DhcpOptionsId

      if dhcp is ""
        dhcp = new DhcpModel( { dhcpType : "default" } )
      else if dhcp is "default"
        dhcp = new DhcpModel( { dhcpType : "none" } )
      else
        dhcp = resolve( MC.extractID( dhcp ) )

      # Create VPC
      new Model({

        id    : data.uid
        name  : data.name
        appId : data.resource.VpcId

        cidr         : data.resource.CidrBlock
        dnsHostnames : MC.getBoolean( data.resource.EnableDnsHostnames )
        dnsSupport   : MC.getBoolean( data.resource.EnableDnsSupport )
        tenancy      : data.resource.InstanceTenancy
        dhcp         : dhcp

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]
      })

      null

  }

  Model
