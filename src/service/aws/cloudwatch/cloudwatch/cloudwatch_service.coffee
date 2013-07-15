#*************************************************************************************
#* Filename     : cloudwatch_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:12
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

    URL = '/aws/cloudwatch/cloudwatch/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "cloudwatch." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
                    aws_result = {}
                    aws_result = parser result, return_code, param_ary

                    callback aws_result

                error : ( result, return_code ) ->

                    aws_result = {}
                    aws_result.return_code      = return_code
                    aws_result.is_error         = true
                    aws_result.error_message    = result.toString()

                    callback aws_result
            }

        catch error
            console.log "cloudwatch." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #///////////////// Parser for GetMetricStatistics return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetMetricStatisticsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser GetMetricStatistics return)
    parserGetMetricStatisticsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveGetMetricStatisticsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserGetMetricStatisticsReturn


    #///////////////// Parser for ListMetrics return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveListMetricsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser ListMetrics return)
    parserListMetricsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveListMetricsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserListMetricsReturn


    #///////////////// Parser for DescribeAlarmHistory return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAlarmHistoryResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeAlarmHistory return)
    parserDescribeAlarmHistoryReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeAlarmHistoryResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeAlarmHistoryReturn


    #///////////////// Parser for DescribeAlarms return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAlarmsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeAlarms return)
    parserDescribeAlarmsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeAlarmsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeAlarmsReturn


    #///////////////// Parser for DescribeAlarmsForMetric return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAlarmsForMetricResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeAlarmsForMetric return)
    parserDescribeAlarmsForMetricReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeAlarmsForMetricResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeAlarmsForMetricReturn


    #############################################################

    #def GetMetricStatistics(self, username, session_id, region_name,
    GetMetricStatistics = ( src, username, session_id, callback ) ->
        send_request "GetMetricStatistics", src, [ username, session_id ], parserGetMetricStatisticsReturn, callback
        true

    #def ListMetrics(self, username, session_id, region_name,
    ListMetrics = ( src, username, session_id, callback ) ->
        send_request "ListMetrics", src, [ username, session_id ], parserListMetricsReturn, callback
        true

    #def DescribeAlarmHistory(self, username, session_id, region_name,
    DescribeAlarmHistory = ( src, username, session_id, callback ) ->
        send_request "DescribeAlarmHistory", src, [ username, session_id ], parserDescribeAlarmHistoryReturn, callback
        true

    #def DescribeAlarms(self, username, session_id, region_name,
    DescribeAlarms = ( src, username, session_id, callback ) ->
        send_request "DescribeAlarms", src, [ username, session_id ], parserDescribeAlarmsReturn, callback
        true

    #def DescribeAlarmsForMetric(self, username, session_id, region_name,
    DescribeAlarmsForMetric = ( src, username, session_id, callback ) ->
        send_request "DescribeAlarmsForMetric", src, [ username, session_id ], parserDescribeAlarmsForMetricReturn, callback
        true


    #############################################################
    #public
    GetMetricStatistics          : GetMetricStatistics
    ListMetrics                  : ListMetrics
    DescribeAlarmHistory         : DescribeAlarmHistory
    DescribeAlarms               : DescribeAlarms
    DescribeAlarmsForMetric      : DescribeAlarmsForMetric

