define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'sdb_DomainMetadata'                     : { type:'aws', url:'/aws/sdb/',	method:'DomainMetadata',	params:['username', 'session_id', 'region_name', 'doamin_name']   },
		'sdb_GetAttributes'                      : { type:'aws', url:'/aws/sdb/',	method:'GetAttributes',	params:['username', 'session_id', 'region_name', 'domain_name', 'item_name', 'attribute_name', 'consistent_read']   },
		'sdb_ListDomains'                        : { type:'aws', url:'/aws/sdb/',	method:'ListDomains',	params:['username', 'session_id', 'region_name', 'max_domains', 'next_token']   },
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
