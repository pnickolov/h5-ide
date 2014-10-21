define [
    'constant'
    './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

        limits:

            ip: ValidationBase.limit.ipv4

        ip: (value) ->

            if not MC.validate('ipv4', value)
                return 'Invalid IP Address'
            return null

    }, {
        handleTypes: [ constant.RESTYPE.OSPORT ]
    }
