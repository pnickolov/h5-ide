define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'iam_GetServerCertificate'               : { url:'/aws/iam/',	method:'GetServerCertificate',	params:['username', 'session_id', 'region_name', 'servercer_name']   },
		'iam_ListServerCertificates'             : { url:'/aws/iam/',	method:'ListServerCertificates',	params:['username', 'session_id', 'region_name', 'marker', 'max_items', 'path_prefix']   },
		'iam_DeleteServerCertificate'            : { url:'/aws/iam/',	method:'DeleteServerCertificate',	params:['username', 'session_id', 'region_name', 'servercer_name']   },
		'iam_UpdateServerCertificate'            : { url:'/aws/iam/',	method:'UpdateServerCertificate',	params:['username', 'session_id', 'region_name', 'servercer_name', 'new_servercer_name', 'new_path']   },
		'iam_UploadServerCertificate'            : { url:'/aws/iam/',	method:'UploadServerCertificate',	params:['username', 'session_id', 'region_name', 'servercer_name', 'cert_body', 'private_key', 'cert_chain', 'path']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
