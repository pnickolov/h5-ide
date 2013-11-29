
define [ "constant", "../GroupModel", "../CanvasManager" ], ( constant, GroupModel, CanvasManager )->

  Model = GroupModel.extend {

    ctype       : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet

    draw : ( isCreate )->

      if isCreate
        node = @createNode( @get("name") )
        $('#subnet_layer').append node

        # Move the group to right place
        CanvasManager.position node, @x(), @y()

  }, {

    deserialize : ( data, layout_data )->

      new Model({

        id           : data.uid
        name         : data.name

        __x : layout_data.coordinate[0]
        __y : layout_data.coordinate[1]
        __w : layout_data.size[0]
        __h : layout_data.size[1]
      })
  }

  Model
