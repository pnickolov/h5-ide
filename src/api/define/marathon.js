define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'app_list'                : { type:'forge', url:'/app/',	method:'list',	params:['username', 'session_id', 'app_id', 'marathon_app_id']   },
		'app_list_version'        : { type:'forge', url:'/app/',	method:'list_version',	params:['username', 'session_id', 'app_id', 'marathon_app_id', 'version']   },
		'deployment_list'         : { type:'forge', url:'/deployment/',	method:'list',	params:['username', 'session_id', 'app_id']   },
		'deployment_delete'       : { type:'forge', url:'/deployment/',	method:'delete',	params:['username', 'session_id', 'deployment_id']   },
		'group_list'              : { type:'forge', url:'/group/',	method:'list',	params:['username', 'session_id', 'app_id', 'group_id']   },
		'subscription_list'       : { type:'forge', url:'/subscription/',	method:'list',	params:['username', 'session_id', 'app_id']   },
		'subscription_register'   : { type:'forge', url:'/subscription/',	method:'register',	params:['username', 'session_id', 'app_id', 'callback_url']   },
		'task_list'               : { type:'forge', url:'/task/',	method:'list',	params:['username', 'session_id', 'app_id', 'marathon_app_id', 'task_id']   },
		'task_kill'               : { type:'forge', url:'/task/',	method:'kill',	params:['username', 'session_id', 'app_id', 'marathon_app_id', 'task_id']   },
		'task_queue'              : { type:'forge', url:'/task/',	method:'queue',	params:['username', 'session_id', 'app_id']   },
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
