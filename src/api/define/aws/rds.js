define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'rds_DescribeDBEngineVersions'           : { url:'/aws/rds/',	method:'DescribeDBEngineVersions',	params:['username', 'session_id', 'region_name', 'engine', 'engine_version', 'param_group_family', 'default_only', 'list_character_sets', 'filters', 'marker', 'max_records']   },
		'rds_DescribeEngineDefaultParameters'    : { url:'/aws/rds/',	method:'DescribeEngineDefaultParameters',	params:['username', 'session_id', 'region_name', 'param_group_family', 'filters', 'marker', 'max_records']   },
		'rds_DescribeEventCategories'            : { url:'/aws/rds/',	method:'DescribeEventCategories',	params:['username', 'session_id', 'region_name', 'source_type', 'filters']   },
		'rds_DescribeEventSubscriptions'         : { url:'/aws/rds/',	method:'DescribeEventSubscriptions',	params:['username', 'session_id', 'region_name', 'sub_scription', 'filters', 'marker', 'max_records']   },
		'rds_DescribeOrderableDBInstanceOptions' : { url:'/aws/rds/',	method:'DescribeOrderableDBInstanceOptions',	params:['username', 'session_id', 'region_name', 'engine', 'engine_version', 'instance_class', 'license_model', 'marker', 'max_records']   },
		'rds_DescribeEvents'                     : { url:'/aws/rds/',	method:'DescribeEvents',	params:['username', 'session_id', 'region_name', 'source_id', 'source_type', 'event_categories', 'duration', 'start_time', 'end_time', 'filters', 'marker', 'max_records']   },
		'rds_ins_DescribeDBInstances'            : { url:'/aws/rds/instance/',	method:'DescribeDBInstances',	params:['username', 'session_id', 'region_name', 'id', 'filters', 'marker', 'max_records']   },
		'rds_ins_DescribeDBLogFiles'             : { url:'/aws/rds/instance/',	method:'DescribeDBLogFiles',	params:['username', 'session_id', 'region_name', 'id', 'filename_contains', 'file_size', 'file_last_written', 'filters', 'marker', 'max_records']   },
		'rds_og_DescribeOptionGroupOptions'      : { url:'/aws/rds/optiongroup/',	method:'DescribeOptionGroupOptions',	params:['username', 'session_id', 'region_name', 'engine_name', 'major_engine_version', 'filters', 'marker', 'max_records']   },
		'rds_og_DescribeOptionGroups'            : { url:'/aws/rds/optiongroup/',	method:'DescribeOptionGroups',	params:['username', 'session_id', 'region_name', 'option_group', 'engine_name', 'major_engine_version', 'filters', 'marker', 'max_records']   },
		'rds_og_DescribeOrderableDBInstanceOptions' : { url:'/aws/rds/optiongroup/',	method:'DescribeOrderableDBInstanceOptions',	params:['username', 'session_id', 'region_name', 'engine_name', 'engine_version', 'instance_class', 'license_model', 'vpc', 'filters', 'marker', 'max_records']   },
		'rds_pg_DescribeDBParameterGroups'       : { url:'/aws/rds/parametergroup/',	method:'DescribeDBParameterGroups',	params:['username', 'session_id', 'region_name', 'param_group', 'filters', 'marker', 'max_records']   },
		'rds_pg_DescribeDBParameters'            : { url:'/aws/rds/parametergroup/',	method:'DescribeDBParameters',	params:['username', 'session_id', 'region_name', 'param_group', 'source', 'filters', 'marker', 'max_records']   },
		'rds_pg_CreateDBParameterGroup'          : { url:'/aws/rds/parametergroup/',	method:'CreateDBParameterGroup',	params:['username', 'session_id', 'region_name', 'param_group', 'param_group_family', 'description', 'tags']   },
		'rds_pg_DeleteDBParameterGroup'          : { url:'/aws/rds/parametergroup/',	method:'DeleteDBParameterGroup',	params:['username', 'session_id', 'region_name', 'param_group']   },
		'rds_pg_ModifyDBParameterGroup'          : { url:'/aws/rds/parametergroup/',	method:'ModifyDBParameterGroup',	params:['username', 'session_id', 'region_name', 'param_group', 'parameters']   },
		'rds_pg_ResetDBParameterGroup'           : { url:'/aws/rds/parametergroup/',	method:'ResetDBParameterGroup',	params:['username', 'session_id', 'region_name', 'param_group', 'parameters', 'reset_all']   },
		'rds_revd_ins_DescribeReservedDBInstances' : { url:'/aws/rds/reservedinstance/',	method:'DescribeReservedDBInstances',	params:['username', 'session_id', 'region_name', 'instance_id', 'instance_class', 'offering_id', 'offering_type', 'duration', 'multi_az', 'description', 'filters', 'marker', 'max_records']   },
		'rds_revd_ins_DescribeReservedDBInstancesOfferings' : { url:'/aws/rds/reservedinstance/',	method:'DescribeReservedDBInstancesOfferings',	params:['username', 'session_id', 'region_name', 'offering_id', 'offering_type', 'instance_class', 'duration', 'multi_az', 'description', 'filters', 'marker', 'max_records']   },
		'rds_sg_DescribeDBSecurityGroups'        : { url:'/aws/rds/securitygroup/',	method:'DescribeDBSecurityGroups',	params:['username', 'session_id', 'region_name', 'security_group', 'filters', 'marker', 'max_records']   },
		'rds_snap_CopyDBSnapshot'                : { url:'/aws/rds/snapshot/',	method:'CopyDBSnapshot',	params:['username', 'session_id', 'region_name', 'source_id', 'target_id', 'tags']   },
		'rds_snap_CreateDBSnapshot'              : { url:'/aws/rds/snapshot/',	method:'CreateDBSnapshot',	params:['username', 'session_id', 'region_name', 'source_id', 'snapshot_id', 'tags']   },
		'rds_snap_DeleteDBSnapshot'              : { url:'/aws/rds/snapshot/',	method:'DeleteDBSnapshot',	params:['username', 'session_id', 'region_name', 'snapshot_id']   },
		'rds_snap_DescribeDBSnapshots'           : { url:'/aws/rds/snapshot/',	method:'DescribeDBSnapshots',	params:['username', 'session_id', 'region_name', 'instance_id', 'snapshot_id', 'snapshot_type', 'filters', 'marker', 'max_records']   },
		'rds_subgrp_DescribeDBSubnetGroups'      : { url:'/aws/rds/subnetgroup/',	method:'DescribeDBSubnetGroups',	params:['username', 'session_id', 'region_name', 'subnet_group', 'filters', 'marker', 'max_records']   },
		'rds_ListTagsForResource'                : { url:'/aws/rds/',	method:'ListTagsForResource',	params:['username', 'session_id', 'region_name', 'resource_name', 'filters']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
