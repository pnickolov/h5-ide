define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'rds_DescribeDBEngineVersions'           : { url:'/aws/rds/',	method:'DescribeDBEngineVersions',	params:['username', 'session_id', 'region_name', 'pg_family', 'default_only', 'engine', 'engine_version', 'list_supported_character_set', 'marker', 'max_records']   },
		'rds_DescribeOrderableDBInstanceOptions' : { url:'/aws/rds/',	method:'DescribeOrderableDBInstanceOptions',	params:['username', 'session_id', 'region_name', 'engine', 'engine_version', 'instance_class', 'license_model', 'marker', 'max_records']   },
		'rds_DescribeEngineDefaultParameters'    : { url:'/aws/rds/',	method:'DescribeEngineDefaultParameters',	params:['username', 'session_id', 'region_name', 'pg_family', 'marker', 'max_records']   },
		'rds_DescribeEvents'                     : { url:'/aws/rds/',	method:'DescribeEvents',	params:['username', 'session_id', 'region_name', 'duration', 'start_time', 'end_time', 'source_id', 'source_type', 'marker', 'max_records']   },
		'rds_ins_DescribeDBInstances'            : { url:'/aws/rds/instance/',	method:'DescribeDBInstances',	params:['username', 'session_id', 'region_name', 'instance_id', 'marker', 'max_records']   },
		'rds_og_DescribeOptionGroupOptions'      : { url:'/aws/rds/optiongroup/',	method:'DescribeOptionGroupOptions',	params:['username', 'session_id', 'region_name', 'engine_name', 'major_engine_version', 'marker', 'max_records']   },
		'rds_og_DescribeOptionGroups'            : { url:'/aws/rds/optiongroup/',	method:'DescribeOptionGroups',	params:['username', 'session_id', 'region_name', 'op_name', 'engine_name', 'major_engine_version', 'marker', 'max_records']   },
		'rds_pg_DescribeDBParameterGroups'       : { url:'/aws/rds/parametergroup/',	method:'DescribeDBParameterGroups',	params:['username', 'session_id', 'region_name', 'pg_name', 'marker', 'max_records']   },
		'rds_pg_DescribeDBParameters'            : { url:'/aws/rds/parametergroup/',	method:'DescribeDBParameters',	params:['username', 'session_id', 'region_name', 'pg_name', 'source', 'marker', 'max_records']   },
		'rds_revd_ins_DescribeReservedDBInstances' : { url:'/aws/rds/reservedinstance/',	method:'DescribeReservedDBInstances',	params:['username', 'session_id', 'region_name', 'instance_id', 'instance_class', 'offering_id', 'offering_type', 'duration', 'multi_az', 'description', 'marker', 'max_records']   },
		'rds_revd_ins_DescribeReservedDBInstancesOfferings' : { url:'/aws/rds/reservedinstance/',	method:'DescribeReservedDBInstancesOfferings',	params:['username', 'session_id', 'region_name', 'offering_id', 'offering_type', 'instance_class', 'duration', 'multi_az', 'description', 'marker', 'max_records']   },
		'rds_sg_DescribeDBSecurityGroups'        : { url:'/aws/rds/securitygroup/',	method:'DescribeDBSecurityGroups',	params:['username', 'session_id', 'region_name', 'sg_name', 'marker', 'max_records']   },
		'rds_snap_DescribeDBSnapshots'           : { url:'/aws/rds/snapshot/',	method:'DescribeDBSnapshots',	params:['username', 'session_id', 'region_name', 'instance_id', 'snapshot_id', 'snapshot_type', 'marker', 'max_records']   },
		'rds_subgrp_DescribeDBSubnetGroups'      : { url:'/aws/rds/subnetgroup/',	method:'DescribeDBSubnetGroups',	params:['username', 'session_id', 'region_name', 'sg_name', 'marker', 'max_records']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
