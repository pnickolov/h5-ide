#############################
#  View(UI logic) for design/property/vpn
#############################

define [ '../base/view', './template/stack','i18n!/nls/lang.js',"UI.modalplus" ], ( PropertyView, template, lang, modalPlus ) ->

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
                    mainContent = lang.PROP.VPN_BLUR_CIDR_REQUIRED
                    descContent = lang.PROP.VPN_BLUR_CIDR_REQUIRED_DESC
            else if !MC.validate 'cidr', inputValue
                mainContent = sprintf lang.PROP.VPN_BLUR_CIDR_NOT_VALID_IP, inputValue
                descContent = lang.PROP.VPN_BLUR_CIDR_NOT_VALID_IP_DESC
            else
                for cidr in allCidrAry
                    if cidr isnt inputValue and @model.isCidrConflict( inputValue, cidr )
                        mainContent = sprintf lang.PROP.VPN_BLUR_CIDR_CONFLICTS_IP, inputValue
                        descContent = lang.PROP.VPN_BLUR_CIDR_CONFLICTS_IP_DESC
                        break

            if not mainContent
                @model.updateIps allCidrAry
                @disabledAllOperabilityArea(false)
                return

            if not @modal?.isOpen()

                dialog_template = MC.template.setupCIDRConfirm {
                    remove_content : lang.PROP.VPN_REMOVE_CONNECTION
                    main_content : mainContent
                    desc_content : descContent
                }

                that = this

                @modal = new modalPlus {
                    title: lang.IDE.VPN_REMOVE_CONNECTION
                    width: 420
                    template: dialog_template
                    confirm: text: "OK", color: "blue"
                    disableClose: true
                    cancel: hide: true
                }

                modal = @modal

                $("""<a id="cidr-removed" class="link-red left link-modal-danger">#{lang.PROP.VPN_REMOVE_CONNECTION}</a>""")
                .appendTo(modal.find(".modal-footer"))

                modal.on "confirm", ()-> modal.close()
                modal.on "close", () -> inputElem.focus()
                modal.on "closed", () -> inputElem.focus()
                modal.find("#cidr-removed").on "click", () ->
                    Design.instance().component( that.model.get("uid") ).remove()
                    that.disabledAllOperabilityArea(false)
                    modal.close()
    }

    new VPNView()
