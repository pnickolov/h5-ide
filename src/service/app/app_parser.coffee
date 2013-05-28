#*************************************************************************************
#* Filename     : app_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:59
#* Description  : parser return data of app
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'app_vo', 'result_vo', 'constant' , 'ebs_parser', 'eip_parser', 'instance_parser'
         'keypair_parser', 'securitygroup_parser', 'elb_parser', 'iam_parser', 'acl_parser'
         'customergateway_parser', 'dhcp_parser', 'eni_parser', 'internetgateway_parser', 'routetable_parser'
         'subnet_parser', 'vpc_parser', 'vpn_parser', 'vpngateway_parser', 'stack_parser'], ( app_vo, result_vo, constant, ebs_parser, eip_parser, instance_parser
         keypair_parser, securitygroup_parser, elb_parser, iam_parser, acl_parser
         customergateway_parser, dhcp_parser, eni_parser, internetgateway_parser, routetable_parser
         subnet_parser, vpc_parser, vpn_parser, vpngateway_parser, stack_parser) ->

    resolveAppRequest = (result) ->
        #resolve result
        app_vo.app_request.id               =   result[0]
        app_vo.app_request.state            =   result[1]
        app_vo.app_request.brief            =   result[2]
        app_vo.app_request.time_submit      =   result[3]
        app_vo.app_request.rid              =   result[4]

        #return vo
        app_vo.app_request

    #///////////////// Parser for create return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveCreateResult = ( result ) ->
        #resolve result
        

        #return vo
        resolveAppRequest result

    #private (parser create return)
    parserCreateReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveCreateResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserCreateReturn


    #///////////////// Parser for update return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveUpdateResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        resolveAppRequest result

    #private (parser update return)
    parserUpdateReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveUpdateResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserUpdateReturn


    #///////////////// Parser for rename return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRenameResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser rename return)
    parserRenameReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveRenameResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserRenameReturn


    #///////////////// Parser for terminate return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveTerminateResult = ( result ) ->
        #resolve result
        

        #return vo
        resolveAppRequest result

    #private (parser terminate return)
    parserTerminateReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveTerminateResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserTerminateReturn


    #///////////////// Parser for start return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveStartResult = ( result ) ->
        #resolve result


        #return vo
        resolveAppRequest result

    #private (parser start return)
    parserStartReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveStartResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserStartReturn


    #///////////////// Parser for stop return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveStopResult = ( result ) ->
        #resolve result

        #return vo
        resolveAppRequest result

    #private (parser stop return)
    parserStopReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveStopResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserStopReturn


    #///////////////// Parser for reboot return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRebootResult = ( result ) ->
        #resolve result
        

        #return vo
        resolveAppRequest result

    #private (parser reboot return)
    parserRebootReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveRebootResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserRebootReturn


    #///////////////// Parser for info return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInfoResult = ( result ) ->
        #resolve result
        #app_list = (resolveApp app_json for app_json in result)

        #return vo
        result

    #private (parser info return)
    parserInfoReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveInfoResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserInfoReturn


    #///////////////// Parser for resource return (need resolve) /////////////////
    resourceMap = ( result ) ->
        responses = {
             "DescribeVolumesResponse"              :   ebs_parser.resolveDescribeVolumesResult
             "DescribeSnapshotsResponse"            :   ebs_parser.resolveDescribeSnapshotsResult
             "DescribeAddressesResponse"            :   eip_parser.resolveDescribeAddressesResult
             "DescribeInstancesResponse"            :   instance_parser.resolveDescribeInstancesResult
             "DescribeKeyPairsResponse"             :   keypair_parser.resolveDescribeKeyPairsResult
             "DescribeSecurityGroupsResponse"       :   securitygroup_parser.resolveDescribeSecurityGroupsResult
             "DescribeLoadBalancersResponse"        :   elb_parser.resolveDescribeLoadBalancersResult
             "DescribeNetworkAclsResponse"          :   acl_parser.resolveDescribeNetworkAclsResult
             "DescribeCustomerGatewaysResponse"     :   customergateway_parser.resolveDescribeCustomerGatewaysResult
             "DescribeDhcpOptionsResponse"          :   dhcp_parser.resolveDescribeDhcpOptionsResult
             "DescribeNetworkInterfacesResponse"    :   eni_parser.resolveDescribeNetworkInterfacesResult
             "DescribeInternetGatewaysResponse"     :   internetgateway_parser.resolveDescribeInternetGatewaysResult
             "DescribeRouteTablesResponse"          :   routetable_parser.resolveDescribeRouteTablesResult
             "DescribeSubnetsResponse"              :   subnet_parser.resolveDescribeSubnetsResult
             "DescribeVpcsResponse"                 :   vpc_parser.resolveDescribeVpcsResult
             "DescribeVpnConnectionsResponse"       :   vpn_parser.resolveDescribeVpnConnectionsResult
             "DescribeVpnGatewaysResponse"          :   vpngateway_parser.resolveDescribeVpnGatewaysResult
        }

        (responses[($.parseXML node[1]).documentElement.localName] node for node in result)

    #private (resolve result to vo )
    resolveResourceResult = ( result ) ->
        #resolve result
        

        #return vo
        resourceMap result

    #private (parser resource return)
    parserResourceReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveResourceResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserResourceReturn


    #///////////////// Parser for summary return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveSummaryResult = ( result ) ->
        #resolve result
        #summary_list = {}

        #summary_list[region] = {"stack" : (stack_parser.resolveInfoResult data['stack']), "app" : (resolveInfoResult data['app'])} for region, data in result
        
        #return vo
        result

    #private (parser summary return)
    parserSummaryReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveSummaryResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserSummaryReturn


    #############################################################
    #public
    parserCreateReturn                       : parserCreateReturn
    parserUpdateReturn                       : parserUpdateReturn
    parserRenameReturn                       : parserRenameReturn
    parserTerminateReturn                    : parserTerminateReturn
    parserStartReturn                        : parserStartReturn
    parserStopReturn                         : parserStopReturn
    parserRebootReturn                       : parserRebootReturn
    parserInfoReturn                         : parserInfoReturn
    parserResourceReturn                     : parserResourceReturn
    parserSummaryReturn                      : parserSummaryReturn

