define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'cinder_List'                       : { url:'/os/cinder/v2_0/cinder/',	method:'List',	params:['username', 'session_id', 'region']   },
		'cinder_V2_Info'                    : { url:'/os/cinder/v2_0/cinder/',	method:'V2_Info',	params:['username', 'session_id', 'region']   },
		'cinder_V2_Extension'               : { url:'/os/cinder/v2_0/cinder/',	method:'V2_Extension',	params:['username', 'session_id', 'region']   },
		'cinder_GetAbsoluteLimits'          : { url:'/os/cinder/v2_0/cinder/',	method:'GetAbsoluteLimits',	params:['username', 'session_id', 'region']   },
		'backup_List'                       : { url:'/os/cinder/v2_0/backup/',	method:'List',	params:['username', 'session_id', 'region']   },
		'backup_Info'                       : { url:'/os/cinder/v2_0/backup/',	method:'Info',	params:['username', 'session_id', 'region', 'ids']   },
		'backup_Delete'                     : { url:'/os/cinder/v2_0/backup/',	method:'Delete',	params:['username', 'session_id', 'region', 'backup_id']   },
		'backup_Restore'                    : { url:'/os/cinder/v2_0/backup/',	method:'Restore',	params:['username', 'session_id', 'region', 'backup_id', 'backup']   },
		'qos_Create'                        : { url:'/os/cinder/v2_0/qos/',	method:'Create',	params:['username', 'session_id', 'region', 'qos_specs']   },
		'qos_List'                          : { url:'/os/cinder/v2_0/qos/',	method:'List',	params:['username', 'session_id', 'region']   },
		'qos_Info'                          : { url:'/os/cinder/v2_0/qos/',	method:'Info',	params:['username', 'session_id', 'region', 'ids']   },
		'qos_Delete'                        : { url:'/os/cinder/v2_0/qos/',	method:'Delete',	params:['username', 'session_id', 'region', 'qos_id']   },
		'qos_GetAssociations'               : { url:'/os/cinder/v2_0/qos/',	method:'GetAssociations',	params:['username', 'session_id', 'region', 'qos_id']   },
		'qos_Associate'                     : { url:'/os/cinder/v2_0/qos/',	method:'Associate',	params:['username', 'session_id', 'region', 'qos_id', 'volume_type_id']   },
		'qos_Disassociate'                  : { url:'/os/cinder/v2_0/qos/',	method:'Disassociate',	params:['username', 'session_id', 'region', 'volume_type_id']   },
		'quota_Info'                        : { url:'/os/cinder/v2_0/quota/',	method:'Info',	params:['username', 'session_id', 'region', 'quota_tenant_id']   },
		'quota_Update'                      : { url:'/os/cinder/v2_0/quota/',	method:'Update',	params:['username', 'session_id', 'region', 'quota_tenant_id', 'quota']   },
		'quota_Delete'                      : { url:'/os/cinder/v2_0/quota/',	method:'Delete',	params:['username', 'session_id', 'region', 'quota_tenant_id']   },
		'quota_GetUserQuota'                : { url:'/os/cinder/v2_0/quota/',	method:'GetUserQuota',	params:['uesrname', 'session_id', 'region', 'quota_tenant_id', 'user_id', 'is_detail']   },
		'quota_UpdateUserQuota'             : { url:'/os/cinder/v2_0/quota/',	method:'UpdateUserQuota',	params:['uesrname', 'session_id', 'region', 'quota_tenant_id', 'user_id', 'quota']   },
		'quota_DeleteUserQuota'             : { url:'/os/cinder/v2_0/quota/',	method:'DeleteUserQuota',	params:['uesrname', 'session_id', 'region', 'quota_tenant_id', 'user_id']   },
		'snapshot_List'                     : { url:'/os/cinder/v2_0/snapshot/',	method:'List',	params:['username', 'session_id', 'region']   },
		'snapshot_Info'                     : { url:'/os/cinder/v2_0/snapshot/',	method:'Info',	params:['username', 'session_id', 'region', 'snapshot_ids']   },
		'snapshot_Update'                   : { url:'/os/cinder/v2_0/snapshot/',	method:'Update',	params:['username', 'session_id', 'region', 'snapshot_id', 'display_name', 'display_description']   },
		'snapshot_Delete'                   : { url:'/os/cinder/v2_0/snapshot/',	method:'Delete',	params:['username', 'session_id', 'region', 'snapshot_id']   },
		'volume_List'                       : { url:'/os/cinder/v2_0/volume/',	method:'List',	params:['username', 'session_id', 'region']   },
		'volume_Info'                       : { url:'/os/cinder/v2_0/volume/',	method:'Info',	params:['username', 'session_id', 'region', 'volume_ids']   },
		'volume_GetVolumeType'              : { url:'/os/cinder/v2_0/volume/',	method:'GetVolumeType',	params:['username', 'session_id', 'region', 'volume_type_id']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
