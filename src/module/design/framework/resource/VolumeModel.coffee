
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    defaults :

      name       : ''
      #ownerType  : '' #'instance'|'lc'
      owner      : null #instance model | lc model
      #servergroup
      serverGroupUid  : ''
      ##serverGroupName : ''
      #common
      deviceName : ''
      volumeSize : 1
      snapshotId : ''
      #extend for instance
      appId      : ''
      volumeType : 'standard'
      iops       : ''


    type : constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume


    constructor : ( attributes )->

      owner = attributes.owner
      delete attributes.owner

      if !attributes.name
        #create volume
        attributes.name = @getDeviceName( owner )
        attributes.deviceName = attributes.name

      if attributes.name
        ComplexResModel.call this, attributes

        @attachTo( owner )

      null

    remove : ()->
      # Remove reference in owner
      vl = @attributes.owner.get("volumeList")
      vl.splice( vl.indexOf(this), 1 )
      null

    attachTo : ( owner )->
      if not owner then return
      if owner is @attributes.owner then return

      oldOwner = @attributes.owner
      if oldOwner
        vl = oldOwner.attributes.volumeList
        vl.splice( vl.indexOf(this), 1 )
        oldOwner.draw()

      @attributes.owner = owner

      if owner.attributes.volumeList
        owner.attributes.volumeList.push( this )
      else
        owner.attributes.volumeList = [ this ]

      owner.draw()

      null


    getDeviceName : (owner)->

      imageId  = owner.get( "imageId" )
      ami_info = MC.data.dict_ami[ imageId ]

      if !ami_info
        notification "warning", "The AMI(" +  imageId + ") is not exist now, try to use another AMI.", false  unless ami_info
        return null

      else
        #set deviceName
        deviceName = null
        if ami_info.virtualizationType isnt "hvm"
          deviceName = ["f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
        else
          deviceName = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"]

        $.each ami_info.blockDeviceMapping, (key, value) ->
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
          notification "warning", "Attached volume has reached instance limit.", false
          return null

        if ami_info.virtualizationType isnt "hvm"
          deviceName = "/dev/sd" + deviceName[0]
        else
          deviceName = "xvd" + deviceName[0]

        return deviceName

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume

    deserialize : ( data, layout_data, resolve )->

      #instance which volume attached
      if data.resource.AttachmentSet
        attachment = data.resource.AttachmentSet
        instance   = if attachment and attachment.InstanceId then resolve( MC.extractID( attachment.InstanceId) ) else null
      else
        console.error "deserialize failed"
        return null

      attr =
        id         : data.uid
        name       : data.name
        #ownerType  : 'instance'
        owner      : instance
        #servergroup
        serverGroupUid  : data.serverGroupUid
        ##serverGroupName : data.serverGroupName
        #resource property
        deviceName : attachment.Device
        volumeSize : data.resource.Size
        snapshotId : data.resource.SnapshotId
        volumeType : data.resource.VolumeType
        iops       : data.resource.Iops
        appId      : data.resource.VolumeId


      model = new Model attr

      null
  }

  Model
