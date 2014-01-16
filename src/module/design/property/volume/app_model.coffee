#############################
#  View Mode for design/property/volume
#############################

define [ '../base/model', 'Design' ], ( PropertyModel, Design ) ->

    VolumeAppModel = PropertyModel.extend {

        init : ( uid )->

          me = this

          myVolumeComponent = Design.instance().component( uid )

          if myVolumeComponent
            appId = myVolumeComponent.get("appId")

          else
            appId = uid

          # appData = MC.data.resource_list[ Design.instance().region() ]
          # if uid.indexOf('_') > 0

          #       tmp = uid.split('_')

          #       realuid = tmp[0]

          #       device_name = tmp[2]

          #       lc_comp = Design.instance().component( uid )

          #       lc_block_device = MC.data.resource_list[ Design.instance().region() ][ lc_comp.get 'appId' ].BlockDeviceMappings.member

          #       $.each lc_block_device, ( i, block ) ->

          #         if block.DeviceName.indexOf(device_name) >=0

          #               volume_detail = $.extend true, {}, block

          #               volume_detail.uid = uid

          #               volume_detail.isLC = true

          #               volume_detail.name = "Volume of " + lc_comp.get 'name'

          #               me.set volume_detail

          #               return false
          # else
            #find volume in resource_list

          volume = MC.data.resource_list[Design.instance().region()][ appId ]
          if volume
            vol_data = volume.attachmentSet.item[0]
            volume.name = vol_data.device
            volume.IOPS = vol_data.iops
            volume.isLC = false

          this.set volume

    }

    new VolumeAppModel()
