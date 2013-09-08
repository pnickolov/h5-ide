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
            this.trigger "CHANGE_BGP", ""

        onChangeBGP : ( event ) ->
            $target = $ event.currentTarget
            region = MC.canvas_data.region
            $target.parsley 'custom', ( val ) ->
                val = + val
                if val < 1 or val > 65534
                    return 'Must be between 1 and 65534'
                if val is 7224 and region is 'us-east-1'
                    return 'ASN number 7224 is reserved in Virginia'
                if val is 9059 and region is 'eu-west-1'
                    return 'ASN number 9059 is reserved in Ireland'

            if $target.parsley 'validate'
                this.trigger "CHANGE_BGP", $target.val()

        onChangeName : ( event ) ->
            $target = $ event.currentTarget
            id = @model.get 'uid'
            MC.validate.preventDupname $target, id, 'Customer Gateway'

            if $target.parsley 'validate'
                @trigger "CHANGE_NAME", $target.val()

        onChangeIP   : ( event ) ->
            this.trigger "CHANGE_IP", event.currentTarget.value

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
                this.trigger "CHANGE_IP", event.target.value

                MC.aws.aws.disabledAllOperabilityArea(false)
                # $('#property-cidr-block').blur()
    }

    view = new CGWView()

    return view
