
define [ "constant", "../GroupModel", "../CanvasManager" ], ( constant, GroupModel, CanvasManager )->

  Model = GroupModel.extend {

    ctype    : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
    defaults :
      x      : 2
      y      : 2
      width  : 17
      height : 17

    draw : ( isCreate )->

      if isCreate
        node = @createNode( @get("name") )

        portX = @width()  * MC.canvas.GRID_WIDTH + 4
        portY = @height() * MC.canvas.GRID_HEIGHT / 2 - 6

        node.append( Canvon.path( MC.canvas.PATH_D_PORT ).attr({
          'class'          : 'port port-gray port-subnet-assoc-in'
          'id'             : @id + '_port-subnet-assoc-in'
          'transform'      : 'translate(-12, ' + portY + ')' # port poition
          'data-name'      : 'subnet-assoc-in' # for identify port
          'data-position'  : 'left' # port position: for calc point of junction
          'data-type'      : 'association' # color of line
          'data-direction' : 'in' # direction
          'data-angle'     : MC.canvas.PORT_LEFT_ANGLE # port angle
        }) )

        node.append( Canvon.path( MC.canvas.PATH_D_PORT ).attr({
          'class'          : 'port port-gray port-subnet-assoc-out'
          'id'             : @id + '_port-subnet-assoc-out'
          'transform'      : 'translate(' + portX + ', ' + portY + ')'
          'data-name'      : 'subnet-assoc-out'
          'data-position'  : 'right'
          'data-type'      : 'association'
          'data-direction' : 'out'
          'data-angle'     : MC.canvas.PORT_RIGHT_ANGLE
        }) )

        $('#subnet_layer').append node

        # Move the group to right place
        CanvasManager.position node, @x(), @y()

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet

    deserialize : ( data, layout_data )->

      new Model({

        id   : data.uid
        name : data.name

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]
      })
  }

  Model
