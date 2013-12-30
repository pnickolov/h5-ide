
define [ "../ComplexResModel", "CanvasManager", "Design", "constant" ], ( ComplexResModel, CanvasManager, Design, constant )->

  Model = ComplexResModel.extend {

    type    : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
    defaults :
      x      : 2
      y      : 2
      width  : 9
      height : 9

      #servergroup
      serverGroupUid  : ''
      serverGroupName : ''
      number          : 1

      imageId         : ''
      tenancy         : ''

      #layout property
      osType         : ''
      architecture   : ''
      rootDeviceType : ''

      parent         : null #subnet model or az model


    constructor : ( attributes, option )->

      ComplexResModel.call this, attributes, option

      null


    __asso: [
      {
        key: 'KeyName'
        type: constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair
        suffix: 'KeyName'
      }
    ]

    getAmi : ()->
      MC.data.config[MC.canvas_data.region].ami[ @get("imageId") ]

    remove : ()->
      this.__mainEni.remove()

    setName : ( name )->

      if @get("name") is name
        return

      @set "name", name
      @set "serverGroupName", name

      if @draw then @draw()
      null

    setEmbedEni : ( eni )->
      this.__mainEni = eni
      null

    iconUrl : ()->
      ami = MC.data.dict_ami[ @get("imageId") ]

      if not ami
        _osType         = @get("osType")
        _architecture   = @get("architecture")
        _rootDeviceType = @get("rootDeviceType")
        if _osType and _architecture and _rootDeviceType
          return "ide/ami/" + _osType + "." + _architecture + "." + _rootDeviceType + ".png"
        else
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
            'data-name'     : 'instance-sg' #for identify port
            'data-position' : 'left' #port position: for calc point of junction
            'data-type'     : 'sg'   #color of line
            'data-direction': 'in'   #direction
          }),

          # right port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-instance-sg-right'
            'class'      : 'port port-blue port-instance-sg port-instance-sg-right'
            'transform'  : 'translate(75, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
            'data-name'     : 'instance-sg'
            'data-position' : 'right'
            'data-type'     : 'sg'
            'data-direction': 'out'
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
              'data-name'     : 'instance-attach'
              'data-position' : 'right'
              'data-type'     : 'attachment'
              'data-direction': 'out'
            })

            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'         : @id + '_port-instance-rtb'
              'class'      : 'port port-blue port-instance-rtb'
              'transform'  : 'translate(42, -1)' + MC.canvas.PORT_UP_ROTATE
              'data-angle' : MC.canvas.PORT_UP_ANGLE
              'data-name'     : 'instance-rtb'
              'data-position' : 'top'
              'data-type'     : 'sg'
              'data-direction': 'in'
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
      if @get("number") > 1
        CanvasManager.toggle node.children(".port-instance-rtb"), false
        CanvasManager.toggle numberGroup, true
        CanvasManager.update numberGroup.children("text"), @get("number")
      else
        CanvasManager.toggle node.children(".port-instance-rtb"), true
        CanvasManager.toggle numberGroup, false

      # update label
      MC.canvas.update( @id, "text", "hostname", @get("name") )

      # TODO : Update Volume number
      # TODO : Update Eip indicator
      # TODO : Update Instance status

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

    deserialize : ( data, layout_data, resolve )->

      if data.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        attr =
          id    : data.uid
          name  : data.name

          #servergroup
          serverGroupUid  : data.serverGroupUid
          serverGroupName : data.serverGroupName
          number          : data.number

          imageId : data.resource.ImageId
          tenancy : data.resource.Placement.Tenancy

          x      : layout_data.coordinate[0]
          y      : layout_data.coordinate[1]

          #layout property
          osType         : layout_data.osType
          architecture   : layout_data.architecture
          rootDeviceType : layout_data.rootDeviceType



        if data.resource.SubnetId
          attr.parent = resolve( MC.extractID( data.resource.SubnetId ) )
        else
          attr.parent = resolve( MC.extractID( data.resource.Placement.AvailabilityZone ) )

        for key, value of data.resource
          attr[ key ] = value

        model = new Model attr

        model.associate resolve
        null


  }

  Model
