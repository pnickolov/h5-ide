#############################
#  View(UI logic) for design/property/elb
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'event'
], ( PropertyView, template, ide_event ) ->

    Helper =
        makeInRange: ( value, range , $target, deflt ) ->
            begin = range[ 0 ]
            end = range[ 1 ]

            if isFinite value
                value = + value
                if value < begin
                    value = begin
                else if value > end
                    value = end
            else
                value = deflt

            $target.val( value )
            value

    template = Handlebars.compile template

    ElbView = PropertyView.extend {

        events   :
            'change #property-elb-name' : 'elbNameChange'
            'change #elb-scheme-select1' : "schemeSelectChange"
            'change #elb-scheme-select2' : "schemeSelectChange"

            'OPTION_CHANGE #elb-property-health-protocol-select' : "healthProtocolSelect"
            'change #property-elb-health-port' : 'healthPortChanged'
            'change #property-elb-health-path' : 'healthPathChanged'
            'change #property-elb-health-interval' : 'healthIntervalChanged'
            'change #property-elb-health-timeout' : 'healthTimeoutChanged'

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


            'mousedown .slider .thumb' : "sliderMouseDown"
            'mousedown .slider li'     : "sliderSelect"
            'SLIDER_CHANGE .slider'    : 'sliderChanged'

        render     : () ->

            @$el.html template @model.attributes

            health_detail = @model.get('health_detail')

            @updateSlider( $('#elb-property-slider-unhealthy'), health_detail.unhealthy_threshold - 2)
            @updateSlider( $('#elb-property-slider-healthy'), health_detail.healthy_threshold - 2)

            #Init Listener List

            listenerAry = @model.get('listener_detail').listenerAry

            Canremove = false
            _.each listenerAry, (obj) ->
                listener = obj.Listener
                listener.Canremove = Canremove
                itemTpl = MC.template.elbPropertyListenerItem(listener)
                $('#accordion-group-elb-property-listener').append itemTpl
                if !Canremove then Canremove = true
                null

            @model.attributes.component.name

        elbNameChange : ( event ) ->
            console.log 'elbNameChange'
            $target = $ event.currentTarget
            value = $target.val()
            cid = $( '#elb-property-detail' ).attr 'component'

            MC.validate.preventDupname $target, cid, value, 'Load Balancer'

            if not $target.parsley('validate')
                return

            @trigger 'ELB_NAME_CHANGED', value
            @setTitle value
            MC.canvas.update cid, 'text', 'elb_name', value
            @trigger 'REFRESH_SG_LIST'

        schemeSelectChange : ( event ) ->
            console.log 'schemeSelectChange'
            value = event.target.value
            cid = $( '#elb-property-detail' ).attr 'component'

            this.trigger 'SCHEME_SELECT_CHANGED', value

            ide_event.trigger ide_event.REDRAW_SG_LINE

            return false

        healthProtocolSelect : ( event, value ) ->
            if _.contains [ 'TCP', 'SSL'], value
                @$el.find('#property-elb-health-path').attr 'disabled', 'disabled'
            else
                @$el.find('#property-elb-health-path').removeAttr 'disabled'

            @trigger 'HEALTH_PROTOCOL_SELECTED', value

        healthPortChanged : ( event ) ->
            $target = $ event.currentTarget
            value = $target.val()
            value = Helper.makeInRange value, [1, 65535], $target, 1

            @trigger 'HEALTH_PORT_CHANGED', value

        healthPathChanged : ( event ) ->
            console.log 'healthPathChanged'
            $target = $ event.currentTarget

            if $target.parsley 'validate'
                @trigger 'HEALTH_PATH_CHANGED', $target.val()

        healthIntervalChanged : ( event ) ->
            $target = $ event.currentTarget
            value = $target.val()
            value = Helper.makeInRange value, [6, 300], $target, 30

            this.trigger 'HEALTH_INTERVAL_CHANGED', value

        healthTimeoutChanged : ( event ) ->
            $target = $ event.currentTarget
            value = $target.val()
            value = Helper.makeInRange value, [2, 60 ], $target, 5

            this.trigger 'HEALTH_TIMEOUT_CHANGED', value

        sliderChanged : ( event, value ) ->
            target = $(event.target)
            id     = event.target.id
            value += 2

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


                elbPort = that.find('.elb-property-listener-elb-port-input')
                instancePort = that.find('.elb-property-listener-instance-port-input')

                elbPort.parsley 'custom', ( val ) ->
                    val = + val
                    allowPorts = [ 25, 80, 443]
                    if not ( (_.contains allowPorts, val) or 1024 <= val <= 65535 )
                        return 'Load Balancer Port must be either 25,80,443 or 1024 to 65535 inclusive'

                instancePort.parsley 'custom', ( val ) ->
                    val = + val
                    if val < 1 or val > 65535
                        return 'Instance Port must be between 1 and 65535'
                    isThisSafe = _.contains [ 'https', 'ssl' ], instanceProtocolValue.toLowerCase()
                    i = 0
                    for listener in listenerAry
                        listener = listener.Listener
                        samePort = listener.InstancePort is instancePortValue
                        isLisenerSafe = _.contains [ 'https', 'ssl' ], listener.InstanceProtocol.toLowerCase()
                        if samePort and isLisenerSafe isnt isThisSafe and index > i
                            if not isLisenerSafe
                                prefix = 'in'
                            return "The Instance Port specified was previous associated with #{prefix}secure protocol so this listener must also use a #{prefix}secure protocol for this Instance Port"

                        i = i + 1

                elbPortValidate = elbPort.parsley 'validate'
                instancePortValidate = instancePort.parsley 'validate'

                if elbPortValidate and instancePortValidate and !isNaN(parseInt(elbPortValue, 10)) and !isNaN(parseInt(instancePortValue, 10))

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


        updateSlider : ( $target, value ) ->
            step  = $target.children(".marker").children().length - 1
            width = $target.width()
            left  = value * Math.floor( width / step )
            $target.data("value", value).children(".thumb").css("left", left)
            null

        sliderSelect : ( event ) ->
            $target = $( event.currentTarget )
            $slider = $target.closest(".slider")
            value   = $target.index()
            @updateSlider( $slider, value )

            $slider.trigger "SLIDER_CHANGE", value
            null

        sliderMouseDown : ( event ) ->
            $body      = $("body")
            $thumb     = $( event.currentTarget )
            $slider    = $thumb.closest(".slider")
            step       = $slider.children(".marker").children().length - 1
            width      = $slider.width()
            stepWidth  = Math.floor( width / step )
            originalX  = event.clientX
            thumbPos   = $thumb.position().left
            value      = $slider.data("value")
            offsetStep = 0

            onMouseMove = ( event )->

                offset        = event.clientX - originalX
                absOffset     = Math.abs( offset )
                halfStepWidth = stepWidth / 2

                if absOffset >= halfStepWidth
                    absOffset += halfStepWidth
                    delta      = if offset > 0 then 1 else -1

                    offsetStep = Math.floor( absOffset / stepWidth ) * delta
                    newPos     = thumbPos + offsetStep * stepWidth

                    if newPos < 0
                        newPos = 0
                    else if newPos > width
                        newPos = width
                else
                    newPos     = thumbPos
                    offsetStep = 0

                $thumb.css("left", newPos)
                false

            onMouseUp = ()->
                $body.off "mousemove", onMouseMove
                value = value + offsetStep
                $slider.data("value", value).trigger("SLIDER_CHANGE", value)

            $body.on "mousemove", onMouseMove
            $body.one "mouseup", onMouseUp

            false

    }

    new ElbView()
