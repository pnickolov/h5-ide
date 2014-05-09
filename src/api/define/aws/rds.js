define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'rds_DescribeDBEngineVersions'           : { url:'/aws/rds/',	method:'DescribeDBEngineVersions',	params:['username']   },
		'rds_DescribeOrderableDBInstanceOptions' : { url:'/aws/rds/',	method:'DescribeOrderableDBInstanceOptions',	params:['username']   },
		'rds_DescribeEngineDefaultParameters'    : { url:'/aws/rds/',	method:'DescribeEngineDefaultParameters',	params:['username', 'session_id', 'region_name', 'pg_family', 'marker', 'max_records']   },
		'rds_DescribeEvents'                     : { url:'/aws/rds/',	method:'DescribeEvents',	params:['username']   },
		'rds_ins_DescribeDBInstances'            : { url:'/aws/rds/instance/',	method:'DescribeDBInstances',	params:['username', 'session_id', 'region_name', 'instance_id', 'marker', 'max_records']   },
		'rds_og_DescribeOptionGroupOptions'      : { url:'/aws/rds/optiongroup/',	method:'DescribeOptionGroupOptions',	params:['username']   },
		'rds_og_DescribeOptionGroups'            : { url:'/aws/rds/optiongroup/',	method:'DescribeOptionGroups',	params:['username']   },
		'rds_pg_DescribeDBParameterGroups'       : { url:'/aws/rds/parametergroup/',	method:'DescribeDBParameterGroups',	params:['username', 'session_id', 'region_name', 'pg_name', 'marker', 'max_records']   },
		'rds_pg_DescribeDBParameters'            : { url:'/aws/rds/parametergroup/',	method:'DescribeDBParameters',	params:['username', 'session_id', 'region_name', 'pg_name', 'source', 'marker', 'max_records']   },
		'rds_revd_ins_DescribeReservedDBInstances' : { url:'/aws/rds/reservedinstance/',	method:'DescribeReservedDBInstances',	params:['username']   },
		'rds_revd_ins_DescribeReservedDBInstancesOfferings' : { url:'/aws/rds/reservedinstance/',	method:'DescribeReservedDBInstancesOfferings',	params:['username']   },
		'rds_sg_DescribeDBSecurityGroups'        : { url:'/aws/rds/securitygroup/',	method:'DescribeDBSecurityGroups',	params:['username', 'session_id', 'region_name', 'sg_name', 'marker', 'max_records']   },
		'rds_snap_DescribeDBSnapshots'           : { url:'/aws/rds/snapshot/',	method:'DescribeDBSnapshots',	params:['username']   },
		'rds_subgrp_DescribeDBSubnetGroups'      : { url:'/aws/rds/subnetgroup/',	method:'DescribeDBSubnetGroups',	params:['username', 'session_id', 'region_name', 'sg_name', 'marker', 'max_records']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
