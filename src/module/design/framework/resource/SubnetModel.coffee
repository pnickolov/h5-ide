
define [ "constant", "Design", "../GroupModel", "../CanvasManager", "../connection/RtbAsso" ], ( constant, Design, GroupModel, CanvasManager, RtbAsso )->

  Model = GroupModel.extend {

    type    : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
    defaults :
      x      : 2
      y      : 2
      width  : 17
      height : 17

    initialize : ()->
      # Connect to the MainRT automatically
      RtbModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )
      new RtbAsso( this, RtbModel.getMainRouteTable(), { implicit : true } )
      null


    # Association is the connection between RTB and Subnet
    getAssociation : ()-> @rtb_asso
    setAssociation : ( connection )->
      @rtb_asso = connection
      null

    connect : ( connection ) ->

      if connection.type is "RTB_Asso"
        # Remove previous association if there's any
        if @rtb_asso then @rtb_asso.remove()
        @rtb_asso = connection

      null


    draw : ( isCreate )->

      if isCreate
        node = @createNode( @get("name") )

        portX = @width()  * MC.canvas.GRID_WIDTH + 4
        portY = @height() * MC.canvas.GRID_HEIGHT / 2 - 5

        node.append( Canvon.path( MC.canvas.PATH_D_PORT ).attr({
          'class'      : 'port port-gray port-subnet-assoc-in'
          'id'         : @id + '_port-subnet-assoc-in'
          'transform'  : 'translate(-12, ' + portY + ')' # port poition
          'data-angle' : MC.canvas.PORT_LEFT_ANGLE # port angle
        }) )

        node.append( Canvon.path( MC.canvas.PATH_D_PORT ).attr({
          'class'      : 'port port-gray port-subnet-assoc-out'
          'id'         : @id + '_port-subnet-assoc-out'
          'transform'  : 'translate(' + portX + ', ' + portY + ')'
          'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
        }) )

        $('#subnet_layer').append node

        # Move the group to right place
        CanvasManager.position node, @x(), @y()

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet

    deserialize : ( data, layout_data )->

      az = Design.instance().getAZ( data.resource.AvailabilityZone )

      subnet = new Model({

        id   : data.uid
        name : data.name

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]
      })

      az.addChild( subnet )

      null
  }

  Model
