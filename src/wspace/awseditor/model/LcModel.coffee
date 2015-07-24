
define [
  "ComplexResModel"
  "./InstanceModel"
  "Design"
  "constant"
  "./VolumeModel"
  "i18n!/nls/lang.js"
  "CloudResources"
  "DiffTree"
], ( ComplexResModel, InstanceModel, Design, constant, VolumeModel, lang, CloudResources, DiffTree )->

  emptyArray = []
  changeDetectExcepts = [ 'name', 'description', 'state' ]

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

    constructor: ( attributes, options ) ->
      if !options or !options.createBySubClass
        if Model.isMesosSlave attributes
          return new ( Design.modelClassForType constant.RESTYPE.MESOSLC ) attributes, options

      ComplexResModel.apply @, arguments

    initialize : ( attr, option )->
      if option and option.createByUser

        @initInstanceType()

        # Default Kp
        Design.modelClassForType( constant.RESTYPE.KP ).getDefaultKP().assignTo( this )

        # Default Sg
        unless @isMesos()
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
        resource_list = CloudResources( @design().credentialId(), constant.RESTYPE.LC, @design().region()).toJSON()
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
      state = @get("state")
      if state and state.length > 0
        return MC.template.NodeStateRemoveConfirmation(name: @get("name"))

      true

    isPublic: -> @get 'publicIp'

    isDefaultTenancy : ()-> true

    # Use by CanvasElement(change members to groupMembers)
    groupMembers : ( asg )->
      if asg
        asgAppId = asg.get('appId')
      else
        asgAppId = @connectionTargets("LcUsage")[0].get("appId")

      Design.modelClassForType(constant.RESTYPE.ASG).members( asgAppId )

    getAsgs: -> @connectionTargets( "LcUsage" )

    getAsgsIncludeExpanded: ->
      asgsIncludeExpanded = []
      asgs = @getAsgs()

      _.each asgs, ( asg ) ->
        asgsIncludeExpanded = asgsIncludeExpanded.concat asg.get("expandedList")

      asgsIncludeExpanded.concat asgs


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
    isMesos                     : InstanceModel.prototype.isMesos
    isMesosMaster               : InstanceModel.prototype.isMesosMaster
    isMesosSlave                : InstanceModel.prototype.isMesosSlave

    getId: ( options, changed ) ->
      if !options or options.usage isnt 'updateApp' then return @id
      if !changed and !@changedInAppEdit() then return @id
      unless @__newId then @__newId = @design().guid()
      @__newId

    changedInAppEdit: () ->
      if !@design().modeIsAppEdit() or !@get( 'appId' )
        return false

      diffTree = new DiffTree();
      !_.isEmpty diffTree.compare(@genResource(), @design().opsModel().getJsonData().component[ @id ].resource)

    createRef: ( refName = 'LaunchConfigurationName', isResourceNS, id, options ) ->
      id = @getId(options)
      ComplexResModel.prototype.createRef.call @, refName, isResourceNS, id

    serialize : ( options )->
      changed = options and options.usage is 'updateApp' and @changedInAppEdit()

      ami = @getAmi() || @get("cachedAmi")
      layout = @generateLayout()
      if ami
        layout.osType         = ami.osType
        layout.architecture   = ami.architecture
        layout.rootDeviceType = ami.rootDeviceType

      if InstanceModel.isMesosMaster(@attributes) or InstanceModel.isMesosSlave(@attributes)
        @setMesosState()

      component =
        type : @type
        uid  : @getId(options, changed)
        name : if changed then @getNewName() else @get("name")
        description : @get("description") or ""
        state : @get("state")
        resource : @genResource(changed)

      { component : component, layout : layout }

    genResource: (changed) ->
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

      UserData                 : @get("userData")
      LaunchConfigurationARN   : if changed then '' else @get("appId")
      InstanceMonitoring       : @get("monitoring")
      ImageId                  : @get("imageId")
      KeyName                  : @get("keyName")
      EbsOptimized             : if @isEbsOptimizedEnabled() then @get("ebsOptimized") else false
      BlockDeviceMapping       : blockDevice
      SecurityGroups           : _.map @connectionTargets("SgAsso"), ( sg )-> sg.createRef( "GroupId" )
      LaunchConfigurationName  : @get("configName") or @get("name")
      InstanceType             : @get("instanceType")
      AssociatePublicIpAddress : @get("publicIp")

  }, {

    handleTypes: constant.RESTYPE.LC

    isMesosMaster: InstanceModel.isMesosMaster
    isMesosSlave: InstanceModel.isMesosSlave

    resolveFirst: true

    preDeserialize: ( data, layout_data ) ->
      #old format state support
      if not (_.isArray(data.state) and data.state.length)
        data.state = null

      attr = {
        id          : data.uid
        name        : data.name
        description : data.description or ""
        state       : data.state
        appId       : data.resource.LaunchConfigurationARN

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
        if (rd and volume.DeviceName is rd.DeviceName) or (not rd and volume.DeviceName in ['/dev/xvda','/dev/sda1'])
          model.set "rdSize", volume.Ebs.VolumeSize
          model.set "rdIops", volume.Ebs.Iops
          model.set "rdType", volume.Ebs.VolumeType
        else
          #skip instance-stored volume
          if volume.Ebs
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
      if model.get 'appId'
        appData = CloudResources(model.design().credentialId(), constant.RESTYPE.LC, model.design().region()).get(model.get('appId'))?.toJSON()

      unless appData
        KP = resolve( MC.extractID( data.resource.KeyName ) )

        if KP
          KP.assignTo( model )
        else
          if data.resource.KeyName || data.resource.KeyName is ""
            model.set 'keyName', data.resource.KeyName
          else
            _.defer ()-> Design.modelClassForType( constant.RESTYPE.KP ).getDefaultKP().assignTo( model )
      else
        model.set 'keyName', appData.KeyName


      null
  }

  Model
