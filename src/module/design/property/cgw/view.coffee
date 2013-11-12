#############################
#  View(UI logic) for design/property/cgw
#############################

define [ '../base/view', 'text!./template/stack.html', 'event', 'constant' ], ( PropertyView, template, ide_event, constant ) ->

    template = Handlebars.compile template

    CGWView = PropertyView.extend {

        events   :
            "click #property-cgw .cgw-routing input" : 'onChangeRouting'
            "change #property-cgw-bgp"  : 'onChangeBGP'
            "change #property-cgw-name" : 'onChangeName'

            "focus #property-cgw-ip"  : 'onFocusIP'
            "keypress #property-cgw-ip"  : 'onPressIP'
            "blur #property-cgw-ip"  : 'onBlurIP'

        render     : () ->
            @$el.html template @model.attributes

            # find empty inputbox and focus
            inputElem = $('#property-cgw-ip')
            inputValue = inputElem.val()
            if !inputValue
                MC.aws.aws.disabledAllOperabilityArea(true)
                $(inputElem).focus()
                @forceShow()

            @model.attributes.name

        onChangeRouting : () ->
            $( '#property-cgw-bgp-wrapper' ).toggle $('#property-routing-dynamic').is(':checked')
            @model.setBGP ""

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
                @model.setBGP $target.val()

        onChangeName : ( event ) ->
            $target = $ event.currentTarget
            id = @model.get 'uid'
            MC.validate.preventDupname $target, id, 'Customer Gateway'

            if $target.parsley 'validate'
                name = $target.val()
                @trigger "CHANGE_NAME", name
                @setTitle name

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
                dialog_template = MC.template.setupCIDRConfirm {
                    remove_content : 'Remove Customer Gateway',
                    main_content : mainContent,
                    desc_content : descContent
                }
                modal dialog_template, false, () ->

                    $('.modal-close').click () ->
                        $('#property-cgw-ip').focus()

                    $('#cidr-remove').click () ->
                        $('#svg_canvas').trigger('CANVAS_NODE_SELECTED', '')
                        ide_event.trigger ide_event.DELETE_COMPONENT, cgwUID, 'node'

                        # remove vpn connection
                        for key, value of MC.canvas_data.component
                            if value.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection
                                continue
                            if value.resource.CustomerGatewayId and MC.extractID( value.resource.CustomerGatewayId ) is cgwUID
                                delete MC.canvas_data.component[ key ]
                                break

                        MC.aws.aws.disabledAllOperabilityArea(false)
                        modal.close()
            else
                @model.setIP event.target.value

                MC.aws.aws.disabledAllOperabilityArea(false)
                # $('#property-cidr-block').blur()
    }

    new CGWView()
