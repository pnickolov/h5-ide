#############################
#  View(UI logic) for design/property/elb
#############################

define [ '../base/view',
         './template/stack',
         'event',
         'i18n!nls/lang.js',
         'sslcert_dropdown'
], ( PropertyView, template, ide_event, lang, sslCertDropdown ) ->

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

    ElbView = PropertyView.extend {

        events   :
            'change #property-elb-name'  : 'elbNameChange'
            'change #elb-scheme-select1' : "schemeSelectChange"
            'change #elb-scheme-select2' : "schemeSelectChange"

            'OPTION_CHANGE #elb-property-health-protocol-select' : "healthProtocolSelect"
            'change #property-elb-health-port'     : 'healthPortChanged'
            'change #property-elb-health-path'     : 'healthPathChanged'
            'change #property-elb-health-interval' : 'healthIntervalChanged'
            'change #property-elb-health-timeout'  : 'healthTimeoutChanged'

            'OPTION_CHANGE .elb-property-elb-protocol'      : 'protocolChanged'
            'OPTION_CHANGE .elb-property-instance-protocol' : 'protocolChanged'
            'change .elb-property-elb-port'                 : 'portChanged'
            'change .elb-property-instance-port'            : 'portChanged'

            'click #elb-property-listener-content-add' : 'listenerItemAddClicked'
            'click .elb-property-listener-item-remove' : 'listenerItemRemovedClicked'

            'change #elb-property-cert-name-input'       : 'listenerCertChanged'
            'change #elb-property-cert-privatekey-input' : 'listenerCertChanged'
            'change #elb-property-cert-publickey-input'  : 'listenerCertChanged'
            'change #elb-property-cert-chain-input'      : 'listenerCertChanged'

            'change .property-elb-az-checkbox' : 'azCheckChanged'

            'mousedown .slider .thumb' : "sliderMouseDown"
            'mousedown .slider li'     : "sliderSelect"
            'SLIDER_CHANGE .slider'    : 'sliderChanged'

            'change #elb-cross-az-select' : 'elbCrossAZSelect'

            'click .editbtn' : 'elbSSLCertAdd'
            'click #sslcert-select .item' : 'changeSSLCert'
            'click #sslcert-select .item .icon-edit' : 'elbSSLCertEdit'
            'click #sslcert-select .item .icon-remove' : 'elbSSLCertRemove'
            'click #elb-connection-draining-select' : 'elbConnectionDrainSelectChange'
            'change #elb-connection-draining-input' : 'elbConnectionDrainTimeoutChange'

            'click #elb-advanced-proxy-protocol-select' : 'elbAdvancedProxyProtocolSelectChange'

        render     : () ->

            @$el.html template @model.attributes

            @updateSlider( $('#elb-property-slider-unhealthy'), @model.get('unHealthyThreshold') - 2)
            @updateSlider( $('#elb-property-slider-healthy'), @model.get('healthyThreshold') - 2)

            @$('.sslcert-placeholder').html new sslCertDropdown().render().el

            @updateCertView()

            @model.attributes.name

        elbNameChange : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            oldName = @model.get("name")

            if @checkResName( target, "Load Balancer" )
                @model.setName name
                @setTitle name

                # Update Elb's Sg's Name
                oldName += "-sg"
                newName = name + "-sg"
                $("#sg-info-list").children().each ()->
                    $name = $(this).find(".sg-name")
                    if $name.text() is oldName
                        $name.text( newName )
                        return false

        schemeSelectChange : ( event ) ->
            @model.setScheme event.currentTarget.value
            null

        healthProtocolSelect : ( event, value ) ->
            if value is "TCP" or value is "SSL"
                $('#property-elb-health-path').attr 'disabled', 'disabled'
            else
                $('#property-elb-health-path').removeAttr 'disabled'

            @model.setHealthProtocol value

        healthPortChanged : ( event ) ->
            $target = $ event.currentTarget
            value = $target.val()
            value = Helper.makeInRange value, [1, 65535], $target, 1

            @model.setHealthPort value

        healthPathChanged : ( event ) ->
            @model.setHealthPath $(event.currentTarget).val()

        healthIntervalChanged : ( event ) ->
            $target = $ event.currentTarget
            value = Helper.makeInRange $target.val(), [5, 300], $target, 30

            $timeoutDom = $('#property-elb-health-timeout')
            $target.parsley 'custom', (val) ->
                intervalValue = Number(val)
                timeoutValue = Number($timeoutDom.val())
                if intervalValue < timeoutValue
                    return lang.ide.PROP_ELB_HEALTH_INTERVAL_VALID
                null

            if not $target.parsley 'validate'
                return
            else
                $timeoutDom.parsley 'validate'

            @model.setHealthInterval value

        healthTimeoutChanged : ( event ) ->
            $target = $ event.currentTarget
            value = Helper.makeInRange $target.val(), [2, 60], $target, 5

            $intervalDom = $('#property-elb-health-interval')
            $target.parsley 'custom', (val) ->
                intervalValue = Number($intervalDom.val())
                timeoutValue = Number(val)
                if intervalValue < timeoutValue
                    return lang.ide.PROP_ELB_HEALTH_INTERVAL_VALID
                null

            if not $target.parsley 'validate'
                return
            else
                $intervalDom.parsley 'validate'

            @model.setHealthTimeout value

        sliderChanged : ( event, value ) ->
            target = $(event.target)
            id     = event.target.id
            value += 2

            if id is 'elb-property-slider-unhealthy'
                @model.setHealthUnhealth value
            else
                @model.setHealthHealth value

        listenerItemAddClicked : ( event ) ->
            $li = $("#elb-property-listener-list").children().eq(0).clone()
            $li.find(".elb-property-listener-item-remove").show()
            $selectbox = $li.find("ul")
            $selectbox.children(".selected").removeClass("selected")
            $selectbox.children(":first-child").addClass("selected")
            $selectbox.prev(".selection").text("HTTP")
            $('#elb-property-listener-list').append $li
            @updateListener( $li )
            return false

        updateListener : ( $li )->
            obj = {
                port : $li.find(".elb-property-elb-port").val()
                protocol : $li.find(".elb-property-elb-protocol .selected").text()
                instancePort : $li.find(".elb-property-instance-port").val()
                instanceProtocol : $li.find(".elb-property-instance-protocol .selected").text()
            }

            @model.setListener $li.index(), obj
            @updateCertView()
            null

        protocolChanged : ( event )->

            $protocol = $( event.currentTarget )

            if event
                thatElem = $(event.target)
                value = thatElem.find('.selection').text()
                if value
                    portElem = null
                    otherProtocolElem = null
                    parentItemElem = thatElem.parents('.elb-property-listener')
                    if thatElem.hasClass('elb-property-elb-protocol')
                        portElem = parentItemElem.find('.elb-property-elb-port')
                        otherProtocolElem = parentItemElem.find('.elb-property-instance-protocol')
                    else
                        portElem = parentItemElem.find('.elb-property-instance-port')
                        otherProtocolElem = parentItemElem.find('.elb-property-elb-protocol')
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
                        $allSelectItem = otherProtocolElem.find('.item')
                        $allSelectItem.removeClass('selected')
                        $selectProtocol = otherProtocolElem.find("[data-id=" + currentPtotocol + "]")
                        $selectProtocol.addClass('selected')

                    if otherProtocolElem.hasClass('elb-property-elb-protocol')
                        portElem = parentItemElem.find('.elb-property-elb-port')
                    else
                        portElem = parentItemElem.find('.elb-property-instance-port')

                    newOtherProtocol = otherProtocolElem.find('.selection').text()
                    if newOtherProtocol in ['HTTPS', 'SSL']
                        portElem.val('443')
                    else
                        portElem.val('80')


            @updateListener( $protocol.closest("li") )
            null

        portChanged : ( event )->
            $input = $( event.currentTarget )

            if $input.hasClass("elb-property-elb-port")
                validate = ( val )->
                    val = parseInt( val, 10 )
                    if not ( val is 25 or val is 80 or val is 443 or ( 1023 < val < 65536 ) )
                        return lang.ide.PARSLEY_LOAD_BALANCER_PORT_MUST_BE_SOME_PROT
            else
                validate = ( val )->
                    val = parseInt( val, 10 )
                    if not ( 0 < val < 65536 )
                        return lang.ide.PARSLEY_INSTANCE_PORT_MUST_BE_BETWEEN_1_AND_65535

            $input.parsley "custom", validate

            if $input.parsley "validate"
                @updateListener( $input.closest("li") )
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

            @model.setListenerAry idx, listener
            @updateCertView()
            null

        listenerItemRemovedClicked : ( event ) ->
            $li = $( event.currentTarget ).closest("li")
            @model.removeListener( $li.index() )
            $li.remove()
            @updateCertView()
            return false

        listenerCertChanged : ( event ) ->
            @model.setCert {
                name  : $('#elb-property-cert-name-input').val()
                key   : $('#elb-property-cert-privatekey-input').val()
                body  : $('#elb-property-cert-publickey-input').val()
                chain : $('#elb-property-cert-chain-input').val()
            }
            null

        updateCertView : ()->
            show = false

            $("#elb-property-listener-list").children().each ()->
                protocol = $(this).find(".elb-property-elb-protocol .selected").text()
                if protocol is "HTTPS" or protocol is "SSL"
                    show = true
                    return false

            $certPanel = $('#property-control-group-cert-setting')
            if show
                $certPanel.show()
            else
                $certPanel.hide()

            null

        azCheckChanged : ( event ) ->
            azArray = _.map $("#property-elb-az-cb-group").find("input:checked"), ( cb )->
                $( cb ).attr("data-name")

            @model.updateElbAZ azArray
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
                        offsetStep = -value
                    else if newPos > width
                        newPos = width
                        offsetStep = step - value
                else
                    newPos     = thumbPos
                    offsetStep = 0

                $thumb.css("left", newPos)
                false

            onMouseUp = ()->
                $body.off "mousemove", onMouseMove

                newValue = value + offsetStep
                $slider.data("value", newValue).trigger("SLIDER_CHANGE", newValue)
                null

            $body.on "mousemove", onMouseMove
            $body.one "mouseup", onMouseUp

            false

        elbCrossAZSelect : ( event ) ->
            @model.setElbCrossAZ event.target.checked
            null

        elbSSLCertAdd : (event) ->
            
            that = this
            that.popSSLCertModal(false)
            return false

        elbSSLCertEdit : (event) ->

            that = this
            $certEditItem = $(event.currentTarget)
            $certItem = $certEditItem.parents('.item')
            certUID = $certItem.attr('data-id')
            if certUID
                that.popSSLCertModal(true, certUID)
            return false

        elbSSLCertRemove : (event) ->

            that = this
            $certEditItem = $(event.currentTarget)
            $certItem = $certEditItem.parents('.item')
            certUID = $certItem.attr('data-id')
            certModel = Design.instance().component(certUID)

            if certModel

                certName = certModel.get('name')
                modal MC.template.modalDeleteELBCert {cert_name: certName}, true

                $("#modal-confirm-elb-cert-delete").one 'click', ()->
                    that.model.removeCert(certUID)
                    ide_event.trigger ide_event.REFRESH_PROPERTY
                    modal.close()
            
            return false

        changeSSLCert : (event) ->

            that = this
            $certItem = $(event.currentTarget)
            certUID = $certItem.attr('data-id')

            that.model.changeCert(certUID)
            ide_event.trigger ide_event.REFRESH_PROPERTY

        popSSLCertModal : (isEdit, certUID) ->

            that = this

            modal MC.template.modalSSLCertSetting {}, true

            $certName = $('#elb-ssl-cert-name-input')
            $certPrikey = $('#elb-ssl-cert-privatekey-input')
            $certPubkey = $('#elb-ssl-cert-publickey-input')
            $certChain = $('#elb-ssl-cert-chain-input')
            currentCertName = ''

            if isEdit and certUID
                certModel = Design.instance().component(certUID)
                if certModel
                    currentCertName = certModel.get('name')
                    $certName.val(currentCertName)
                    $certPrikey.val(certModel.get('key'))
                    $certPubkey.val(certModel.get('body'))
                    $certChain.val(certModel.get('chain'))

            otherCertNameAry = that.model.getOtherCertName(currentCertName)

            $("#elb-ssl-cert-confirm").off('click').on('click', ()->

                isCorrect = false

                $certName.parsley 'custom', (val) ->
                    if val in otherCertNameAry
                        return lang.ide.PARSLEY_THIS_NAME_IS_ALREADY_IN_USING
                    null

                valid1 = $certName.parsley('validate')
                valid2 = $certPrikey.parsley('validate')
                valid3 = $certPubkey.parsley('validate')

                if valid1 and valid2 and valid3
                    isCorrect = true

                if isCorrect

                    certObj = {
                        name  : $certName.val()
                        key   : $certPrikey.val()
                        body  : $certPubkey.val()
                        chain : $certChain.val()
                    }

                    if isEdit and certUID
                        that.model.updateCert(certUID, certObj)
                    else
                        that.model.addCert(certObj)

                    ide_event.trigger ide_event.REFRESH_PROPERTY
                    modal.close()

                null
            )

        elbConnectionDrainSelectChange : (event) ->

            that = this
            $selectbox = that.$('#elb-connection-draining-select')
            $inputGroup = that.$('.elb-connection-draining-input-group')
            $timeoutInput = that.$('#elb-connection-draining-input')
            selectValue = $selectbox.prop('checked')
            if selectValue
                $inputGroup.removeClass('hide')
            else
                $inputGroup.addClass('hide')

            timeoutValue = Number($timeoutInput.val())
            if selectValue and timeoutValue
                that.model.setConnectionDraining(true, timeoutValue)
            if not selectValue
                that.model.setConnectionDraining(false)

        elbConnectionDrainTimeoutChange : (event) ->

            that = this
            $timeoutInput = that.$('#elb-connection-draining-input')
            $selectbox = that.$('#elb-connection-draining-select')
            selectValue = $selectbox.prop('checked')

            timeoutValue = Number($timeoutInput.val())

            $timeoutInput.parsley 'custom', (val) ->
                inputValue = Number($timeoutInput.val())
                if not (inputValue >= 1 and inputValue < 3600)
                    return lang.ide.PROP_ELB_CONNECTION_DRAIN_TIMEOUT_INVALID
                null

            if not $timeoutInput.parsley 'validate'
                return

            if selectValue and timeoutValue
                that.model.setConnectionDraining(true, timeoutValue)

        elbAdvancedProxyProtocolSelectChange : (event) ->

            that = this
            $selectbox = that.$('#elb-advanced-proxy-protocol-select')
            $tipBox = $('#elb-advanced-proxy-protocol-select-tip')
            selectValue = $selectbox.prop('checked')
            if selectValue
                $tipBox.removeClass('hide')
            else
                $tipBox.addClass('hide')

            that.model.setAdvancedProxyProtocol(selectValue, [80])

    }

    new ElbView()
