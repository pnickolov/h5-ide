#############################
#  View Mode for design/property/volume
#############################

define [ 'backbone', 'MC' ], () ->

    VolumeAppModel = Backbone.Model.extend {

        ###
        defaults :

        ###

        init : ( volume_uid )->

          me = this

          myVolumeComponent = MC.canvas_data.component[ volume_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          if volume_uid.indexOf('_') > 0

                tmp = volume_uid.split('_')

                realuid = tmp[0]

                device_name = tmp[2]

                lc_comp = MC.canvas_data.component[realuid]

                lc_block_device = MC.data.resource_list[MC.canvas_data.region][lc_comp.resource.LaunchConfigurationARN].BlockDeviceMappings.member

                $.each lc_block_device, ( i, block ) ->

                  if block.DeviceName.indexOf(device_name) >=0

                        volume_detail = $.extend true, {}, block

                        volume_detail.uid = volume_uid

                        volume_detail.isLC = true

                        volume_detail.name = "Volume of " + lc_comp.name

                        me.set volume_detail

                        return false
          else

            volume = $.extend true, {}, appData[ myVolumeComponent.resource.VolumeId ]
            volume.name = myVolumeComponent.name
            volume.IOPS = myVolumeComponent.resource.Iops
            volume.isLC = false
            if volume.status == "in-use"
              volume.isInUse = true

          this.set volume

    }

    new VolumeAppModel()
