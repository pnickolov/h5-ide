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

            volume_detail = $.extend true, {}, MC.canvas_data.component[uid]

            volume_detail.isStandard = true if volume_detail.resource.VolumeType == 'standard'

            volume_detail.editName = volume_detail.name.slice(5)

            me.set 'volume_detail', volume_detail

            if volume_detail.resource.SnapshotId

                ebs_model.DescribeSnapshots { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), volume_detail.resource.AvailabilityZone.slice(0,-1), [volume_detail.resource.SnapshotId]

                ebs_model.once 'EC2_EBS_DESC_SSS_RETURN', ( result ) ->

                    if $.isEmptyObject result.resolved_data.item.description

                        result.resolved_data.item.description = 'None'

                    if not result.resolved_data.item.volumeId

                        result.resolved_data.item.volumeId = 'None'

                    volume_detail.snapshot = JSON.stringify result.resolved_data.item

                    me.set 'volume_detail', volume_detail

                    me.trigger "REFRESH_PANEL"

        setDeviceName : ( uid, name ) ->

            me = this

            device_name = '/dev/' + name

            MC.canvas_data.component[uid].name = device_name

            MC.canvas_data.component[uid].resource.AttachmentSet.Device = '/dev/' + name

            null

        setVolumeSize : ( uid, value ) ->

            me = this

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