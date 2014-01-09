
define [ "../ComplexResModel", "./InstanceModel", "CanvasManager", "Design", "constant", "./VolumeModel", 'i18n!nls/lang.js' ], ( ComplexResModel, InstanceModel, CanvasManager, Design, constant, VolumeModel, lang )->

  emptyArray = []

  Model = ComplexResModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 9
      height   : 9

      imageId      : ""
      ebsOptimized : false
      instanceType : ""
      monitoring   : false
      userData     : ""
      publicIp     : false

    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
    newNameTmpl : "launch-config-"

    initialize : ( attr, option )->
      # Draw before create SgAsso
      @draw(true)

      if option and option.createByUser
        # Default Kp
        KpModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair )
        KpModel.getDefaultKP().assignTo( this )

        # Default Sg
        defaultSg = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup ).getDefaultSg()
        SgAsso = Design.modelClassForType( "SgAsso" )
        new SgAsso( defaultSg, this )
      null

    isRemovable : ()-> { error : lang.ide.CVS_MSG_ERR_DEL_LC }

    remove : ()->
      # Remove attached volumes
      for v in @get("volumeList") or emptyArray
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
    setInstanceType       : InstanceModel.prototype.setInstanceType
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
          Canvon.image( MC.IMG_URL + 'ide/icon/instance-volume-attached-active.png' , 31, 44, 29, 24 ).attr({'id': @id + '_volume_status'}),
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

        layout_data.osType and layout_data.architecture and layout_data.rootDeviceType
        attr.cachedAmi = {
          osType         : layout_data.osType
          architecture   : layout_data.architecture
          rootDeviceType : layout_data.rootDeviceType
        }

      kp = @connectionTargets("KeypairUsage")[0]
      sgarray = _.map @connectionTargets("SgAsso"), ( sg )->
        "@#{sg.id}.resource.GroupId"

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
          EbsOptimized             : @get("ebsOptimized")
          BlockDeviceMapping       : blockDevice
          KeyName                  : "@#{kp.id}.resource.KeyName"
          SecurityGroups           : sgarray
          SpotPrice                : ""
          LaunchConfigurationName  : @get("name")
          KernelId                 : ""
          IamInstanceProfile       : ""
          InstanceType             : @get("instanceType")
          AssociatePublicIpAddress : @get("publicIp")

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
          deviceName : volume.DeviceName
          snapshotId : volume.Ebs.SnapshotId
          volumeSize : volume.Ebs.VolumeSize
        _opt =
          isForLC : true
          owner   : model
        new VolumeModel(_attr, _opt)

      # Asso SG
      SgAsso = Design.modelClassForType( "SgAsso" )
      for sg in data.resource.SecurityGroups || []
        new SgAsso( model, resolve( MC.extractID(sg) ) )

      # Add Keypair
      resolve( MC.extractID( data.resource.KeyName ) ).assignTo( model )
      null
  }

  Model

