#############################
#  View Mode for design/property/volume
#############################

define [ 'backbone', 'MC' ], () ->

    VolumeAppModel = Backbone.Model.extend {

        ###
        defaults :

        ###

        init : ( volume_uid )->

          myVolumeComponent = MC.canvas_data.component[ volume_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          volume = $.extend true, {}, appData[ myVolumeComponent.resource.VolumeId ]
          volume.name = myVolumeComponent.name
          volume.IOPS = myVolumeComponent.resource.Iops

          if volume.status == "in-use"
            volume.isInUse = true

          this.set volume

    }

    new VolumeAppModel()
