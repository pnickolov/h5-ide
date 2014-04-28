define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

    isHasIGW = () ->

        # check platform
        if (MC.canvas_data.platform in
            [MC.canvas.PLATFORM_TYPE.EC2_CLASSIC, MC.canvas.PLATFORM_TYPE.DEFAULT_VPC])
                return null

        if not _hasType(constant.RESTYPE.EIP) or _hasType(constant.RESTYPE.IGW)
            return null

        tipInfo = lang.ide.TA_MSG_ERROR_HAS_EIP_NOT_HAS_IGW

        # return
        level   : constant.TA.ERROR
        info    : tipInfo


    _hasType = ( type ) ->
        components = MC.canvas_data.component
        _.some components, ( component ) ->
            component.type is type


    # public
    isHasIGW : isHasIGW