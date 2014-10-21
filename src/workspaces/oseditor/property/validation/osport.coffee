define [
    'constant'
    './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

        limits:

            ip: ValidationBase.limit.ipv4

        ip: (value) ->

            return null

    }, {
        handleTypes: [ constant.RESTYPE.OSPORT ]
    }
