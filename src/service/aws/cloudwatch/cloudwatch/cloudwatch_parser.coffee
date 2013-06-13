#*************************************************************************************
#* Filename     : cloudwatch_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:05
#* Description  : parser return data of cloudwatch
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'cloudwatch_vo', 'result_vo', 'constant' ], ( cloudwatch_vo, result_vo, constant ) ->


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
    #public
    parserGetMetricStatisticsReturn          : parserGetMetricStatisticsReturn
    parserListMetricsReturn                  : parserListMetricsReturn
    parserDescribeAlarmHistoryReturn         : parserDescribeAlarmHistoryReturn
    parserDescribeAlarmsReturn               : parserDescribeAlarmsReturn
    parserDescribeAlarmsForMetricReturn      : parserDescribeAlarmsForMetricReturn

