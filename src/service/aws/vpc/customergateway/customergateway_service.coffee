#*************************************************************************************
#* Filename     : customergateway_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:22
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'customergateway_parser', 'result_vo' ], ( MC, customergateway_parser, result_vo ) ->

    URL = '/aws/vpc/cgw/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "customergateway." + api_name + " callback is null"
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
            console.log "customergateway." + method + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeCustomerGateways(self, username, session_id, region_name, gw_ids=None, filters=None):
    DescribeCustomerGateways = ( username, session_id, region_name, gw_ids=null, filters=null, callback ) ->
        send_request "DescribeCustomerGateways", [ username, session_id, region_name, gw_ids, filters ], customergateway_parser.parserDescribeCustomerGatewaysReturn, callback
        true


    #############################################################
    #public
    DescribeCustomerGateways     : DescribeCustomerGateways

