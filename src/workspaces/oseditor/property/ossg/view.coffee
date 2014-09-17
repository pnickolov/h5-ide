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

                sourceValid: (value) ->

                    return true if MC.validate('cidr', value)
                    return false

                portValid: (value) ->

                    return false if not (value and value[0])

                    value = value[0]

                    rule = that.getRuleValue(@)

                    # for tcp and udp
                    if rule.protocol in ['tcp', 'udp', 'null']
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

        getPortStr: (min, max) ->

            if min is max
                return min + ''
            else
                return min + '-' + max

        render: ->

            that = @

            bindSelection(@$el, @selectTpl)

            ingressRules = []
            egressRules = []
            sgRules = that.sgModel.get('rules')

            _.each sgRules, (ruleModel) ->

                rule = ruleModel.toJSON()

                portStr = that.getPortStr(rule.port_range_min, rule.port_range_max)

                ruleData = {
                    protocol: rule.protocol,
                    ip: rule.remote_ip_prefix,
                    port: portStr
                }

                if rule.direction is 'ingress'
                    ingressRules.push(ruleData)
                else if rule.direction is 'egress'
                    egressRules.push(ruleData)

            @$el.html template.stack({
                ingressRules: ingressRules,
                egressRules: egressRules
            })

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

                    # direction        : @get( "direction" )
                    # port_range_min   : @get( "portMin" )
                    # port_range_max   : @get( "portMax" )
                    # protocol         : @get( "protocol" )
                    # remote_group_id  : if sg then sg.createRef( "id" ) else ""
                    # remote_ip_prefix : @get( "ip" )
                    # id               : @get( "appId" )

                    @sgModel.addRule({
                        direction: rule.ip
                        portMin: rule.ip
                        portMax: rule.ip
                        protocol: rule.protocol
                        sg: null
                        ip: rule.ip
                    })

        getRuleValue: ($target) ->

            $ruleItem = $target.parents('.rule-item')

            $protocol = $ruleItem.find('select[data-target="protocol"]')
            $port = $ruleItem.find('select[data-target="port"]')
            $ip = $ruleItem.find('select[data-target="ip"]')

            protocol = $protocol.getValue()
            port = $port.getValue()
            ip = $ip.getValue()

            return {
                protocol: protocol,
                port: port,
                ip: ip
            }

    }, {
        handleTypes: [ 'ossg' ]
        handleModes: [ 'stack', 'appedit' ]
    }
