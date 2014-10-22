define [
  'constant'
  './ValidationBase'
  './osport'
], ( constant, ValidationBase, PortValidation ) ->

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

        delay: ValidationBase.validation.range4G
        timeout: ValidationBase.validation.range4G

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

        limit: ValidationBase.validation.range4G

        ip: (new PortValidation()).ip

    }, {
        handleTypes: [ constant.RESTYPE.OSLISTENER ]
    }
