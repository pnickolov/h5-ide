#############################
#  View Mode for design/property/volume
#############################

define [ 'ebs_model', 'backbone', 'jquery', 'underscore', 'MC' ], ( ebs_model ) ->

    VolumeModel = Backbone.Model.extend {

        defaults :
            'volume_detail'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

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

                        me.set 'volume_detail', volume_detail

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

                me.set 'volume_detail', volume_detail

            if volume_detail.resource

                if volume_detail.resource.SnapshotId

                    ebs_model.DescribeSnapshots { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), volume_detail.resource.AvailabilityZone.slice(0,-1), [volume_detail.resource.SnapshotId]

            if volume_detail.Ebs

                if volume_detail.Ebs.SnapshotId

                    ebs_model.DescribeSnapshots { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), MC.canvas_data.region, [volume_detail.Ebs.SnapshotId]

            me.once 'EC2_EBS_DESC_SSS_RETURN', ( result ) ->

                if $.isEmptyObject result.resolved_data.item.description

                    result.resolved_data.item.description = 'None'

                if not result.resolved_data.item.volumeId

                    result.resolved_data.item.volumeId = 'None'

                volume_detail.snapshot = JSON.stringify result.resolved_data.item

                me.set 'volume_detail', volume_detail

                me.trigger "REFRESH_PANEL"

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