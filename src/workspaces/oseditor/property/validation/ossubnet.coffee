define [
    'constant'
    './ValidationBase'
], ( constant, ValidationBase ) ->

    ValidationBase.extend {

        limits:

            cidr: ValidationBase.limit.cidrv4

        cidr: (value) ->

            if not MC.validate('cidr', value)
                return 'Invalid CIDR Address'
            return null

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
    }
