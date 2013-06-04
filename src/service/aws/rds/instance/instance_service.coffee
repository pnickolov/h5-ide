#*************************************************************************************
#* Filename     : instance_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:22
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'instance_parser', 'result_vo' ], ( MC, instance_parser, result_vo ) ->

    URL = '/aws/rds/instance/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "instance." + api_name + " callback is null"
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
            console.log "instance." + method + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeDBInstances(self, username, session_id, region_name, instance_id=None, marker=None, max_records=None):
    DescribeDBInstances = ( src, username, session_id, region_name, instance_id=null, marker=null, max_records=null, callback ) ->
        send_request "DescribeDBInstances", src, [ username, session_id, region_name, instance_id, marker, max_records ], instance_parser.parserDescribeDBInstancesReturn, callback
        true


    #############################################################
    #public
    DescribeDBInstances          : DescribeDBInstances

