#*************************************************************************************
#* Filename     : vpn_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:24
#* Description  : parser return data of vpn
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'vpn_vo', 'result_vo', 'constant' ], ( vpn_vo, result_vo, constant ) ->

    resolvedObjectToArray = ( objs ) ->

        if objs.constructor == Array

            for obj in objs

                obj = resolvedObjectToArray obj

        if objs.constructor == Object

            if $.isEmptyObject objs

                objs = null

            for key, value of objs

                if key == 'item' and value.constructor == Object

                    tmp = []

                    tmp.push resolvedObjectToArray value

                    objs[key] = tmp

                else if value.constructor == Object or value.constructor == Array

                    objs[key] = resolvedObjectToArray value

        objs
    #///////////////// Parser for DescribeVpnConnections return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeVpnConnectionsResult = ( result ) ->
        #return

        result_set = ($.xml2json ($.parseXML result[1])).DescribeVpnConnectionsResponse.vpnConnectionSet

        result = resolvedObjectToArray result_set

        if result?.item?

            return result.item

        else
        
            return null

    #private (parser DescribeVpnConnections return)
    parserDescribeVpnConnectionsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeVpnConnectionsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeVpnConnectionsReturn


    #############################################################
    #public
    parserDescribeVpnConnectionsReturn       : parserDescribeVpnConnectionsReturn
    resolveDescribeVpnConnectionsResult      : resolveDescribeVpnConnectionsResult
