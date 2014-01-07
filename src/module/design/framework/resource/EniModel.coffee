
define [ "../ServergroupModel", "CanvasManager", "Design", "../connection/SgAsso", "../connection/EniAttachment", "constant", 'i18n!nls/lang.js' ], ( ServergroupModel, CanvasManager, Design, SgAsso, EniAttachment, constant, lang )->

  ###
  IpObject is used to represent an ip in Eni
  ###
  IpObject = ( attr )->
    if not attr then attr = {}

    this.hasEip     = attr.hasEip or false
    this.eipId      = attr.eipId  or ""
    this.autoAssign = if attr.autoAssign isnt undefined then attr.autoAssign else true
    this.ip         = attr.ip or ""
    null


  ###
  Defination of EniModel
  ###
  Model = ServergroupModel.extend {

    defaults : ()->
      sourceDestCheck : true
      description     : ""
      ips             : []
      assoPublicIp    : false

      x        : 0
      y        : 0
      width    : 9
      height   : 9

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
    newNameTmpl : "eni"

    constructor : ( attributes, option )->

      if option and option.instance
        @__embedInstance = option.instance

      if !attributes.ips
        attributes.ips = []
      if attributes.ips.length is 0
        attributes.ips.push( new IpObject() )

      ComplexResModel.call this, attributes, option

    initialize : ( attributes, option )->
      option = option || {}

      # Draw first then create SgAsso
      @draw( true )

      if option.createByUser and not option.instance
        # DefaultSg
        defaultSg = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup ).getDefaultSg()
        SgAsso = Design.modelClassForType( "SgAsso" )
        new SgAsso( defaultSg, this )
      null

    isReparentable : ( newParent )->
      if newParent.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
        if newParent.parent() isnt @parent().parent()
          check = true
      else
        check = true

      # If changing the parent results in changing Instance's AZ, then
      # We need to check if there's connected Eni to this Instance.
      if check and @connectionTargets("EniAttachment").length > 0
        return lang.ide.CVS_MSG_ERR_MOVE_ATTACHED_ENI

      true

    # isVisual() is used by CanavasAdaptor to determine this is a node is visually
    # in the canvas.
    isVisual : ()-> !@__embedInstance
    embedInstance : ()-> @__embedInstance
    attachedInstance : ()->
      instance = @embedInstance()
      if not instance
        target = @connectionTargets( "EniAttachment" )
        if target.length then instance = target[0]

      return instance

    serverGroupCount : ()->
      instance = @attachedInstance()
      if instance then instance.get("count") else 1

    maxIpCount : ()->
      instance = @attachedInstance()
      if instance
        config = instance.getInstanceTypeConfig()
        if config
          return config.ip_per_eni

      return 1

    limitIpAddress : ()->
      ipCount = @maxIpCount()
      if @get("ips").length > ipCount
        @get("ips").length = ipCount
      null

    setPrimaryEip : ( toggle )->
      if not @attachedInstance() then return

      @get("ips")[0].hasEip = toggle
      @draw()
      null

    hasPrimaryEip : ()->
      if not @attachedInstance() then return false
      @get("ips")[0].hasEip

    hasEip : ()->
      @get("ips").some ( ip )-> ip.hasEip

    subnetCidr : ()->
      parent = @parent() or @embedInstance().parent()

      if parent.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
        cidr = parent.get("cidr")
      else
        cidr = MC.aws.vpc.getAZSubnetForDefaultVPC( parent.get("name") )

      cidr

    getIpArray : ()->

      cidr            = @subnetCidr()
      editable        = @serverGroupCount() is 1
      prefixSuffixAry = MC.aws.subnet.genCIDRPrefixSuffix( cidr )
      ips             = []

      for ip, idx in @get("ips")

        obj = {
          hasEip     : ip.hasEip
          autoAssign : ip.autoAssign
          editable   : editable
          prefix     : prefixSuffixAry[0]
        }

        if obj.autoAssign
          obj.suffix = prefixSuffixAry[1]
        else
          ipAry = ip.ip.split(".")
          if prefixSuffixAry is "x.x"
            obj.suffix = ipAry[2] + "." + ipAry[3]
          else
            obj.suffix = ipAry[3]

        obj.ip = obj.prefix + obj.suffix

        ips.push obj

      ips

    isValidIp : ( ip )->

      if ip.indexOf("x") isnt -1
        return true

      # Check for subnet
      if not MC.aws.subnet.isIPInSubnet( ip, @subnetCidr() )
        return 'This IP address conflicts with subnet’s IP range'

      # Check for other eni's ip
      for eni in Model.allObjects()

        if not eni.attachedInstance() # Only test attached Eni
          continue

        for ipObj in eni.attributes.ips
          if ipObj.ip is ip and not ipObj.autoAssign
            if eni is this
              return 'This IP address conflicts with other IP'
            else
              return 'This IP address conflicts with other network interface’s IP'

      return true

    addIp : ( idx, ip, autoAssign, hasEip )->
      ips = @get("ips")

      if @maxIpCount() <= ips.length then return false

      ip = new IpObject({
        hasEip     : false
        ip         : "x.x.x.x"
        autoAssign : true
      })

      ips = ips.slice(0)
      ips.push( ip )
      @set("ips", ips)

      return true

    setIp : ( idx, ip, autoAssign, hasEip )->
      ipObj = @get("ips")[idx]

      if ip isnt undefined and ip isnt null
        ipObj.ip = ip

      if autoAssign isnt undefined and autoAssign isnt null
        ipObj.autoAssign = autoAssign

      if hasEip isnt undefined and hasEip isnt null and hasEip isnt ipObj.hasEip
        ipObj.hasEip = hasEip

        if idx is 0
          if @embedInstance()
            @embedInstance().draw()
          else
            @draw()

      null

    removeIp : ( idx )->
      ips = @get("ips")

      # Make sure we have at least ipAddress in this eni
      if ips.length <= 1 or idx is 0 then return

      ips = ips.slice(0)
      ips.splice( idx, 1 )
      @set( "ips", ips )
      null

    canAddIp : ()->
      instance = @attachedInstance()
      if not instance then return false

      maxIp = @maxIpCount()
      ips   = @get("ips")

      if ips.length >= maxIp
        return sprintf( lang.ide.PROP_MSG_WARN_ENI_IP_EXTEND, instance.get("instanceType"), maxIp )

      subent = if @embedInstance() then @embedInstance().parent() else @parent()

      result = true
      # Add an fake item to see if there's an error in subnet
      ips.push( { ip : "fake" } )

      if not subent.isCidrEnoughForIps()
        result = "Ip count limit has reached in #{subnet.get('name')}"

      # Remove the fake item
      ips.length = ips.length - 1

      result

    connect : ( connection )->
      if connection.type is "EniAttachment" then @draw()
      null

    disconnect : ( connection )->
      if connection.type is "EniAttachment" then @draw()
      null

    iconUrl : ()->
      if @connections( "EniAttachment" ).length
        state = "attached"
      else
        state = "unattached"

      "ide/icon/eni-canvas-#{state}.png"

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
          Canvon.image( "", 44,37,12,14 ).attr({
            'id': @id + "_eip_status"
            'class':'eip-status'
          }),

          # Left Port
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-eni-sg-left'
            'class'      : 'port port-blue port-eni-sg port-eni-sg-left'
            'transform'  : 'translate(5, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
            'data-name'     : 'eni-sg'
            'data-position' : 'left'
            'data-type'     : 'sg'
            'data-direction': "in"
          }),

          # Left port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-eni-attach'
            'class'      : 'port port-green port-eni-attach'
            'transform'  : 'translate(8, 45)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
            'data-name'     : 'eni-attach'
            'data-position' : 'left'
            'data-type'     : 'attachment'
            'data-direction': "in"
          }),

          # Right port
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-eni-sg-right'
            'class'      : 'port port-blue port-eni-sg port-eni-sg-right'
            'transform'  : 'translate(75, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
            'data-name'     : 'eni-sg'
            'data-position' : 'right'
            'data-type'     : 'sg'
            'data-direction': 'out'
          }),

          # Top port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-eni-rtb'
            'class'      : 'port port-blue port-eni-rtb'
            'transform'  : 'translate(42, -1)' + MC.canvas.PORT_UP_ROTATE
            'data-angle' : MC.canvas.PORT_UP_ANGLE
            'data-name'     : 'eni-rtb'
            'data-position' : 'top'
            'data-type'     : 'sg'
            'data-direction': 'in'
          }),

          Canvon.group().append(
            Canvon.rectangle(36, 1, 20, 16).attr({'class':'server-number-bg','rx':4,'ry':4}),
            Canvon.text(46, 13, "0").attr({'class':'node-label server-number'})
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

      # Update SeverGroup Count
      count = @serverGroupCount()

      numberGroup = node.children(".server-number-group")
      if count > 1
        CanvasManager.toggle node.children(".port-eni-rtb"), false
        CanvasManager.toggle numberGroup, true
        CanvasManager.update numberGroup.children("text"), count
      else
        CanvasManager.toggle node.children(".port-eni-rtb"), true
        CanvasManager.toggle numberGroup, false

      # Update EIP
      CanvasManager.updateEip node.children(".eip-status"), @hasPrimaryEip()

  }, {

    handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface, constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP ]

    deserialize : ( data, layout_data, resolve )->

      # deserialize EIP
      if data.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
        if data.resource.InstanceId
          resolve( MC.extractID( data.resource.InstanceId ) ).setPrimaryEip( true )
        else
          eni      = resolve( MC.extractID( data.resource.NetworkInterfaceId ) )
          eipIndex = data.resource.PrivateIpAddress.split(".")[3]
          ipObj    = eni.get("ips")[ eipIndex ]

          # Update IpObject's Eip status.
          ipObj.hasEip = true
          ipObj.eipId  = data.uid
        return


      # deserialize Eni
      # First, try to deserialize it by ServergroupModel
      if ServergroupModel.tryDeserialize( data, layout_data, resolve )
        return

      # See if it's embeded eni
      attachment = data.resource.Attachment
      embed      = attachment and attachment.DeviceIndex is "0"
      instance   = if attachment and attachment.InstanceId then resolve( MC.extractID( attachment.InstanceId) ) else null

      # Create
      attr = {
        id    : data.uid
        name  : data.serverGroupName || data.name
        appId : data.resource.NetworkInterfaceId

        description     : data.resource.Description
        sourceDestCheck : data.resource.SourceDestCheck
        assoPublicIp    : data.resource.AssociatePublicIpAddress

        ips : []

        x : if embed then 0 else layout_data.coordinate[0]
        y : if embed then 0 else layout_data.coordinate[1]
      }

      for ip in data.resource.PrivateIpAddressSet || []
        attr.ips.push( new IpObject({
          autoAssign : ip.AutoAssign
          ip         : ip.PrivateIpAddress
        }) )


      if embed
        option = { instance : instance }
      else
        attr.parent = resolve( MC.extractID(data.resource.SubnetId) )

      eni = new Model( attr, option )


      # Create SgAsso
      sgTarget = eni.embedInstance() or eni
      for group in data.resource.GroupSet || []
        new SgAsso( sgTarget, resolve( MC.extractID( group.GroupId ) ) )


      # Create connection between Eni and Instance
      if instance
        if embed
          instance.setEmbedEni( eni ) # Need to add it to instance
        else
          new EniAttachment( eni, instance )
      null
  }

  Model

