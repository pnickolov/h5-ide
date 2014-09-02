define [ 'constant', 'MC','i18n!/nls/lang.js' ], ( constant, MC, lang ) ->

    isHasIGW = () ->
        if not _hasType(constant.RESTYPE.EIP) or _hasType(constant.RESTYPE.IGW)
            return null

        tipInfo = lang.TA.ERROR_HAS_EIP_NOT_HAS_IGW

        # return
        level   : constant.TA.ERROR
        info    : tipInfo


    _hasType = ( type ) ->
        components = MC.canvas_data.component
        _.some components, ( component ) ->
            component.type is type


    # public
    isHasIGW : isHasIGW
