define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'asl_DescribeAdjustmentTypes'            : { url:'/aws/autoscaling/',	method:'DescribeAdjustmentTypes',	params:['username', 'session_id', 'region_name']   },
		'asl_DescribeAutoScalingGroups'          : { url:'/aws/autoscaling/',	method:'DescribeAutoScalingGroups',	params:['username', 'session_id', 'region_name', 'group_names', 'max_records', 'next_token']   },
		'asl_DescribeAutoScalingInstances'       : { url:'/aws/autoscaling/',	method:'DescribeAutoScalingInstances',	params:['username', 'session_id', 'region_name', 'instance_ids', 'max_records', 'next_token']   },
		'asl_DescribeAutoScalingNotificationTypes' : { url:'/aws/autoscaling/',	method:'DescribeAutoScalingNotificationTypes',	params:['username', 'session_id', 'region_name']   },
		'asl_DescribeLaunchConfigurations'       : { url:'/aws/autoscaling/',	method:'DescribeLaunchConfigurations',	params:['username', 'session_id', 'region_name', 'config_names', 'max_records', 'next_token']   },
		'asl_DeleteLaunchConfiguration'          : { url:'/aws/autoscaling/',	method:'DeleteLaunchConfiguration',	params:['username', 'session_id', 'region_name', 'config_name']   },
		'asl_DescribeMetricCollectionTypes'      : { url:'/aws/autoscaling/',	method:'DescribeMetricCollectionTypes',	params:['username', 'session_id', 'region_name']   },
		'asl_DescribeNotificationConfigurations' : { url:'/aws/autoscaling/',	method:'DescribeNotificationConfigurations',	params:['username', 'session_id', 'region_name', 'group_names', 'max_records', 'next_token']   },
		'asl_DescribePolicies'                   : { url:'/aws/autoscaling/',	method:'DescribePolicies',	params:['username', 'session_id', 'region_name', 'group_name', 'policy_names', 'max_records', 'next_token']   },
		'asl_DescribeScalingActivities'          : { url:'/aws/autoscaling/',	method:'DescribeScalingActivities',	params:['username', 'session_id', 'region_name', 'group_name', 'activity_ids', 'max_records', 'next_token']   },
		'asl_DescribeScalingProcessTypes'        : { url:'/aws/autoscaling/',	method:'DescribeScalingProcessTypes',	params:['username', 'session_id', 'region_name']   },
		'asl_DescribeScheduledActions'           : { url:'/aws/autoscaling/',	method:'DescribeScheduledActions',	params:['username', 'session_id', 'region_name', 'group_name', 'action_names', 'start_time', 'end_time', 'max_records', 'next_token']   },
		'asl_DescribeTags'                       : { url:'/aws/autoscaling/',	method:'DescribeTags',	params:['username', 'session_id', 'region_name', 'filters', 'max_records', 'next_token']   },
		'asl_CreateAutoScalingGroup'             : { url:'/aws/autoscaling/',	method:'CreateAutoScalingGroup',	params:['username', 'session_id', 'region_name', 'group_name', 'min_size', 'max_size', 'availability_zones', 'default_cooldown', 'desired_capacity', 'health_check_period', 'health_check_type', 'instance_id', 'launch_config', 'load_balancers', 'placement_group', 'tags', 'termination_policies', 'vpc_zone_identifier']   },
		'asl_CreateLaunchConfiguration'          : { url:'/aws/autoscaling/',	method:'CreateLaunchConfiguration',	params:['username', 'session_id', 'region_name', 'config_name', 'associate_public_ip', 'block_device_mappings', 'ebs_optimized', 'iam_instance_profile', 'image_id', 'instance_id', 'instance_monitoring', 'instance_type', 'kernel_id', 'key_name', 'placement_tenancy', 'ramdisk_id', 'security_groups', 'spot_price', 'user_data']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
