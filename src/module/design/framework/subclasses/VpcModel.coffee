
define [ "constant", "../GroupModel", "../CanvasManager" ], ( constant, GroupModel, CanvasManager )->

  Model = GroupModel.extend {

    defaults :
      __x : 5
      __y : 3
      __w : 600
      __h : 600

    ctype       : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC
    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC


    draw : ( isCreate )->

      if isCreate
        node = @createNode( "vpc (#{@get('cidr')})" )
        $('#vpc_layer').append node

        # Move the group to right place
        CanvasManager.position node, @x(), @y()

  }, {

    deserialize : ( data, layout_data )->

      new Model({

        id           : data.uid
        name         : data.name

        cidr         : data.resource.CidrBlock
        dnsHostnames : MC.getBoolean( data.resource.EnableDnsHostnames )
        dnsSupport   : MC.getBoolean( data.resource.InstanceTenancy )
        tenancy      : data.resource.InstanceTenancy

        __x : layout_data.coordinate[0]
        __y : layout_data.coordinate[1]
        __w : layout_data.size[0]
        __h : layout_data.size[1]
      })

  }

  Model
