#############################
#  View Mode for design/property/volume
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    VolumeModel = Backbone.Model.extend {

        defaults :
            'volume_detail'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getVolume : ( uid ) ->

            me = this

            volume_detail = MC.canvas_data.component[uid]

            volume_detail.isStandard = true if volume_detail.resource.VolumeType == 'standard'

            volume_detail.editName = volume_detail.name.slice(5)

            me.set 'volume_detail', volume_detail

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

            null

        setVolumeTypeIops : ( uid ) ->

            MC.canvas_data.component[uid].resource.VolumeType = 'iops'

            null

        setVolumeIops : ( uid, value )->

            MC.canvas_data.component[uid].resource.Iops = value

            null

    }

    model = new VolumeModel()

    return model