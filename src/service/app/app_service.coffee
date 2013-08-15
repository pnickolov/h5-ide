#*************************************************************************************
#* Filename     : app_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:08
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

    URL = '/app/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "app." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
                    forge_result = {}
                    forge_result = parser result, return_code, param_ary

                    callback forge_result

                error : ( result, return_code ) ->

                    forge_result = {}
                    forge_result.return_code      = return_code
                    forge_result.is_error         = true
                    forge_result.error_message    = result.toString()

                    callback forge_result
            }

        catch error
            console.log "app." + api_name + " error:" + error.toString()


        true
    # end of send_request

    resolveAppRequest = (result) ->
        app_request = {}

        #resolve result
        app_request.id               =   result[0]
        app_request.state            =   result[1]
        app_request.brief            =   result[2]
        app_request.time_submit      =   result[3]
        app_request.rid              =   result[4]

        #return vo
        app_request

    #///////////////// Parser for create return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveCreateResult = ( result ) ->
        #resolve result


        #return vo
        resolveAppRequest result

    #private (parser create return)
    parserCreateReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveCreateResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

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
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveUpdateResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

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
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveRenameResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

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
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveTerminateResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

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
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveStartResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

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
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveStopResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

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
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveRebootResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

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
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveInfoResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserInfoReturn


    #///////////////// Parser for getKey return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetKeyResult = ( result ) ->

        #return vo
        result

    #private (parser info return)
    parserGetKeyReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveGetKeyResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserInfoReturn


    #///////////////// Parser for resource return (need resolve) /////////////////
    #resourceMap = ( result ) ->
    #    responses = {
    #         "DescribeVolumesResponse"              :   ebs_parser.resolveDescribeVolumesResult
    #         "DescribeSnapshotsResponse"            :   ebs_parser.resolveDescribeSnapshotsResult
    #         "DescribeAddressesResponse"            :   eip_parser.resolveDescribeAddressesResult
    #         "DescribeInstancesResponse"            :   instance_parser.resolveDescribeInstancesResult
    #         "DescribeKeyPairsResponse"             :   keypair_parser.resolveDescribeKeyPairsResult
    #         "DescribeSecurityGroupsResponse"       :   securitygroup_parser.resolveDescribeSecurityGroupsResult
    #         "DescribeLoadBalancersResponse"        :   elb_parser.resolveDescribeLoadBalancersResult
    #         "DescribeNetworkAclsResponse"          :   acl_parser.resolveDescribeNetworkAclsResult
    #         "DescribeCustomerGatewaysResponse"     :   customergateway_parser.resolveDescribeCustomerGatewaysResult
    #         "DescribeDhcpOptionsResponse"          :   dhcp_parser.resolveDescribeDhcpOptionsResult
    #         "DescribeNetworkInterfacesResponse"    :   eni_parser.resolveDescribeNetworkInterfacesResult
    #         "DescribeInternetGatewaysResponse"     :   internetgateway_parser.resolveDescribeInternetGatewaysResult
    #         "DescribeRouteTablesResponse"          :   routetable_parser.resolveDescribeRouteTablesResult
    #         "DescribeSubnetsResponse"              :   subnet_parser.resolveDescribeSubnetsResult
    #         "DescribeVpcsResponse"                 :   vpc_parser.resolveDescribeVpcsResult
    #         "DescribeVpnConnectionsResponse"       :   vpn_parser.resolveDescribeVpnConnectionsResult
    #         "DescribeVpnGatewaysResponse"          :   vpngateway_parser.resolveDescribeVpnGatewaysResult
    #    }

    #    (responses[($.parseXML node[1]).documentElement.localName] node for node in result)

    #private (resolve result to vo )
    resolveResourceResult = ( result ) ->
        #resolve result


        #return vo
        aws_parser.resourceMap result

    #private (parser resource return)
    parserResourceReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveResourceResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

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
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveSummaryResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserSummaryReturn


    #///////////////// Parser for list return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveListResult = ( result ) ->
        #resolve result
        app_list = {}
        for vo in result
            if app_list[vo.region] == undefined
                app_list[vo.region]=[]

            app_list[vo.region].push vo

        #return vo
        app_list

    #private (parser list return)
    parserListReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveListResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserListReturn


    #///////////////// Parser for getKey return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetKeyResult = ( result ) ->
        #resolve result
        result

    #private (parser list return)
    parseGetKeyReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveGetKeyResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserListReturn


    #############################################################

    #def create(self, username, session_id, region_name, spec):
    create = ( src, username, session_id, region_name, spec, callback ) ->
        send_request "create", src, [ username, session_id, region_name, spec ], parserCreateReturn, callback
        true

    #def update(self, username, session_id, region_name, spec, app_id):
    update = ( src, username, session_id, region_name, spec, app_id, callback ) ->
        send_request "update", src, [ username, session_id, region_name, spec, app_id ], parserUpdateReturn, callback
        true

    #def rename(self, username, session_id, region_name, app_id, new_name, app_name=None):
    rename = ( src, username, session_id, region_name, app_id, new_name, app_name=null, callback ) ->
        send_request "rename", src, [ username, session_id, region_name, app_id, new_name, app_name ], parserRenameReturn, callback
        true

    #def terminate(self, username, session_id, region_name, app_id, app_name=None):
    terminate = ( src, username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "terminate", src, [ username, session_id, region_name, app_id, app_name ], parserTerminateReturn, callback
        true

    #def start(self, username, session_id, region_name, app_id, app_name=None):
    start = ( src, username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "start", src, [ username, session_id, region_name, app_id, app_name ], parserStartReturn, callback
        true

    #def stop(self, username, session_id, region_name, app_id, app_name=None):
    stop = ( src, username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "stop", src, [ username, session_id, region_name, app_id, app_name ], parserStopReturn, callback
        true

    #def reboot(self, username, session_id, region_name, app_id, app_name=None):
    reboot = ( src, username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "reboot", src, [ username, session_id, region_name, app_id, app_name ], parserRebootReturn, callback
        true

    #def info(self, username, session_id, region_name, app_ids=None):
    info = ( src, username, session_id, region_name, app_ids=null, callback ) ->
        send_request "info", src, [ username, session_id, region_name, app_ids ], parserInfoReturn, callback
        true

    #def list(self, username, session_id, region_name, app_ids=None):
    list = ( src, username, session_id, region_name, app_ids=null, callback ) ->
        send_request "list", src, [ username, session_id, region_name, app_ids ], parserListReturn, callback
        true

    #def resource(self, username, session_id, region_name, app_id):
    resource = ( src, username, session_id, region_name, app_id, callback ) ->
        send_request "resource", src, [ username, session_id, region_name, app_id ], parserResourceReturn, callback
        true

    #def summary(self, username, session_id, region_name=None):
    summary = ( src, username, session_id, region_name=null, callback ) ->
        send_request "summary", src, [ username, session_id, region_name ], parserSummaryReturn, callback
        true

    #def getKey(self, username, session_id, region_name, app_id):
    getKey = ( src, username, session_id, region_name, app_id, callback) ->
        send_request "getKey", src, [ username, session_id, region_name, app_id ], parseGetKeyReturn, callback


    #############################################################
    #public
    create                       : create
    update                       : update
    rename                       : rename
    terminate                    : terminate
    start                        : start
    stop                         : stop
    reboot                       : reboot
    info                         : info
    list                         : list
    resource                     : resource
    summary                      : summary
    getKey                       : getKey

