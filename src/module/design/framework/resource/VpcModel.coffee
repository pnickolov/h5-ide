
define [ "constant", "../GroupModel", "../CanvasManager" ], ( constant, GroupModel, CanvasManager )->

  Model = GroupModel.extend {

    ctype    : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC

    defaults :
      dnsSupport   : true
      dnsHostnames : false
      tenancy      : "default"
      cidr         : "10.0.0.0/16"

      x      : 5
      y      : 3
      width  : 60
      height : 60

    draw : ( isCreate )->

      if isCreate
        node = @createNode( "vpc (" + @get('cidr') + ")" )
        $('#vpc_layer').append node

        # Move the group to right place
        CanvasManager.position node, @x(), @y()

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC
    deserialize : ( data, layout_data )->

      new Model({

        id           : data.uid
        name         : data.name

        cidr         : data.resource.CidrBlock
        dnsHostnames : MC.getBoolean( data.resource.EnableDnsHostnames )
        dnsSupport   : MC.getBoolean( data.resource.InstanceTenancy )
        tenancy      : data.resource.InstanceTenancy

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]
      })

      null

  }

  Model
