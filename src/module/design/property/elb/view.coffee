#############################
#  View(UI logic) for design/property/elb
#############################

define ['event', 'MC',
        'backbone', 'jquery', 'handlebars',
        'UI.secondarypanel',
        'UI.selectbox',
        'UI.tooltip',
        'UI.notification',
        'UI.toggleicon',
        'UI.slider'], ( ide_event, MC ) ->

    ElbView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-elb-tmpl' ).html()

        ###
        initialize : ->
            #handlebars equal logic
            Handlebars.registerHelper 'ifCond', (v1, v2, options) ->
                if v1 is v2
                    return options.fn this
                options.inverse this

            null
        ###

        events   :
            'change #property-elb-name' : 'elbNameChange'
            'change #elb-scheme-select1' : "schemeSelectChange"
            'change #elb-scheme-select2' : "schemeSelectChange"

            'OPTION_CHANGE #elb-property-health-protocol-select' : "healthProtocolSelect"
            'change #property-elb-health-port' : 'healthPortChanged'
            'change #property-elb-health-path' : 'healthPathChanged'
            'change #property-elb-health-interval' : 'healthIntervalChanged'
            'change #property-elb-health-timeout' : 'healthTimeoutChanged'
            'SLIDER_CHANGE .slider' : 'sliderChanged'

            'click #elb-property-listener-content-add' : 'listenerItemAddClicked'
            'OPTION_CHANGE .elb-property-listener-elb-protocol-select' : 'listenerItemChanged'
            'OPTION_CHANGE .elb-property-listener-instance-protocol-select' : 'listenerItemChanged'
            'change .elb-property-listener-elb-port-input' : 'listenerItemChanged'
            'change .elb-property-listener-instance-port-input' : 'listenerItemChanged'
            'click .elb-property-listener-item-remove' : 'listenerItemRemovedClicked'

            'change #elb-property-cert-name-input' : 'listenerCertChanged'
            'change #elb-property-cert-privatekey-input' : 'listenerCertChanged'
            'change #elb-property-cert-publickey-input' : 'listenerCertChanged'
            'change #elb-property-cert-chain-input' : 'listenerCertChanged'

            'change .property-elb-az-checkbox' : 'azCheckChanged'

        render     : ( attributes ) ->

            console.log 'property:elb render'
            $( '.property-details' ).html this.template(attributes)

            health_detail = this.model.get('health_detail')
            $('#elb-property-slider-unhealthy').setSliderValue(health_detail.unhealthy_threshold)
            $('#elb-property-slider-healthy').setSliderValue(health_detail.healthy_threshold)

            #Init Listener List

            listenerDetail = this.model.get 'listener_detail'
            listenerAry = listenerDetail.listenerAry

            Canremove = false
            _.each listenerAry, (obj) ->
                listener = obj.Listener
                listener.Canremove = Canremove
                itemTpl = MC.template.elbPropertyListenerItem(listener)
                $('#accordion-group-elb-property-listener').append itemTpl
                if !Canremove then Canremove = true
                null

            this.trigger 'REFRESH_CERT_PANEL_DATA'

        elbNameChange : ( event ) ->

            console.log 'elbNameChange'
            value = event.target.value

            # # required validate
            # if not MC.validate 'required', value
            #     return

            # # repeat name check
            # cid = $( '#elb-property-detail' ).attr 'component'
            # if MC.aws.aws.checkIsRepeatName(cid, value)
            #     $('#property-elb-name').parsley('showError', 'Load Balancer name already in use, please choose another.')
            #     return

            # $('#property-elb-name').parsley('hideError')

            cid = $( '#elb-property-detail' ).attr 'component'

            target = $ event.currentTarget
            MC.validate.preventDupname target, cid, value, 'Load Balancer'

            if !target.parsley('validate') then return

            this.trigger 'ELB_NAME_CHANGED', value

            MC.canvas.update cid, 'text', 'elb_name', value

            this.trigger 'REFRESH_SG_LIST'

        schemeSelectChange : ( event ) ->
            console.log 'schemeSelectChange'
            value = event.target.value
            cid = $( '#elb-property-detail' ).attr 'component'
            this.trigger 'SCHEME_SELECT_CHANGED', value

            if value is 'internal'
                MC.canvas.update cid, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNAL_CANVAS
                MC.canvas.display(cid, 'port-elb-sg-in', true)
            else
                MC.canvas.update cid, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNET_CANVAS
                MC.canvas.display(cid, 'port-elb-sg-in', false)

            ide_event.trigger ide_event.REDRAW_SG_LINE

        healthProtocolSelect : ( evnet, value ) ->
            console.log 'healthProtocolSelect'
            this.trigger 'HEALTH_PROTOCOL_SELECTED', value

        healthPortChanged : ( evnet ) ->
            console.log 'healthPortChanged'
            value = event.target.value
            this.trigger 'HEALTH_PORT_CHANGED', value

        healthPathChanged : ( evnet ) ->
            console.log 'healthPathChanged'
            value = event.target.value
            this.trigger 'HEALTH_PATH_CHANGED', value

        healthIntervalChanged : ( evnet ) ->
            console.log 'healthIntervalChanged'
            value = event.target.value
            this.trigger 'HEALTH_INTERVAL_CHANGED', value

        healthTimeoutChanged : ( evnet ) ->
            console.log 'healthTimeoutChanged'
            value = event.target.value
            this.trigger 'HEALTH_TIMEOUT_CHANGED', value

        sliderChanged : ( event ) ->
            target = $(event.target)
            id = event.target.id
            value = target.data('value')

            if id is 'elb-property-slider-unhealthy'
                this.trigger 'UNHEALTHY_SLIDER_CHANGE', value
            else
                this.trigger 'HEALTHY_SLIDER_CHANGE', value

        listenerItemAddClicked : ( event ) ->
            itemTpl = MC.template.elbPropertyListenerItem({
                "LoadBalancerPort": "",
                "InstanceProtocol": "HTTP",
                "Protocol": "HTTP",
                "SSLCertificateId": "",
                "InstancePort":"",
                "Canremove":true
            })
            $('#accordion-group-elb-property-listener').append itemTpl
            null

        # listenerElbProtocolSelected : ( event ) ->

        # listenerElbPortChanged : ( event ) ->

        # listenerInstanceProtocolSelected : ( event ) ->

        # listenerInstancePortChanged : ( event ) ->

        listenerItemChanged : ( event ) ->

            # auto change port accord protocol
            # auto change protocol accord layers
            if event
                thatElem = $(event.target)
                value = thatElem.find('.selection').text()
                if value
                    portElem = null
                    otherProtocolElem = null
                    parentItemElem = thatElem.parents('.elb-property-listener-main')
                    if thatElem.hasClass('elb-property-listener-elb-protocol-select')
                        portElem = parentItemElem.find('.elb-property-listener-elb-port-input')
                        otherProtocolElem = parentItemElem.find('.elb-property-listener-instance-protocol-select')
                    else
                        portElem = parentItemElem.find('.elb-property-listener-instance-port-input')
                        otherProtocolElem = parentItemElem.find('.elb-property-listener-elb-protocol-select')
                    if value in ['HTTPS', 'SSL']
                        portElem.val('443')
                    else
                        portElem.val('80')

                    if value in ['TCP', 'SSL']
                        $('#property-elb-health-path').prop('disabled', true)
                    else
                        $('#property-elb-health-path').prop('disabled', false)

                    # auto change protocol accord layers
                    layerMap = {
                        'HTTP': 'application',
                        'HTTPS': 'application',
                        'TCP': 'transport',
                        'SSL': 'transport'
                    }
                    currentPtotocol = value
                    otherProtocol = otherProtocolElem.find('.selection').text()
                    if layerMap[currentPtotocol] isnt layerMap[otherProtocol]
                        # diffrent layer
                        otherProtocolElem.find('.selection').text(currentPtotocol)
                    if otherProtocolElem.hasClass('elb-property-listener-elb-protocol-select')
                        portElem = parentItemElem.find('.elb-property-listener-elb-port-input')
                    else
                        portElem = parentItemElem.find('.elb-property-listener-instance-port-input')

                    newOtherProtocol = otherProtocolElem.find('.selection').text()
                    if newOtherProtocol in ['HTTPS', 'SSL']
                        portElem.val('443')
                    else
                        portElem.val('80')

            #
            me = this

            listenerContainerElem = $('#accordion-group-elb-property-listener')
            listenerItemElem = listenerContainerElem.find('.elb-property-listener-main')

            listenerAry = []

            isShowCertPanel = false

            hasValidateError = false
            listenerItemElem.each (index, elem) ->
                that = $(this)
                elbProtocolValue = $.trim(that.find('.elb-property-listener-elb-protocol-select .selection').text())
                elbPortValue = that.find('.elb-property-listener-elb-port-input').val()
                instanceProtocolValue = $.trim(that.find('.elb-property-listener-instance-protocol-select .selection').text())
                instancePortValue = that.find('.elb-property-listener-instance-port-input').val()

                if !elbProtocolValue or !elbPortValue or !instanceProtocolValue or !instancePortValue
                    hasValidateError = true
                    return false

                if !isNaN(parseInt(elbPortValue, 10)) and !isNaN(parseInt(instancePortValue, 10))

                    newItemObj = {
                        Listener: {
                            "LoadBalancerPort": elbPortValue,
                            "InstanceProtocol": instanceProtocolValue,
                            "Protocol": elbProtocolValue,
                            "SSLCertificateId": "",
                            "InstancePort": instancePortValue
                        },
                        PolicyNames: ''
                    }

                    listenerAry.push newItemObj

                if (elbProtocolValue is 'HTTPS' or elbProtocolValue is 'SSL')
                    isShowCertPanel = true

                null

            if hasValidateError then return

            #show/hide cert panel
            certPanelElem = $('#elb-property-listener-cert-main')
            if isShowCertPanel
                certPanelElem.show()
                me.listenerCertChanged()
            else certPanelElem.hide()

            me.trigger 'LISTENER_ITEM_CHANGE', listenerAry

            null

        listenerItemRemovedClicked : ( event ) ->
            elem = $(event.target)
            elem.parent('.elb-property-listener-main').remove()
            this.listenerItemChanged()
            this.trigger 'REFRESH_SG_LIST'

        listenerCertChanged : ( event ) ->
            certNameValue = $('#elb-property-cert-name-input').val()
            certPrikeyValue = $('#elb-property-cert-privatekey-input').val()
            certPubkeyValue = $('#elb-property-cert-publickey-input').val()
            certChainValue = $('#elb-property-cert-chain-input').val()

            newCertObj = {
                name: certNameValue,
                resource: {
                    PrivateKey: certPrikeyValue,
                    CertificateBody: certPubkeyValue,
                    CertificateChain: certChainValue
                }
            }

            # if certNameValue and certPrikeyValue and certPubkeyValue
            this.trigger 'LISTENER_CERT_CHANGED', newCertObj

            null

        refreshCertPanel : ( certObj ) ->

            $('#elb-property-cert-name-input').val(certObj.name)
            $('#elb-property-cert-privatekey-input').val(certObj.resource.PrivateKey)
            $('#elb-property-cert-publickey-input').val(certObj.resource.CertificateBody)
            $('#elb-property-cert-chain-input').val(certObj.resource.CertificateChain)

            $('#elb-property-listener-cert-main').show()

            null

        azCheckChanged : ( event ) ->
            checkboxElem = $(event.target)

            azName = checkboxElem.prop('name')
            checkStat = checkboxElem.prop('checked')

            if checkStat
                this.trigger 'ADD_AZ_TO_ELB', azName
            else
                this.trigger 'REMOVE_AZ_FROM_ELB', azName

            null
    }

    view = new ElbView()

    return view
