
define [ "../ComplexResModel", "../CanvasManager", "Design", "constant" ], ( ComplexResModel, CanvasManager, Design, constant )->

  Model = ComplexResModel.extend {

    type    : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
    defaults :
      x      : 2
      y      : 2
      width  : 9
      height : 9
      count  : 1

    __asso: [
      {
        key: 'KeyName'
        type: constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair
        suffix: 'KeyName'
      }
    ]

    remove : ()->
      this.__mainEni.remove()


    setEmbedEni : ( eni )->
      this.__mainEni = eni
      null

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
          Canvon.image( MC.IMG_URL + 'ide/icon/instance-volume-attached-active.png' , 21, 44, 29, 24 ).attr({'class':'volume-image'}),
          # Volume Label
          Canvon.text( 35, 56, "0" ).attr({
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
          Canvon.image( MC.canvas.IMAGE.EIP_ON, 53, 47, 12, 14).attr({'class':'eip-status'}),

          # Child number
          Canvon.group().append(
            Canvon.rectangle(36, 1, 20, 16).attr({'class':'server-number-bg','rx':4,'ry':4}),
            Canvon.text(46, 13, "0").attr({'class':'node-label server-number'})
          ).attr({
            'class'   : 'server-number-group'
            "display" : "none"
          }),


          # left port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-instance-sg-left'
            'class'      : 'port port-blue port-instance-sg port-instance-sg-left'
            'transform'  : 'translate(5, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
          }),

          # right port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-instance-sg-right'
            'class'      : 'port port-blue port-instance-sg port-instance-sg-right'
            'transform'  : 'translate(75, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
          })
        )

        if not Design.instance().typeIsClassic()
          # Show RTB/ENI Port in VPC Mode
          node.append(
            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'         : @id + '_port-instance-attach'
              'class'      : 'port port-green port-instance-attach'
              'transform'  : 'translate(78, 45)' + MC.canvas.PORT_RIGHT_ROTATE
              'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
            })

            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'         : @id + '_port-instance-rtb'
              'class'      : 'port port-blue port-instance-rtb'
              'transform'  : 'translate(42, -1)' + MC.canvas.PORT_UP_ROTATE
              'data-angle' : MC.canvas.PORT_UP_ANGLE
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
      # Update Server number
      numberGroup = node.children(".server-number-group")
      if @get("count") > 1
        CanvasManager.toggle node.children(".port-instance-rtb"), false
        CanvasManager.toggle numberGroup, true
        CanvasManager.update numberGroup.children("text"), @get("count")
      else
        CanvasManager.toggle node.children(".port-instance-rtb"), true
        CanvasManager.toggle numberGroup, false



      # TODO : Update Volume number
      # TODO : Update Eip indicator
      # TODO : Update Instance status

  }, {

    handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance, constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume ]

    deserialize : ( data, layout_data, resolve )->

      if data.type is constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume
        null

      else if data.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

        model = new Model({

          id    : data.uid
          name  : data.name
          count : data.number

          imageId : data.resource.ImageId

          x      : layout_data.coordinate[0]
          y      : layout_data.coordinate[1]
        })

        model.associate resolve
        null


  }

  Model
