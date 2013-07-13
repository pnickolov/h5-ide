#############################
#  View(UI logic) for design/property/volume
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'UI.secondarypanel' ], ( ide_event ) ->

    VolumeView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-volume-tmpl' ).html()

        events   :
            'change #radio-standard' : 'standardRadioChecked'
            'change #radio-iops' : 'iopsRadioChecked'
            'change #volume-device' : 'deviceNameChanged'
            'change #volume-size-ranged' : 'sizeChanged'
            #'keyup #volume-size-ranged' : 'sizeChanged'
            'change #iops-ranged' : 'iopsChanged'
            #'keyup #iops-ranged' : 'iopsChanged'
            'click #snapshot-info-group' : 'showSnapshotDetail'

        render     : () ->
            console.log 'property:volume render'
            $( '.property-details' ).html this.template this.model.attributes

        standardRadioChecked : ( event ) ->
            $( '#iops-group' ).hide()
            this.trigger 'VOLUME_TYPE_STANDARD'

        iopsRadioChecked : ( event ) ->
            $( '#iops-group' ).show()
            this.trigger 'VOLUME_TYPE_IOPS'

        deviceNameChanged : ( event ) ->
            name = $( '#volume-device' ).val()
            if(name.length > 4)
                console.log 'Device name must be like /dev/hd[a-z], /dev/hd[a-z][1-15], /dev/sd[a-z] or /dev/sd[b-z][1-15].'

            else
                this.trigger 'DEVICE_NAME_CHANGED', name

        sizeChanged : ( event ) ->
            size = $( '#volume-size-ranged' ).val()
            if(size > 1024 || size < 1 )
                console.log 'Volume size must in the range of 1-1024 GB.'
            else
                this.trigger 'VOLUME_SIZE_CHANGED', size

        iopsChanged : ( event ) ->
            iops_size = $( '#iops-ranged' ).val()
            volume_size = $( '#volume-size-ranged' ).val()
            if(iops_size > 2000 || iops_size < 1 )
                console.log 'IOPS must be between 100 and 2000'
            if(iops_size > 10 * volume_size)
                console.log 'IOPS must be less than 10 times of volume size.'

        showSnapshotDetail : ( event ) ->
            target = $('#snapshot-info-group')
            secondarypanel.open target, MC.template.snapshotSecondaryPanel target.data('secondarypanel-data')
            $(document.body).on 'click', '.back', secondarypanel.close
    }

    view = new VolumeView()

    return view