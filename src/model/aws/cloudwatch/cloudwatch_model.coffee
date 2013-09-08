#*************************************************************************************
#* Filename     : cloudwatch_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:44
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'cloudwatch_service', 'base_model' ], ( Backbone, _, cloudwatch_service, base_model ) ->

    CloudWatchModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #GetMetricStatistics api (define function)
        GetMetricStatistics : ( src, username, session_id, region_name, metric_name, namespace, start_time, end_time, period, unit, statistics, dimensions=null ) ->

            me = this

            src.model = me

            cloudwatch_service.GetMetricStatistics src, username, session_id, region_name, metric_name, namespace, start_time, end_time, period, unit, statistics, dimensions, ( aws_result ) ->

                if !aws_result.is_error
                #GetMetricStatistics succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'CW__GET_METRIC_STATS_RETURN', aws_result

                else
                #GetMetricStatistics failed

                    console.log 'cloudwatch.GetMetricStatistics failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #ListMetrics api (define function)
        ListMetrics : ( src, username, session_id, region_name, metric_name=null, namespace=null, dimensions=null, next_token=null ) ->

            me = this

            src.model = me

            cloudwatch_service.ListMetrics src, username, session_id, region_name, metric_name, namespace, dimensions, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #ListMetrics succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'CW__LST_METRICS_RETURN', aws_result

                else
                #ListMetrics failed

                    console.log 'cloudwatch.ListMetrics failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeAlarmHistory api (define function)
        DescribeAlarmHistory : ( src, username, session_id, region_name, alarm_name=null, start_date=null, end_date=null, history_item_type=null, max_records=null, next_token=null ) ->

            me = this

            src.model = me

            cloudwatch_service.DescribeAlarmHistory src, username, session_id, region_name, alarm_name, start_date, end_date, history_item_type, max_records, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAlarmHistory succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'CW__DESC_ALM_HIST_RETURN', aws_result

                else
                #DescribeAlarmHistory failed

                    console.log 'cloudwatch.DescribeAlarmHistory failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeAlarms api (define function)
        DescribeAlarms : ( src, username, session_id, region_name, alarm_names=null, alarm_name_prefix=null, action_prefix=null, state_value=null, max_records=null, next_token=null ) ->

            me = this

            src.model = me

            cloudwatch_service.DescribeAlarms src, username, session_id, region_name, alarm_names, alarm_name_prefix, action_prefix, state_value, max_records, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAlarms succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'CW__DESC_ALMS_RETURN', aws_result

                else
                #DescribeAlarms failed

                    console.log 'cloudwatch.DescribeAlarms failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeAlarmsForMetric api (define function)
        DescribeAlarmsForMetric : ( src, username, session_id, region_name, metric_name, namespace, dimension_names=null, period=null, statistic=null, unit=null ) ->

            me = this

            src.model = me

            cloudwatch_service.DescribeAlarmsForMetric src, username, session_id, region_name, metric_name, namespace, dimension_names, period, statistic, unit, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAlarmsForMetric succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'CW__DESC_ALMS_FOR_METRIC_RETURN', aws_result

                else
                #DescribeAlarmsForMetric failed

                    console.log 'cloudwatch.DescribeAlarmsForMetric failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    cloudwatch_model = new CloudWatchModel()

    #public (exposes methods)
    cloudwatch_model

