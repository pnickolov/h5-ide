define [
    'constant'
    './ValidationBase'
    'i18n!/nls/lang.js'
], ( constant, ValidationBase, lang ) ->

    ValidationBase.extend {

        limits:

            ip: ValidationBase.limit.ipv4

        ip: (value) ->

            if not MC.validate('ipv4', value)
                return 'Invalid IP Address'

            subnetModel = @model.parent()

            if subnetModel.type is constant.RESTYPE.OSSUBNET

                subnetCIDR = subnetModel.get('cidr')
                validObj = Design.modelClassForType(constant.RESTYPE.SUBNET).isIPInSubnet(value, subnetCIDR, [0, 1, 2])
                if not validObj.isValid
                    if validObj.isReserved
                        return lang.IDE.VALIDATION_IP_IN_SUBNET_REVERSED_RANGE
                    return lang.IDE.VALIDATION_IP_CONFLICTS_WITH_SUBNET_IP_RANGE

            return null

    }, {
        handleTypes: [ constant.RESTYPE.OSPORT ]
    }
