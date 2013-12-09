
define [ "../ComplexResModel", "../CanvasManager", "Design", "constant" ], ( ComplexResModel, CanvasManager, Design, constant )->

  Model = ComplexResModel.extend {

    defaults :
      internal : true
      x        : 0
      y        : 0
      width    : 9
      height   : 9

    type : constant.AWS_RESOURCE_TYPE.AWS_ELB

    iconUrl : ()->
      "ide/icon/elb-" + (if @get("internal") then "internal-canvas.png" else "internet-canvas.png")

    draw : ( isCreate )->

      if isCreate

        design = Design.instance()

        # Call parent's createNode to do basic creation
        node = @createNode({
          image  : @iconUrl()
          imageX : 9
          imageY : 11
          imageW : 70
          imageH : 53
          label  : @get "name"
          sg     : not design.typeIsClassic()
        })

        # Port
        if not design.typeIsClassic()
          node.append(
            # Left
            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'         : @id + '_port-elb-sg-in'
              'class'      : 'port port-blue port-elb-sg-in'
              'transform'  : 'translate(2, 30)' + MC.canvas.PORT_RIGHT_ROTATE
              'data-angle' : MC.canvas.PORT_LEFT_ANGLE
            }),
            # Right gray
            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'         : @id + '_port-elb-assoc'
              'class'      : 'port port-gray port-elb-assoc'
              'transform'  : 'translate(79, 45)' + MC.canvas.PORT_RIGHT_ROTATE
              'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
            })
          )

        node.append(
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-elb-sg-out'
            'class'      : 'port port-blue port-elb-sg-out'
            'transform'  : 'translate(79, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
          })
        )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_ELB

    deserialize : ( data, layout_data, resolve )->

      new Model({

        id           : data.uid
        name         : data.name

        internal : data.resource.Scheme is 'internal'

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

  }

  Model
