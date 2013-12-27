
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    defaults : ()->
    #property of volume
        id         : ''
        name       : ''
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


    constructor : ( attributes, option )->

      ComplexResModel.call this, attributes, option

      if option and option.isForLC
      #volume is attached to lc
        #@attributes.ownerType = 'lc'
        @attributes.owner = option.owner
        @attributes.deviceName = attributes.deviceName
        @attributes.volumeSize = attributes.volumeSize
        @attributes.snapshotId = attributes.snapshotId

      null

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume

    deserialize : ( data, layout_data, resolve )->

      #instance which volume attached
      if data and data.type is constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume and data.resource and data.resource.AttachmentSet
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
