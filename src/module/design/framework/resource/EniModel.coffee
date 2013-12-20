
define [ "../ComplexResModel", "../CanvasManager", "Design", "../connection/SgAsso", "../connection/EniAttachment", "constant" ], ( ComplexResModel, CanvasManager, Design, SgAsso, EniAttachment, constant )->

  Model = ComplexResModel.extend {

    defaults :
      embed : false

      x        : 0
      y        : 0
      width    : 9
      height   : 9

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

    iconUrl : ()->
      "ide/icon/eni-canvas-attached.png"

    draw : ( isCreate )->

      if @get("embed")
        # Do nothing if this is embed eni, a.k.a the internal eni of an Instance
        return

      if isCreate

        design = Design.instance()

        # Call parent's createNode to do basic creation
        node = @createNode({
          image   : @iconUrl()
          imageX  : 16
          imageY  : 15
          imageW  : 59
          imageH  : 49
          label   : @get("name")
          labelBg : true
          sg      : true
        })

        node.append(
          Canvon.image( MC.canvas.IMAGE.EIP_ON, 44, 37, 12, 14 ).attr({
            'id'    : @id + '_eip_status'
            'class' : 'eip-status'
          }),

          # Left Port
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-eni-sg-left'
            'class'      : 'port port-blue port-eni-sg port-eni-sg-left'
            'transform'  : 'translate(5, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
          }),

          # Left port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-eni-attach'
            'class'      : 'port port-green port-eni-attach'
            'transform'  : 'translate(8, 45)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
          }),

          # Right port
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-eni-sg-right'
            'class'      : 'port port-blue port-eni-sg port-eni-sg-right'
            'transform'  : 'translate(75, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
          }),

          # Top port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-eni-rtb'
            'class'      : 'port port-blue port-eni-rtb'
            'transform'  : 'translate(42, -1)' + MC.canvas.PORT_UP_ROTATE
            'data-angle' : MC.canvas.PORT_UP_ANGLE
          }),

          Canvon.group().append(
            Canvon.rectangle(35, 3, 20, 16).attr({
              'class' : 'eni-number-bg'
              'rx'    : 4
              'ry'    : 4
            }),
            Canvon.text(45, 15, "0").attr({
              'id'    : @id + '_eni-number'
              'class' : 'node-label eni-number'
            })
          ).attr({
            'id'      : @id + '_eni-number-group'
            'class'   : 'eni-number-group'
            'display' : "none"
          })

        )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

    deserialize : ( data, layout_data, resolve )->

      attachment = data.resource.Attachment

      embed = false
      if attachment
        embed    = attachment.DeviceIndex is "0"
        instance = resolve( MC.extractID attachment.InstanceId )

      eni = new Model({

        id   : data.uid
        name : data.name

        embed : embed

        x : if embed then 0 else layout_data.coordinate[0]
        y : if embed then 0 else layout_data.coordinate[1]
      })

      if data.resource.GroupSet
        sgTarget = if embed then instance else eni
        for group in data.resource.GroupSet
          new SgAsso( sgTarget, resolve( MC.extractID( group.GroupId ) ) )

      if attachment and attachment.DeviceIndex isnt "0"
        new EniAttachment( eni, resolve( MC.extractID( attachment.InstanceId ) ) )

      null

  }

  Model

