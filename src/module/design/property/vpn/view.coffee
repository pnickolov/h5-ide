#############################
#  View(UI logic) for design/property/vpn
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'UI.notification', 'UI.multiinputbox' ], ( ide_event ) ->

   VPNView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-vpn-tmpl' ).html()

        events   :
            "change #property-vpn-ips input"    : 'addIP'
            "REMOVE_ROW #property-vpn-ips"      : 'removeIP'

            "focus #property-vpn-ips input"      : 'onFocusCIDR'
            "keypress #property-vpn-ips input"   : 'onPressCIDR'
            "blur #property-vpn-ips input"       : 'onBlurCIDR'

        render     : () ->
            console.log 'property:vpn render'

            $( '.property-details' ).html this.template this.model.attributes

            # find empty inputbox and focus
            inputElemAry = $('#property-vpn-ips input')
            _.each inputElemAry, (inputElem) ->
                inputValue = $(inputElem).val()
                if !inputValue
                    MC.aws.aws.disabledAllOperabilityArea(true)
                    ide_event.trigger ide_event.SHOW_PROPERTY_PANEL
                    $(inputElem).focus()

        addIP : (event) ->
            # ips = []
            # $("#property-vpn-ips input").each ()->
            #     ips.push $(this).val()

            # this.trigger 'VPN_IP_UPDATE', ips
            null

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
                    return

                template = MC.template.setupCIDRConfirm {
                    remove_content : 'Remove Connection',
                    main_content : mainContent,
                    desc_content : descContent
                }
                modal template, false, () ->

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

    view = new VPNView()

    return view
