#############################
#  View Mode for design/property/volume
#############################

define [ '../base/model', 'Design', 'CloudResources', 'constant' ], ( PropertyModel, Design, CloudResources, constant ) ->

    getVolRes = ( volComp ) ->

      representMember = volComp.get( 'owner' ).groupMembers()[ 0 ]
      deviceName = volComp.get 'name'
      appId = representMember.appId

      instanceList = CloudResources(constant.RESTYPE.INSTANCE, Design.instance().region())
      volumeList = CloudResources(constant.RESTYPE.VOL, Design.instance().region())

      if not instanceList then return null

      data = instanceList.get(appId)?.toJSON()

      if data and data.blockDeviceMapping
        for v in data.blockDeviceMapping
          if data.rootDeviceName.indexOf(v.deviceName) isnt -1 then continue

          volume = volumeList.get( v.ebs.volumeId )?.attributes

          if not volume then continue
          if volume.device isnt deviceName then continue

          return volume

      null




    VolumeAppModel = PropertyModel.extend {

        init : ( uid )->

          myVolumeComponent = Design.instance().component( uid )

          if myVolumeComponent
            appId = myVolumeComponent.get("appId")

          else
            appId = uid

          # LC's volume don't have appId
          if not appId and myVolumeComponent.get( 'owner' ).type is constant.RESTYPE.LC
            volume = getVolRes myVolumeComponent
          else
            volume = CloudResources(constant.RESTYPE.VOL, Design.instance().region()).get(appId)
            volume = volume.attributes

          if volume
            if volume.attachmentSet
              volume.name = volume.attachmentSet[0].device
          else
            return false

          this.set volume

    }

    new VolumeAppModel()
