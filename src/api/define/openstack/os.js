define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'volume_ListVolumeAttachment'       : { url:'/os/nova/v2_0/volume/',	method:'v2_auth',	params:['username', 'os_username', 'os_user_id', 'os_password', 'tenant_id', 'tenant_name']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
