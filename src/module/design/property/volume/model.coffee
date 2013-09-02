#############################
#  View Mode for design/property/volume
#############################

define [ 'ebs_model', 'backbone', 'jquery', 'underscore', 'MC' ], ( ebs_model ) ->

    VolumeModel = Backbone.Model.extend {

        defaults :
            'volume_detail' : null
            'get_xxx'       : null

        initialize : ->
            #listen

        getVolume : ( uid ) ->

            me = this

            volume_detail = null

            if uid.indexOf('_') > 0

                tmp = uid.split('_')

                realuid = tmp[0]

                device_name = tmp[2]

                lc_block_device = MC.canvas_data.component[realuid].resource.BlockDeviceMapping

                $.each lc_block_device, ( i, block ) ->

                    if block.DeviceName.indexOf(device_name) >=0

                        volume_detail = $.extend true, {}, block

                        volume_detail.uid = uid

                        volume_detail.isWin = true if volume_detail.DeviceName.slice(0,1) != '/'

                        if volume_detail.isWin

                            volume_detail.editName = volume_detail.DeviceName.slice(-1)

                        else
                            volume_detail.editName = volume_detail.DeviceName.slice(5)

                        volume_detail.isLC = true

                        return false



            else
                volume_detail = $.extend true, {}, MC.canvas_data.component[uid]

                volume_detail.isLC = false

                volume_detail.isStandard = true if volume_detail.resource.VolumeType == 'standard'

                volume_detail.isWin = true if volume_detail.resource.AttachmentSet.Device.slice(0,1) != '/'

                if volume_detail.isWin

                    volume_detail.editName = volume_detail.resource.AttachmentSet.Device.slice(-1)

                else
                    volume_detail.editName = volume_detail.resource.AttachmentSet.Device.slice(5)


            snapshot_list = MC.data.config[MC.canvas.data.get('region')].snapshot_list
            if volume_detail.resource and volume_detail.resource.SnapshotId
                ssid = volume_detail.resource.SnapshotId

            else if volume_detail.Ebs and volume_detail.Ebs.SnapshotId
                ssid = volume_detail.Ebs.SnapshotId

            if ssid
                for item in snapshot_list.item
                    if item.snapshotId is ssid
                        volume_detail.snapshot = JSON.stringify item
                        break

            me.set 'volume_detail', volume_detail
            null

        setDeviceName : ( uid, name ) ->

            me = this

            if uid.indexOf('_') >0

                tmp = uid.split('_')

                realuid = tmp[0]

                device_name = tmp[2]

                lc_block_device = MC.canvas_data.component[realuid].resource.BlockDeviceMapping

                $.each lc_block_device, ( i, block ) ->

                    if block.DeviceName.slice(0,1) != '/' and block.DeviceName.indexOf(device_name)>=0

                        block.DeviceName = 'xvd' + name

                        MC.canvas.update(realuid,'id','volume_' + device_name, realuid + '_volume_' + 'xvd' + name)

                        $("#property-panel-volume").attr 'uid', realuid + '_volume_' + 'xvd' + name

                        MC.canvas.update(realuid,'text','volume_' + block.DeviceName, block.DeviceName)

                    else if block.DeviceName.slice(0,1) == '/' and block.DeviceName.indexOf(device_name)>=0

                        block.DeviceName = '/dev/' + name

                        MC.canvas.update(realuid,'id','volume_' + device_name, realuid + '_volume_' + name)

                        $("#property-panel-volume").attr 'uid', realuid + '_volume_' + name

                        MC.canvas.update(realuid,'text','volume_' + name, block.DeviceName)

                    null



            else

                if MC.canvas_data.component[uid].resource.AttachmentSet.Device.slice(0,1) != '/'

                    device_name = 'xvd' + name

                    MC.canvas_data.component[uid].name = device_name

                else
                    device_name = '/dev/' + name

                    MC.canvas_data.component[uid].name = name


                MC.canvas_data.component[uid].resource.AttachmentSet.Device = device_name

            null

        setVolumeSize : ( uid, value ) ->

            me = this

            if uid.indexOf('_') >0

                tmp = uid.split('_')

                realuid = tmp[0]

                device_name = tmp[2]

                lc_block_device = MC.canvas_data.component[realuid].resource.BlockDeviceMapping

                $.each lc_block_device, ( i, block ) ->

                    if block.DeviceName.slice(0,1) != '/' and block.DeviceName.indexOf('xvd'+device_name)>=0

                        block.Ebs.VolumeSize = value

                    else if block.DeviceName.slice(0,1) == '/' and block.DeviceName.indexOf(device_name)>=0

                        block.Ebs.VolumeSize = value

                    null

            else

                MC.canvas_data.component[uid].resource.Size = value

            null

        setVolumeTypeStandard : ( uid ) ->

            MC.canvas_data.component[uid].resource.VolumeType = 'standard'

            MC.canvas_data.component[uid].resource.Iops = ''

            null

        setVolumeTypeIops : ( uid, value ) ->

            MC.canvas_data.component[uid].resource.VolumeType = 'iops'

            MC.canvas_data.component[uid].resource.Iops = value

            null

        setVolumeIops : ( uid, value )->

            MC.canvas_data.component[uid].resource.Iops = value

            null

    }

    model = new VolumeModel()

    return model
