define [
    'constant'
    './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

        limits:

            port: ValidationBase.limit.portICMPRange

        port: (value, $dom) ->

            port = value

            protocol = $dom.prevAll('.selection[data-target="protocol"]').getValue()

            tip = 'Port/Type/Code range invalid'

            if protocol is 'icmp'
                port = @view.getICMPRange(port)
                if port is null
                    return tip
            else if protocol in ['tcp', 'udp']
                port = @view.getPortRange(port)
                if port is null
                    return tip

    }, {
        handleTypes: [ constant.RESTYPE.OSSG ]
    }
