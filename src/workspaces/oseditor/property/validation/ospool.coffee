define [
  'constant'
  './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

        limit:
            weight: ValidationBase.limit.positive
            port: ValidationBase.limit.positive

        port: (value) ->
            if 0 <= +value <= 65535
                return null

            return ValidationBase.commonTip 'port'



    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
    }
