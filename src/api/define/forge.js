define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'session_login'           : { url:'/session/',	method:'login',	params:['username', 'password']   },
		'session_logout'          : { url:'/session/',	method:'logout',	params:['username', 'session_id']   },
		'session_set_credential'  : { url:'/session/',	method:'set_credential',	params:['username', 'session_id', 'access_key', 'secret_key', 'account_id']   },
		'app_create'              : { url:'/app/',	method:'create',	params:['username', 'session_id', 'region_name', 'spec']   },
		'app_update'              : { url:'/app/',	method:'update',	params:['username', 'session_id', 'region_name', 'spec', 'app_id']   },
		'app_rename'              : { url:'/app/',	method:'rename',	params:['username', 'session_id', 'region_name', 'app_id', 'new_name', 'app_name']   },
		'app_terminate'           : { url:'/app/',	method:'terminate',	params:['username', 'session_id', 'region_name', 'app_id', 'app_name', 'flag']   },
		'app_start'               : { url:'/app/',	method:'start',	params:['username', 'session_id', 'region_name', 'app_id', 'app_name']   },
		'app_stop'                : { url:'/app/',	method:'stop',	params:['username', 'session_id', 'region_name', 'app_id', 'app_name', 'force']   },
		'app_reboot'              : { url:'/app/',	method:'reboot',	params:['username', 'session_id', 'region_name', 'app_id', 'app_name']   },
		'app_info'                : { url:'/app/',	method:'info',	params:['username', 'session_id', 'region_name', 'app_ids']   },
		'app_list'                : { url:'/app/',	method:'list',	params:['username', 'session_id', 'region_name', 'app_ids']   },
		'app_resource'            : { url:'/app/',	method:'resource',	params:['username', 'session_id', 'region_name', 'app_id']   },
		'app_render_app'          : { url:'/app/',	method:'render_app',	params:['timestamp', 'app_id', 'res_id', 'is_arrived']   },
		'app_check_app'           : { url:'/app/',	method:'check_app',	params:['timestamp', 'app_id']   },
		'app_update_status'       : { url:'/app/',	method:'update_status',	params:['app_id', 'instance_id', 'recipe_version', 'timestamp', 'statuses', 'waiting', 'agent_status', 'token']   },
		'favorite_add'            : { url:'/favorite/',	method:'add',	params:['username', 'session_id', 'region_name', 'resource']   },
		'favorite_remove'         : { url:'/favorite/',	method:'remove',	params:['username', 'session_id', 'region_name', 'resource_ids']   },
		'favorite_info'           : { url:'/favorite/',	method:'info',	params:['username', 'session_id', 'region_name', 'provider', 'service', 'resource']   },
		'guest_invite'            : { url:'/guest/',	method:'invite',	params:['username', 'session_id', 'region_name', 'guest_emails', 'stack_id', 'time_length', 'time_due', 'post_ops', 'autostart', 'autostop_when', 'autostop_during', 'information', 'stack_name']   },
		'guest_cancel'            : { url:'/guest/',	method:'cancel',	params:['username', 'session_id', 'region_name', 'guest_id']   },
		'guest_access'            : { url:'/guest/',	method:'access',	params:['guestname', 'session_id', 'region_name', 'guest_id']   },
		'guest_end'               : { url:'/guest/',	method:'end',	params:['guestname', 'session_id', 'region_name', 'guest_id']   },
		'guest_info'              : { url:'/guest/',	method:'info',	params:['username', 'session_id', 'region_name', 'guest_id']   },
		'opsbackend_render_app'   : { url:'/opsbackend/',	method:'render_app',	params:['timestamp', 'app_id', 'res_id', 'is_arrived']   },
		'opsbackend_check_app'    : { url:'/opsbackend/',	method:'check_app',	params:['timestamp', 'app_id']   },
		'opsbackend_update_status' : { url:'/opsbackend/',	method:'update_status',	params:['app_id', 'instance_id', 'recipe_version', 'timestamp', 'statuses', 'waiting', 'agent_status', 'token']   },
		'opsbackend_verify'       : { url:'/opsbackend/',	method:'verify',	params:['username', 'token']   },
		'request_init'            : { url:'/request/',	method:'init',	params:['username', 'session_id', 'region_name']   },
		'request_update'          : { url:'/request/',	method:'update',	params:['username', 'session_id', 'region_name', 'timestamp']   },
		'stack_create'            : { url:'/stack/',	method:'create',	params:['username', 'session_id', 'region_name', 'spec']   },
		'stack_remove'            : { url:'/stack/',	method:'remove',	params:['username', 'session_id', 'region_name', 'stack_id', 'stack_name']   },
		'stack_save'              : { url:'/stack/',	method:'save',	params:['username', 'session_id', 'region_name', 'spec']   },
		'stack_rename'            : { url:'/stack/',	method:'rename',	params:['username', 'session_id', 'region_name', 'stack_id', 'new_name', 'stack_name']   },
		'stack_run'               : { url:'/stack/',	method:'run',	params:['username', 'session_id', 'region_name', 'stack_id', 'app_name', 'app_desc', 'app_component', 'app_property', 'app_layout', 'stack_name', 'usage']   },
		'stack_save_as'           : { url:'/stack/',	method:'save_as',	params:['username', 'session_id', 'region_name', 'stack_id', 'new_name', 'stack_name']   },
		'stack_info'              : { url:'/stack/',	method:'info',	params:['username', 'session_id', 'region_name', 'stack_ids']   },
		'stack_list'              : { url:'/stack/',	method:'list',	params:['username', 'session_id', 'region_name', 'stack_ids']   },
		'stack_export_cloudformation' : { url:'/stack/',	method:'export_cloudformation',	params:['username', 'session_id', 'region_name', 'stack']   },
		'stack_verify'            : { url:'/stack/',	method:'verify',	params:['username', 'session_id', 'spec']   },
		'stackstore_fetch_stackstore' : { url:'/stackstore/',	method:'fetch_stackstore',	params:['filename']   },
		'state_module'            : { url:'/state/',	method:'module',	params:['username', 'session_id', 'mod_repo', 'mod_tag']   },
		'state_status'            : { url:'/state/',	method:'status',	params:['username', 'session_id', 'app_id']   },
		'state_log'               : { url:'/state/',	method:'log',	params:['username', 'session_id', 'app_id', 'res_id']   },
		'token_create'            : { url:'/token/',	method:'create',	params:['username', 'session_id', 'token_name']   },
		'token_update'            : { url:'/token/',	method:'update',	params:['username', 'session_id', 'token', 'new_token_name']   },
		'token_remove'            : { url:'/token/',	method:'remove',	params:['username', 'session_id', 'token', 'token_name']   },
		'token_list'              : { url:'/token/',	method:'list',	params:['username', 'session_id', 'token_names']   },
		'account_register'        : { url:'/account/',	method:'register',	params:['username', 'password', 'email']   },
		'account_update_account'  : { url:'/account/',	method:'update_account',	params:['username', 'session_id', 'attributes']   },
		'account_reset_password'  : { url:'/account/',	method:'reset_password',	params:['username']   },
		'account_update_password' : { url:'/account/',	method:'update_password',	params:['key', 'new_pwd']   },
		'account_check_repeat'    : { url:'/account/',	method:'check_repeat',	params:['username', 'email']   },
		'account_check_validation' : { url:'/account/',	method:'check_validation',	params:['key', 'operation_flag']   },
		'account_reset_key'       : { url:'/account/',	method:'reset_key',	params:['username', 'session_id', 'flag']   },
		'account_del_account'     : { url:'/account/',	method:'del_account',	params:['username', 'email', 'password', 'force_delete']   },
		'account_is_invitated'    : { url:'/account/',	method:'is_invitated',	params:['username', 'session_id']   },
		'account_apply_trial'     : { url:'/account/',	method:'apply_trial',	params:['username', 'session_id', 'message']   },
		'account_set_credential'  : { url:'/account/',	method:'set_credential',	params:['username', 'session_id', 'access_key', 'secret_key', 'account_id', 'force_update']   },
		'account_validate_credential' : { url:'/account/',	method:'validate_credential',	params:['username', 'session_id', 'access_key', 'secret_key']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
