#############################
#  View Mode for design/property/volume
#############################

define [ '../base/model' ], ( PropertyModel ) ->

    VolumeAppModel = PropertyModel.extend {

        init : ( volume_uid )->

          me = this

          myVolumeComponent = MC.canvas_data.component[ volume_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          if volume_uid.indexOf('_') > 0

                tmp = volume_uid.split('_')

                realuid = tmp[0]

                device_name = tmp[2]

                lc_comp = MC.canvas_data.component[realuid]

                if ! MC.data.resource_list[MC.canvas_data.region][lc_comp.resource.LaunchConfigurationARN]
                  console.warn "not found lc data in resource_list"
                  return null

                lc_block_device = MC.data.resource_list[MC.canvas_data.region][lc_comp.resource.LaunchConfigurationARN].BlockDeviceMappings.member

                $.each lc_block_device, ( i, block ) ->

                  if block.DeviceName.indexOf(device_name) >=0

                        volume_detail = $.extend true, {}, block

                        volume_detail.uid = volume_uid

                        volume_detail.isLC = true

                        volume_detail.name = "Volume of " + lc_comp.name

                        #append for volume of lc
                        volume_detail.size       = block.Ebs.VolumeSize
                        volume_detail.volumeType = block.Ebs.VolumeType
                        volume_detail.IOPS       = block.Ebs.Iops
                        volume_detail.snapshotId = block.Ebs.SnapshotId

                        me.set volume_detail

                        return false
          else if volume_uid.indexOf("vol-") is 0
            #volume in asg
            if appData[ volume_uid ]
              volume = $.extend true, {}, appData[ volume_uid ]
              volume.name = volume.attachmentSet.item[0].device
              volume.IOPS = volume.iops
              volume.isLC = false
          else
            #volume in instance
            volume = $.extend true, {}, appData[ myVolumeComponent.resource.VolumeId ]
            volume.name = myVolumeComponent.name
            volume.IOPS = myVolumeComponent.resource.Iops
            volume.isLC = false

          this.set volume

    }

    new VolumeAppModel()
