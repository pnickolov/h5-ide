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

        delay: (v) ->
            if v > 2147483647
                return ValidationBase.lowerTip 2147483648
            null

        timeout: (v) ->
            if v > 2147483647
                return ValidationBase.lowerTip 2147483648
            null

        maxRetries: (v) ->
            if v > 3
                return ValidationBase.lowerTip 4
            null

    }, {
        handleTypes: [ constant.RESTYPE.OSHM ]
    }
