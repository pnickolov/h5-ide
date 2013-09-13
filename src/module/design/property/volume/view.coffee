#############################
#  View(UI logic) for design/property/volume
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    VolumeView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-volume-tmpl' ).html()

        events   :
            'click #volume-type-radios input' : 'volumeTypeChecked'
            'change #volume-device' : 'deviceNameChanged'
            'change #volume-size-ranged' : 'sizeChanged'
            #'keyup #volume-size-ranged' : 'sizeChanged'
            'change #iops-ranged' : 'iopsChanged'
            #'keyup #iops-ranged' : 'iopsChanged'
            'click #snapshot-info-group' : 'showSnapshotDetail'

        render     : () ->
            console.log 'property:volume render'
            #
            this.undelegateEvents()
            #
            $( '.property-details' ).html this.template this.model.attributes
            #
            this.delegateEvents this.events

        volumeTypeChecked : ( event ) ->
            if($('#volume-type-radios input:checked').val() is 'radio-standard')
                $( '#iops-group' ).hide()
                this.trigger 'VOLUME_TYPE_STANDARD'
            else
                $( '#iops-group' ).show()
                this.trigger 'VOLUME_TYPE_IOPS', $( '#iops-ranged' ).val()

        deviceNameChanged : ( event ) ->
            target       = $ event.currentTarget
            name         = target.val()
            devicePrefix = target.prev( 'label' ).text()
            type         = if devicePrefix is '/dev/' then 'linux' else 'windows'

            self = this

            target.parsley 'custom', ( val ) ->
                if not MC.validate.deviceName val, type, true
                    if type is 'linux'
                        return "Device name must be like /dev/hd[a-z], /dev/hd[a-z][1-15],/dev/sd[a-z] or /dev/sd[b-z][1-15]"
                    else
                        return "Device name must be like xvd[a-p]."

                if self.model.isDuplicate val
                    "Volume name '#{val}' is already in using. Please use another one."

            if target.parsley 'validate'
                this.trigger 'DEVICE_NAME_CHANGED', name

        sizeChanged : ( event ) ->
            size = parseInt $( '#volume-size-ranged' ).val(), 10
            if(not size || size > 1024 || size < 1 )
                $( event.currentTarget ).parsley('custom', ( val ) ->
                    return "Volume size must in the range of 1-1024 GB."
                ).parsley('validate')
            else
                this.trigger 'VOLUME_SIZE_CHANGED', size

            null

        iopsChanged : ( event ) ->
            target = $ event.currentTarget

            iops_size = parseInt( target.val(), 10 )
            volume_size = parseInt( $( '#volume-size-ranged' ).val(), 10 )

            target.parsley 'custom', ( val ) ->
                volume_size = parseInt( $( '#volume-size-ranged' ).val(), 10 )
                if( val > 4000 || val < 100 )
                    return 'IOPS must be between 100 and 4000'
                else if( val > 10 * volume_size)
                    return 'IOPS must be less than 10 times of volume size.'

            if target.parsley 'validate'
                this.trigger 'IOPS_CHANGED', "" + iops_size

        showSnapshotDetail : ( event ) ->
            console.log 'showSnapshotDetail'

            target = $('#snapshot-info-group')
            ide_event.trigger ide_event.PROPERTY_OPEN_SUBPANEL, {
                title : $( event.target ).text()
                dom   : MC.template.snapshotSecondaryPanel target.data( 'secondarypanel-data' )
                id    : 'Snapshot'
            }
            null
    }

    view = new VolumeView()

    return view
