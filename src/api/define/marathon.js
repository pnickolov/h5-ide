define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'marathon_app_list'       : { type:'marathon', url:'/app/',	method:'list',	params:['username', 'session_id', 'app_id', 'marathon_app_id']   },
		'marathon_app_list_version' : { type:'marathon', url:'/app/',	method:'list_version',	params:['username', 'session_id', 'app_id', 'marathon_app_id', 'version']   },
		'marathon_deployment_list' : { type:'marathon', url:'/deployment/',	method:'list',	params:['username', 'session_id', 'app_id']   },
		'marathon_deployment_delete' : { type:'marathon', url:'/deployment/',	method:'delete',	params:['username', 'session_id', 'deployment_id']   },
		'marathon_group_list'     : { type:'marathon', url:'/group/',	method:'list',	params:['username', 'session_id', 'app_id', 'group_id']   },
		'marathon_marathon'       : { type:'marathon', url:'/marathon/',	method:'marathon',	params:['username', 'session_id', 'sources', 'fields']   },
		'marathon_server_info'    : { type:'marathon', url:'/server/',	method:'info',	params:['username', 'session_id', 'app_id']   },
		'marathon_server_leader'  : { type:'marathon', url:'/server/',	method:'leader',	params:['username', 'session_id', 'app_id', 'new_election']   },
		'marathon_subscription_list' : { type:'marathon', url:'/subscription/',	method:'list',	params:['username', 'session_id', 'app_id']   },
		'marathon_subscription_register' : { type:'marathon', url:'/subscription/',	method:'register',	params:['username', 'session_id', 'app_id', 'callback_url']   },
		'marathon_task_list'      : { type:'marathon', url:'/task/',	method:'list',	params:['username', 'session_id', 'app_id', 'marathon_app_id', 'task_id']   },
		'marathon_task_kill'      : { type:'marathon', url:'/task/',	method:'kill',	params:['username', 'session_id', 'app_id', 'marathon_app_id', 'task_id']   },
		'marathon_task_queue'     : { type:'marathon', url:'/task/',	method:'queue',	params:['username', 'session_id', 'app_id']   },
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
