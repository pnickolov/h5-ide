define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    'UI.selection'
], ( constant, OsPropertyView, template, CloudResources, bindSelection ) ->

    OsPropertyView.extend {

        events:

            "change [data-target]": "updateAttribute"
            "click .direction-switch .t-m-btn": "switchDirection"

        className: 'float-panel-sg'

        initialize: (options) ->

            that = @

            that.sgModel = options.sgModel

            @selectTpl =

                ipValid: (value) ->

                    return true if MC.validate('cidr', value)
                    return false

                portValid: (value) ->

                    return false if not (value and value[0])

                    value = value[0]

                    rule = that.getRuleValue(@)

                    # for tcp and udp
                    if rule.protocol in ['tcp', 'udp', 'all']
                        return true if that.getPortRange(value)
                    # for icmp
                    else
                        return true if that.getICMPRange(value)

                    return false

        render: ->

            that = @

            bindSelection(@$el, @selectTpl)

            ingressRules = []
            egressRules = []
            sgRules = that.sgModel.get('rules')

            _.each sgRules, (ruleModel) ->

                rule = ruleModel.toJSON()

                ruleStrObj = that.getRuleStr(rule)

                if ruleStrObj.direction is 'ingress'
                    ingressRules.push(ruleStrObj)
                else if ruleStrObj.direction is 'egress'
                    egressRules.push(ruleStrObj)

            @$el.html template.stack({
                ingressRules: ingressRules,
                egressRules: egressRules
            })

            @

        nullStr: 'N/A'

        switchDirection: (event) ->

            $target = $(event.target)
            @$el.find('.direction-switch .t-m-btn').removeClass('active')
            $target.addClass('active')

            @$el.find('.rule-container').addClass('hide')
            if $target.hasClass('ingress')
                @$el.find('.rule-container.ingress').removeClass('hide')
            else
                @$el.find('.rule-container.egress').removeClass('hide')

        setTitle: ( title ) -> @$( 'h1' ).text title

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            rule = @getRuleValue($target)

            return if not rule

            if attr is 'protocol'
                @setDefaultPort(rule, $target)

            $ruleItem = $target.parents('.rule-item')
            ruleId = $ruleItem.data('id')
            ruleModel = @sgModel.getRule(ruleId)

            if ruleModel
                @sgModel.updateRule(ruleId, rule) if rule
            else
                newRuleId = @sgModel.addRule(rule) if rule
                $ruleItem.data('id', newRuleId)

        setDefaultPort: (rule, $target) ->

            $ruleContainer = $target.parents('.rule-item')
            $port = $ruleContainer.find('input[data-target="port"]')

            $port.removeAttr('disabled')
            if rule.protocol in ['tcp', 'udp']
                $port.val('0-65535')
            else if rule.protocol is 'icmp'
                $port.val('-1/-1')
            else if rule.protocol is null
                $port.val(@nullStr)
                $port.attr('disabled', 'disabled')

        getPortStr: (min, max) ->

            if min is null or max is null
                return '0-65535'

            if min is max
                return min + ''
            else
                return min + '-' + max

        getICMPStr: (type, code) ->

            type = -1 if type is null
            code = -1 if code is null
            return type + '/' + code

        getPortRange: (portStr) ->

            return [null, null] if portStr is '0-65535'

            portRange = MC.validate.portRange(portStr)
            if portRange and MC.validate.portValidRange(portRange)
                return portRange
            else
                return null

        getICMPRange: (icmpStr) ->

            icmpAry = icmpStr.split('/')
            if icmpAry and icmpAry.length and icmpAry.length is 2
                icmpType = Number(icmpAry[0])
                icmpCode = Number(icmpAry[1])
                if _.isNumber(icmpType) and _.isNumber(icmpCode)
                    icmpAry[0] = null if icmpType is -1
                    icmpAry[1] = null if icmpCode is -1
                    return icmpAry
            return null

        # for model to use
        getRuleValue: ($target) ->

            # direction        : @get( "direction" )
            # port_range_min   : @get( "portMin" )
            # port_range_max   : @get( "portMax" )
            # protocol         : @get( "protocol" )
            # remote_group_id  : if sg then sg.createRef( "id" ) else null
            # remote_ip_prefix : @get( "ip" )
            # id               : @get( "appId" )

            $ruleItem = $target.parents('.rule-item')

            $ruleContainer = $ruleItem.parents('.rule-container')

            $protocol = $ruleItem.find('select[data-target="protocol"]')
            $port = $ruleItem.find('input[data-target="port"]')
            $ip = $ruleItem.find('select[data-target="ip"]')

            protocol = $protocol.getValue()
            port = $port.getValue()
            ip = $ip.getValue()

            ip = null if ip is '0.0.0.0/0'

            direction = 'ingress'
            if $ruleContainer.hasClass('egress')
                direction = 'egress'

            if protocol is 'all'
                protocol = null
                port_range_min = null
                port_range_max = null
            else if protocol is 'icmp'
                port = @getICMPRange(port)
                if port is null
                    port_range_min = null
                    port_range_max = null
                else
                    port_range_min = port[0]
                    port_range_max = port[1]
            else
                port = @getPortRange(port)
                if port is null
                    port_range_min = null
                    port_range_max = null
                else
                    port_range_min = port[0]
                    port_range_max = port[1]

            return {
                direction: direction,
                protocol: protocol,
                portMin: port_range_min,
                portMax: port_range_max,
                ip: ip,
                sg: null
            }

        # for view to use
        getRuleStr: (rule) ->

            # protocol: protocol,
            # port: @getPortRange(port),
            # ip: ip

            direction = rule.direction
            ip = rule.remote_ip_prefix
            protocol = rule.protocol

            ip = '0.0.0.0/0' if ip is null

            if rule.protocol in ['tcp', 'udp']
                port = @getPortStr(rule.port_range_min, rule.port_range_max)
            else if rule.protocol in ['icmp']
                port = @getICMPStr(rule.port_range_min, rule.port_range_max)
            else
                protocol = 'all'
                port = @nullStr

            ruleData = {
                id: rule.id,
                direction: direction,
                protocol: protocol,
                port: port,
                ip: ip
            }

    }, {
        handleTypes: [ 'ossg' ]
        handleModes: [ 'stack', 'appedit' ]
    }
