define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo', 'Design' ], ( constant, MC, lang, resultVO, Design ) ->

    __wrap = ( method ) ->
        ( uid ) ->
            if __hasState uid
                method uid
            else
                null

    __hasState = ( uid ) ->
        if uid
            component = MC.canvas_data.component[ uid ]
            component.state and component.state.length
        else
            _.some MC.canvas_data.component, ( component ) ->
                component.state and component.state.length

    __hasType = ( type ) ->
        _.some MC.canvas_data.component, ( component ) ->
            component.type is type

    isHasIgw = ( uid ) ->
        if __hasType constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway
            return null

        tipInfo = lang.ide.TA_MSG_ERROR_NO_CGW

        # return
        level   : constant.TA.ERROR
        info    : tipInfo
        uid     : uid





    # public
    isHasIgw    : __wrap isHasIgw
