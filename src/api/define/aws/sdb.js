define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'sdb_DomainMetadata'                     : { url:'/aws/sdb/',	method:'DomainMetadata',	params:['username', 'session_id', 'region_name', 'doamin_name']   },
		'sdb_GetAttributes'                      : { url:'/aws/sdb/',	method:'GetAttributes',	params:['username', 'session_id', 'region_name', 'domain_name', 'item_name', 'attribute_name', 'consistent_read']   },
		'sdb_ListDomains'                        : { url:'/aws/sdb/',	method:'ListDomains',	params:['username', 'session_id', 'region_name', 'max_domains', 'next_token']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
