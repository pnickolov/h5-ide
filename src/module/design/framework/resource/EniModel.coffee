
define [ "../ComplexResModel", "CanvasManager", "Design", "../connection/SgAsso", "../connection/EniAttachment", "constant", 'i18n!nls/lang.js' ], ( ComplexResModel, CanvasManager, Design, SgAsso, EniAttachment, constant, lang )->

  ###
  IpObject is used to represent an ip in Eni
  ###
  IpObject = ( attr )->
    if not attr then attr = {}

    this.hasEip       = attr.hasEip or false
    this.autoAssign   = if attr.autoAssign isnt undefined then attr.autoAssign else true
    this.ip           = attr.ip or "x.x.x.x"
    this.eipData      = attr.eipData or { id : MC.guid() }
    this.fixedIpInApp = attr.fixedIpInApp or false
    null


  ###
  Defination of EniModel
  ###
  Model = ComplexResModel.extend {

    defaults : ()->
      sourceDestCheck : true
      description     : ""
      ips             : []
      assoPublicIp    : false
      name            : "eni"

      x        : 0
      y        : 0
      width    : 9
      height   : 9

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

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

    groupMembers : ()->
      if not @__groupMembers then @__groupMembers = []
      return @__groupMembers

    updateName : ()->
      oldName = @attributes.name

      instance = @embedInstance()
      if instance
        @attributes.name = "eni0"
      else
        attachment = @connections( "EniAttachment" )[0]
        if attachment
          @attributes.name = "eni" + attachment.get("index")
        else
          @attributes.name = "eni"

      if @attributes.name isnt oldName
        @draw()
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
      if instance
        count = instance.get("count")
      count || 1

    maxIpCount : ()->
      instance = @attachedInstance()
      if instance
        config = instance.getInstanceTypeConfig()
        if config
          return config.ip_per_eni

      return 1

    limitIpAddress : ()->
      # Only limit the ip when we have instance config
      instance = @attachedInstance()
      if instance and instance.getInstanceTypeConfig()
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
        defaultSubnet = MC.aws.vpc.getAZSubnetForDefaultVPC( parent.get("name") )
        if defaultSubnet
          cidr = defaultSubnet.cidrBlock

      cidr

    getIpArray : ()->

      cidr            = @subnetCidr()
      isServergroup   = @serverGroupCount() > 1
      prefixSuffixAry = MC.aws.subnet.genCIDRPrefixSuffix( cidr )
      ips             = []

      for ip, idx in @get("ips")

        obj = {
          hasEip       : ip.hasEip
          autoAssign   : ip.autoAssign
          editable     : not ( isServergroup or ip.fixedIpInApp )
          prefix       : prefixSuffixAry[0]
        }

        if obj.autoAssign or isServergroup
          obj.suffix = prefixSuffixAry[1]
        else
          ipAry = ip.ip.split(".")
          if prefixSuffixAry[1] is "x.x"
            obj.suffix = ipAry[2] + "." + ipAry[3]
          else
            obj.suffix = ipAry[3]

        obj.ip = obj.prefix + obj.suffix

        ips.push obj

      ips

    # generate an realIp according to the cidr
    getRealIp : ( ip, cidr )->
      if ip is "x.x.x.x" then return ip

      if not cidr then cidr = @subnetCidr()
      if not cidr then return ip

      prefixSuffixAry = MC.aws.subnet.genCIDRPrefixSuffix( cidr )

      ipAry = ip.split(".")
      if prefixSuffixAry[1] is "x.x"
        realIp = prefixSuffixAry[0] + ipAry[2] + "." + ipAry[3]
      else
        realIp = prefixSuffixAry[0] + ipAry[3]

      realIp

    isValidIp : ( ip )->

      if ip.indexOf("x") isnt -1
        return true

      cidr = @subnetCidr()

      # Check for subnet
      if not MC.aws.subnet.isIPInSubnet( ip, cidr )
        return 'This IP address conflicts with subnet’s IP range'

      realNewIp = @getRealIp( ip, cidr )

      # Check for other eni's ip
      for eni in Model.allObjects()

        if not eni.attachedInstance() # Only test attached Eni
          continue

        for ipObj in eni.attributes.ips
          if ipObj.autoAssign then continue

          # The ip is not necessary correct in Eni.get("ips")
          realIp = eni.getRealIp( ipObj.ip )
          if realIp is realNewIp
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
      if connection.type is "EniAttachment"
        # When the instance is attached to an eni
        # See if the instance allows eni to have that much of ips.
        @limitIpAddress()
        @updateName()
        @draw()
      null

    disconnect : ( connection )->
      if connection.type is "EniAttachment"
        @attributes.name = "eni"
        @draw()
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
            'class':'eip-status tooltip'
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

      # Update SeverGroup Count
      count = @serverGroupCount()

      numberGroup = node.children(".eni-number-group")
      if count > 1
        CanvasManager.toggle node.children(".port-eni-rtb"), false
        CanvasManager.toggle numberGroup, true
        CanvasManager.update numberGroup.children("text"), count
      else
        CanvasManager.toggle node.children(".port-eni-rtb"), true
        CanvasManager.toggle numberGroup, false

      # Update EIP
      CanvasManager.updateEip node.children(".eip-status"), @

      # Update Resource State in app view
      if not Design.instance().modeIsStack() and @.get("appId")
        @updateState()

      null

    ensureEnoughMember : ()->
      instance = @attachedInstance()
      if not instance then return

      count = instance.get("count") - 1

      ipTemplate = @get("ips")

      while @groupMembers().length < count
        ips = []
        for ip, idx in ipTemplate
          ips.push {
            hasEip     : ipTemplate[ idx ].hasEip
            autoAssign : true
            ip         : "x.x.x.x"
            eipData    : { id : MC.guid() }
          }

        @groupMembers().push {
          id              : MC.guid()
          appId           : ""
          forceAutoAssign : true
          ips             : ips
        }

      null


    generateJSON : ( index, servergroupOption, eniIndex )->

      resources = [{}]

      @ensureEnoughMember()

      ips = []
      if index is 0
        memberData = {
          id    : @id
          appId : @get("appId")
          ips   : @get("ips")
        }
      else
        memberData = @groupMembers()[ index - 1 ]

      # When we generate IPs for serverGroupMember.
      # We need to create as much as `ServerGroup Eni's IP count`
      # But we also need to fill in IP/EIP data of ServerGroup Member Enis.
      for ipObj, idx in @get("ips")

        ipObj = memberData.ips[ idx ]
        if servergroupOption.number > 1
          autoAssign = true
        else
          autoAssign = ipObj.autoAssign

        ips.push {
          PrivateIpAddress : @getRealIp( ipObj.ip )
          AutoAssign       : autoAssign
          Primary          : false
          #reserved
          Association      :
            InstanceId        : ""
            AssociationID     : ""
            PublicDnsName     : ""
            IpOwnerId         : ""
            PublicIp          : ""
            AllocationID      : ""
        }

        if ipObj.hasEip
          # Create Eip Component
          eip = ipObj.eipData

          resources.push {
            uid   : eip.id or MC.guid()
            type  : constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
            name  : "EIP"
            index : index
            resource :
              Domain : if Design.instance().typeIsVpc() then "vpc" else "standard"
              InstanceId         : ""
              AllocationId       : eip.allocationId or ""
              NetworkInterfaceId : @createRef( "NetworkInterfaceId", memberData.id )
              PrivateIpAddress   : @createRef( "PrivateIpAddressSet.#{idx}.PrivateIpAddress", memberData.id )
              NetworkInterfaceOwnerId : ""
              AllowReassociation      : ""
              AssociationId           : ""
              PublicIp                : ""
          }
      ips[0].Primary = true


      sgTarget = if @embedInstance() then @embedInstance() else @

      securitygroups = _.map sgTarget.connectionTargets("SgAsso"), ( sg )->
        {
          GroupName : sg.createRef( "GroupName" )
          GroupId   : sg.createRef( "GroupId" )
        }

      instanceId = @createRef( "InstanceId", servergroupOption.instanceId )

      az = ""

      if @embedInstance()
        parent = @embedInstance().parent()
      else
        parent = @parent()

      if parent.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
        subnetId = parent.createRef( "SubnetId" )
        vpcId    = parent.parent().parent().createRef( "VpcId" )
        az       = parent.parent().get("name")
      else
        az = parent.get("name")

      assoPublicIp = @get("assoPublicIp")
      if Design.instance().typeIsDefaultVpc() and @embedInstance()
        assoPublicIp = true

      component =
        index           : index
        uid             : memberData.id
        type            : @type
        name            : (servergroupOption.instanceName or "") + @get("name")
        serverGroupUid  : @id
        serverGroupName : @get("name")
        number          : servergroupOption.number or 1
        resource :
          SourceDestCheck    : @get("sourceDestCheck")
          Description        : @get("description")
          NetworkInterfaceId : memberData.appId

          AvailabilityZone : az
          VpcId            : parent.getVpcRef()
          SubnetId         : parent.getSubnetRef()

          PrivateIpAddressSet : ips
          GroupSet   : securitygroups
          Attachment :
            InstanceId   : instanceId
            DeviceIndex  : if eniIndex is undefined then "1" else "" + eniIndex
            AttachmentId : ""
            AttachTime   : ""

          SecondPriIpCount : ""
          MacAddress       : ""
          RequestId        : ""
          RequestManaged   : ""
          OwnerId          : ""
          PrivateIpAddress : ""

          AssociatePublicIpAddress : assoPublicIp
          #reserved
          PrivateDnsName     : ""
          Status             : ""


      resources[0] = component
      resources

    serialize : ()->
      # Eni does not serialize data by itself.
      # Eni is serialized by instance, because instance might be a server-group
      # And Eni's IP is assign in serializeVistor/SubnetVisitor

      # Here, we only serialize layout
      res = null
      if not @embedInstance()
        layout =
          coordinate : [ @x(), @y() ]
          uid        : @id
          groupUId   : @parent().id

        if res is null then res = {}
        res.layout = layout

      if not @attachedInstance()
        if res is null then res = {}
        res.component = @generateJSON( 0, { number : 1 }, 0 )[0]

      res

  }, {

    handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface ]

    createServerGroupMember : ( data )->
      memberData = {
        id    : data.uid
        appId : data.resource.NetworkInterfaceId
        ips   : []
      }
      for ip in data.resource.PrivateIpAddressSet || []
        ipObj = new IpObject({
          autoAssign   : ip.AutoAssign
          ip           : ip.PrivateIpAddress
          fixedIpInApp : Design.instance().modeIsApp()
        })
        if ip.EipResource
          ipObj.eipData =
            id           : ip.EipResource.uid
            allocationId : ip.EipResource.AllocationId
        memberData.ips.push( ipObj )

      memberData

    deserialize : ( data, layout_data, resolve )->

      # deserialize ServerGroup Member Eni
      if data.serverGroupUid and data.serverGroupUid isnt data.uid
        members = resolve( data.serverGroupUid ).groupMembers()
        for m in members
          if m and m.id is data.uid
            console.debug "This eni servergroup member has already deserialized", data
            return

        members[data.index - 1] = @createServerGroupMember(data)
        return



      # deserialize Eni
      # See if it's embeded eni
      attachment = data.resource.Attachment
      embed      = attachment and attachment.DeviceIndex is "0"
      instance   = if attachment and attachment.InstanceId then resolve( MC.extractID( attachment.InstanceId) ) else null

      # Create
      attr = {
        id    : data.uid
        appId : data.resource.NetworkInterfaceId

        description     : data.resource.Description
        sourceDestCheck : data.resource.SourceDestCheck
        assoPublicIp    : data.resource.AssociatePublicIpAddress

        ips : []

        x : if embed then 0 else layout_data.coordinate[0]
        y : if embed then 0 else layout_data.coordinate[1]
      }


      for ip in data.resource.PrivateIpAddressSet || []
        autoAssign = if Design.instance().modeIsStack() then ip.autoAssign else false
        ipObj = new IpObject({
          autoAssign   : autoAssign
          ip           : ip.PrivateIpAddress
          fixedIpInApp : Design.instance().modeIsApp()
        })
        if ip.EipResource
          ipObj.hasEip  = true
          ipObj.eipData =
            id           : ip.EipResource.uid
            allocationId : ip.EipResource.resource.AllocationId
        attr.ips.push( ipObj )


      if embed
        attr.name = "eni0"
        option = { instance : instance }
      else
        attr.parent = resolve( layout_data.groupUId )

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
          eniIndex = if attachment and attachment.DeviceIndex then attachment.DeviceIndex else 1
          new EniAttachment( eni, instance, { index : eniIndex * 1 } )
      null

    postDeserialize : ( data, layout )->
      # Previous version of IDE does not assign serverGroupUid for Embed Eni. Which results in that Eni is not store in groupMembers.

      attach = data.resource.Attachment
      if not attach then return


      embed = attach.DeviceIndex is "0"
      if not embed then return

      design     = Design.instance()
      instanceId = MC.extractID( attach.InstanceId )
      instance   = design.component( instanceId )

      if instance then return

      eni = design.component( data.uid )
      if not eni then return

      console.debug "Found embed eni which doesn't belong to visible instance, it might be embed eni of an servergroup member", eni
      eni.remove()

      eniMember = @createServerGroupMember(data)
      for instance in Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance ).allObjects()
        for m, idx in instance.groupMembers()
          if m.id is instanceId
            found = true
            break

      if not found
        console.warn "Cannot found instance server group for embed eni :", eni
        return

      instance.getEmbedEni().groupMembers()[ idx ] = eniMember
      null
  }

  Model

