
define [ "../GroupModel", "CanvasManager", "./VpcModel", "constant" ], ( GroupModel, CanvasManager, VpcModel, constant )->

  Model = GroupModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

    defaults :
      x      : 2
      y      : 2
      width  : 21
      height : 21

    initialize : ()->
      vpc = VpcModel.theVPC()
      if vpc
        vpc.addChild( @ )
      null

    draw : ( isCreate ) ->

      if isCreate
        node = @createNode( @get "name" )
        $('#az_layer').append node

        # Move the group to right place
        CanvasManager.position node, @x(), @y()

      else
        CanvasManager.update( $( document.getElementById( @id ) ).children("text"), @get("name") )

  }, {
    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.name

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]
      })
      null

    getAzByName : ( name )->
      for az in Model.allObjects()
        if az.get("name") is name
          return az
      null
  }

  Model
