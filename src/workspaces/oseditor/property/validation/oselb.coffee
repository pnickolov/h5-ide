define [
  'constant'
  './ValidationBase'
], ( constant, ValidationBase ) ->

    # POOL
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

    # Health Monitor
    ValidationBase.extend {
        limit:
            delay: ValidationBase.limit.positive
            timeout: ValidationBase.limit.positive
            maxRetries: ValidationBase.limit.positive

    }, {
        handleTypes: [ constant.RESTYPE.OSHM ]
    }
