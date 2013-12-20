
define [ "../ComplexResModel", "../CanvasManager", "Design", "../connection/SgAsso", "../connection/EniAttachment", "constant" ], ( ComplexResModel, CanvasManager, Design, SgAsso, EniAttachment, constant )->

  Model = ComplexResModel.extend {

    defaults :
      embed           : false
      sourceDestCheck : true
      description     : ""

      x        : 0
      y        : 0
      width    : 9
      height   : 9

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface


    connect : ( connection )->
      if connection.type is "EniAttachment"
        @draw()
      null

    iconUrl : ()->
      if @connections( "EniAttachment" ).length
        state = "attached"
      else
        state = "unattached"

      "ide/icon/eni-canvas-#{state}.png"

    eipIconUrl : ()->
      if @hasEip()
        MC.canvas.IMAGE.EIP_ON
      else
        MC.canvas.IMAGE.EIP_OFF

    hasEip : ()->
      false


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
          Canvon.image( @eipIconUrl(), 44,37,12,14 ).attr({'class':'eip-status'}),

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

      else
        node = $( document.getElementById( @id ) )
        # Update label
        CanvasManager.update node.children(".node-label"), @get("name")

        # Update Image
        CanvasManager.update node.children("image:not(.eip-status)"), @iconUrl(), "href"

        # Update Image
        CanvasManager.update node.children(".eip-status"), @eipIconUrl(), "href"



  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

    deserialize : ( data, layout_data, resolve )->

      subnet = resolve( MC.extractID( data.resource.SubnetId ) )

      attachment = data.resource.Attachment
      embed      = attachment and attachment.DeviceIndex is "0"
      instance   = if attachment and attachment.InstanceId then resolve( MC.extractID( attachment.InstanceId) ) else null

      eni = new Model({

        id    : data.uid
        name  : data.name
        appId : data.resource.NetworkInterfaceId

        embed           : embed
        description     : data.resource.Description
        sourceDestCheck : data.resource.SourceDestCheck

        parent : subnet

        x : if embed then 0 else layout_data.coordinate[0]
        y : if embed then 0 else layout_data.coordinate[1]
      })

      if data.resource.GroupSet
        sgTarget = if embed then instance else eni
        for group in data.resource.GroupSet
          new SgAsso( sgTarget, resolve( MC.extractID( group.GroupId ) ) )

      if not embed and instance
        new EniAttachment( eni, instance )

      null

  }

  Model

