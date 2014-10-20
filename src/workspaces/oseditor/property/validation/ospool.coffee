define [
  'constant'
  './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

        limit:

            port: ValidationBase.limit.port

        port: (value) ->
            return 'pool have some port valid error.'

    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
    }
