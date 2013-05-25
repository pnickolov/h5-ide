#*************************************************************************************
#* Filename     : eni_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:22
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'eni_parser', 'result_vo' ], ( MC, eni_parser, result_vo ) ->

    URL = '/aws/vpc/eni/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "eni." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    result_vo.aws_result = parser result, return_code, param_ary

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result
            }

        catch error
            console.log "eni." + method + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeNetworkInterfaces(self, username, session_id, region_name, eni_ids=None, filters=None):
    DescribeNetworkInterfaces = ( username, session_id, region_name, eni_ids=null, filters=null, callback ) ->
        send_request "DescribeNetworkInterfaces", [ username, session_id, region_name, eni_ids, filters ], eni_parser.parserDescribeNetworkInterfacesReturn, callback
        true

    #def DescribeNetworkInterfaceAttribute(self, username, session_id, region_name, eni_id, attribute):
    DescribeNetworkInterfaceAttribute = ( username, session_id, region_name, eni_id, attribute, callback ) ->
        send_request "DescribeNetworkInterfaceAttribute", [ username, session_id, region_name, eni_id, attribute ], eni_parser.parserDescribeNetworkInterfaceAttributeReturn, callback
        true


    #############################################################
    #public
    DescribeNetworkInterfaces    : DescribeNetworkInterfaces
    DescribeNetworkInterfaceAttribute : DescribeNetworkInterfaceAttribute

