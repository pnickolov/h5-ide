
define [ "../ComplexResModel", "CanvasManager", "Design", "constant", "i18n!nls/lang.js" ], ( ComplexResModel, CanvasManager, Design, constant, lang )->

  emptyArray = []

  Model = ComplexResModel.extend {

    type        : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
    newNameTmpl : "host"

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

      cachedAmi : null

    initialize : ( attr, option )->

      if option and option.createByUser

        @initInstanceType()

        # Draw before creating SgAsso
        @draw(true)
        #create mode => no option or option.isCreate==true

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

        if Design.instance().typeIsVpc()
          #create eni0
          EniModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface )
          @setEmbedEni( new EniModel({ name : "eni0" }, { instance: this }) )

      else
        @draw( true )

      vpc = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).theVPC()
      if vpc and not vpc.isDefaultTenancy()
        @setTenancy( "dedicated" )

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

      @draw()

    hasPrimaryEip : ()->
      eni = @getEmbedEni()
      if eni
        eni.hasPrimaryEip()
      else
        @get("hasEip")

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

    getAmi : ()-> MC.data.dict_ami[@get("imageId")]
    getInstanceTypeConfig : ()->
      t = @get("instanceType").split(".")
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
      EbsMap =
        "m1.large"   : true
        "m1.xlarge"  : true
        "m2.2xlarge" : true
        "m2.4xlarge" : true
        "m3.xlarge"  : true
        "m3.2xlarge" : true
        "c1.xlarge"  : true

      ami = @getAmi() || @get("cachedAmi")
      if ami and ami.rootDeviceType is "instance-store"
        return false

      return !!EbsMap[ @get("instanceType") ]

    setInstanceType : ( type )->

      # Ensure type is not t1.micro when using dedicated tenancy
      if type is "t1.micro" and not @isDefaultTenancy()
        type = "m1.small"

      @set("instanceType", type)
      if not @isEbsOptimizedEnabled()
        @set("ebsOptimized", false)

      # Eni's IP address count is limited by instanceType
      enis = @connectionTargets("EniAttachment")
      enis.push( @getEmbedEni() )
      for eni in enis
        eni.limitIpAddress()
      null

    setTenancy : ( tenancy )->
      @set "tenancy", tenancy

      if tenancy is "dedicated" and @get("instanceType") is "t1.micro"
        @setInstanceType "m1.small"
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
      for v in @get("volumeList") or emptyArray
        v.remove()
      null

    setEmbedEni : ( eni )->
      this.__mainEni = eni
      null

    getEmbedEni : ()-> this.__mainEni

    iconUrl : ()->
      ami = @getAmi() || @get("cachedAmi")

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
          Canvon.image( MC.IMG_URL + 'ide/icon/instance-volume-attached-normal.png' , 21, 44, 29, 24 ).attr({
            'id': @id + "_volume_status"
            'class':'volume-image'
          }),
          # Volume Label
          Canvon.text( 35, 56, "" ).attr({'class':'node-label volume-number'}),
          # Volume Hotspot
          Canvon.rectangle(21, 44, 29, 24).attr({
            'data-target-id' : @id
            'class'          : 'instance-volume'
            'fill'           : 'none'
          }),

          # Eip
          Canvon.image( "", 53, 47, 12, 14).attr({
            'id': @id + "_eip_status"
            'class':'eip-status tooltip'
          }),

          # Child number
          Canvon.group().append(
            Canvon.rectangle(36, 1, 20, 16).attr({'class':'server-number-bg','rx':4,'ry':4}),
            Canvon.text(46, 13, "0").attr({'class':'node-label server-number'})
          ).attr({
            'id'      : @id + "_instance-number-group"
            'class'   : 'instance-number-group'
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

        if not Design.instance().modeIsStack() and @.get("appId")
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

      else
        node = $( document.getElementById( @id ) )
        # update label
        CanvasManager.update node.children(".node-label-name"), @get("name")

        # Update Instance State in app
        if not Design.instance().modeIsStack() and @.get("appId")
          @_updateState()


      # Update Server number
      numberGroup = node.children(".instance-number-group")
      if @get("count") > 1
        CanvasManager.toggle node.children(".port-instance-rtb"), false
        CanvasManager.toggle numberGroup, true
        CanvasManager.update numberGroup.children("text"), @get("count")
      else
        CanvasManager.toggle node.children(".port-instance-rtb"), true
        CanvasManager.toggle numberGroup, false

      volumeCount = if @get("volumeList") then @get("volumeList").length else 0
      CanvasManager.update node.children(".volume-number"), volumeCount
      if volumeCount > 0
        volumeImage = 'ide/icon/instance-volume-attached-normal.png'
      else
        volumeImage = 'ide/icon/instance-volume-not-attached.png'
      CanvasManager.update node.children(".volume-image"), volumeImage, "href"

      # Update EIP
      CanvasManager.updateEip node.children(".eip-status"), @hasPrimaryEip()

      null


    _updateState : ()->

      if !Design.instance().modeIsApp()
        console.warn '[InstanceModel._updateState] this method should be use in app view'
        return null

      # Check icon
      if $("#" + @id + "_instance-state").length is 0
        console.error '[InstanceModel._updateState] can not found "#' + @id + '_instance-state"'
        return null

      # Init icon to unknown state
      Canvon($("#" + @id)).removeClass "deleted"

      # Get instance state
      instance_data = MC.data.resource_list[ Design.instance().region() ][ @.get("appId") ]
      if instance_data
        instanceState = instance_data.instanceState.name
        Canvon($("#" + @id)).addClass "deleted"  if instanceState is "terminated"
      else
        #instance data not found, or maybe instance already terminated
        instanceState = "unknown"
        Canvon("#" + @id).addClass "deleted"

      #update icon state and tooltip
      $("#" + @id + "_instance-state").attr({
        "class"       : "instance-state tooltip"
      })

      Canvon( "#" + @id + "_instance-state" )
      .addClass( "instance-state-" + instanceState + " instance-state-" + Design.instance().mode() )
      .data( 'tooltip', instanceState )
      .attr( 'data-tooltip', instanceState )

      null

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
          id    : MC.guid()
          appId : ""
        }
      null

    generateJSON : ()->
      vpcId = subnetId = azName = tenancy = ""

      p = @parent()
      if p.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
        azName   = p.parent().get("name")
        subnetId = "@#{p.id}.resource.SubnetId"
        vpc      = p.parent().parent()
        vpcId    = "@#{vpc.id}.resource.VpcId"

        if vpc.isDefaultTenancy()
          tenancy = "dedicated"

      else
        azName = p.get("name")



      name = @get("name")
      if @get("count") > 1 then name += "-0"

      component =
        type   : @type
        uid    : @id
        name   : name
        index  : 0
        number : @get("count")
        serverGroupUid  : @id
        serverGroupName : @get("name")
        resource :
          UserData : {
            Base64Encoded : false
            Data : @get("userData")
          }
          BlockDeviceMapping : []
          Placement : {
            GroupName : ""
            Tenancy : if tenancy is "dedicated" then "dedicated" else ""
            AvailabilityZone : azName
          }
          InstanceId            : @get("appId")
          ImageId               : @get("imageId")
          KeyName               : ""
          EbsOptimized          : if @isEbsOptimizedEnabled() then @get("ebsOptimized") else false
          VpcId                 : vpcId
          SubnetId              : subnetId
          Monitoring            : if @get("monitoring") then "enabled" else "disabled"
          NetworkInterface      : []
          InstanceType          : @get("instanceType")
          DisableApiTermination : false
          RamdiskId             : ""
          ShutdownBehavior      : "terminate"
          KernelId              : ""
          SecurityGroup         : []
          SecurityGroupId       : []
          PrivateIpAddress      : ""

      component

    serialize : ()->

      allResourceArray = []

      ami    = @getAmi() || @get("cachedAmi")
      layout =
        coordinate : [ @x(), @y() ]
        uid        : @id
        groupUId   : @parent().id
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

      while i < @get("count")
        member = $.extend true, {}, instances[0]
        member.name  = @get("name") + "-" + i
        member.index = i
        memberObj = @groupMembers()[ instances.length - 1 ]
        member.uid      = memberObj.id
        member.resource.InstanceId = memberObj.appId

        # In non-VPC type, we should add Eip For instance
        if @get("hasEip") and not Design.instance().typeIsVpc()
          eipData = memberObj.eipData || {}
          allResourceArray.push {
            component : {
              uid   : eipData.id or MC.guid()
              type  : constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
              index : i
              resource :
                Domain : "standard"
                InstanceId         : "@#{memberData.id}.resource.InstanceId"
                AllocationId       : eipData.allocationId or ""
                NetworkInterfaceId : ""
                PrivateIpAddress   : ""
            }
          }

        ++i
        instances.push( member )



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
          instance.resource.BlockDeviceMapping.push( "#"+ v.uid )
          volumes.push( v )

        for eni, eniIndex in eniModels
          # The generate JSON might be something like : [ EniObject, EipObject, EipObject ]
          enis = enis.concat eni.generateJSON( idx, serverGroupOption, eniIndex )

      for res in instances.concat( volumes ).concat( enis )
        allResourceArray.push( { component : res } )

      return allResourceArray

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

    deserialize : ( data, layout_data, resolve )->

      # Compact instance for servergroup
      if data.serverGroupUid and data.serverGroupUid isnt data.uid
        members = resolve( data.serverGroupUid ).groupMembers()
        for m in members
          if m and m.id is data.uid
            console.debug "This instance servergroup member has already deserialized", data
            return

        members[data.index-1] = {
          id      : data.uid
          appId   : data.resource.InstanceId
          eipData : data.resource.EipResource
        }
        return


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
        userData     : data.resource.UserData.Data

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]

      if data.resource.EipResource
        attr.hasEip  = true
        attr.eipData = {
          id : data.resource.EipResource.uid
          allocationId : data.resource.EipResource.AllocationId
        }

      if layout_data.osType and layout_data.architecture and layout_data.rootDeviceType
        attr.cachedAmi = {
          osType         : layout_data.osType
          architecture   : layout_data.architecture
          rootDeviceType : layout_data.rootDeviceType
        }

      if data.resource.SubnetId
        attr.parent = resolve( MC.extractID( data.resource.SubnetId ) )
      else
        attr.parent = resolve( MC.extractID( data.resource.Placement.AvailabilityZone ) )

      model = new Model( attr )

      # Add Keypair
      resolve( MC.extractID( data.resource.KeyName ) ).assignTo( model )
      null


  }

  Model
