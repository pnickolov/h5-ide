define [
    'constant'
    './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

        limit:

            ip: ValidationBase.limit.ipv4

        ip: (value) ->

            return null

    }, {
        handleTypes: [ constant.RESTYPE.OSPORT ]
    }
