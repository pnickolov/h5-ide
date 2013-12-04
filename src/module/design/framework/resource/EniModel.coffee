
define [ "../ComplexResModel", "../CanvasManager", "../Design", "constant" ], ( ComplexResModel, CanvasManager, Design, constant )->

  Model = ComplexResModel.extend {

    defaults :
      primary  : false

      x        : 0
      y        : 0
      width    : 9
      height   : 9

    ctype : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

    iconUrl : ()->
      "ide/icon/eni-canvas-attached.png"

    draw : ( isCreate )->

      if @get("primary")
        # Do nothing if this is primary eni, a.k.a the internal eni of an Instance
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
            'id'             : @id + '_port-eni-sg-left'
            'class'          : 'port port-blue port-eni-sg port-eni-sg-left'
            'transform'      : 'translate(5, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-name'      : 'eni-sg'
            'data-position'  : 'left'
            'data-type'      : 'sg'
            'data-direction' : "in"
            'data-angle'     : MC.canvas.PORT_LEFT_ANGLE
          }),

          # Left port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'             : @id + '_port-eni-attach'
            'class'          : 'port port-green port-eni-attach'
            'transform'      : 'translate(8, 45)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-name'      : 'eni-attach'
            'data-position'  : 'left'
            'data-type'      : 'attachment'
            'data-direction' : "in"
            'data-angle'     : MC.canvas.PORT_LEFT_ANGLE
          }),

          # Right port
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'             : @id + '_port-eni-sg-right'
            'class'          : 'port port-blue port-eni-sg port-eni-sg-right'
            'transform'      : 'translate(75, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-name'      : 'eni-sg'
            'data-position'  : 'right'
            'data-type'      : 'sg'
            'data-direction' : 'out'
            'data-angle'     : MC.canvas.PORT_RIGHT_ANGLE
          }),

          # Top port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'             : @id + '_port-eni-rtb'
            'class'          : 'port port-blue port-eni-rtb'
            'transform'      : 'translate(42, -1)' + MC.canvas.PORT_UP_ROTATE
            'data-name'      : 'eni-rtb'
            'data-position'  : 'top'
            'data-type'      : 'sg'
            'data-direction' : 'in'
            'data-angle'     : MC.canvas.PORT_UP_ANGLE
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

      primary = false
      if data.resource.PrivateIpAddressSet and data.resource.PrivateIpAddressSet[0]
        primary = MC.getBoolean( data.resource.PrivateIpAddressSet[0].Primary )

      new Model({

        id   : data.uid
        name : data.name

        primary : primary

        x : if primary then 0 else layout_data.coordinate[0]
        y : if primary then 0 else layout_data.coordinate[1]
      })

  }

  Model

