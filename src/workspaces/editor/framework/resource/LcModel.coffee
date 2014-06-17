
define [ "../ComplexResModel", "./InstanceModel", "Design", "constant", "./VolumeModel", 'i18n!nls/lang.js', 'CloudResources' ], ( ComplexResModel, InstanceModel, Design, constant, VolumeModel, lang, CloudResources )->

  emptyArray = []

  Model = ComplexResModel.extend {
    # offset of asg
    offset:
      x: 2
      y: 3

    x: ()-> @parent()?.x() + @offset.x
    y: ()-> @parent()?.y() + @offset.y

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
      publicIp     : false
      state        : null

      # RootDevice
      rdSize : 0
      rdIops : ""

    type : constant.RESTYPE.LC
    newNameTmpl : "launch-config-"

    __brothers: []
    __bigBrother: null
    __isClone: false

    constructor : ( attr, option )->
      if option and option.createByUser and attr.parent.get("lc")
          return

      if option and option.clone
        @__isClone = true

      ComplexResModel.call( this, attr, option )

    clone: ->
      dolly = new Model null, clone: true
      @addBrother dolly

      for conn in @connections()
        connClass = Design.modelClassForType( conn.type )
        target = conn.getOtherTarget @type
        new connClass dolly, target

      dolly

    getBigBrother: ->
      @__bigBrother

    isClone: -> @__isClone

    addBrother: ( brother ) ->
      @__brothers.push brother
      brother.__bigBrother = @
      brother.listenTo @, 'all', ->
        if /^change/.test arguments[ 0 ]
          brother.trigger.apply brother, arguments

    removeBrother: ( brother ) ->
      idx = @__brothers.indexOf brother
      @__brothers.splice idx, 1 if idx > -1
      brother.stopListening()

    getContext: ( attr ) ->
      exception = [ '__parent', '__connections', 'x', 'y' ]
      if @__bigBrother and attr not in exception and not (_.intersection _.keys(exception), attr).length
        return @__bigBrother

      @

    set: ->
      context = @getContext arguments[ 0 ]
      ComplexResModel.prototype.set.apply context, arguments

    get: ->
      context = @getContext arguments[ 0 ]
      ComplexResModel.prototype.get.apply context, arguments





    initialize : ( attr, option )->
      @__brothers = []

      # Draw before create SgAsso
      if not option or not option.clone
        @draw(true)

      if option and option.createByUser

        @initInstanceType()

        # Default Kp
        KpModel = Design.modelClassForType( constant.RESTYPE.KP )
        KpModel.getDefaultKP().assignTo( this )

        # Default Sg
        defaultSg = Design.modelClassForType( constant.RESTYPE.SG ).getDefaultSg()
        SgAsso = Design.modelClassForType( "SgAsso" )
        new SgAsso( defaultSg, this )

      if not @get("rdSize")
        #append root device
        @set("rdSize",@getAmiRootDeviceVolumeSize())

      null

    getNewName : ( base )->
      if not @newNameTmpl
        newName = if @defaults then @defaults.name
        return newName or ""

      if base is undefined
        myKinds = _.filter Design.modelClassForType( @type ).allObjects(), (m) -> m.getBigBrother() is null
        base = myKinds.length

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
      if (state and _.isArray(state) and state.length > 0) or
        ($('#state-editor-model').is(':visible') and $('#state-editor-model .state-list .state-item').length >= 1)
          return MC.template.NodeStateRemoveConfirmation(name: @get("name"))

      true

    isDefaultTenancy : ()-> true

    # Use by CanvasElement(change members to groupMembers)
    groupMembers : ()->
      resource_list = CloudResources(constant.RESTYPE.LC, Design.instance().region())?.toJSON()
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
      if @__bigBrother
        @__bigBrother.removeBrother @
      else if @__brothers.length
        # Young brother continue his big-brother's duty when the big-brother dying
        for k, v of @attributes
          if k not in [ '__parent', '__connections' ]
            @__brothers[0].attributes[ k ] = v

        @__brothers[0].__bigBrother = null
        @__brothers[0].__brothers = []

        for brother, i in @__brothers
          if i isnt 0
            brother.__bigBrother = @__brothers[ 0 ]
            @__brothers[0].__brothers.push brother

      # Remove attached volumes
      for v in (@get("volumeList") or emptyArray).slice(0)
        v.remove()

      ComplexResModel.prototype.remove.call this
      null

    connect : ( cn )->
      if @parent() and cn.type is "SgRuleLine"
        # Create duplicate sgline for each expanded asg
        @parent().updateExpandedAsgSgLine( cn.getOtherTarget(@) )

      null

    disconnect : ( cn )->
      if @parent()
        if cn.type is "ElbAmiAsso"
          # No need to reset Asg's healthCheckType to EC2, when disconnected from Elb
          # Because user might just want to asso another Elb right after disconnected.
          # @parent().updateExpandedAsgAsso( cn.getOtherTarget(@), true )

        else if cn.type is "SgRuleLine"
          @parent().updateExpandedAsgSgLine( cn.getOtherTarget(@), true )
      null

    getStateData : () ->
      @get("state")

    setStateData : (stateAryData) ->
      @set("state", stateAryData)

    setKey: ( keyName, defaultKey ) ->
      KpModel = Design.modelClassForType( constant.RESTYPE.KP )
      defaultKp = KpModel.getDefaultKP()

      if defaultKey
        if defaultKp
          defaultKp.assignTo( this )
        else
          console.error "No DefaultKP found when initialize InstanceModel"
      else
        kp = @connectionTargets( "KeypairUsage" )[0]
        kp and kp.dissociate @
        @set 'keyName', keyName


    getKeyName: ->
      kp = @connectionTargets( "KeypairUsage" )[0]

      if kp
        if kp.isDefault() then '$DefaultKeyPair' else kp.get('name')
      else
         @get( 'keyName' ) or 'No Key Pair'

    isDefaultKey: ->
      kp = @connectionTargets( "KeypairUsage" )[0]
      kp and kp.isDefault()

    isNoKey: ->
      kp = @connectionTargets( "KeypairUsage" )[0]
      not kp and not @get( 'keyName' )


    setAmi                     : InstanceModel.prototype.setAmi
    getAmi                     : InstanceModel.prototype.getAmi
    getOSFamily                : InstanceModel.prototype.getOSFamily
    setInstanceType            : InstanceModel.prototype.setInstanceType
    initInstanceType           : InstanceModel.prototype.initInstanceType
    isEbsOptimizedEnabled      : InstanceModel.prototype.isEbsOptimizedEnabled
    getBlockDeviceMapping      : InstanceModel.prototype.getBlockDeviceMapping
    getAmiRootDevice           : InstanceModel.prototype.getAmiRootDevice
    getAmiRootDeviceName       : InstanceModel.prototype.getAmiRootDeviceName
    getAmiRootDeviceVolumeSize : InstanceModel.prototype.getAmiRootDeviceVolumeSize
    getInstanceType            : InstanceModel.prototype.getInstanceType
    getInstanceTypeConfig      : InstanceModel.prototype.getInstanceTypeConfig
    getInstanceTypeList        : InstanceModel.prototype.getInstanceTypeList

    serialize : ()->
      if @isClone()
        return

      ami = @getAmi() || @get("cachedAmi")
      layout = @generateLayout()
      if ami
        layout.osType         = ami.osType
        layout.architecture   = ami.architecture
        layout.rootDeviceType = ami.rootDeviceType


      sgarray = _.map @connectionTargets("SgAsso"), ( sg )-> sg.createRef( "GroupId" )

      # Generate an array containing the root device and then append all other volumes
      # to the array to form the LC's volume list
      blockDevice = @getBlockDeviceMapping()
      for volume in @get("volumeList") or emptyArray

        vd =
          DeviceName : volume.get("name")
          Ebs :
            VolumeSize : volume.get("volumeSize")
            VolumeType : volume.get("volumeType")

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
          SecurityGroups           : sgarray
          LaunchConfigurationName  : @get("configName") or @get("name")
          InstanceType             : @get("instanceType")
          AssociatePublicIpAddress : @get("publicIp")


      { component : component, layout : layout }

  }, {

    handleTypes : constant.RESTYPE.LC

    deserialize : ( data, layout_data, resolve )->
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

      rd = model.getAmiRootDevice()

      # Create Volume for
      for volume in data.resource.BlockDeviceMapping || []
        if rd and volume.DeviceName is rd.DeviceName
          model.set "rdSize", volume.Ebs.VolumeSize
          model.set "rdIops", volume.Ebs.Iops
        else
          _attr =
            name       : volume.DeviceName
            snapshotId : volume.Ebs.SnapshotId
            volumeSize : volume.Ebs.VolumeSize
            iops       : volume.Ebs.Iops
            owner      : model

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

