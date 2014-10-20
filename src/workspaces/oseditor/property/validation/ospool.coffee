define [
  'constant'
  './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

        limit:

            port: ValidationBase.limit.port

        port: (value) ->
            return 'pool have some port valid error.' if value is '8080'
            return null

    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
    }
