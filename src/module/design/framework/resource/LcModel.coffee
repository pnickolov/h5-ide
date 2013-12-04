
define [ "../ComplexResModel", "../CanvasManager", "../Design", "constant" ], ( ComplexResModel, CanvasManager, Design, constant )->

  Model = ComplexResModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 9
      height   : 9

    ctype : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

    iconUrl : ()->
      ami = MC.data.dict_ami[ @get("imageId") ]

      if not ami
        return "ide/ami/ami-not-available.png"
      else
        return "ide/ami/" + ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"

    draw : ( isCreate )->

      if isCreate

        design = Design.instance()

        # Call parent's createNode to do basic creation
        node = @createNode({
          image   : "ide/icon/instance-canvas.png"
          imageX  : 15
          imageY  : 9
          imageW  : 61
          imageH  : 62
          label   : @get "name"
          labelBg : true
          sg      : true
        })

        # Insert Volume / Eip / Port
        node.append(
          # Ami Icon
          Canvon.image( MC.IMG_URL + @iconUrl(), 30, 15, 39, 27 ),

          # Volume Image
          Canvon.image( MC.IMG_URL + 'ide/icon/instance-volume-attached-active.png' , 31, 44, 29, 24 ).attr({'id': @id + '_volume_status'}),
          # Volume Label
          Canvon.text( 45, 56, "0" ).attr({
            'id'    : @id + '_volume_number'
            'class' : 'node-label volume-number'
            'value' : 0
          }),
          # Volume Hotspot
          Canvon.rectangle(31, 44, 29, 24).attr({
            'data-target-id' : @id
            'class'          : 'instance-volume'
            'fill'           : 'none'
          }),

          # left port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'             : @id + '_port-instance-sg-left'
            'class'          : 'port port-blue port-instance-sg port-instance-sg-left'
            'transform'      : 'translate(5, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-name'      : 'instance-sg'
            'data-position'  : 'left'
            'data-type'      : 'sg'
            'data-direction' : 'in'
            'data-angle'     : MC.canvas.PORT_LEFT_ANGLE
          }),

          # right port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'             : @id + '_port-instance-sg-right'
            'class'          : 'port port-blue port-instance-sg port-instance-sg-right'
            'transform'      : 'translate(75, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-name'      : 'instance-sg'
            'data-position'  : 'right'
            'data-type'      : 'sg'
            'data-direction' : 'out'
            'data-angle'     : MC.canvas.PORT_RIGHT_ANGLE
          })
        )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

    deserialize : ( data, layout_data, resolve )->

      new Model({

        id           : data.uid
        name         : data.name

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

  }

  Model

