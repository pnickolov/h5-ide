define [ 'constant', 'MC','i18n!/nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

    isConnectToRTB = ( uid ) ->
        components = MC.canvas_data.component
        igw = components[ uid ]
        igwId = MC.genResRef(uid, 'resource.InternetGatewayId')

        isConnectRTB = _.some components, ( component ) ->
            if component.type is constant.RESTYPE.RT
                _.some component.resource.RouteSet, ( rt ) ->
                    if rt.GatewayId is igwId
                        RTB = component
                        return true

        if isConnectRTB
            return null

        tipInfo = lang.ide.TA_MSG_WARNING_NO_RTB_CONNECT_IGW

        # return
        level   : constant.TA.WARNING
        info    : tipInfo
        uid     : uid

    # public
    isConnectToRTB : isConnectToRTB
