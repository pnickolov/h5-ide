
define [ "../ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume

    deserialize : ( data, layout_data, resolve )->

      #instance which volume attached
      attachment = data.resource.AttachmentSet
      instance   = if attachment and attachment.InstanceId then resolve( MC.extractID( attachment.InstanceId) ) else null

      attr =
        id     : data.uid
        name   : data.name
        count  : data.number
        #resource property
        snapshotId : data.resource.SnapshotId
        appId      : data.resource.VolumeId
        size       : data.resource.Size
        iops       : data.resource.Iops
        volumeType : data.resource.VolumeType
        deviceName : attachment.Device
        #
        instance : instance


      #for key, value of data.resource
      #  attr[ key ] = value

      model = new Model attr

      null
  }

  Model
