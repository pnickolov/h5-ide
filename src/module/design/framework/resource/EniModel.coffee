
define [ "../ComplexResModel", "../CanvasManager", "Design", "../connection/SgAsso", "../connection/EniAttachment", "constant" ], ( ComplexResModel, CanvasManager, Design, SgAsso, EniAttachment, constant )->

  Model = ComplexResModel.extend {

    defaults :
      sourceDestCheck : true
      description     : ""

      x        : 0
      y        : 0
      width    : 9
      height   : 9

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface


    constructor : ( attributes, option )->
      if attributes.instance
        @__embedInstance = attributes.instance

      delete attributes.instance

      ComplexResModel.call this, attributes, option
      null


    embedInstance : ()-> @__embedInstance

    hasEip : ()-> false


    connect : ( connection )->
      if connection.type is "EniAttachment"
        @draw()
      null

    disconnect : ( connection )->
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

    draw : ( isCreate )->

      if @embedInstance()
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
              'class' : 'server-number-bg'
              'rx'    : 4
              'ry'    : 4
            }),
            Canvon.text(45, 15, "0").attr({'class':'node-label server-number'})
          ).attr({
            'class'   : 'server-number-group'
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

        # Update EIP
        CanvasManager.update node.children(".eip-status"), @eipIconUrl(), "href"


      # Update SeverGroup Count
      instance = @connectionTargets("EniAttachment")
      count = if instance.length then instance[0].get("count") else 0

      numberGroup = node.children(".server-number-group")
      if count > 1
        CanvasManager.toggle node.children(".port-eni-rtb"), false
        CanvasManager.toggle numberGroup, true
        CanvasManager.update numberGroup.children("text"), count
      else
        CanvasManager.toggle node.children(".port-eni-rtb"), true
        CanvasManager.toggle numberGroup, false


  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

    deserialize : ( data, layout_data, resolve )->

      # See if it's embeded eni
      attachment = data.resource.Attachment
      embed      = attachment and attachment.DeviceIndex is "0"
      instance   = if attachment and attachment.InstanceId then resolve( MC.extractID( attachment.InstanceId) ) else null

      # Create
      attr = {
        id    : data.uid
        name  : data.name
        appId : data.resource.NetworkInterfaceId

        description     : data.resource.Description
        sourceDestCheck : data.resource.SourceDestCheck

        parent : resolve( MC.extractID(data.resource.SubnetId) )

        x : if embed then 0 else layout_data.coordinate[0]
        y : if embed then 0 else layout_data.coordinate[1]
      }

      if embed then attr.instance = instance
      eni = new Model( attr )


      sgTarget = eni.embedInstance() or eni

      # Create SgAsso
      for group in data.resource.GroupSet || []
        new SgAsso( sgTarget, resolve( MC.extractID( group.GroupId ) ) )

      # Create connection between Eni and Instance
      if instance
        if embed
          instance.setEmbedEni( eni )
          eni.__embedInstance = instance
        else
          new EniAttachment( eni, instance )
      null
  }

  Model

