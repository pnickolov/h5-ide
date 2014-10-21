define [
  'constant'
  './ValidationBase'
], ( constant, ValidationBase ) ->

    # POOL
    ValidationBase.extend {
        limits:
            weight: ValidationBase.limit.positive
            port: ValidationBase.limit.positive

    }, {
        handleTypes: [ constant.RESTYPE.OSPOOL ]
    }

    # Health Monitor
    ValidationBase.extend {
        limits:
            delay: ValidationBase.limit.positive
            timeout: ValidationBase.limit.positive
            maxRetries: ValidationBase.limit.positive

        delay: ( v ) ->
            if v > 2147483647
                return ValidationBase.lowerTip 2147483648
            null

        timeout: ( v ) ->
            if v > 2147483647
                return ValidationBase.lowerTip 2147483648
            null

        maxRetries: ( v ) ->
            if v > 3
                return ValidationBase.lowerTip 4
            null

    }, {
        handleTypes: [ constant.RESTYPE.OSHM ]
    }

    # Listener
    ValidationBase.extend {
        limits:
            ip: ValidationBase.limit.ipv4
            port: ValidationBase.limit.positive
            limit: ValidationBase.limit.positive


    }, {
        handleTypes: [ constant.RESTYPE.OSLISTENER ]
    }
