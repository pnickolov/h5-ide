define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'clw_GetMetricStatistics'                : { type:'aws', url:'/aws/cloudwatch/',	method:'GetMetricStatistics',	params:['username', 'session_id', 'region_name', 'metric_name', 'namespace', 'start_time', 'end_time', 'period', 'statistics', 'unit', 'dimensions']   },
		'clw_ListMetrics'                        : { type:'aws', url:'/aws/cloudwatch/',	method:'ListMetrics',	params:['username', 'session_id', 'region_name', 'metric_name', 'namespace', 'dimensions', 'next_token']   },
		'clw_DescribeAlarmHistory'               : { type:'aws', url:'/aws/cloudwatch/',	method:'DescribeAlarmHistory',	params:['username', 'session_id', 'region_name', 'alarm_name', 'start_date', 'end_date', 'history_item_type', 'max_records', 'next_token']   },
		'clw_DescribeAlarms'                     : { type:'aws', url:'/aws/cloudwatch/',	method:'DescribeAlarms',	params:['username', 'session_id', 'region_name', 'alarm_names', 'alarm_name_prefix', 'action_prefix', 'state_value', 'max_records', 'next_token']   },
		'clw_DescribeAlarmsForMetric'            : { type:'aws', url:'/aws/cloudwatch/',	method:'DescribeAlarmsForMetric',	params:['username', 'session_id', 'region_name', 'metric_name', 'namespace', 'dimension_names', 'period', 'statistic', 'unit']   },
		'clw_DeleteAlarms'                       : { type:'aws', url:'/aws/cloudwatch/',	method:'DeleteAlarms',	params:['username', 'session_id', 'region_name', 'alarm_names']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
