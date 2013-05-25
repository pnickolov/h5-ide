#*************************************************************************************
#* Filename     : cloudwatch_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:05
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'cloudwatch_parser', 'result_vo' ], ( MC, cloudwatch_parser, result_vo ) ->

    URL = '/aws/cloudwatch/cloudwatch/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

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
                    result_vo.aws_result = parser result, return_code, param_ary

                    callback result_vo.aws_result

                error : ( result, return_code ) ->

                    result_vo.aws_result.return_code      = return_code
                    result_vo.aws_result.is_error         = true
                    result_vo.aws_result.error_message    = result.toString()

                    callback result_vo.aws_result
            }

        catch error
            console.log "cloudwatch." + method + " error:" + error.toString()


        true
    # end of send_request

    #def GetMetricStatistics(self, username, session_id, region_name,
    GetMetricStatistics = ( username, session_id, callback ) ->
        send_request "GetMetricStatistics", [ username, session_id ], cloudwatch_parser.parserGetMetricStatisticsReturn, callback
        true

    #def ListMetrics(self, username, session_id, region_name,
    ListMetrics = ( username, session_id, callback ) ->
        send_request "ListMetrics", [ username, session_id ], cloudwatch_parser.parserListMetricsReturn, callback
        true

    #def DescribeAlarmHistory(self, username, session_id, region_name,
    DescribeAlarmHistory = ( username, session_id, callback ) ->
        send_request "DescribeAlarmHistory", [ username, session_id ], cloudwatch_parser.parserDescribeAlarmHistoryReturn, callback
        true

    #def DescribeAlarms(self, username, session_id, region_name,
    DescribeAlarms = ( username, session_id, callback ) ->
        send_request "DescribeAlarms", [ username, session_id ], cloudwatch_parser.parserDescribeAlarmsReturn, callback
        true

    #def DescribeAlarmsForMetric(self, username, session_id, region_name,
    DescribeAlarmsForMetric = ( username, session_id, callback ) ->
        send_request "DescribeAlarmsForMetric", [ username, session_id ], cloudwatch_parser.parserDescribeAlarmsForMetricReturn, callback
        true


    #############################################################
    #public
    GetMetricStatistics          : GetMetricStatistics
    ListMetrics                  : ListMetrics
    DescribeAlarmHistory         : DescribeAlarmHistory
    DescribeAlarms               : DescribeAlarms
    DescribeAlarmsForMetric      : DescribeAlarmsForMetric

