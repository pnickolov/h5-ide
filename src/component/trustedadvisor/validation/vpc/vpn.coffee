define [ 'constant', 'MC','i18n!/nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

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
            vgwComp = MC.canvas_data.component[vgwUID]
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
                        vgwName = vgwComp.name
                        cgwName = cgwComp.name

                        tipInfo = sprintf lang.ide.TA_MSG_ERROR_VPN_NO_IP_FOR_STATIC_CGW, cgwName, vgwName
                        returnObj = {
                            level   : constant.TA.ERROR
                            info    : tipInfo
                            uid     : uid
                        }

        return returnObj

    isVPNPrefixIPNotValid = (uid) ->

        returnObj = null

        vpnComp = MC.canvas_data.component[uid]
        vpnName = vpnComp.name
        routeAry = vpnComp.resource.Routes

        invalidRouteCIDRAry = []

        _.each routeAry, (routeObj) ->

            routeCIDR = routeObj.DestinationCidrBlock

            if routeCIDR

                validSubnetCIDR = Design.modelClassForType(constant.RESTYPE.SUBNET).isValidSubnetCIDR(routeCIDR)

                if not validSubnetCIDR
                    invalidRouteCIDRAry.push(routeCIDR)

                else

                    routeIP = routeCIDR.split('/')[0]
                    routeIPCIDR = routeCIDR.split('/')[1]
                    isInAnyPubIPRange = MC.aws.aws.isValidInIPRange(routeIP, 'public')
                    isInAnyPriIPRange = MC.aws.aws.isValidInIPRange(routeIP, 'private')

                    if (isInAnyPubIPRange and not isInAnyPriIPRange) or Number(routeIPCIDR) is 0
                        invalidRouteCIDRAry.push(routeCIDR)

        if invalidRouteCIDRAry.length

            tipInfo = sprintf lang.ide.TA_MSG_ERROR_VPN_NOT_PUBLIC_IP, vpnName, invalidRouteCIDRAry.join(', ')
            returnObj = {
                level   : constant.TA.ERROR
                info    : tipInfo
                uid     : uid
            }

        return returnObj

    # public
    isVPNHaveIPForStaticCGW : isVPNHaveIPForStaticCGW
    isVPNPrefixIPNotValid : isVPNPrefixIPNotValid
