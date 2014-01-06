
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    defaults :
      #ownerType  : '' #'instance'|'lc'
      owner      : null #instance model | lc model
      #servergroup
      serverGroupUid  : ''
      serverGroupName : ''
      #common
      deviceName : ''
      volumeSize : 1
      snapshotId : ''
      #extend for instance
      appId      : ''
      volumeType : ''
      iops       : ''


    type : constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume


    constructor : ( attributes )->

      owner = attributes.owner
      delete attributes.owner

      ComplexResModel.call this, attributes

      @attachTo( owner )

      null

    attachTo : ( owner )->
      if not owner then return
      if owner is @attributes.owner then return

      oldOwner = @attributes.owner
      if oldOwner
        vl = oldOwner.attributes.volumeList
        vl.splice( vl.indexOf(this), 1 )

      @attributes.owner = owner

      if owner.attributes.volumeList
        owner.attributes.volumeList.push( this )
      else
        owner.attributes.volumeList = [ this ]

      null

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
        serverGroupName : data.serverGroupName
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
