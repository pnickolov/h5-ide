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

define [ 'MC', 'cloudwatch_parser', 'result_vo' ], ( MC, cloudwatch_parser, result_vo ) ->

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
            console.log "cloudwatch." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def GetMetricStatistics(self, username, session_id, region_name,
    GetMetricStatistics = ( src, username, session_id, callback ) ->
        send_request "GetMetricStatistics", src, [ username, session_id ], cloudwatch_parser.parserGetMetricStatisticsReturn, callback
        true

    #def ListMetrics(self, username, session_id, region_name,
    ListMetrics = ( src, username, session_id, callback ) ->
        send_request "ListMetrics", src, [ username, session_id ], cloudwatch_parser.parserListMetricsReturn, callback
        true

    #def DescribeAlarmHistory(self, username, session_id, region_name,
    DescribeAlarmHistory = ( src, username, session_id, callback ) ->
        send_request "DescribeAlarmHistory", src, [ username, session_id ], cloudwatch_parser.parserDescribeAlarmHistoryReturn, callback
        true

    #def DescribeAlarms(self, username, session_id, region_name,
    DescribeAlarms = ( src, username, session_id, callback ) ->
        send_request "DescribeAlarms", src, [ username, session_id ], cloudwatch_parser.parserDescribeAlarmsReturn, callback
        true

    #def DescribeAlarmsForMetric(self, username, session_id, region_name,
    DescribeAlarmsForMetric = ( src, username, session_id, callback ) ->
        send_request "DescribeAlarmsForMetric", src, [ username, session_id ], cloudwatch_parser.parserDescribeAlarmsForMetricReturn, callback
        true


    #############################################################
    #public
    GetMetricStatistics          : GetMetricStatistics
    ListMetrics                  : ListMetrics
    DescribeAlarmHistory         : DescribeAlarmHistory
    DescribeAlarms               : DescribeAlarms
    DescribeAlarmsForMetric      : DescribeAlarmsForMetric

