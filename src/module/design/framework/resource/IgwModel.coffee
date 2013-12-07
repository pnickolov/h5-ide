
define [ "../ComplexResModel", "../CanvasManager", "../Design", "constant" ], ( ComplexResModel, CanvasManager, Design, constant )->

  Model = ComplexResModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 8
      height   : 8

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway

    draw : ( isCreate )->

      if isCreate

        design = Design.instance()

        # Call parent's createNode to do basic creation
        node = @createNode({
          image   : "ide/icon/igw-canvas.png"
          imageX  : 10
          imageY  : 16
          imageW  : 60
          imageH  : 46
          label   : @get("name")
        })

        node.append(
          # Port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-igw-tgt'
            'class'      : 'port port-blue port-igw-tgt'
            'transform'  : 'translate(70, 30)' + MC.canvas.PORT_LEFT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
          })
        )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway

    deserialize : ( data, layout_data, resolve )->

      new Model({

        id           : data.uid
        name         : data.name

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

  }

  Model

