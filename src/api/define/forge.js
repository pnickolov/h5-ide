define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'session_login'           : { type:'forge', url:'/session/',	method:'login',	params:['username', 'password']   },
		'session_logout'          : { type:'forge', url:'/session/',	method:'logout',	params:['username', 'session_id']   },
		'session_set_credential'  : { type:'forge', url:'/session/',	method:'set_credential',	params:['username', 'session_id', 'access_key', 'secret_key', 'account_id']   },
		'app_create'              : { type:'forge', url:'/app/',	method:'create',	params:['username', 'session_id', 'region_name', 'spec']   },
		'app_update'              : { type:'forge', url:'/app/',	method:'update',	params:['username', 'session_id', 'region_name', 'spec', 'app_id', 'fast_update', 'create_snapshot']   },
		'app_rename'              : { type:'forge', url:'/app/',	method:'rename',	params:['username', 'session_id', 'region_name', 'app_id', 'new_name', 'app_name']   },
		'app_terminate'           : { type:'forge', url:'/app/',	method:'terminate',	params:['username', 'session_id', 'region_name', 'app_id', 'app_name', 'flag', 'create_snapshot']   },
		'app_start'               : { type:'forge', url:'/app/',	method:'start',	params:['username', 'session_id', 'region_name', 'app_id', 'app_name']   },
		'app_stop'                : { type:'forge', url:'/app/',	method:'stop',	params:['username', 'session_id', 'region_name', 'app_id', 'app_name', 'force']   },
		'app_reboot'              : { type:'forge', url:'/app/',	method:'reboot',	params:['username', 'session_id', 'region_name', 'app_id', 'app_name']   },
		'app_info'                : { type:'forge', url:'/app/',	method:'info',	params:['username', 'session_id', 'region_name', 'app_ids']   },
		'app_list'                : { type:'forge', url:'/app/',	method:'list',	params:['username', 'session_id', 'region_name', 'app_ids']   },
		'app_resource'            : { type:'forge', url:'/app/',	method:'resource',	params:['username', 'session_id', 'region_name', 'app_id']   },
		'app_get_info'            : { type:'forge', url:'/app/',	method:'get_info',	params:['username', 'session_id', 'vpc_ids']   },
		'app_save_info'           : { type:'forge', url:'/app/',	method:'save_info',	params:['username', 'session_id', 'spec']   },
		'favorite_add'            : { type:'forge', url:'/favorite/',	method:'add',	params:['username', 'session_id', 'region_name', 'resource']   },
		'favorite_remove'         : { type:'forge', url:'/favorite/',	method:'remove',	params:['username', 'session_id', 'region_name', 'resource_ids']   },
		'favorite_info'           : { type:'forge', url:'/favorite/',	method:'info',	params:['username', 'session_id', 'region_name', 'provider', 'service', 'resource']   },
		'guest_invite'            : { type:'forge', url:'/guest/',	method:'invite',	params:['username', 'session_id', 'region_name', 'guest_emails', 'stack_id', 'time_length', 'time_due', 'post_ops', 'autostart', 'autostop_when', 'autostop_during', 'information', 'stack_name']   },
		'guest_cancel'            : { type:'forge', url:'/guest/',	method:'cancel',	params:['username', 'session_id', 'region_name', 'guest_id']   },
		'guest_access'            : { type:'forge', url:'/guest/',	method:'access',	params:['guestname', 'session_id', 'region_name', 'guest_id']   },
		'guest_end'               : { type:'forge', url:'/guest/',	method:'end',	params:['guestname', 'session_id', 'region_name', 'guest_id']   },
		'guest_info'              : { type:'forge', url:'/guest/',	method:'info',	params:['username', 'session_id', 'region_name', 'guest_id']   },
		'opsbackend_render_app'   : { type:'forge', url:'/opsbackend/',	method:'render_app',	params:['timestamp', 'app_id', 'res_id', 'is_arrived']   },
		'opsbackend_check_app'    : { type:'forge', url:'/opsbackend/',	method:'check_app',	params:['timestamp', 'app_id']   },
		'opsbackend_update_status' : { type:'forge', url:'/opsbackend/',	method:'update_status',	params:['app_id', 'instance_id', 'recipe_version', 'timestamp', 'statuses', 'waiting', 'agent_status', 'token']   },
		'opsbackend_verify'       : { type:'forge', url:'/opsbackend/',	method:'verify',	params:['username', 'token']   },
		'request_init'            : { type:'forge', url:'/request/',	method:'init',	params:['username', 'session_id', 'region_name']   },
		'request_update'          : { type:'forge', url:'/request/',	method:'update',	params:['username', 'session_id', 'region_name', 'timestamp']   },
		'resource_change_detail'  : { type:'forge', url:'/resource/',	method:'change_detail',	params:['username', 'session_id', 'region_name', 'app_id']   },
		'resource_vpc_resource'   : { type:'forge', url:'/resource/',	method:'vpc_resource',	params:['username', 'session_id', 'region_name', 'vpc_id']   },
		'resource_get_resource'   : { type:'forge', url:'/resource/',	method:'get_resource',	params:['username', 'session_id', 'region_name', 'provider', 'res_id', 'resource']   },
		'resource_check_change'   : { type:'forge', url:'/resource/',	method:'check_change',	params:['username', 'session_id', 'region_name', 'app_id']   },
		'resource_generate_json'  : { type:'forge', url:'/resource/',	method:'generate_json',	params:['username', 'session_id', 'app_id']   },
		'resource_region_resource' : { type:'forge', url:'/resource/',	method:'region_resource',	params:['username', 'session_id']   },
		'stack_create'            : { type:'forge', url:'/stack/',	method:'create',	params:['username', 'session_id', 'region_name', 'spec']   },
		'stack_remove'            : { type:'forge', url:'/stack/',	method:'remove',	params:['username', 'session_id', 'region_name', 'stack_id', 'stack_name']   },
		'stack_save'              : { type:'forge', url:'/stack/',	method:'save',	params:['username', 'session_id', 'region_name', 'spec']   },
		'stack_rename'            : { type:'forge', url:'/stack/',	method:'rename',	params:['username', 'session_id', 'region_name', 'stack_id', 'new_name', 'stack_name']   },
		'stack_run_v2'            : { type:'forge', url:'/stack/',	method:'run_v2',	params:['username', 'session_id', 'region_name', 'stack', 'app_name']   },
		'stack_run'               : { type:'forge', url:'/stack/',	method:'run',	params:['username', 'session_id', 'region_name', 'stack_id', 'app_name', 'app_desc', 'app_component', 'app_property', 'app_layout', 'stack_name', 'usage']   },
		'stack_save_as'           : { type:'forge', url:'/stack/',	method:'save_as',	params:['username', 'session_id', 'region_name', 'stack_id', 'new_name', 'stack_name']   },
		'stack_info'              : { type:'forge', url:'/stack/',	method:'info',	params:['username', 'session_id', 'region_name', 'stack_ids']   },
		'stack_list'              : { type:'forge', url:'/stack/',	method:'list',	params:['username', 'session_id', 'region_name', 'stack_ids']   },
		'stack_export_cloudformation' : { type:'forge', url:'/stack/',	method:'export_cloudformation',	params:['username', 'session_id', 'region_name', 'stack']   },
		'stack_verify'            : { type:'forge', url:'/stack/',	method:'verify',	params:['username', 'session_id', 'spec']   },
		'stackstore_fetch_stackstore' : { type:'forge', url:'/stackstore/',	method:'fetch_stackstore',	params:['sub_path']   },
		'state_module'            : { type:'forge', url:'/state/',	method:'module',	params:['username', 'session_id', 'mod_repo', 'mod_tag']   },
		'state_status'            : { type:'forge', url:'/state/',	method:'status',	params:['username', 'session_id', 'app_id']   },
		'state_log'               : { type:'forge', url:'/state/',	method:'log',	params:['username', 'session_id', 'app_id', 'res_id']   },
		'token_create'            : { type:'forge', url:'/token/',	method:'create',	params:['username', 'session_id', 'token_name']   },
		'token_update'            : { type:'forge', url:'/token/',	method:'update',	params:['username', 'session_id', 'token', 'new_token_name']   },
		'token_remove'            : { type:'forge', url:'/token/',	method:'remove',	params:['username', 'session_id', 'token', 'token_name']   },
		'token_list'              : { type:'forge', url:'/token/',	method:'list',	params:['username', 'session_id', 'token_names']   },
		'account_register'        : { type:'forge', url:'/account/',	method:'register',	params:['username', 'password', 'email']   },
		'account_update_account'  : { type:'forge', url:'/account/',	method:'update_account',	params:['username', 'session_id', 'attributes']   },
		'account_reset_password'  : { type:'forge', url:'/account/',	method:'reset_password',	params:['username']   },
		'account_update_password' : { type:'forge', url:'/account/',	method:'update_password',	params:['key', 'new_pwd']   },
		'account_check_repeat'    : { type:'forge', url:'/account/',	method:'check_repeat',	params:['username', 'email']   },
		'account_check_validation' : { type:'forge', url:'/account/',	method:'check_validation',	params:['key', 'operation_flag']   },
		'account_reset_key'       : { type:'forge', url:'/account/',	method:'reset_key',	params:['username', 'session_id', 'flag']   },
		'account_del_account'     : { type:'forge', url:'/account/',	method:'del_account',	params:['username', 'email', 'password', 'force_delete']   },
		'account_is_invitated'    : { type:'forge', url:'/account/',	method:'is_invitated',	params:['username', 'session_id']   },
		'account_apply_trial'     : { type:'forge', url:'/account/',	method:'apply_trial',	params:['username', 'session_id', 'message']   },
		'account_set_credential'  : { type:'forge', url:'/account/',	method:'set_credential',	params:['username', 'session_id', 'access_key', 'secret_key', 'account_id', 'force_update']   },
		'account_validate_credential' : { type:'forge', url:'/account/',	method:'validate_credential',	params:['username', 'session_id', 'access_key', 'secret_key']   },
		'account_get_userinfo'    : { type:'forge', url:'/account/',	method:'get_userinfo',	params:['username']   },
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
