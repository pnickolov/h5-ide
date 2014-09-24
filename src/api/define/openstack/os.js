define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'os_endpoint'      : { type:'openstack', url:'/os/',	method:'endpoint',	params:['username', 'session_id', 'cloud_type', 'provider']   },
		'os_v2_auth'       : { type:'openstack', url:'/os/',	method:'v2_auth',	params:['username', 'session_id', 'os_username', 'os_user_id', 'os_password', 'tenant_id', 'tenant_name']   },
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
