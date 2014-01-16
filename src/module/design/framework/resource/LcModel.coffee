
define [ "../ComplexResModel", "./InstanceModel", "CanvasManager", "Design", "constant", "./VolumeModel", 'i18n!nls/lang.js' ], ( ComplexResModel, InstanceModel, CanvasManager, Design, constant, VolumeModel, lang )->

  emptyArray = []

  Model = ComplexResModel.extend {

    defaults : ()->
      x        : 0
      y        : 0
      width    : 9
      height   : 9

      imageId      : ""
      ebsOptimized : false
      instanceType : "m1.small"
      monitoring   : false
      userData     : ""
      publicIp     : Design.instance().typeIsDefaultVpc()

    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
    newNameTmpl : "launch-config-"

    initialize : ( attr, option )->
      # Draw before create SgAsso
      @draw(true)

      if option and option.createByUser

        @initInstanceType()

        # Default Kp
        KpModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair )
        KpModel.getDefaultKP().assignTo( this )

        # Default Sg
        defaultSg = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup ).getDefaultSg()
        SgAsso = Design.modelClassForType( "SgAsso" )
        new SgAsso( defaultSg, this )
      null

    isRemovable : ()-> { error : lang.ide.CVS_MSG_ERR_DEL_LC }
    isDefaultTenancy : ()-> true

    # Use by CanvasElement
    groupMembers : ()->
      resource_list = MC.data.resource_list[ Design.instance().region() ]
      if not resource_list then return []

      resource = resource_list[ @parent().get("appId") ]

      if resource and resource.Instances and resource.Instances.member
        amis = []
        for i in resource.Instances.member
          amis.push {
            id    : i.InstanceId
            appId : i.InstanceId
            state : i.HealthStatus
          }

      amis || []

    remove : ()->
      # Remove attached volumes
      for v in (@get("volumeList") or emptyArray).slice(0)
        v.remove()

      null

    iconUrl : ()->
      ami = MC.data.dict_ami[ @get 'imageId' ] || @get("cachedAmi")

      if not ami
        return "ide/ami/ami-not-available.png"
      else
        return "ide/ami/" + ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"

    connect : ( cn )->
      if @parent()
        if cn.type is "ElbAmiAsso"
          @parent().updateExpandedAsgAsso( cn.getTarget(constant.AWS_RESOURCE_TYPE.AWS_ELB) )

        if cn.type is "SgRuleLine"
          # Create duplicate sgline for each expanded asg
          @parent().updateExpandedAsgSgLine( cn.getOtherTarget( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration ) )

      null

    disconnect : ( cn )->
      if @parent()
        if cn.type is "ElbAmiAsso"
          # No need to reset Asg's healthCheckType to EC2, when disconnected from Elb
          # Because user might just want to asso another Elb right after disconnected.
          @parent().updateExpandedAsgAsso( cn.getTarget(constant.AWS_RESOURCE_TYPE.AWS_ELB), true )
      else
        if cn.type is "SgRuleLine"
          @parent().updateExpandedAsgSgLine( cn.getOtherTarget( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration ), true )
      null

    getAmi                : InstanceModel.prototype.getAmi
    getDetailedOSFamily   : InstanceModel.prototype.getDetailedOSFamily
    setInstanceType       : InstanceModel.prototype.setInstanceType
    initInstanceType      : InstanceModel.prototype.initInstanceType
    isEbsOptimizedEnabled : InstanceModel.prototype.isEbsOptimizedEnabled

    draw : ( isCreate )->

      if isCreate

        design = Design.instance()

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
          Canvon.image( MC.IMG_URL + 'ide/icon/instance-volume-attached-normal.png' , 31, 44, 29, 24 ).attr({
              'id': @id + '_volume_status'
              'class':'volume-image'
            }),
          # Volume Label
          Canvon.text( 45, 56, "" ).attr({'class':'node-label volume-number'}),

          # Volume Hotspot
          Canvon.rectangle(31, 44, 29, 24).attr({
            'data-target-id' : @id
            'class'          : 'instance-volume'
            'fill'           : 'none'
          }),

          # left port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-launchconfig-sg-left'
            'class'      : 'port port-blue port-launchconfig-sg port-launchconfig-sg-left'
            'transform'  : 'translate(5, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
            'data-name'     : 'launchconfig-sg'
            'data-position' : 'left'
            'data-type'     : 'sg'
            'data-direction': 'in'
          }),

          # right port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-launchconfig-sg-right'
            'class'      : 'port port-blue port-launchconfig-sg port-launchconfig-sg-right'
            'transform'  : 'translate(75, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
            'data-name'     : 'launchconfig-sg'
            'data-position' : 'right'
            'data-type'     : 'sg'
            'data-direction': 'out'
          })

          # Child number
          Canvon.group().append(
            Canvon.rectangle(36, 1, 20, 16).attr({'class':'server-number-bg','rx':4,'ry':4}),
            Canvon.text(46, 13, "0").attr({'class':'node-label server-number'})
          ).attr({
            'id'      : @id + "_instance-number-group"
            'class'   : 'instance-number-group'
            "display" : "none"
          })
        )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()

      else
        node = $( document.getElementById( @id ) )

        # Node Label
        CanvasManager.update node.children(".node-label-name"), @get("name")

      # Volume Number
      volumeCount = if @get("volumeList") then @get("volumeList").length else 0
      CanvasManager.update node.children(".volume-number"), volumeCount
      if volumeCount > 0
        volumeImage = 'ide/icon/instance-volume-attached-normal.png'
      else
        volumeImage = 'ide/icon/instance-volume-not-attached.png'
      CanvasManager.update node.children(".volume-image"), volumeImage, "href"

      # In app mode, show number
      if not Design.instance().modeIsStack() and @parent()
        data = MC.data.resource_list[ Design.instance().region() ][ @parent().get("appId") ]
        numberGroup = node.children(".instance-number-group")
        if data and data.Instances and data.Instances.member and data.Instances.member.length > 0
          CanvasManager.toggle numberGroup, true
          CanvasManager.update numberGroup.children("text"), data.Instances.member.length
        else
          CanvasManager.toggle numberGroup, false
      null

    serialize : ()->

      layout =
        coordinate : [ @x(), @y() ]
        uid        : @id
        groupUId   : @parent().id

      ami = @getAmi() || @get("cachedAmi")
      if ami
        layout.osType         = ami.osType
        layout.architecture   = ami.architecture
        layout.rootDeviceType = ami.rootDeviceType


      sgarray = _.map @connectionTargets("SgAsso"), ( sg )-> sg.createRef( "GroupId" )

      blockDevice = []
      for volume in @get("volumeList") or emptyArray
        vd =
          DeviceName : volume.get("name")
          Ebs :
            VolumeSize : volume.get("volumeSize")

        if volume.get("snapshotId")
          vd.Ebs.SnapshotId = volume.get("snapshotId")

        blockDevice.push vd

      component =
        type : @type
        uid  : @id
        name : @get("name")
        resource :
          UserData                 : @get("userData")
          LaunchConfigurationARN   : @get("appId")
          InstanceMonitoring       : @get("monitoring")
          ImageId                  : @get("imageId")
          EbsOptimized             : if @isEbsOptimizedEnabled() then @get("ebsOptimized") else false
          BlockDeviceMapping       : blockDevice
          KeyName                  : ""
          SecurityGroups           : sgarray
          SpotPrice                : ""
          LaunchConfigurationName  : @get("configName") or @get("name")
          KernelId                 : ""
          IamInstanceProfile       : ""
          InstanceType             : @get("instanceType")
          AssociatePublicIpAddress : @get("publicIp")
          #reserved
          CreatedTime              : ""
          RamdiskId                : ""


      { component : component, layout : layout }

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

    deserialize : ( data, layout_data, resolve )->

      attr = {
        id    : data.uid
        name  : data.name
        appId : data.resource.LaunchConfigurationARN

        imageId      : data.resource.ImageId
        ebsOptimized : data.resource.EbsOptimized
        instanceType : data.resource.InstanceType
        monitoring   : data.resource.InstanceMonitoring
        userData     : data.resource.UserData
        publicIp     : data.resource.AssociatePublicIpAddress
        configName   : data.resource.LaunchConfigurationName

        createdTime   : data.resource.CreatedTime

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      }

      if layout_data.osType and layout_data.architecture and layout_data.rootDeviceType
        attr.cachedAmi = {
          osType         : layout_data.osType
          architecture   : layout_data.architecture
          rootDeviceType : layout_data.rootDeviceType
        }

      model = new Model( attr )


      # Create Volume for
      for volume in data.resource.BlockDeviceMapping || []
        _attr =
          name       : volume.DeviceName
          snapshotId : volume.Ebs.SnapshotId
          volumeSize : volume.Ebs.VolumeSize
          owner      : model

        new VolumeModel(_attr, {noNeedGenName:true})

      # Asso SG
      SgAsso = Design.modelClassForType( "SgAsso" )
      for sg in data.resource.SecurityGroups || []
        new SgAsso( model, resolve( MC.extractID(sg) ) )

      # Add Keypair
      resolve( MC.extractID( data.resource.KeyName ) ).assignTo( model )
      null
  }

  Model

