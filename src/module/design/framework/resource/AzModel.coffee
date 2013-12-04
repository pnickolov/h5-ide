
define [ "../GroupModel", "constant" ], ( GroupModel, constant )->

  # AzModel doesn't have deserialize() method, because it doesn't

  Model = GroupModel.extend {

    ctype : constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

    defaults :
      x      : 2
      y      : 2
      width  : 21
      height : 21

    draw : ( isCreate ) ->

      if isCreate
        node = @createNode( @get "name" )
        $('#az_layer').append node

        # Move the group to right place
        CanvasManager.position node, @x(), @y()

  }

  Model
