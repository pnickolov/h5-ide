#*************************************************************************************
#* Filename     : reservedinstance_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:23
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'reservedinstance_parser', 'result_vo' ], ( MC, reservedinstance_parser, result_vo ) ->

    URL = '/aws/rds/reservedinstance/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "reservedinstance." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, src
                    result_vo.aws_result = parser result, return_code, param_ary

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result
            }

        catch error
            console.log "reservedinstance." + method + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeReservedDBInstances(self, username, session_id, region_name,
    DescribeReservedDBInstances = ( src, username, session_id, callback ) ->
        send_request "DescribeReservedDBInstances", src, [ username, session_id ], reservedinstance_parser.parserDescribeReservedDBInstancesReturn, callback
        true

    #def DescribeReservedDBInstancesOfferings(self, username, session_id, region_name,
    DescribeReservedDBInstancesOfferings = ( src, username, session_id, callback ) ->
        send_request "DescribeReservedDBInstancesOfferings", src, [ username, session_id ], reservedinstance_parser.parserDescribeReservedDBInstancesOfferingsReturn, callback
        true


    #############################################################
    #public
    DescribeReservedDBInstances  : DescribeReservedDBInstances
    DescribeReservedDBInstancesOfferings : DescribeReservedDBInstancesOfferings

