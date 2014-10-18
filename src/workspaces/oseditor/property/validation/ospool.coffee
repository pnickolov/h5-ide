define [
  'constant'
  './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

        limit:
            port: '^[0-9]*$'

        port: (value) ->

            return 'pool have some port valid error.'

    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
    }
