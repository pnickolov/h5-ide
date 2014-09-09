define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'ow_DescribeApps'                        : { type:'aws', url:'/aws/opsworks/',	method:'DescribeApps',	params:['username', 'session_id', 'region_name', 'app_ids', 'stack_id']   },
		'ow_DescribeStacks'                      : { type:'aws', url:'/aws/opsworks/',	method:'DescribeStacks',	params:['username', 'session_id', 'region_name', 'stack_ids']   },
		'ow_DescribeCommands'                    : { type:'aws', url:'/aws/opsworks/',	method:'DescribeCommands',	params:['username', 'session_id', 'region_name', 'command_ids', 'deployment_id', 'instance_id']   },
		'ow_DescribeDeployments'                 : { type:'aws', url:'/aws/opsworks/',	method:'DescribeDeployments',	params:['username', 'session_id', 'region_name', 'app_id', 'deployment_ids', 'stack_id']   },
		'ow_DescribeElasticIps'                  : { type:'aws', url:'/aws/opsworks/',	method:'DescribeElasticIps',	params:['username', 'session_id', 'region_name', 'instance_id', 'ips']   },
		'ow_DescribeInstances'                   : { type:'aws', url:'/aws/opsworks/',	method:'DescribeInstances',	params:['username', 'session_id', 'region_name', 'app_id', 'instance_ids', 'layer_id', 'stack_id']   },
		'ow_DescribeLayers'                      : { type:'aws', url:'/aws/opsworks/',	method:'DescribeLayers',	params:['username', 'session_id', 'region_name', 'stack_id', 'layer_ids']   },
		'ow_DescribeLoadBasedAutoScaling'        : { type:'aws', url:'/aws/opsworks/',	method:'DescribeLoadBasedAutoScaling',	params:['username', 'session_id', 'region_name', 'layer_ids']   },
		'ow_DescribePermissions'                 : { type:'aws', url:'/aws/opsworks/',	method:'DescribePermissions',	params:['username', 'session_id', 'region_name', 'iam_user_arn', 'stack_id']   },
		'ow_DescribeRaidArrays'                  : { type:'aws', url:'/aws/opsworks/',	method:'DescribeRaidArrays',	params:['username', 'session_id', 'region_name', 'instance_id', 'raid_array_ids']   },
		'ow_DescribeServiceErrors'               : { type:'aws', url:'/aws/opsworks/',	method:'DescribeServiceErrors',	params:['username', 'session_id', 'region_name', 'instance_id', 'service_error_ids', 'stack_id']   },
		'ow_DescribeTimeBasedAutoScaling'        : { type:'aws', url:'/aws/opsworks/',	method:'DescribeTimeBasedAutoScaling',	params:['username', 'session_id', 'region_name', 'instance_ids']   },
		'ow_DescribeUserProfiles'                : { type:'aws', url:'/aws/opsworks/',	method:'DescribeUserProfiles',	params:['username', 'session_id', 'region_name', 'iam_user_arns']   },
		'ow_DescribeVolumes'                     : { type:'aws', url:'/aws/opsworks/',	method:'DescribeVolumes',	params:['username', 'session_id', 'region_name', 'instance_id', 'raid_array_id', 'volume_ids']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
