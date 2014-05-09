define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'asl_DescribeAdjustmentTypes'            : { url:'/aws/autoscaling/',	method:'DescribeAdjustmentTypes',	params:['username', 'session_id', 'region_name']   },
		'asl_DescribeAutoScalingGroups'          : { url:'/aws/autoscaling/',	method:'DescribeAutoScalingGroups',	params:['username', 'session_id', 'region_name', 'group_names', 'max_records', 'next_token']   },
		'asl_DescribeAutoScalingInstances'       : { url:'/aws/autoscaling/',	method:'DescribeAutoScalingInstances',	params:['username', 'session_id', 'region_name', 'instance_ids', 'max_records', 'next_token']   },
		'asl_DescribeAutoScalingNotificationTypes' : { url:'/aws/autoscaling/',	method:'DescribeAutoScalingNotificationTypes',	params:['username', 'session_id', 'region_name']   },
		'asl_DescribeLaunchConfigurations'       : { url:'/aws/autoscaling/',	method:'DescribeLaunchConfigurations',	params:['username', 'session_id', 'region_name', 'config_names', 'max_records', 'next_token']   },
		'asl_DescribeMetricCollectionTypes'      : { url:'/aws/autoscaling/',	method:'DescribeMetricCollectionTypes',	params:['username', 'session_id', 'region_name']   },
		'asl_DescribeNotificationConfigurations' : { url:'/aws/autoscaling/',	method:'DescribeNotificationConfigurations',	params:['username', 'session_id', 'region_name', 'group_names', 'max_records', 'next_token']   },
		'asl_DescribePolicies'                   : { url:'/aws/autoscaling/',	method:'DescribePolicies',	params:['username', 'session_id', 'region_name', 'group_name', 'policy_names', 'max_records', 'next_token']   },
		'asl_DescribeScalingActivities'          : { url:'/aws/autoscaling/',	method:'DescribeScalingActivities',	params:['username', 'session_id', 'region_name', 'group_name', 'activity_ids', 'max_records', 'next_token']   },
		'asl_DescribeScalingProcessTypes'        : { url:'/aws/autoscaling/',	method:'DescribeScalingProcessTypes',	params:['username', 'session_id', 'region_name']   },
		'asl_DescribeScheduledActions'           : { url:'/aws/autoscaling/',	method:'DescribeScheduledActions',	params:['username', 'session_id', 'region_name', 'group_name', 'action_names', 'start_time', 'end_time', 'max_records', 'next_token']   },
		'asl_DescribeTags'                       : { url:'/aws/autoscaling/',	method:'DescribeTags',	params:['username', 'session_id', 'region_name', 'filters', 'max_records', 'next_token']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
