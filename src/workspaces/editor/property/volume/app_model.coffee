#############################
#  View Mode for design/property/volume
#############################

define [ '../base/model', 'Design' ], ( PropertyModel, Design ) ->

    VolumeAppModel = PropertyModel.extend {

        init : ( uid )->
          myVolumeComponent = Design.instance().component( uid )

          if myVolumeComponent
            appId = myVolumeComponent.get("appId")

          else
            appId = uid

          volume = MC.data.resource_list[Design.instance().region()][ appId ]
          if volume
            if volume.attachmentSet
              volume.name = volume.attachmentSet.item[0].device
          else
            return false

          this.set volume

    }

    new VolumeAppModel()
