#############################
#  View Mode for design/property/volume
#############################

define [ '../base/model', 'Design', 'CloudResources', 'constant' ], ( PropertyModel, Design, CloudResources, constant ) ->

    VolumeAppModel = PropertyModel.extend {

        init : ( uid )->
          myVolumeComponent = Design.instance().component( uid )

          if myVolumeComponent
            appId = myVolumeComponent.get("appId")

          else
            appId = uid

          volume = CloudResources(constant.RESTYPE.VOL, Design.instance().region()).get(appId)
          if volume
            if volume.attachmentSet
              volume.name = volume.attachmentSet.item[0].device
          else
            return false

          this.set volume

    }

    new VolumeAppModel()
