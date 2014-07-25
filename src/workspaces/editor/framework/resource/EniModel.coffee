
define [ "../ComplexResModel", "Design", "../connection/SgAsso", "../connection/EniAttachment", "constant", 'i18n!/nls/lang.js' ], ( ComplexResModel, Design, SgAsso, EniAttachment, constant, lang )->

  ###
  IpObject is used to represent an ip in Eni
  ###
  IpObject = ( attr )->
    if not attr then attr = {}

    # If the ip is not malform, switch to autoAssign ip.
    attr.ip = attr.ip || ""
    if attr.ip.split(".").length != 4 or attr.ip[attr.ip.length-1] is "."
      attr.ip = ""

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

    type : constant.RESTYPE.ENI

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

      if option.createByUser and not option.instance
        # DefaultSg
        defaultSg = Design.modelClassForType( constant.RESTYPE.SG ).getDefaultSg()
        SgAsso = Design.modelClassForType( "SgAsso" )
        new SgAsso( defaultSg, this )

      if option.cloneSource
        @clone( option.cloneSource )
      null

    clone : ( srcTarget )->
      @cloneAttributes srcTarget

      # Update Ips to automatically assign, and reassign eip uid
      for ip in @get("ips")
        ip.ip = "x.x.x.x"
        ip.autoAssign = true
        ip.eipData.id = @design().guid()

      null

    groupMembers : ()->
      if not @__groupMembers then @__groupMembers = []
      return @__groupMembers

    updateName : ()->
      instance = @__embedInstance
      if instance
        name = "eni0"
      else
        attachment = @connections( "EniAttachment" )[0]
        if attachment
          name = "eni" + attachment.get("index")
        else
          name = "eni"

      @set "name", name
      null


    isReparentable : ( newParent )->
      if newParent.type is constant.RESTYPE.SUBNET
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
      instance = @__embedInstance
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
      null

    hasPrimaryEip : ()-> @get("ips")[0].hasEip

    hasEip : ()->
      @get("ips").some ( ip )-> ip.hasEip

    subnetCidr : ()->
      parent = @parent() or @__embedInstance.parent()

      console.assert( parent.type is constant.RESTYPE.SUBNET, "Eni's parent must be subnet" )
      parent.get("cidr") || "10.0.0.1"

    getIpArray : ()->

      cidr            = @subnetCidr()
      isServergroup   = @serverGroupCount() > 1
      prefixSuffixAry = Design.modelClassForType(constant.RESTYPE.SUBNET).genCIDRPrefixSuffix( cidr )
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

      prefixSuffixAry = Design.modelClassForType(constant.RESTYPE.SUBNET).genCIDRPrefixSuffix( cidr )

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
      validObj = Design.modelClassForType(constant.RESTYPE.SUBNET).isIPInSubnet( ip, cidr )
      if not validObj.isValid
        if validObj.isReserved
          return "This IP address is in subnet’s reserved address range"
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
          if realIp is realNewIp and eni isnt @
            if eni is this
              return 'This IP address conflicts with other IP'
            else
              return 'This IP address conflicts with other network interface’s IP'

      true

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
          (@__embedInstance || @).trigger "change:primaryEip"
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

      subnet = if @__embedInstance then @__embedInstance.parent() else @parent()

      result = true
      # Add an fake item to see if there's an error in subnet
      ips.push( { ip : "fake" } )

      if subnet.getAvailableIPCountInSubnet() <= 0
        result = "Ip count limit has reached in #{subnet.get('name')}"

      # Remove the fake item
      ips.length = ips.length - 1

      result

    connect : ( connection )->
      if connection.type isnt "EniAttachment" then return

      # When the instance is attached to an eni
      # See if the instance allows eni to have that much of ips.
      @limitIpAddress()
      @updateName()

      # When an Eni is attached, show SgLine for the Eni
      SgModel = Design.modelClassForType( constant.RESTYPE.SG )
      SgModel.tryDrawLine( @ )
      null

    disconnect : ( connection )->
      if connection.type isnt "EniAttachment" then return

      @attributes.name = "eni"

      # When an Eni is detached, hide SgLine for the Eni
      reason = { reason : connection }
      for sgline in @connections( "SgRuleLine" )
        sgline.remove( reason )
      null

    ensureEnoughMember : ()->
      instance = @attachedInstance()
      if not instance then return

      count = instance.get("count") - 1

      ipTemplate = @get("ips")

      # In ensureEnoughMember(), we need to ensure the we have at least
      # servergroup count of member.
      # And we also need to ensure each member's ip have at least the amount
      # of the main eni's ip.
      for member in @groupMembers()
        while member.ips.length < ipTemplate.length
          member.ips.push {
            autoAssign : true
            ip         : "x.x.x.x"
            eipData    : { id :MC.guid() }
          }

      while @groupMembers().length < count
        ips = []
        for ip, idx in ipTemplate
          ips.push {
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

    onParentChanged : () ->

      for ipObj, idx in @get("ips")
        @setIp( idx, null, true, ipObj.hasEip )

    generateJSON : ( index, servergroupOption, eniIndex )->

      resources = [{}]

      @ensureEnoughMember()

      eniName = (servergroupOption.instanceName or "") + @get("name")

      ips = []
      if index is 0
        memberData = {
          id           : @id
          appId        : @get("appId")
          ips          : @get("ips")
          attachmentId : @get("attachmentId")
        }
      else
        memberData = @groupMembers()[ index - 1 ]

      # When we generate IPs for serverGroupMember.
      # We need to create as much as `ServerGroup Eni's IP count`
      # But we also need to fill in IP/EIP data of ServerGroup Member Enis.
      for ipObj, idx in @get("ips")

        hasEip = ipObj.hasEip

        # The ipObj in memberData always exists, because ensureEnoughMember() ensures it.
        ipObj = memberData.ips[ idx ]
        console.assert ipObj, "ipObj should be defined."

        if servergroupOption.number > 1
          autoAssign = true
        else
          autoAssign = ipObj.autoAssign

        if ipObj.fixedIpInApp
          autoAssign = false

        ips.push {
          PrivateIpAddress : @getRealIp( ipObj.ip )
          AutoAssign       : autoAssign
          Primary          : false
        }

        if hasEip
          # Create Eip Component
          eip = ipObj.eipData

          resources.push {
            uid   : eip.id or MC.guid()
            type  : constant.RESTYPE.EIP
            name  : "#{eniName}-eip#{idx}"
            index : index
            resource :
              Domain : "vpc"
              InstanceId         : ""
              AllocationId       : eip.allocationId or ""
              NetworkInterfaceId : @createRef( "NetworkInterfaceId", memberData.id )
              PrivateIpAddress   : @createRef( "PrivateIpAddressSet.#{idx}.PrivateIpAddress", memberData.id )
              PublicIp           : eip.publicIp or ""
          }
      ips[0].Primary = true


      sgTarget = if @__embedInstance then @__embedInstance else @

      securitygroups = _.map sgTarget.connectionTargets("SgAsso"), ( sg )->
        {
          GroupName : sg.createRef( "GroupName" )
          GroupId   : sg.createRef( "GroupId" )
        }

      if servergroupOption.instanceId
        instanceId = @createRef( "InstanceId", servergroupOption.instanceId )
      else
        instanceId = ""

      az = ""

      if @__embedInstance
        parent = @__embedInstance.parent()
      else
        parent = @parent()

      if parent.type is constant.RESTYPE.SUBNET
        subnetId = parent.createRef( "SubnetId" )
        vpcId    = parent.parent().parent().createRef( "VpcId" )
        az       = parent.parent()
      else
        az = parent


      component =
        index           : index
        uid             : memberData.id
        type            : @type
        name            : eniName
        serverGroupUid  : @id
        serverGroupName : @get("name")
        number          : servergroupOption.number or 1
        resource :
          SourceDestCheck    : @get("sourceDestCheck")
          Description        : @get("description")
          NetworkInterfaceId : memberData.appId

          AvailabilityZone : az.createRef()
          VpcId            : parent.getVpcRef()
          SubnetId         : parent.getSubnetRef()

          AssociatePublicIpAddress : @get("assoPublicIp")
          PrivateIpAddressSet : ips
          GroupSet   : securitygroups
          Attachment :
            InstanceId   : instanceId
            DeviceIndex  : if eniIndex is undefined then "1" else "" + eniIndex
            AttachmentId : memberData.attachmentId or ""

      resources[0] = component
      resources

    serialize : ()->
      # Eni does not serialize data by itself.
      # Eni is serialized by instance, because instance might be a server-group
      # And Eni's IP is assign in serializeVistor/SubnetVisitor

      # Here, we only serialize layout
      res = []
      if not @__embedInstance
        layout = @generateLayout()

        res[0] = {layout:layout}

      if not @attachedInstance()
        eniIndex = if @__embedInstance then 0 else 1
        comps = @generateJSON( 0, { number : 1 }, eniIndex )

        # Add Eni
        if not res[0] then res[0] = {}
        res[0].component = comps[0]

        # Add Eip
        if comps[1] then res.push {component:comps[1]}

      res

  }, {

    # EniModel does not handle EIP's deserialize.
    handleTypes : [ constant.RESTYPE.ENI, constant.RESTYPE.EIP ]

    getAvailableIPInCIDR : (ipCidr, filter, maxNeedIPCount) ->

      cutAry = ipCidr.split('/')
      ipAddr = cutAry[0]
      suffix = Number cutAry[1]
      prefix = 32 - suffix

      ipAddrAry = ipAddr.split '.'
      ipAddrBinAry = ipAddrAry.map (value) -> MC.leftPadString( parseInt(value).toString(2), 8, "0" )

      ipAddrBinStr = ipAddrBinAry.join ''
      ipAddrBinPrefixStr = ipAddrBinStr.slice(0, suffix)

      ipAddrBinStrSuffixMin = ipAddrBinStr.slice(suffix).replace(/1/g, '0')
      ipAddrBinStrSuffixMax = ipAddrBinStrSuffixMin.replace(/0/g, '1')

      ipAddrNumSuffixMin = parseInt ipAddrBinStrSuffixMin, 2
      ipAddrNumSuffixMax = parseInt ipAddrBinStrSuffixMax, 2

      allIPAry = []
      availableIPCount = 0
      readyAssignAry = [ipAddrNumSuffixMin...ipAddrNumSuffixMax + 1]
      readyAssignAryLength = readyAssignAry.length
      $.each readyAssignAry, (idx, value) ->
        newIPBinStr = ipAddrBinPrefixStr + MC.leftPadString(value.toString(2), prefix, "0")
        isAvailableIP = true
        if idx in [0, 1, 2, 3]
          isAvailableIP = false
        if idx is readyAssignAryLength - 1
          isAvailableIP = false
        newIPAry = _.map [0, 8, 16, 24], (value) ->
          newIPNum = (parseInt newIPBinStr.slice(value, value + 8), 2)
          return newIPNum

        newIPStr = newIPAry.join('.')
        if newIPStr in filter
          isAvailableIP = false
        newIPObj = {
          ip: newIPStr
          available: isAvailableIP
        }

        allIPAry.push(newIPObj)
        if isAvailableIP then availableIPCount++
        if availableIPCount > maxNeedIPCount then return false

        null

      console.log('availableIPCount: ' + availableIPCount)

      return allIPAry

    getAvailableIPCountInCIDR : (ipCidr) ->

      cutAry = ipCidr.split('/')
      ipAddr = cutAry[0]
      suffix = Number cutAry[1]
      prefix = 32 - suffix

      ipAddrAry = ipAddr.split '.'
      ipAddrBinAry = ipAddrAry.map (value) -> MC.leftPadString(parseInt(value).toString(2), 8,"0")

      ipAddrBinStr = ipAddrBinAry.join ''
      ipAddrBinPrefixStr = ipAddrBinStr.slice(0, suffix)

      ipAddrBinStrSuffixMin = ipAddrBinStr.slice(suffix).replace(/1/g, '0')
      ipAddrBinStrSuffixMax = ipAddrBinStrSuffixMin.replace(/0/g, '1')

      ipAddrNumSuffixMin = parseInt ipAddrBinStrSuffixMin, 2
      ipAddrNumSuffixMax = parseInt ipAddrBinStrSuffixMax, 2

      # availableIPCount = (ipAddrNumSuffixMax - ipAddrNumSuffixMin + 1) - filter.length - 5
      availableIPCount = (ipAddrNumSuffixMax - ipAddrNumSuffixMin + 1) - 5
      if availableIPCount < 0
        availableIPCount = 0

      return availableIPCount

    createServerGroupMember : ( data )->
      attachment = data.resource.Attachment || {}

      memberData = {
        id           : data.uid
        appId        : data.resource.NetworkInterfaceId
        attachmentId : attachment.AttachmentId || ""
        ips          : []
      }
      for ip in data.resource.PrivateIpAddressSet || []
        ipObj = new IpObject({
          autoAssign   : ip.AutoAssign
          ip           : ip.PrivateIpAddress
          fixedIpInApp : Design.instance().modeIsApp() || Design.instance().modeIsAppView()
        })
        if ip.EipResource
          ipObj.eipData =
            id            : ip.EipResource.uid
            allocationId  : ip.EipResource.resource.AllocationId
            publicIp      : ip.EipResource.resource.PublicIp
        memberData.ips.push( ipObj )

      memberData

    deserialize : ( data, layout_data, resolve )->

      if data.type is constant.RESTYPE.EIP then return

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
      embed      = attachment and ( attachment.DeviceIndex is "0" or attachment.DeviceIndex is 0 )
      instance   = if attachment and attachment.InstanceId then resolve( MC.extractID( attachment.InstanceId) ) else null

      # Create
      attr = {
        id    : data.uid
        appId : data.resource.NetworkInterfaceId

        description     : data.resource.Description
        sourceDestCheck : data.resource.SourceDestCheck
        assoPublicIp    : data.resource.AssociatePublicIpAddress
        attachmentId    : if attachment then attachment.AttachmentId else ""

        ips : []

        x : if embed then 0 else layout_data.coordinate[0]
        y : if embed then 0 else layout_data.coordinate[1]
      }


      for ip in data.resource.PrivateIpAddressSet || []
        autoAssign = if Design.instance().modeIsStack() then ip.AutoAssign else false
        ipObj = new IpObject({
          autoAssign   : autoAssign
          ip           : ip.PrivateIpAddress
          fixedIpInApp : Design.instance().modeIsApp() || Design.instance().modeIsAppView()
        })
        if ip.EipResource
          ipObj.hasEip  = true
          ipObj.eipData =
            id            : ip.EipResource.uid
            allocationId  : ip.EipResource.resource.AllocationId
            publicIp      : ip.EipResource.resource.PublicIp
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
      for instance in Design.modelClassForType( constant.RESTYPE.INSTANCE ).allObjects()
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

