define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'os_image_List'                        : { type:'openstack', url:'/os/glance/v2_2/image/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_image_Info'                        : { type:'openstack', url:'/os/glance/v2_2/image/',	method:'Info',	params:['username', 'session_id', 'region', 'ids']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
