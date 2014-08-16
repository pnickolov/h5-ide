define [ 'constant', 'MC','i18n!/nls/lang.js' ], ( constant, MC, lang ) ->

    isConnectToRTB = ( uid ) ->
        components = MC.canvas_data.component
        vpn = components[ uid ]
        vpnId = MC.genResRef(uid, 'resource.VpnGatewayId')

        isConnectRTB = _.some components, ( component ) ->
            if component.type is constant.RESTYPE.RT
                _.some component.resource.RouteSet, ( rt ) ->
                    if rt.GatewayId is vpnId
                        RTB = component
                        return true

        if isConnectRTB
            return null

        tipInfo = lang.ide.TA_MSG_WARNING_NO_RTB_CONNECT_VGW

        # return
        level   : constant.TA.WARNING
        info    : tipInfo
        uid     : uid



    # public
    isConnectToRTB : isConnectToRTB
