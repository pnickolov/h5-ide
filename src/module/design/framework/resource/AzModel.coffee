
define [ "../GroupModel", "CanvasManager", "./VpcModel", "constant", "i18n!nls/lang.js" ], ( GroupModel, CanvasManager, VpcModel, constant, lang )->

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

      @draw()
      null

    isRemovable : ()->
      # Return a warning, so that AZ's children will not be checked. ( Otherwise, Subnet will be check if it's connected to an ELB )
      sprintf lang.ide.CVS_CFM_DEL_GROUP, @get("name")

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

    # Get all az, including unused az.
    allPossibleAZ : ()->
      azMap = {}

      for az in Model.allObjects()
        azMap[ az.get("name") ] = az.id

      zones = MC.data.config[ Design.instance().region() ].zone
      if zones
        for z in zones.item
          if not azMap.hasOwnProperty( z.zoneName )
            azMap[ z.zoneName ] = ""

      azArr = []
      for azName, id of azMap
        azArr.push {
          name : azName
          id   : id
        }

      azArr


    getAzByName : ( name )->
      for az in Model.allObjects()
        if az.get("name") is name
          return az
      null
  }

  Model
