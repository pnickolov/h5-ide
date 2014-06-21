#############################
#  View(UI logic) for design/property/vpn
#############################

define [ '../base/view', './template/stack' ], ( PropertyView, template ) ->

    VPNView = PropertyView.extend {
        events   :
            "BEFORE_REMOVE_ROW #property-vpn-ips" : 'beforeRemoveIP'
            "REMOVE_ROW #property-vpn-ips" : 'removeIP'
            "ADD_ROW #property-vpn-ips"    : 'addIP'

            "focus #property-vpn-ips input"      : 'onFocusCIDR'
            "keypress #property-vpn-ips input"   : 'onPressCIDR'
            "blur #property-vpn-ips input"       : 'onBlurCIDR'

        render : ()->
            @$el.html template @model.attributes
            @model.attributes.name

        addIP : ()->
            $("#property-vpn-ips input").last().focus()
            null

        beforeRemoveIP : ( event )->
            # If user delete the an non empty ip and it's the only one, prevent it.
            if event.value
                nonEmptyInputs = $("#property-vpn-ips").find("input").filter ()-> this.value.length > 0
                if nonEmptyInputs.length < 2
                    event.preventDefault()
            null


        removeIP : (event, ip) ->
            if not ip
                return

            ips = []
            $("#property-vpn-ips input").each ()->
                ips.push $(this).val()

            @model.updateIps ips
            null

        onPressCIDR : ( event ) ->
            if (event.keyCode is 13)
                $(event.currentTarget).blur()
            null

        onFocusCIDR : ( event ) ->
            @disabledAllOperabilityArea(true)
            null

        onBlurCIDR : ( event ) ->

            inputElem = $(event.currentTarget)
            inputValue = inputElem.val()

            ips = []
            $("#property-vpn-ips input").each ()->
                if this.value then ips.push this.value
                null

            allCidrAry = _.uniq( ips )

            if !inputValue
                if inputElem.parents('.multi-ipt-row').siblings().length == 0
                    mainContent = 'CIDR block is required.'
                    descContent = 'Please provide a IP ranges for this IP Prefix.'
            else if !MC.validate 'cidr', inputValue
                mainContent = "#{inputValue} is not a valid form of CIDR block."
                descContent = 'Please provide a valid IP range. For example, 10.0.0.1/24.'
            else
                for cidr in allCidrAry
                    if cidr isnt inputValue and @model.isCidrConflict( inputValue, cidr )
                        mainContent = "#{inputValue} conflicts with other IP Prefix."
                        descContent = 'Please choose a CIDR block not conflicting with existing IP Prefix.'
                        break

            if not mainContent
                @model.updateIps allCidrAry
                @disabledAllOperabilityArea(false)
                return

            dialog_template = MC.template.setupCIDRConfirm {
                remove_content : 'Remove Connection'
                main_content : mainContent
                desc_content : descContent
            }

            that = this
            modal dialog_template, false, () ->
                $('.modal-close').click () -> inputElem.focus()

                $('#cidr-remove').click () ->
                    $canvas.clearSelected()
                    Design.instance().component( that.model.get("uid") ).remove()

                    that.disabledAllOperabilityArea(false)
                    modal.close()
            , {
                $source: $(event.target)
            }
    }

    new VPNView()
