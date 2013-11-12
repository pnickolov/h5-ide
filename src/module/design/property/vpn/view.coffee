#############################
#  View(UI logic) for design/property/vpn
#############################

define [ '../base/view',
         'text!./template/stack.html'
], ( PropertyView, template ) ->

    template = Handlebars.compile template

    VPNView = PropertyView.extend {
        events   :
            "REMOVE_ROW #property-vpn-ips"       : 'removeIP'

            "focus #property-vpn-ips input"      : 'onFocusCIDR'
            "keypress #property-vpn-ips input"   : 'onPressCIDR'
            "blur #property-vpn-ips input"       : 'onBlurCIDR'

        render : ()->
            @$el.html template @model.attributes

            # find empty inputbox and focus
            $inputs = $('#property-vpn-ips input')
            if $inputs.length is 1 and not $inputs.val()
                MC.aws.aws.disabledAllOperabilityArea(true)
                @forceShow()
                $inputs.focus()

            "vpn:#{@model.attributes.cgw_name}"

        removeIP : (event, ip) ->
            if not ip
                return

            ips = []
            $("#property-vpn-ips input").each ()->
                ips.push $(this).val()

            this.trigger 'VPN_IP_UPDATE', ips
            null

        onPressCIDR : ( event ) ->
            if (event.keyCode is 13)
                $(event.currentTarget).blur()
            null

        onFocusCIDR : ( event ) ->

            MC.aws.aws.disabledAllOperabilityArea(true)
            null

        onBlurCIDR : ( event ) ->

            inputElem = $(event.currentTarget)
            inputValue = inputElem.val()

            cgwUID = this.model.get('cgw_uid')

            allCidrAry = []
            repeatFlag = false
            allCidrInputElemAry = $('#property-vpn-ips input')
            _.each allCidrInputElemAry, (inputElem) ->
                cidrValue = $(inputElem).val()
                if cidrValue isnt inputValue
                    allCidrAry.push(cidrValue)
                else
                    if repeatFlag then allCidrAry.push(cidrValue)
                    if !repeatFlag then repeatFlag = true
                null

            haveError = true
            if !inputValue
                mainContent = 'CIDR block is required.'
                descContent = 'Please provide a IP ranges for this IP Prefix.'
            else if !MC.validate 'cidr', inputValue
                mainContent = inputValue + ' is not a valid form of CIDR block.'
                descContent = 'Please provide a valid IP range. For example, 10.0.0.1/24.'
            else if !MC.aws.rtb.isNotCIDRConflict(inputValue, allCidrAry)
                mainContent = inputValue + ' conflicts with other IP Prefix.'
                descContent = 'Please choose a CIDR block not conflicting with existing IP Prefix.'
            else
                haveError = false

            if haveError
                brotherElemAry = inputElem.parents('.multi-ipt-row').prev('.multi-ipt-row')
                if brotherElemAry.length isnt 0
                    MC.aws.aws.disabledAllOperabilityArea(false)
                    # return

                dialog_template = MC.template.setupCIDRConfirm {
                    remove_content : 'Remove Connection',
                    main_content : mainContent,
                    desc_content : descContent
                }
                modal dialog_template, false, () ->

                    $('.modal-close').click () ->
                        inputElem.focus()

                    $('#cidr-remove').click () ->
                        connectionObj = MC.canvas_data.layout.component.node[cgwUID].connection[0]
                        if connectionObj
                            lineUID = connectionObj.line
                            vgwUID = connectionObj.target
                            $("#svg_canvas").trigger("CANVAS_OBJECT_DELETE", {
                                'id': lineUID,
                                'type': 'line'
                            })
                        MC.aws.aws.disabledAllOperabilityArea(false)
                        modal.close()
            else
                ips = []
                $("#property-vpn-ips input").each ()->
                    value = $(this).val()
                    if value
                        ips.push value
                this.trigger 'VPN_IP_UPDATE', ips
                MC.aws.aws.disabledAllOperabilityArea(false)

            null
    }

    new VPNView()
