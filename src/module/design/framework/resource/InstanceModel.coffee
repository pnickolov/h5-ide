
define [ "../ComplexResModel", "../CanvasManager", "../Design", "constant" ], ( ComplexResModel, CanvasManager, Design, constant )->

  Model = ComplexResModel.extend {

    ctype    : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
    defaults :
      x      : 2
      y      : 2
      width  : 9
      height : 9

    iconUrl : ()->
      ami = MC.data.dict_ami[ @get("imageId") ]

      if not ami
        return "ide/ami/ami-not-available.png"
      else
        return "ide/ami/" + ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"

    draw : ( isCreate ) ->

      if isCreate

        # Call parent's createNode to do basic creation
        node = @createNode({
          image  : @iconUrl()
          imageX : 30
          imageY : 15
          imageW : 39
          imageH : 27
          label  : @get "name"
          sg     : true
        })

        # Insert Instance's background
        children = node[0].children || node[0].childNodes

        node[0].insertBefore(
          Canvon.image( MC.IMG_URL + "ide/icon/instance-canvas.png", 15, 9, 61, 62 )[0],
          children[1]
        )

        # Insert Volume / Eip / Port
        icon_volume_status = "attached-active"
        node.append(
          # Volume Image
          Canvon.image( MC.IMG_URL + 'ide/icon/instance-volume-' + icon_volume_status + '.png' , 21, 44, 29, 24 ).attr({'id': @id + '_volume_status'}),
          # Volume Label
          Canvon.text( 35, 56, "0" ).attr({
            'id'    : @id + '_volume_number'
            'class' : 'node-label volume-number'
            'value' : 0
          }),
          # Volume Hotspot
          Canvon.rectangle(21, 44, 29, 24).attr({
            'data-target-id' : @id
            'class'          : 'instance-volume'
            'fill'           : 'none'
          }),

          # Eip
          Canvon.image( MC.canvas.IMAGE.EIP_ON, 53, 47, 12, 14).attr({
            'id'    : @id + '_eip_status'
            'class' : 'eip-status'
          }),

          # Child number
          Canvon.group().append(
            Canvon.rectangle(36, 1, 20, 16).attr({
              'class': 'instance-number-bg'
              'rx': 4
              'ry': 4
            }),

            Canvon.text(46, 13, "0").attr({
              'id'    : @id + '_instance-number'
              'class' : 'node-label instance-number'
            })
          ).attr({
            'id'    : @id + '_instance-number-group'
            'class' : 'instance-number-group'
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

        if not Design.instance().typeIsClassic()
          # Show RTB/ENI Port in VPC Mode
          node.append(
            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'             : @id + '_port-instance-attach'
              'class'          : 'port port-green port-instance-attach'
              'transform'      : 'translate(76, 45)' + MC.canvas.PORT_RIGHT_ROTATE
              'data-name'      : 'instance-attach'
              'data-position'  : 'right'
              'data-type'      : 'attachment'
              'data-direction' : 'out'
              'data-angle'     : MC.canvas.PORT_RIGHT_ANGLE
            })

            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'             : @id + '_port-instance-rtb'
              'class'          : 'port port-blue port-instance-rtb'
              'transform'      : 'translate(45, -8)' + MC.canvas.PORT_UP_ROTATE
              'data-name'      : 'instance-rtb'
              'data-position'  : 'top'
              'data-type'      : 'sg'
              'data-direction' : 'in'
              'data-angle'     : MC.canvas.PORT_UP_ANGLE
            })
          )

        if not Design.instance().modeIsStack()
          # instance-state
          node.append(
            Canvon.circle(68, 15, 5,{}).attr({
              'id'    : @id + '_instance-state'
              'class' : 'instance-state instance-state-unknown'
            })
          )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()

      # Update the node
      # TODO : Update Server number
      # TODO : Update Volume number
      # TODO : Update Eip indicator
      # TODO : Update Instance status

  }, {

    handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance, constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume ]

    deserialize : ( data, layout_data, resolve )->

      if data.type is constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume
        null

      else if data.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

        instance = new Model({

          id           : data.uid
          name         : data.name

          imageId : data.resource.ImageId

          x      : layout_data.coordinate[0]
          y      : layout_data.coordinate[1]
        })

        null


  }

  Model
