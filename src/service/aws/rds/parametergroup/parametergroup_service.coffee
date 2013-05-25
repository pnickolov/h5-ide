#*************************************************************************************
#* Filename     : parametergroup_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:19
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'parametergroup_parser', 'result_vo' ], ( MC, parametergroup_parser, result_vo ) ->

    URL = '/aws/rds/parametergroup/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "parametergroup." + api_name + " callback is null"
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
            console.log "parametergroup." + method + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeDBParameterGroups(self, username, session_id, region_name, pg_name=None, marker=None, max_records=None):
    DescribeDBParameterGroups = ( username, session_id, region_name, pg_name=null, marker=null, max_records=null, callback ) ->
        send_request "DescribeDBParameterGroups", [ username, session_id, region_name, pg_name, marker, max_records ], parametergroup_parser.parserDescribeDBParameterGroupsReturn, callback
        true

    #def DescribeDBParameters(self, username, session_id, region_name, pg_name, source=None, marker=None, max_records=None):
    DescribeDBParameters = ( username, session_id, region_name, pg_name, source=null, marker=null, max_records=null, callback ) ->
        send_request "DescribeDBParameters", [ username, session_id, region_name, pg_name, source, marker, max_records ], parametergroup_parser.parserDescribeDBParametersReturn, callback
        true


    #############################################################
    #public
    DescribeDBParameterGroups    : DescribeDBParameterGroups
    DescribeDBParameters         : DescribeDBParameters

