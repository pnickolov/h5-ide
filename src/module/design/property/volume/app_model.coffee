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
                        volume_detail.volumeType = if block.Ebs.VolumeType then block.Ebs.VolumeType else '-'
                        volume_detail.IOPS       = if block.Ebs.Iops       then block.Ebs.Iops       else '-'
                        volume_detail.snapshotId = if block.Ebs.SnapshotId then block.Ebs.SnapshotId else '-'

                        me.set volume_detail

                        return false
          else

            volume = $.extend true, {}, appData[ myVolumeComponent.resource.VolumeId ]
            volume.name = myVolumeComponent.name
            volume.IOPS = myVolumeComponent.resource.Iops
            volume.isLC = false

          this.set volume

    }

    new VolumeAppModel()
