#############################
#  View(UI logic) for design/property/cgw
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

   CGWView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-cgw-tmpl' ).html()

        events   :
            "click #property-cgw .cgw-routing input" : 'onChangeRouting'
            "change #property-cgw-bgp"  : 'onChangeBGP'
            "change #property-cgw-name" : 'onChangeName'
            # "change #property-cgw-ip"   : 'onChangeIP'

            "focus #property-cgw-ip"  : 'onFocusIP'
            "keypress #property-cgw-ip"  : 'onPressIP'
            "blur #property-cgw-ip"  : 'onBlurIP'

        render     : () ->
            console.log 'property:cgw render'
            $( '.property-details' ).html this.template this.model.attributes

            # find empty inputbox and focus
            inputElem = $('#property-cgw-ip')
            inputValue = inputElem.val()
            if !inputValue
                MC.aws.aws.disabledAllOperabilityArea(true)
                $(inputElem).focus()
                ide_event.trigger ide_event.SHOW_PROPERTY_PANEL

        onChangeRouting : () ->
            $( '#property-cgw-bgp-wrapper' ).toggle $('#property-routing-dynamic').is(':checked')

            change.value = ""
            change.event = "CHANGE_BGP"
            this.trigger "CHANGE_BGP", change

        onChangeBGP : ( event ) ->

            change.handled = false
            change.value   = event.target.value
            change.event   = "CHANGE_BGP"

            this.trigger "CHANGE_BGP", change

        onChangeName : ( event ) ->

            change.value = event.target.value
            change.event = "CHANGE_NAME"

            this.trigger "CHANGE_NAME", change

        onChangeIP   : ( event ) ->

            # TODO : Validate IP
            change.value = event.target.value
            change.event = "CHANGE_IP"

            this.trigger "CHANGE_IP", change

        setBGP : ( bgp ) ->
            dynamic = false
            if bgp
                $( '#property-cgw-bgp' ).val bgp
                dynamic = true

            $( '#property-routing-dynamic' ).prop "checked", dynamic
            $( '#property-routing-static' ).prop  "checked", !dynamic
            $( '#property-cgw-bgp-wrapper').toggle dynamic

        onPressIP : ( event ) ->
            if (event.keyCode is 13)
                $('#property-cgw-ip').blur()

        onFocusIP : ( event ) ->
            MC.aws.aws.disabledAllOperabilityArea(true)
            null

        onBlurIP : ( event ) ->

            that = this

            mainContent = ''
            descContent = ''

            cgwUID = this.model.get 'uid'
            ipAddr = $('#property-cgw-ip').val()

            haveError = true
            if !ipAddr
                mainContent = 'IP Address is required.'
                descContent = 'Please provide a IP Address of this Customer Gateway.'
            else if !MC.validate 'ipv4', ipAddr
                mainContent = ipAddr + ' is not a valid IP Address.'
                descContent = 'Please provide a valid IP Address. For example, 192.168.1.1.'
            else
                haveError = false

            if haveError
                template = MC.template.setupCIDRConfirm {
                    remove_content : 'Remove Customer Gateway',
                    main_content : mainContent,
                    desc_content : descContent
                }
                modal template, false, () ->

                    $('.modal-close').click () ->
                        $('#property-cgw-ip').focus()

                    $('#cidr-remove').click () ->
                        $('#svg_canvas').trigger('CANVAS_NODE_SELECTED', '')
                        ide_event.trigger ide_event.DELETE_COMPONENT, cgwUID, 'node'
                        MC.aws.aws.disabledAllOperabilityArea(false)
                        modal.close()
            else
                change.value = event.target.value
                change.event = "CHANGE_IP"

                this.trigger "CHANGE_IP", change

                MC.aws.aws.disabledAllOperabilityArea(false)
                # $('#property-cidr-block').blur()
    }

    view = new CGWView()

    eventTgtMap =
        "CHANGE_BGP"  : "#property-cgw-bgp"
        "CHANGE_NAME" : "#property-cgw-name"
        "CHANGE_IP"   : "#property-cgw-ip"

    change =
        value   : ""
        event   : ""
        handled : true
        done    : ( error ) ->
            if this.handled
                return

            if error
                # TODO : show error on the input

                # Restore last value
                $ipt = $( eventTgtMap[ this.event ] )
                $ipt.val( $ipt.attr "lastValue" )
            else
                $( eventTgtMap[ this.event ] ).attr "lastValue", this.value

            this.handled = true
            null

    return view
