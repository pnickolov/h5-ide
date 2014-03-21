
define [ "i18n!nls/lang.js", "../ComplexResModel", "constant" ], ( lang, ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    defaults :

      name       : ''
      #ownerType  : '' #'instance'|'lc'
      owner      : null #instance model | lc model
      #common
      #deviceName : ''
      volumeSize : 1
      snapshotId : ''
      #extend for instance
      appId      : ''
      volumeType : 'standard'
      iops       : ''


    type : constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume


    constructor : ( attributes, options )->

      #  <attributes.owner> : InstanceModel
      #  [attributes.snapshotId]
      #  [attributes.volumeSize]
      #  [attributes.volumeType]
      #  [attributes.iops]
      #  [options.noNeedGenName] : true|false

      owner = attributes.owner
      delete attributes.owner

      if !attributes.name
        #create volume
        attributes.name = @getDeviceName( owner )

      if attributes.name
        ComplexResModel.call this, attributes

        @attachTo( owner, options )

      if options and options.cloneSource
        @clone( options.cloneSource )

      if attributes.iops
        attributes.volumeType = "io1"
      null

    clone : ( srcTarget )->
      @cloneAttributes srcTarget, { reserve : "owner" }
      null

    isVisual : ()-> false

    isReparentable : ( newParent )->
      if @design().modeIsAppEdit()
        parent = @get("owner")

        if parent.type isnt newParent.type
          return false

        if not @get("appId") then return true

        # Disable transfering exsiting volume between servergroups and others.
        if parent.get("count") > 1
          return lang.ide.CVS_MSG_ERR_SERVERGROUP_VOLUME

        if newParent.get("count") > 1
          return lang.ide.CVS_MSG_ERR_SERVERGROUP_VOLUME2

        while parent and parent.type isnt constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone
          parent    = parent.parent()
          newParent = newParent.parent()

        if parent and newParent and parent isnt newParent
          return "Cannot move volume across availability zone."

      true

    groupMembers : ()->
      if not @__groupMembers then @__groupMembers = []
      return @__groupMembers

    remove : ()->
      # Remove reference in owner
      vl = @attributes.owner.get("volumeList")
      vl.splice( vl.indexOf(this), 1 )
      @attributes.owner.draw()

      ComplexResModel.prototype.remove.call this
      null

    genFullName: ( name ) ->
      if @get( 'name' )[ 0 ] isnt '/'
        'xvd' + name
      else
        '/dev/' + name

    getCost : ( priceMap, currency, force )->
      if not priceMap.ebs then return

      owner = @get("owner")
      if not owner
        console.warn( "This volume has not attached to any ami, found when calc-ing cost :", this )
        return

      if not force and @get("owner").type isnt constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        return

      standardType = @get("volumeType") is "standard"
      for t in priceMap.ebs.types
        if standardType
          if t.ebsVols
            volumePrices = t.ebsVols
        else if t.ebsPIOPSVols
          volumePrices = t.ebsPIOPSVols

      if not volumePrices then return

      count = @get("owner").get("count") or 1
      name  = owner.get("name") + " - " + @get("name")
      if count > 1
        name += " (x#{count})"

      for p in volumePrices
        if p.unit is 'perGBmoProvStorage'
          fee = p[currency]
          return {
            resource    : name
            type        : @get("volumeSize") + "G"
            fee         : fee * @get("volumeSize") * count
            formatedFee : fee + "/GB/mo"
          }
      null

    attachTo : ( owner, options )->
      if not owner then return false
      if owner is @attributes.owner then return false

      oldOwner = @attributes.owner
      if oldOwner
        vl = oldOwner.attributes.volumeList
        vl.splice( vl.indexOf(this), 1 )
        oldOwner.draw()

      @attributes.owner = owner

      if not (options and options.noNeedGenName)
        #generate new deviceName
        @attributes.name = @getDeviceName( owner )
        if !@attributes.name
          return false

      if owner.attributes.volumeList
        owner.attributes.volumeList.push( this )
      else
        owner.attributes.volumeList = [ this ]

      owner.draw()
      true

    getDeviceName : (owner)->

      imageId  = owner.get( "imageId" )
      ami_info = MC.data.dict_ami[ imageId ]

      if !ami_info
        notification "warning", sprintf(lang.ide.NOTIFY_MSG_WARN_AMI_NOT_EXIST_TRY_USE_OTHER, imageId), false  unless ami_info
        return null

      else
        #set deviceName
        deviceName = null
        if ami_info.osType isnt "windows"
          deviceName = ["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
        else
          deviceName = ["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"]

        $.each ami_info.blockDeviceMapping || [], (key, value) ->
          if key.slice(0, 4) is "/dev/"
            k = key.slice(-1)
            index = deviceName.indexOf(k)
            deviceName.splice index, 1  if index >= 0

        #check existed volume attached to instance
        volumeList = owner.get( "volumeList" )
        if volumeList and volumeList.length>0
          $.each volumeList, (key, value) ->
            k = value.get( "name" ).slice(-1)
            index = deviceName.indexOf(k)
            deviceName.splice index, 1  if index >= 0

        #no valid deviceName
        if deviceName.length is 0
          notification "warning", lang.ide.NOTIFY_MSG_WARN_ATTACH_VOLUME_REACH_INSTANCE_LIMIT, false
          return null

        if ami_info.osType isnt "windows"
          deviceName = "/dev/sd" + deviceName[0]
        else
          deviceName = "xvd" + deviceName[0]

        return deviceName

    ensureEnoughMember : ()->
      if not @get("owner") then return

      totalCount = @get("owner").get("count")
      if not totalCount then return

      totalCount -= 1
      while @groupMembers().length < totalCount
        @groupMembers().push {
          id    : MC.guid()
          appId : ""
        }
      null

    generateJSON : ( index, serverGroupOption )->

      console.assert( not serverGroupOption or serverGroupOption.instanceId isnt undefined, "Invalid serverGroupOption" )

      @ensureEnoughMember()

      appId = ""

      if index > 0
        member = @groupMembers()[ index - 1 ]
        uid   = member.id
        appId = member.appId
      else
        uid   = @id
        appId = @get("appId")

      instanceId = @createRef( "InstanceId", serverGroupOption.instanceId )

      owner = @get("owner")

      {
        uid             : uid
        type            : @type
        name            : @get("name")
        serverGroupUid  : @id
        serverGroupName : @get("name")
        index           : index
        number          : serverGroupOption.number or 1
        resource :
          VolumeId   : appId
          Size       : @get("volumeSize")
          SnapshotId : @get("snapshotId")
          Iops       : @get("iops")
          VolumeType : @get("volumeType")
          AvailabilityZone : if owner then owner.getAvailabilityZone().createRef() else ""
          AttachmentSet :
            InstanceId : instanceId
            Device     : @get("name")
      }


    serialize : () ->
      # Does not serialize Volume for LC.
      # And instance will do serialization for Volume.
      # So if a volume is attached, it should not be serialized.
      if @get("owner") then return

      { component : @generateJSON( 0, { number : 1 } ) }

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume

    diffJson : ( newData, oldData, newComponent, oldComponent )->
      if not ( newData and oldData and _.isEqual(newData, oldData) )
        changeData = newData or oldData
        instance = Design.instance().component( changeData.resource.AttachmentSet.InstanceId )
        if instance
          return {
            id     : instance.id
            name   : instance.get("name")
            change : "Update"
          }

      return

    deserialize : ( data, layout_data, resolve )->

      # Compact volume for servergroup
      if data.serverGroupUid and data.serverGroupUid isnt data.uid
        members = resolve( data.serverGroupUid ).groupMembers()
        for m in members
          if m and m.id is data.uid
            console.debug "This volume servergroup member has already deserialized", data
            return

        members[data.index-1] = {
          id    : data.uid
          appId : data.resource.VolumeId
        }
        return


      #instance which volume attached
      if data.resource.AttachmentSet
        attachment = data.resource.AttachmentSet
        instance   = if attachment and attachment.InstanceId then resolve( MC.extractID( attachment.InstanceId) ) else null
      else
        console.error "deserialize failed"
        return null

      attr =
        id    : data.uid
        name  : data.serverGroupName or data.name
        owner : instance
        #resource property
        #deviceName : attachment.Device
        volumeSize : data.resource.Size
        snapshotId : data.resource.SnapshotId
        volumeType : data.resource.VolumeType
        iops       : data.resource.Iops
        appId      : data.resource.VolumeId


      model = new Model attr, {noNeedGenName:true}

      null
  }

  Model
