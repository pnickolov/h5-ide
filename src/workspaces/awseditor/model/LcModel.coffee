
define [ "ComplexResModel", "./InstanceModel", "Design", "constant", "./VolumeModel", 'i18n!/nls/lang.js', 'CloudResources' ], ( ComplexResModel, InstanceModel, Design, constant, VolumeModel, lang, CloudResources )->

  emptyArray = []

  Model = ComplexResModel.extend {

    defaults : ()->
      imageId      : ""
      ebsOptimized : false
      instanceType : "m1.small"
      monitoring   : false
      userData     : ""
      publicIp     : false
      state        : null

      # RootDevice
      rdSize : 0
      rdIops : ""
      rdType : 'gp2'

    type : constant.RESTYPE.LC
    newNameTmpl : "launch-config-"

    initialize : ( attr, option )->
      if option and option.createByUser

        @initInstanceType()

        # Default Kp
        Design.modelClassForType( constant.RESTYPE.KP ).getDefaultKP().assignTo( this )

        # Default Sg
        SgAsso = Design.modelClassForType( "SgAsso" )
        new SgAsso( Design.modelClassForType( constant.RESTYPE.SG ).getDefaultSg(), this )

      if not @get("rdSize")
        #append root device
        @set("rdSize",@getAmiRootDeviceVolumeSize())

      null

    getNewName : ( base )->
      if not @newNameTmpl
        newName = if @defaults then @defaults.name
        return newName or ""

      if base is undefined
        base = @getAllObjects().length

      # Collect all the resources name
      nameMap = {}
      @design().eachComponent ( comp )->
        if comp.get("name")
          nameMap[ comp.get("name") ] = true
        null

      if Design.instance().modeIsAppEdit()
        resource_list = CloudResources(constant.RESTYPE.LC, Design.instance().region()).toJSON()
        for id, rl of resource_list
          if rl.LaunchConfigurationName
            nameMap[ _.first rl.LaunchConfigurationName.split( '---' ) ] = true



      while true
        newName = @newNameTmpl + base
        if nameMap[ newName ]
          base += 1
        else
          break

      newName

    isRemovable : () ->

      if @design().modeIsAppEdit() and @get("appId")
        return error : lang.ide.CVS_MSG_ERR_DEL_LC

      state = @get("state")
      if state and state.length > 0
        return MC.template.NodeStateRemoveConfirmation(name: @get("name"))

      true

    isDefaultTenancy : ()-> true

    # Use by CanvasElement(change members to groupMembers)
    groupMembers : ()->
      resource_list = CloudResources(constant.RESTYPE.ASG, Design.instance().region())
      if not resource_list then return []

      resource = resource_list.get(@connectionTargets("LcUsage")[0].get("appId"))?.toJSON()
      if resource and resource.Instances and resource.Instances.length
        amis = []
        for i in resource.Instances
          amis.push {
            id    : i.InstanceId
            appId : i.InstanceId
            state : i.HealthStatus
          }

      amis || []

    remove : ()->
      # Remove attached volumes when this lc is last lc
      for v in (@get("volumeList") or emptyArray).slice(0)
        v.remove()

      ComplexResModel.prototype.remove.call this
      null

    getStateData                : InstanceModel.prototype.getStateData
    setStateData                : InstanceModel.prototype.setStateData
    setKey                      : InstanceModel.prototype.setKey
    getKeyName                  : InstanceModel.prototype.getKeyName
    isDefaultKey                : InstanceModel.prototype.isDefaultKey
    isNoKey                     : InstanceModel.prototype.isNoKey
    setAmi                      : InstanceModel.prototype.setAmi
    getAmi                      : InstanceModel.prototype.getAmi
    getOSFamily                 : InstanceModel.prototype.getOSFamily
    setInstanceType             : InstanceModel.prototype.setInstanceType
    initInstanceType            : InstanceModel.prototype.initInstanceType
    isEbsOptimizedEnabled       : InstanceModel.prototype.isEbsOptimizedEnabled
    getBlockDeviceMapping       : InstanceModel.prototype.getBlockDeviceMapping
    getAmiRootDevice            : InstanceModel.prototype.getAmiRootDevice
    getAmiRootDeviceName        : InstanceModel.prototype.getAmiRootDeviceName
    getAmiRootDeviceVolumeSize  : InstanceModel.prototype.getAmiRootDeviceVolumeSize
    getInstanceType             : InstanceModel.prototype.getInstanceType
    getInstanceTypeConfig       : InstanceModel.prototype.getInstanceTypeConfig
    getInstanceTypeList         : InstanceModel.prototype.getInstanceTypeList

    serialize : ()->
      ami = @getAmi() || @get("cachedAmi")
      layout = @generateLayout()
      if ami
        layout.osType         = ami.osType
        layout.architecture   = ami.architecture
        layout.rootDeviceType = ami.rootDeviceType

      # Generate an array containing the root device and then append all other volumes
      # to the array to form the LC's volume list
      blockDevice = @getBlockDeviceMapping()
      for volume in @get("volumeList") or emptyArray

        vd =
          DeviceName : volume.get("name")
          Ebs :
            VolumeSize : volume.get("volumeSize")
            VolumeType : volume.get("volumeType")
            # Encrypted : volume.get("encrypted")

        if volume.get("volumeType") is "io1"
          vd.Ebs.Iops = volume.get("iops")

        if volume.get("snapshotId")
          vd.Ebs.SnapshotId = volume.get("snapshotId")

        blockDevice.push vd

      component =
        type : @type
        uid  : @id
        name : @get("name")
        state : @get("state")
        resource :
          UserData                 : @get("userData")
          LaunchConfigurationARN   : @get("appId")
          InstanceMonitoring       : @get("monitoring")
          ImageId                  : @get("imageId")
          KeyName                  : @get("keyName")
          EbsOptimized             : if @isEbsOptimizedEnabled() then @get("ebsOptimized") else false
          BlockDeviceMapping       : blockDevice
          SecurityGroups           : _.map @connectionTargets("SgAsso"), ( sg )-> sg.createRef( "GroupId" )
          LaunchConfigurationName  : @get("configName") or @get("name")
          InstanceType             : @get("instanceType")
          AssociatePublicIpAddress : @get("publicIp")


      { component : component, layout : layout }

  }, {

    handleTypes: constant.RESTYPE.LC

    resolveFirst: true

    preDeserialize: ( data, layout_data ) ->
      #old format state support
      if not (_.isArray(data.state) and data.state.length)
        data.state = null

      attr = {
        id    : data.uid
        name  : data.name
        state : data.state
        appId : data.resource.LaunchConfigurationARN

        imageId      : data.resource.ImageId
        ebsOptimized : data.resource.EbsOptimized
        instanceType : data.resource.InstanceType
        monitoring   : data.resource.InstanceMonitoring
        userData     : data.resource.UserData
        publicIp     : data.resource.AssociatePublicIpAddress
        configName   : data.resource.LaunchConfigurationName
      }

      if layout_data.osType and layout_data.architecture and layout_data.rootDeviceType
        attr.cachedAmi = {
          osType         : layout_data.osType
          architecture   : layout_data.architecture
          rootDeviceType : layout_data.rootDeviceType
        }

      new Model( attr )

      null

    deserialize : ( data, layout_data, resolve )->
      model = resolve data.uid

      rd = model.getAmiRootDevice()

      # Create Volume for
      for volume in data.resource.BlockDeviceMapping || []
        if rd and volume.DeviceName is rd.DeviceName
          model.set "rdSize", volume.Ebs.VolumeSize
          model.set "rdIops", volume.Ebs.Iops
          model.set "rdType", volume.Ebs.VolumeType
        else
          _attr =
            name       : volume.DeviceName
            snapshotId : volume.Ebs.SnapshotId
            volumeSize : volume.Ebs.VolumeSize
            volumeType : volume.Ebs.VolumeType
            iops       : volume.Ebs.Iops
            owner      : model
            # encrypted  : volume.Ebs.Encrypted

          new VolumeModel(_attr, {noNeedGenName:true})

      # Asso SG
      SgAsso = Design.modelClassForType( "SgAsso" )
      for sg in data.resource.SecurityGroups || []
        new SgAsso( model, resolve( MC.extractID(sg) ) )

      # Add Keypair
      KP = resolve( MC.extractID( data.resource.KeyName ) )

      if KP
        KP.assignTo( model )
      else
        model.set 'keyName', data.resource.KeyName


      null
  }

  Model

