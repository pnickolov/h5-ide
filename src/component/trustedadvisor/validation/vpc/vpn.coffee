define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

    isVPNHaveIPForStaticCGW = (uid) ->

        returnObj = null

        vpnComp = MC.canvas_data.component[uid]
        cgwRef = vpnComp.resource.CustomerGatewayId
        vgwRef = vpnComp.resource.VpnGatewayId

        cgwUID = ''
        if cgwRef then cgwUID = MC.extractID(cgwRef)
        vgwUID = ''
        if vgwRef then vgwUID = MC.extractID(vgwRef)

        if cgwUID and vgwUID
            cgwComp = MC.canvas_data.component[cgwUID]
            if cgwComp
                isStaticCGW = true
                bgpAsn = cgwComp.resource.BgpAsn
                if bgpAsn and _.isNumber(Number(bgpAsn))
                    isStaticCGW = false
                if isStaticCGW
                    routeAry = vpnComp.resource.Routes
                    isHaveNoEmptyRoute = true

                    if not routeAry.length
                        isHaveNoEmptyRoute = false

                    if _.isArray(routeAry)
                        _.each routeAry, (routeObj) ->
                            if not routeObj.DestinationCidrBlock
                                isHaveNoEmptyRoute = false
                            null

                    if isStaticCGW and not isHaveNoEmptyRoute
                        vpnName = vpnComp.name
                        cgwName = cgwComp.name

                        tipInfo = sprintf lang.ide.TA_MSG_ERROR_VPN_NO_IP_FOR_STATIC_CGW, cgwName, vpnName
                        returnObj = {
                            level   : constant.TA.ERROR
                            info    : tipInfo
                            uid     : uid
                        }

        return returnObj
        
    # public
    isVPNHaveIPForStaticCGW : isVPNHaveIPForStaticCGW