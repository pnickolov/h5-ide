
define [ "../ComplexResModel", "Design", "constant", "i18n!nls/lang.js" ], ( ComplexResModel, Design, constant, lang )->

  emptyArray = []

  Model = ComplexResModel.extend {

    type        : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
    newNameTmpl : "host-"

    defaults :
      x      : 2
      y      : 2
      width  : 9
      height : 9

      #servergroup
      count  : 1

      imageId      : ''
      tenancy      : 'default'
      ebsOptimized : false
      instanceType : "m1.small"
      monitoring   : false
      userData     : ""

      # RootDevice
      rdSize : 0
      rdIops : 0

      cachedAmi : null

      state : undefined

    initialize : ( attr, option )->

      option = option || {}

      # Create Eni0 if necessary
      if option.createByUser and not Design.instance().typeIsClassic()
        #create eni0
        EniModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface )
        @setEmbedEni( new EniModel({
          name : "eni0"
          assoPublicIp : Design.instance().typeIsDefaultVpc()
        }, { instance: this }) )


      # Clone the attributes if cloneSource is supplied.
      if option.cloneSource
        @clone( option.cloneSource )
      else if option.createByUser
        @initInstanceType()


      # Set rdSize if it's empty
      if not @get("rdSize")
        #append root device
        volSize = @getAmiRootDeviceVolumeSize()
        if volSize > 0
          @set("rdSize",volSize)

          # < need add volume of ami like root device, not support now >
          # append other volume in ami
          # amiInfo = @.getAmi()
          # volList = amiInfo.blockDeviceMapping
          # for key, vol of volList
          #   if key is amiInfo.rootDeviceName
          #     continue
          #   attribute =
          #     name : key
          #     snapshotId : vol.snapshotId
          #     volumeSize : vol.volumeSize
          #     volumeType : vol.volumeType
          #   if vol.volumeType is "io1"
          #     attribute.iops = vol.iops
          #   attribute.owner = @
          #   VolumeModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume )
          #   new VolumeModel( attribute, {noNeedGenName:true})


      # Draw before creating SgAsso
      @draw(true)

      # Create additonal association if the instance is created by user.
      if option.createByUser and not option.cloneSource
        #assign DefaultKP
        KpModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair )
        defaultKp = KpModel.getDefaultKP()
        if defaultKp
          defaultKp.assignTo( this )
        else
          console.error "No DefaultKP found when initialize InstanceModel"

        #assign DefaultSG
        SgModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )
        defaultSg = SgModel.getDefaultSg()
        if defaultSg
          SgAsso = Design.modelClassForType( "SgAsso" )
          new SgAsso( this, defaultSg )
        else
          console.error "No DefaultSG found when initialize InstanceModel"


      # Always setTenancy to insure we don't have micro type for dedicated.
      tenancy = @get("tenancy")
      vpc = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).theVPC()
      if vpc and not vpc.isDefaultTenancy() then tenancy = "dedicated"

      @setTenancy( tenancy )
      null

    groupMembers : ()->
      if not @__groupMembers then @__groupMembers = []
      return @__groupMembers

    getAvailabilityZone : ()->
      p = @parent()
      if p.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
        return p.parent()
      else
        return p

    getDetailedOSFamily : ()->
      ami = @getAmi() || @get("cachedAmi")
      if not ami or not ami.osType or not ami.osFamily
        console.warn "Cannot find ami infomation for instance :", this
        return "linux"

      osType   = ami.osType
      osFamily = ami.osFamily

      if constant.OS_TYPE_MAPPING[osType]
        osFamily = constant.OS_TYPE_MAPPING[osType]

      if osType in constant.WINDOWS
        osFamily = 'mswin'

        sql_web_pattern = /sql.*?web.*?/
        sql_standerd_pattern = /sql.*?standard.*?/

        name        = ami.name or ""
        desc        = ami.description or ""
        imgLocation = ami.imageLocation or ""

        if name.match( sql_web_pattern ) or desc.match( sql_web_pattern ) or imgLocation.match( sql_web_pattern )
          osFamily = 'mswinSQLWeb'
        else if name.match( sql_standerd_pattern ) or desc.match( sql_standerd_pattern ) or imgLocation.match( sql_standerd_pattern )
          osFamily = 'mswinSQL'

      osFamily

    initInstanceType : ()->
      ami = @getAmi()
      if ami and ami.instance_type
        instance_type = ami.instance_type.replace(/\s/g, "").split(",")
        for i in instance_type
          # Do not return t1.micro, because if vpc is dedicated, the instance
          # should be m1.small
          if i isnt "t1.micro"
            type = i
            break

      @attributes.instanceType = type || "m1.small"
      null

    getCost : ( priceMap, currency )->
      if not priceMap.instance then return null

      ami = @getAmi() || @get("cachedAmi")
      osType   = if ami then ami.osType else "linux-other"
      osFamily = @getDetailedOSFamily()

      instanceType = @get("instanceType").split(".")
      unit = priceMap.instance.unit
      fee  = priceMap.instance[ instanceType[0] ][ instanceType[1] ]
      fee  = if fee then fee.onDemand

      if fee
        if fee[ osFamily ] is undefined and osFamily.indexOf("mswin") is 0
          osFamily = "mswin"
        fee = fee[osFamily]

      fee  = if fee then fee[ currency ]

      if not fee then return null

      if unit is "perhr"
        formatedFee = fee + "/hr"
        fee *= 24 * 30
      else
        formatedFee = fee + "/mo"

      count = @get("count") or 1
      name  = @get("name")
      if count > 1
        name += " (x#{count})"
        fee  *= count

      priceObj =
          resource    : name
          type        : @get("instanceType")
          fee         : fee
          formatedFee : formatedFee

      if @get("monitoring")
        for t in priceMap.cloudwatch.types
          if t.ec2Monitoring
            fee = t.ec2Monitoring[ currency ]
            cw_fee =
              resource    : @get("name") + "-monitoring"
              type        : "CloudWatch"
              fee         : fee * count
              formatedFee : fee + "/mo"

            return [ priceObj, cw_fee ]

      return priceObj

    isReparentable : ( newParent )->
      if newParent.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
        return false

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

    connect : ( cn )->
      if cn.type is "EniAttachment"
        # Disable auto assign public ip when connects to another eni.
        eni = @getEmbedEni()
        if eni then eni.set("assoPublicIp", false)

    setPrimaryEip : ( toggle )->
      eni = @getEmbedEni()
      if eni
        eni.setPrimaryEip( toggle )
      else
        @set("hasEip", toggle)
        if toggle
          if not @attributes.eipData
            @attributes.eipData = {}
          if not @attributes.eipData.id
            @attributes.eipData.id = MC.guid()

      @draw()

    hasPrimaryEip : ()->
      eni = @getEmbedEni()
      if eni
        eni.hasPrimaryEip()
      else
        @get("hasEip")

    hasAutoAssignPublicIp: () ->
      @getEmbedEni().get 'assoPublicIp'

    setCount : ( count )->
      @set "count", count

      if count > 1
        # Remove route to Embed Eni ( Embed Eni routes is conencted to instance )
        route = @connections('RTB_Route')[0]
        if route then route.remove()

      # Update my self and connected Eni
      @draw()
      for eni in @connectionTargets("EniAttachment")
        if count > 1
          for c in eni.connections("RTB_Route")
            c.remove()
        eni.draw()
      null

    isDefaultTenancy : ()->
      VpcModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC )
      vpc = VpcModel.allObjects()[0]
      if vpc and not vpc.isDefaultTenancy()
        return false
      else
        return @get("tenancy") isnt "dedicated"
      null

    setAmi : ( amiId )->
      @set "imageId", amiId

      # Update cached ami
      ami    = @getAmi()
      cached = @get("cachedAmi")
      if ami and cached
        cached.osType         = ami.osType
        cached.architecture   = ami.architecture
        cached.rootDeviceType = ami.rootDeviceType

      # Update RootDevice Size
      if ami.blockDeviceMapping
        rdName = ami.rootDeviceName
        rdEbs  = ami.blockDeviceMapping[ rdName ]
        if not rdEbs
        #rootDeviceName is partition
          _.each ami.blockDeviceMapping, (value,key) ->
            if rdName.indexOf(key) isnt -1 and not rdEbs
              rdEbs = value
            null

        minRdSize  = if rdEbs then parseInt( rdEbs.volumeSize, 10 ) else 10
        if @get("rdSize") < minRdSize
          @set("rdSize", minRdSize)

      # Assume the new amiId supports current instancetype
      # Assume the new amiId is the same OS of current one.

      # Check If the new amiId is supports current type
      # instance_type_list = MC.aws.ami.getInstanceType( @getAmi() )
      # instanceType = @get("instanceType")
      # for v in instance_type_list or []
      #   if v is instanceType
      #     support = true
      #     break
      # if not support then @initInstanceType()
      @draw()
      null

    getAmi : ()-> MC.data.dict_ami[@get("imageId")]

    getBlockDeviceMapping : ()->
      #get root device of current instance
      ami = @getAmi() || @get("cachedAmi")
      if ami and ami.rootDeviceType is "ebs" and ami.blockDeviceMapping

        rdName = ami.rootDeviceName
        rdEbs  = ami.blockDeviceMapping[rdName]
        if not rdEbs
        #rootDeviceName is partition
          _.each ami.blockDeviceMapping, (value,key) ->
            if rdName.indexOf(key) isnt -1 and not rdEbs
              rdEbs = value
              rdName = key
            null

        blockDeviceMapping = [{
          DeviceName : rdName
          Ebs : {
            SnapshotId : rdEbs.snapshotId
            VolumeSize : @get("rdSize") || rdEbs.volumeSize
            VolumeType : "standard"
          }
        }]

        if @get("rdIops") and parseInt( @get("rdSize"), 10 ) >= 10
          blockDeviceMapping[0].Ebs.Iops = @get("rdIops")
          blockDeviceMapping[0].Ebs.VolumeType = "io1"

      blockDeviceMapping || []

    getAmiRootDevice : () ->
      #get root deivce of ami
      amiInfo = @getAmi() || @get("cachedAmi")
      rd = null
      if amiInfo and amiInfo.rootDeviceType is "ebs" and amiInfo.blockDeviceMapping
        rdName = amiInfo.rootDeviceName
        rdEbs = amiInfo.blockDeviceMapping[rdName]

        if rdName and not rdEbs
        #rootDeviceName is partition
          _.each amiInfo.blockDeviceMapping, (value,key) ->
            if rdName.indexOf(key) isnt -1 and not rdEbs
              rdEbs  = value
              rdName = key
            null

        if rdName and rdEbs
          rd =
            "DeviceName": rdName
            "Ebs":
              "VolumeSize": Number(rdEbs.volumeSize)
              "SnapshotId": rdEbs.snapshotId
              "VolumeType": rdEbs.volumeType

          if rdEbs.volumeType is "io1"
            rd.Ebs.Iops = rdEbs.iops
        else

          console.warn "getAmiRootDevice(): can not found root device of AMI(" + @get("imageId") + ")", this
      rd

    getAmiRootDeviceVolumeSize : () ->
      volSize = 0
      amiInfo = @getAmi()
      if amiInfo
        if amiInfo.osType is "windows"
          volumeSize = 30
        else
          volumeSize = 10

        rd = @getAmiRootDevice()
        if rd
          volSize = rd.Ebs.VolumeSize
        else
          console.warn "getAmiRootDeviceVolumeSize(): use default volumeSize " + volSize , this
      else
        console.warn "getAmiRootDeviceVolumeSize(): unknown volumeSize for " + @get("imageId")
      volSize

    getAmiRootDeviceName : () ->
      rd = @getAmiRootDevice()
      if rd and rd.DeviceName then rd.DeviceName else ""

    getInstanceTypeConfig : ( type )->
      t = (type || @get("instanceType")).split(".")
      if t.length >= 2
        config = MC.data.config[ Design.instance().region() ]
        if config and config.instance_type
          return config.instance_type[ t[0] ][ t[1] ]

      return null

    getMaxEniCount : ()->
      config = @getInstanceTypeConfig()
      if config then config = config.eni

      config or 16


    isEbsOptimizedEnabled : ()->

      ami = @getAmi() || @get("cachedAmi")
      if ami and ami.rootDeviceType is "instance-store"
        return false

      k = @get("instanceType").split '.'
      instanceType = MC.data.config[ Design.instance().region() ].instance_type
      if instanceType then instanceType = instanceType[ k[0] ]
      if instanceType then instanceType = instanceType[ k[1] ]
      if instanceType and instanceType.ebs_optimized
        return instanceType.ebs_optimized is 'Yes'

      #default
      EbsMap =
        "m1.large"   : true
        "m1.xlarge"  : true
        "m2.2xlarge" : true
        "m2.4xlarge" : true
        "m3.xlarge"  : true
        "m3.2xlarge" : true
        "c1.xlarge"  : true
        "c3.xlarge"   : true
        "c3.2xlarge"  : true
        "c3.4xlarge"  : true
        "g2.2xlarge"  : true
        "i2.xlarge"   : true
        "i2.2xlarge"  : true
        "i2.4xlarge"  : true

      !!EbsMap[ @get("instanceType") ]

    setInstanceType : ( type )->

      # Ensure type is not t1.micro when using dedicated tenancy
      if type is "t1.micro" and not @isDefaultTenancy()
        type = "m1.small"

      @set("instanceType", type)
      if not @isEbsOptimizedEnabled()
        @set("ebsOptimized", false)

      # Well, LC borrows setInstanceType of Instance,
      # but LC doesn't have getEmbedEni
      if @getEmbedEni and not Design.instance().typeIsClassic()
        # Eni's IP address count is limited by instanceType
        enis = @connectionTargets("EniAttachment")
        enis.push( @getEmbedEni() )
        for eni in enis
          eni.limitIpAddress()
      null

    setTenancy : ( tenancy )->
      @set "tenancy", tenancy

      if tenancy is "dedicated" and @get("instanceType") is "t1.micro"
        @initInstanceType()
      null

    getInstanceTypeList : ()->

      instance_type_list = MC.aws.ami.getInstanceType( @getAmi() )

      if not instance_type_list
        return []

      tenancy      = @isDefaultTenancy()
      instanceType = @get("instanceType")

      return _.map instance_type_list, ( value )->
        main     : constant.INSTANCE_TYPE[value][0]
        ecu      : constant.INSTANCE_TYPE[value][1]
        core     : constant.INSTANCE_TYPE[value][2]
        mem      : constant.INSTANCE_TYPE[value][3]
        name     : value
        selected : instanceType is value
        hide     : not tenancy and value is "t1.micro"

    remove : ()->
      if this.__mainEni
        this.__mainEni.remove()

      # Remove attached volumes
      for v in (@get("volumeList") or emptyArray).slice(0)
        v.remove()

      # In AppEdit Mode, we need to delete all eni associated to this Instance.
      if Design.instance().modeIsAppEdit()
        for eni in @connectionTargets("EniAttachment")
          eni.remove()

      ComplexResModel.prototype.remove.call this
      null

    isRemovable : ()->
      state = @get("state")
      if (state isnt undefined and state.length > 0) or
        ($('#state-editor-model').is(':visible') and $('#state-editor-model .state-list .state-item').length >= 1)
          return MC.template.NodeStateRemoveConfirmation(name: @get("name"))

      true

    clone : ( srcTarget )->
      @cloneAttributes srcTarget, {
        reserve : "volumeList"
        copyConnection : [ "KeypairUsage", "SgAsso", "ElbAmiAsso" ]
      }

      # Update states id
      for state in @get("state") or []
        state.id = "state-" + @design().guid()

      # Copy volume
      Volume = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume )
      for v in srcTarget.get("volumeList") or []
        new Volume( { owner : this }, { cloneSource : v } )

      # Copy Eni
      @getEmbedEni().clone( srcTarget.getEmbedEni() )
      null

    setEmbedEni : ( eni )->
      this.__mainEni = eni
      null

    getEmbedEni : ()-> this.__mainEni

    getRealGroupMemberIds : ()->
      @ensureEnoughMember()

      c = @get("count")
      members = [ this.id ]

      for mem in @groupMembers()
        if members.length >= c then break
        members.push mem.id

      members

    ensureEnoughMember : ()->
      totalCount = @get("count") - 1
      while @groupMembers().length < totalCount
        @groupMembers().push {
          id      : MC.guid()
          appId   : ""
          eipData : { id : MC.guid() }
        }
      null

    generateJSON : ()->
      tenancy = @get("tenancy")

      p = @parent()
      if p.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
        vpc      = p.parent().parent()
        if not vpc.isDefaultTenancy()
          tenancy = "dedicated"

      kp = @connectionTargets( "KeypairUsage" )[0]
      kp = if kp then kp.createRef( "KeyName" ) else ""

      name = @get("name")
      if @get("count") > 1 then name += "-0"

      securitygroups   = []
      securitygroupsId = []
      if Design.instance().typeIsClassic()
        # In Vpc, Sg is written in Eni's JSON, not in Instance's JSON
        for sg in @connectionTargets("SgAsso")
          securitygroups.push( sg.createRef( "GroupName" ) )
          securitygroupsId.push( sg.createRef( "GroupId" ) )

      # Generate RootDevice
      blockDeviceMapping = @getBlockDeviceMapping()
      for volume in @get("volumeList") or []
        blockDeviceMapping.push "#"+volume.id

      component =
        type   : @type
        uid    : @id
        name   : name
        index  : 0
        number : @get("count")
        serverGroupUid  : @id
        serverGroupName : @get("name")
        state : @get("state")
        resource :
          UserData : {
            Base64Encoded : false
            Data : @get("userData")
          }
          BlockDeviceMapping : blockDeviceMapping
          Placement : {
            Tenancy : if tenancy is "dedicated" then "dedicated" else ""
            AvailabilityZone : @getAvailabilityZone().createRef()
          }
          InstanceId            : @get("appId")
          ImageId               : @get("imageId")
          KeyName               : kp
          EbsOptimized          : if @isEbsOptimizedEnabled() then @get("ebsOptimized") else false
          VpcId                 : @getVpcRef()
          SubnetId              : @getSubnetRef()
          Monitoring            : if @get("monitoring") then "enabled" else "disabled"
          NetworkInterface      : []
          InstanceType          : @get("instanceType")
          DisableApiTermination : false
          ShutdownBehavior      : "terminate"
          SecurityGroup         : securitygroups
          SecurityGroupId       : securitygroupsId
          PrivateIpAddress      : "" # After app update, the PrivateIpAddress will be set by the backend. So we always ensure PrivateIpAddress existence to suppress a faulty change in proceeding appupdate.

      component

    createEipJson : ( eipData, instanceId )->
      instanceId = instanceId or this.id

      {
        uid   : eipData.id
        type  : constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
        index : 0
        name  : "EIP"
        resource :
          Domain : "standard"
          InstanceId         : @createRef( "InstanceId", instanceId )
          AllocationId       : eipData.allocationId or ""
          NetworkInterfaceId : ""
          PrivateIpAddress   : ""
          PublicIp           : eipData.publicIp or ""
      }

    getStateData : () ->

      @get("state")

    setStateData : (stateAryData) ->

      @set("state", stateAryData)

    serialize : ()->

      allResourceArray = []

      ami    = @getAmi() || @get("cachedAmi")
      layout = @generateLayout()
      if ami
        layout.osType         = ami.osType
        layout.architecture   = ami.architecture
        layout.rootDeviceType = ami.rootDeviceType

      # Add this instance' layout first.
      allResourceArray.push( { layout : layout } )

      # Generate instance member.
      instances = [ @generateJSON() ]
      i = instances.length
      @ensureEnoughMember()

      # In non-VPC type, we should add Eip For instance
      if @get("hasEip") and not Design.instance().typeIsVpc()
        allResourceArray.push {
          component : @createEipJson( @get("eipData") )
        }

      while i < @get("count")
        member = $.extend true, {}, instances[0]
        member.name  = @get("name") + "-" + i
        member.index = i
        memberObj = @groupMembers()[ instances.length - 1 ]
        member.uid      = memberObj.id
        member.resource.InstanceId = memberObj.appId

        # In non-VPC type, we should add Eip For instance
        if @get("hasEip") and not Design.instance().typeIsVpc()
          eip = @createEipJson( memberObj.eipData, memberObj.id )
          eip.index = i
          allResourceArray.push { component : eip }

        ++i
        instances.push( member )


      layout.instanceList = _.map instances, ( ami )-> ami.uid


      # Generate Volume
      serverGroupOption = { number : instances.length, instanceId : "" }
      volumeModels = @get("volumeList") || emptyArray
      eniModels    = if @getEmbedEni() then [ @getEmbedEni() ] else []
      for attach in @connections("EniAttachment")
        eniModels[ attach.get("index") ] = attach.getOtherTarget( this )

      volumes = []
      enis    = []
      for instance, idx in instances

        serverGroupOption.instanceId   = instance.uid
        serverGroupOption.instanceName = instance.name + "-"

        for volume in volumeModels
          v = volume.generateJSON( idx, serverGroupOption )
          volumes.push( v )

        for eni, eniIndex in eniModels
          # The generate JSON might be something like : [ EniObject, EipObject, EipObject ]
          enis = enis.concat eni.generateJSON( idx, serverGroupOption, eniIndex )

      for res in instances.concat( volumes ).concat( enis )
        allResourceArray.push( { component : res } )

      return allResourceArray

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

    # parameter could be uid or aws id
    # return uid and mid( memberId )
    getEffectiveId : ( instance_id ) ->
      design = Design.instance()

      # The instance_id might be component uid or aws id
      if design.component( instance_id ) then return {uid:instance_id, mid:null}

      for instance in @allObjects()
        if instance.get("appId") is instance_id
          return { uid : instance.id, mid : "#{instance.id}_0" }
        else if instance.groupMembers
          for member, index in instance.groupMembers()
            if member and member.appId is instance_id
              return { uid : instance.id, mid : "#{member.id}_#{index + 1}" }

      resource_list = MC.data.resource_list[ design.region() ]
      for asg in Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group ).allObjects()
        data = resource_list[ asg.get("appId") ]
        if not data or not data.Instances then continue
        data = data.Instances
        for obj in (data.member or data)
          if obj is instance_id or obj.InstanceId is instance_id
            return { uid : asg.get("lc").id, mid : instance_id }

      {uid:null,mid:null}

    diffJson : ( newData, oldData )->
      changeData = newData or oldData

      if changeData.index isnt 0 then return

      change = {
        id      : changeData.uid
        type    : changeData.type
        name    : changeData.serverGroupName
        changes : []
      }
      if newData and oldData and not _.isEqual( newData.resource, oldData.resource )
        change.changes.push { name : "Update" }

      newCount = if newData then newData.number else 0
      oldCount = if oldData then oldData.number else 0
      if newCount > oldCount
        change.changes.push {
          name  : "Create"
          count : newCount - oldCount
        }
      else if newCount < oldCount
        change.change = "Terminate"
        change.changes.push {
          name  : "Terminate"
          count : newCount - oldCount
        }

      if newData and oldData
        if newData.resource.InstanceType isnt oldData.resource.InstanceType or newData.resource.EbsOptimized isnt oldData.resource.EbsOptimized or newData.resource.UserData.Data isnt oldData.resource.UserData.Data
           change.extra = "Need to restart."
           change.info  = "If the instance or instance group has been automatically assigned public IP, the IP will change after restart."

      if change.changes.length
        change
      else
        null


    deserialize : ( data, layout_data, resolve )->

      # Compact instance for servergroup
      if data.serverGroupUid and data.serverGroupUid isnt data.uid
        members = resolve( data.serverGroupUid ).groupMembers()
        for m in members
          if m and m.id is data.uid
            console.debug "This instance servergroup member has already deserialized", data
            return

        if data.resource.EipResource
          eipData = {
            id            : data.resource.EipResource.uid
            allocationId  : data.resource.EipResource.resource.AllocationId
            publicIp      : data.resource.EipResource.resource.PublicIp
          }

        members[data.index-1] = {
          id      : data.uid
          appId   : data.resource.InstanceId
          eipData : eipData || { id : MC.guid() }
        }
        return


      rootDevice = data.resource.BlockDeviceMapping[0]
      if not rootDevice or _.isString( rootDevice )
        rootDevice =
          Ebs :
            VolumeSize : 0
            Iops : ""


      attr =
        id    : data.uid
        name  : data.serverGroupName or data.name
        appId : data.resource.InstanceId
        count : data.number

        imageId      : data.resource.ImageId
        tenancy      : data.resource.Placement.Tenancy
        ebsOptimized : data.resource.EbsOptimized
        instanceType : data.resource.InstanceType
        monitoring   : data.resource.Monitoring isnt "disabled"
        userData     : data.resource.UserData.Data or ""

        rdSize : rootDevice.Ebs.VolumeSize
        rdIops : rootDevice.Ebs.Iops

        parent : resolve( layout_data.groupUId )

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]

        state : data.state

      if data.resource.EipResource
        attr.hasEip  = true
        attr.eipData = {
          id : data.resource.EipResource.uid
          allocationId : data.resource.EipResource.resource.AllocationId
        }

      if layout_data.osType and layout_data.architecture and layout_data.rootDeviceType
        #patch for old windows ami
        if layout_data.osType is "win"
          layout_data.osType = "windows"

        attr.cachedAmi = {
          osType         : layout_data.osType
          architecture   : layout_data.architecture
          rootDeviceType : layout_data.rootDeviceType
        }

      model = new Model( attr )

      # Add Keypair
      resolve( MC.extractID( data.resource.KeyName ) ).assignTo( model )

      # Associate Sg in classic mode
      if Design.instance().typeIsClassic() and data.resource.SecurityGroup
        SgAsso = Design.modelClassForType( "SgAsso" )
        for groupId in data.resource.SecurityGroup
          new SgAsso( model, resolve( MC.extractID( groupId ) ) )

      null


  }

  Model
