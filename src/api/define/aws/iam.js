define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'iam_GetServerCertificate'               : { url:'/aws/iam/',	method:'GetServerCertificate',	params:['username', 'session_id', 'region_name', 'servercer_name']   },
		'iam_ListServerCertificates'             : { url:'/aws/iam/',	method:'ListServerCertificates',	params:['username', 'session_id', 'region_name', 'marker', 'max_items', 'path_prefix']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
