define [
  'constant'
  './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

        limit:
            port: '^[0-9]*$'

        port: (value) ->

            return 'error'

    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
    }
