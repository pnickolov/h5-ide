define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'os_image_List'                        : { type:'openstack', url:'/os/glance/v2_2/image/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_image_Info'                        : { type:'openstack', url:'/os/glance/v2_2/image/',	method:'Info',	params:['username', 'session_id', 'region', 'ids']   },
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
