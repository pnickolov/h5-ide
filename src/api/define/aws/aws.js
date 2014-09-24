define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'aws_quickstart'     : { type:'aws', url:'/aws/',	method:'quickstart',	params:['username', 'session_id', 'region_name']   },
		'aws_public'         : { type:'aws', url:'/aws/',	method:'public',	params:['username', 'session_id', 'region_name', 'filters']   },
		'aws_property'       : { type:'aws', url:'/aws/',	method:'property',	params:['username', 'session_id']   },
		'aws_aws'            : { type:'aws', url:'/aws/',	method:'aws',	params:['username', 'session_id', 'region_names', 'fields', 'filters']   },
		'aws_resource'       : { type:'aws', url:'/aws/',	method:'resource',	params:['username', 'session_id', 'region_name', 'resources', 'addition', 'retry_times']   },
	}

	for ( var i in Apis ) {
		/* env:dev */
		if (ApiRequestDefs.Defs[ i ]){
			console.warn('api duplicate: ' + i);
		}
		/* env:dev:end */
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
