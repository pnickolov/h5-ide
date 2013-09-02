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
            target = $ event.currentTarget
            name = target.val()
            devicePrefix = target.prev( 'label' ).text()
            type = if devicePrefix is '/dev/' then 'linux' else 'windows'
            id = @model.get( 'volume_detail' ).uid
            instanceId = MC.canvas_data.component[ id ].resource.AttachmentSet.InstanceId

            target.parsley 'custom', ( val ) ->
                if not MC.validate.deviceName val, type, true
                    if type is 'linux'
                        return "Device name must be like /dev/hd[a-z], /dev/hd[a-z][1-15],/dev/sd[a-z] or /dev/sd[b-z][1-15]"
                    else
                        return "Device name must be like xvd[a-p]."

                isDuplicate = _.some MC.canvas_data.component, ( component ) ->
                    if component.uid isnt id and component.type is 'AWS.EC2.EBS.Volume' and component.resource.AttachmentSet.InstanceId is instanceId and component.name is val
                        true
                if isDuplicate
                    "Volume name '#{val}' is already in using. Please use another one."

            if target.parsley 'validate'
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
            else if(iops_size > 10 * volume_size)
                console.log 'IOPS must be less than 10 times of volume size.'
            else
                this.trigger 'IOPS_CHANGED', iops_size

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
