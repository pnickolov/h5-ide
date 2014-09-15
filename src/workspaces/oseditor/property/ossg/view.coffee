define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
], ( constant, OsPropertyView, template, CloudResources ) ->

    OsPropertyView.extend {

        events:

            "change [data-target]": "updateAttribute"
            "click .direction-switch .t-m-btn": "switchDirection"

        initialize: ->

            that = @

            @selectTpl =

                sourceValid: (value) ->

                    return true if MC.validate('cidr', value)
                    return false

                portValid: (value) ->

                    return false if not value

                    rule = that.getRuleValue(@)

                    # for tcp and udp
                    if rule.protocol in ['tcp', 'udp']
                        portRange = MC.validate.portRange(value)
                        if portRange and MC.validate.portValidRange(portRange)
                            return true
                        else
                            return false
                    # for icmp
                    else
                        valueAry = value.split('/')
                        if valueAry and valueAry.length
                            if valueAry.length is 2
                                icmpType = Number(valueAry[0])
                                icmpCode = Number(valueAry[1])
                                if _.isNumber(icmpType) and _.isNumber(icmpCode)
                                    return true
                        return false

        render: ->

            @$el.html template.stack()
            @

        switchDirection: (event) ->

            $target = $(event.target)
            @$el.find('.direction-switch .t-m-btn').removeClass('active')
            $target.addClass('active')

            @$el.find('.rule-container').addClass('hide')
            if $target.hasClass('ingress')
                @$el.find('.rule-container.ingress').removeClass('hide')
            else
                @$el.find('.rule-container.egress').removeClass('hide')

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            if (attr in ['protocol', 'port', 'source'])
                rule = @getRuleValue($target)
                if rule.protocol and rule.port and rule.source
                    @model

        getRuleValue: ($target) ->

            $ruleItem = $target.parents('.rule-item')

            $protocol = $ruleItem.find('select[data-target="protocol"]')
            $port = $ruleItem.find('select[data-target="port"]')
            $source = $ruleItem.find('select[data-target="source"]')

            protocol = $protocol.getValue()
            port = $port.getValue()
            source = $source.getValue()

            return {
                protocol: protocol,
                port: port,
                source: source
            }

    }, {
        handleTypes: [ constant.RESTYPE.OSSG ]
        handleModes: [ 'stack', 'appedit' ]
    }
