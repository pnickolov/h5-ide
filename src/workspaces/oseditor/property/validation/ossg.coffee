define [
    'constant'
    './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

        # limit:
        #
        #     # name: ValidationBase.limit.name
        #     port: ValidationBase.limit.portCodeRange
        #
        # port: (value) ->
        #
        #     return 'pool have some port valid error.'

        name: (value) ->

            return 'not empty' if not value

    }, {
        handleTypes: [ constant.RESTYPE.OSSG ]
    }
