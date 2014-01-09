
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
      instanceType : "t1.micro"
      monitoring   : false
      userData     : ""

      cachedAmi : null

    initialize : ( attr, option )->

      if option and option.createByUser

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
          @setEmbedEni( new EniModel({}, { instance: this }) )

      else
        @draw( true )

      vpc = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).theVPC()
      if vpc and not vpc.isDefaultTenancy()
        @setTenancy( "dedicated" )

      #listen resource update event
      @listenTo Design.instance(), Design.EVENT.AwsResourceUpdated, @draw

      null

    getCost : ( priceMap, currency )->
      if not priceMap.instance then return null

      ami = @getAmi() || @get("cachedAmi")
      osType   = if ami then ami.osType else "linux-other"
      osFamily = if ami then ami.osFamily else "linux"

      instanceType = @get("instanceType").split(".")
      unit = priceMap.instance.unit
      fee  = priceMap.instance[ instanceType[0] ][ instanceType[1] ]
      fee  = if fee then fee.onDemand
      fee  = if fee then fee[ osFamily ]
      fee  = if fee then fee[ currency ]

      if not fee then return null

      if unit is "perhr"
        formatedFee = fee + "/hr"
        fee *= 24 * 30
      else
        formatedFee = fee + "/mo"

      priceObj =
          resource    : @get("name")
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
              fee         : fee
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

      # Remove route to Embed Eni
      route = @getEmbedEni().connections('RTB_Route')[0]
      if route then route.remove()

      # Update my self and connected Eni
      @draw()
      for eni in @connectionTargets("EniAttachment")
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
          Canvon.image( MC.IMG_URL + 'ide/icon/instance-volume-attached-active.png' , 21, 44, 29, 24 ).attr({
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

      else
        node = $( document.getElementById( @id ) )

        # update label
        CanvasManager.update node.children(".node-label-name"), @get("name")

      # Update Server number
      numberGroup = node.children(".server-number-group")
      if @get("count") > 1
        CanvasManager.toggle node.children(".port-instance-rtb"), false
        CanvasManager.toggle numberGroup, true
        CanvasManager.update numberGroup.children("text"), @get("count")
      else
        CanvasManager.toggle node.children(".port-instance-rtb"), true
        CanvasManager.toggle numberGroup, false

      volumeCount = if @get("volumeList") then @get("volumeList").length else 0
      CanvasManager.update node.children(".volume-number"), volumeCount

      # Update EIP
      CanvasManager.updateEip node.children(".eip-status"), @hasPrimaryEip()

      # TODO : Update Instance status

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
    appIdKey    : "InstanceId"

    deserialize : ( data, layout_data, resolve )->

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
