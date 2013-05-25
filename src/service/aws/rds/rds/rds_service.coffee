#*************************************************************************************
#* Filename     : rds_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:19
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'rds_parser', 'result_vo' ], ( MC, rds_parser, result_vo ) ->

    URL = '/aws/rds/rds/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "rds." + api_name + " callback is null"
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
            console.log "rds." + method + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeDBEngineVersions(self, username, session_id, region_name,
    DescribeDBEngineVersions = ( username, callback ) ->
        send_request "DescribeDBEngineVersions", [ username ], rds_parser.parserDescribeDBEngineVersionsReturn, callback
        true

    #def DescribeOrderableDBInstanceOptions(self, username, session_id, region_name,
    DescribeOrderableDBInstanceOptions = ( username, callback ) ->
        send_request "DescribeOrderableDBInstanceOptions", [ username ], rds_parser.parserDescribeOrderableDBInstanceOptionsReturn, callback
        true

    #def DescribeEngineDefaultParameters(self, username, session_id, region_name, pg_family, marker=None, max_records=None):
    DescribeEngineDefaultParameters = ( username, session_id, region_name, pg_family, marker=null, max_records=null, callback ) ->
        send_request "DescribeEngineDefaultParameters", [ username, session_id, region_name, pg_family, marker, max_records ], rds_parser.parserDescribeEngineDefaultParametersReturn, callback
        true

    #def DescribeEvents(self, username, session_id, region_name,
    DescribeEvents = ( username, session_id, callback ) ->
        send_request "DescribeEvents", [ username, session_id ], rds_parser.parserDescribeEventsReturn, callback
        true


    #############################################################
    #public
    DescribeDBEngineVersions     : DescribeDBEngineVersions
    DescribeOrderableDBInstanceOptions : DescribeOrderableDBInstanceOptions
    DescribeEngineDefaultParameters : DescribeEngineDefaultParameters
    DescribeEvents               : DescribeEvents

