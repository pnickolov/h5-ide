define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'os_cinder_List'                       : { type:'openstack', url:'/os/cinder/v2_0/cinder/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_cinder_V2_Info'                    : { type:'openstack', url:'/os/cinder/v2_0/cinder/',	method:'V2_Info',	params:['username', 'session_id', 'region']   },
		'os_cinder_V2_Extension'               : { type:'openstack', url:'/os/cinder/v2_0/cinder/',	method:'V2_Extension',	params:['username', 'session_id', 'region']   },
		'os_cinder_GetAbsoluteLimits'          : { type:'openstack', url:'/os/cinder/v2_0/cinder/',	method:'GetAbsoluteLimits',	params:['username', 'session_id', 'region']   },
		'os_backup_List'                       : { type:'openstack', url:'/os/cinder/v2_0/backup/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_backup_Info'                       : { type:'openstack', url:'/os/cinder/v2_0/backup/',	method:'Info',	params:['username', 'session_id', 'region', 'ids']   },
		'os_backup_Delete'                     : { type:'openstack', url:'/os/cinder/v2_0/backup/',	method:'Delete',	params:['username', 'session_id', 'region', 'backup_id']   },
		'os_backup_Restore'                    : { type:'openstack', url:'/os/cinder/v2_0/backup/',	method:'Restore',	params:['username', 'session_id', 'region', 'backup_id', 'backup']   },
		'os_qos_Create'                        : { type:'openstack', url:'/os/cinder/v2_0/qos/',	method:'Create',	params:['username', 'session_id', 'region', 'qos_specs']   },
		'os_qos_List'                          : { type:'openstack', url:'/os/cinder/v2_0/qos/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_qos_Info'                          : { type:'openstack', url:'/os/cinder/v2_0/qos/',	method:'Info',	params:['username', 'session_id', 'region', 'ids']   },
		'os_qos_Delete'                        : { type:'openstack', url:'/os/cinder/v2_0/qos/',	method:'Delete',	params:['username', 'session_id', 'region', 'qos_id']   },
		'os_qos_GetAssociations'               : { type:'openstack', url:'/os/cinder/v2_0/qos/',	method:'GetAssociations',	params:['username', 'session_id', 'region', 'qos_id']   },
		'os_qos_Associate'                     : { type:'openstack', url:'/os/cinder/v2_0/qos/',	method:'Associate',	params:['username', 'session_id', 'region', 'qos_id', 'volume_type_id']   },
		'os_qos_Disassociate'                  : { type:'openstack', url:'/os/cinder/v2_0/qos/',	method:'Disassociate',	params:['username', 'session_id', 'region', 'volume_type_id']   },
		'os_cinder_quota_Info'                 : { type:'openstack', url:'/os/cinder/v2_0/quota/',	method:'Info',	params:['username', 'session_id', 'region', 'quota_tenant_id']   },
		'os_cinder_quota_Update'               : { type:'openstack', url:'/os/cinder/v2_0/quota/',	method:'Update',	params:['username', 'session_id', 'region', 'quota_tenant_id', 'quota']   },
		'os_cinder_quota_Delete'               : { type:'openstack', url:'/os/cinder/v2_0/quota/',	method:'Delete',	params:['username', 'session_id', 'region', 'quota_tenant_id']   },
		'os_cinder_quota_GetUserQuota'         : { type:'openstack', url:'/os/cinder/v2_0/quota/',	method:'GetUserQuota',	params:['uesrname', 'session_id', 'region', 'quota_tenant_id', 'user_id', 'is_detail']   },
		'os_cinder_quota_UpdateUserQuota'      : { type:'openstack', url:'/os/cinder/v2_0/quota/',	method:'UpdateUserQuota',	params:['uesrname', 'session_id', 'region', 'quota_tenant_id', 'user_id', 'quota']   },
		'os_cinder_quota_DeleteUserQuota'      : { type:'openstack', url:'/os/cinder/v2_0/quota/',	method:'DeleteUserQuota',	params:['uesrname', 'session_id', 'region', 'quota_tenant_id', 'user_id']   },
		'os_snapshot_List'                     : { type:'openstack', url:'/os/cinder/v2_0/snapshot/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_snapshot_Info'                     : { type:'openstack', url:'/os/cinder/v2_0/snapshot/',	method:'Info',	params:['username', 'session_id', 'region', 'ids']   },
		'os_snapshot_Update'                   : { type:'openstack', url:'/os/cinder/v2_0/snapshot/',	method:'Update',	params:['username', 'session_id', 'region', 'snapshot_id', 'display_name', 'display_description']   },
		'os_snapshot_Create'                   : { type:'openstack', url:'/os/cinder/v2_0/snapshot/',	method:'Create',	params:['username', 'session_id', 'region', 'volume_id', 'display_name', 'display_description', 'is_force']   },
		'os_snapshot_Delete'                   : { type:'openstack', url:'/os/cinder/v2_0/snapshot/',	method:'Delete',	params:['username', 'session_id', 'region', 'snapshot_id']   },
		'os_volume_List'                       : { type:'openstack', url:'/os/cinder/v2_0/volume/',	method:'List',	params:['username', 'session_id', 'region']   },
		'os_volume_Info'                       : { type:'openstack', url:'/os/cinder/v2_0/volume/',	method:'Info',	params:['username', 'session_id', 'region', 'ids']   },
		'os_volume_GetVolumeType'              : { type:'openstack', url:'/os/cinder/v2_0/volume/',	method:'GetVolumeType',	params:['username', 'session_id', 'region', 'volume_type_id']   },
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
