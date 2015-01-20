define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'ec2_CreateTags'                         : { type:'aws', url:'/aws/ec2/',	method:'CreateTags',	params:['username', 'session_id', 'region_name', 'resource_ids', 'tags']   },
		'ec2_DeleteTags'                         : { type:'aws', url:'/aws/ec2/',	method:'DeleteTags',	params:['username', 'session_id', 'region_name', 'resource_ids', 'tags']   },
		'ec2_DescribeTags'                       : { type:'aws', url:'/aws/ec2/',	method:'DescribeTags',	params:['username', 'session_id', 'region_name', 'filters']   },
		'ec2_DescribeRegions'                    : { type:'aws', url:'/aws/ec2/',	method:'DescribeRegions',	params:['username', 'session_id', 'region_names', 'filters']   },
		'ec2_DescribeAvailabilityZones'          : { type:'aws', url:'/aws/ec2/',	method:'DescribeAvailabilityZones',	params:['username', 'session_id', 'region_name', 'zone_names', 'filters']   },
		'ami_CreateImage'                        : { type:'aws', url:'/aws/ec2/ami/',	method:'CreateImage',	params:['username', 'session_id', 'key_id', 'region_name', 'instance_id', 'ami_name', 'ami_desc', 'no_reboot', 'bd_mappings']   },
		'ami_RegisterImage'                      : { type:'aws', url:'/aws/ec2/ami/',	method:'RegisterImage',	params:['username', 'session_id', 'key_id', 'region_name', 'ami_name', 'ami_desc', 'location', 'architecture', 'kernel_id', 'ramdisk_id', 'root_device_name', 'block_device_map']   },
		'ami_DeregisterImage'                    : { type:'aws', url:'/aws/ec2/ami/',	method:'DeregisterImage',	params:['username', 'session_id', 'key_id', 'region_name', 'ami_id']   },
		'ami_ModifyImageAttribute'               : { type:'aws', url:'/aws/ec2/ami/',	method:'ModifyImageAttribute',	params:['username', 'session_id', 'key_id', 'region_name', 'ami_id', 'user_ids', 'group_names', 'product_codes', 'description']   },
		'ami_ResetImageAttribute'                : { type:'aws', url:'/aws/ec2/ami/',	method:'ResetImageAttribute',	params:['username', 'session_id', 'key_id', 'region_name', 'ami_id', 'attribute_name']   },
		'ami_DescribeImageAttribute'             : { type:'aws', url:'/aws/ec2/ami/',	method:'DescribeImageAttribute',	params:['username', 'session_id', 'key_id', 'region_name', 'ami_id', 'attribute_name']   },
		'ami_DescribeImages'                     : { type:'aws', url:'/aws/ec2/ami/',	method:'DescribeImages',	params:['username', 'session_id', 'key_id', 'region_name', 'ami_ids', 'owners', 'executable_by', 'filters']   },
		'ebs_CreateVolume'                       : { type:'aws', url:'/aws/ec2/ebs/volume/',	method:'CreateVolume',	params:['username', 'session_id', 'region_name', 'zone_name', 'snapshot_id', 'volume_size', 'volume_type', 'iops']   },
		'ebs_DeleteVolume'                       : { type:'aws', url:'/aws/ec2/ebs/volume/',	method:'DeleteVolume',	params:['username', 'session_id', 'region_name', 'volume_id']   },
		'ebs_AttachVolume'                       : { type:'aws', url:'/aws/ec2/ebs/volume/',	method:'AttachVolume',	params:['username', 'session_id', 'region_name', 'volume_id', 'instance_id', 'device']   },
		'ebs_DetachVolume'                       : { type:'aws', url:'/aws/ec2/ebs/volume/',	method:'DetachVolume',	params:['username', 'session_id', 'region_name', 'volume_id', 'instance_id', 'device', 'force']   },
		'ebs_DescribeVolumes'                    : { type:'aws', url:'/aws/ec2/ebs/volume/',	method:'DescribeVolumes',	params:['username', 'session_id', 'region_name', 'volume_ids', 'filters']   },
		'ebs_DescribeVolumeAttribute'            : { type:'aws', url:'/aws/ec2/ebs/volume/',	method:'DescribeVolumeAttribute',	params:['username', 'session_id', 'region_name', 'volume_id', 'attribute_name']   },
		'ebs_DescribeVolumeStatus'               : { type:'aws', url:'/aws/ec2/ebs/volume/',	method:'DescribeVolumeStatus',	params:['username', 'session_id', 'region_name', 'volume_ids', 'filters', 'max_result', 'next_token']   },
		'ebs_ModifyVolumeAttribute'              : { type:'aws', url:'/aws/ec2/ebs/volume/',	method:'ModifyVolumeAttribute',	params:['username', 'session_id', 'region_name', 'volume_id', 'auto_enable_IO']   },
		'ebs_EnableVolumeIO'                     : { type:'aws', url:'/aws/ec2/ebs/volume/',	method:'EnableVolumeIO',	params:['username', 'session_id', 'region_name', 'volume_id']   },
		'ebs_CreateSnapshot'                     : { type:'aws', url:'/aws/ec2/ebs/snapshot/',	method:'CreateSnapshot',	params:['username', 'session_id', 'region_name', 'volume_id', 'description']   },
		'ebs_DeleteSnapshot'                     : { type:'aws', url:'/aws/ec2/ebs/snapshot/',	method:'DeleteSnapshot',	params:['username', 'session_id', 'region_name', 'snapshot_id']   },
		'ebs_ModifySnapshotAttribute'            : { type:'aws', url:'/aws/ec2/ebs/snapshot/',	method:'ModifySnapshotAttribute',	params:['username', 'session_id', 'region_name', 'snapshot_id', 'user_ids', 'group_names']   },
		'ebs_ResetSnapshotAttribute'             : { type:'aws', url:'/aws/ec2/ebs/snapshot/',	method:'ResetSnapshotAttribute',	params:['username', 'session_id', 'region_name', 'snapshot_id', 'attribute_name']   },
		'ebs_DescribeSnapshots'                  : { type:'aws', url:'/aws/ec2/ebs/snapshot/',	method:'DescribeSnapshots',	params:['username', 'session_id', 'region_name', 'snapshot_ids', 'owners', 'restorable_by', 'filters']   },
		'ebs_DescribeSnapshotAttribute'          : { type:'aws', url:'/aws/ec2/ebs/snapshot/',	method:'DescribeSnapshotAttribute',	params:['username', 'session_id', 'region_name', 'snapshot_id', 'attribute_name']   },
		'ebs_CopySnapshot'                       : { type:'aws', url:'/aws/ec2/ebs/snapshot/',	method:'CopySnapshot',	params:['username', 'session_id', 'region_name', 'snapshot_id', 'description', 'dst_region_name', 'pre_signed_url']   },
		'eip_AllocateAddress'                    : { type:'aws', url:'/aws/ec2/elasticip/',	method:'AllocateAddress',	params:['username', 'session_id', 'region_name', 'domain']   },
		'eip_ReleaseAddress'                     : { type:'aws', url:'/aws/ec2/elasticip/',	method:'ReleaseAddress',	params:['username', 'session_id', 'region_name', 'ip', 'allocation_id']   },
		'eip_AssociateAddress'                   : { type:'aws', url:'/aws/ec2/elasticip/',	method:'AssociateAddress',	params:['username', 'session_id', 'region_name', 'ip', 'instance_id', 'allocation_id', 'nif_id', 'private_ip', 'allow_reassociation']   },
		'eip_DisassociateAddress'                : { type:'aws', url:'/aws/ec2/elasticip/',	method:'DisassociateAddress',	params:['username', 'session_id', 'region_name', 'ip', 'association_id']   },
		'eip_DescribeAddresses'                  : { type:'aws', url:'/aws/ec2/elasticip/',	method:'DescribeAddresses',	params:['username', 'session_id', 'region_name', 'ips', 'allocation_ids', 'filters']   },
		'ins_RunInstances'                       : { type:'aws', url:'/aws/ec2/instance/',	method:'RunInstances',	params:['username', 'session_id', 'region_name', 'ami_id', 'min_count', 'max_count', 'key_name', 'security_group_ids', 'security_group_names', 'user_data', 'instance_type', 'placement', 'kernel_id', 'ramdisk_id', 'block_device_map', 'monitoring_enabled', 'subnet_id', 'disable_api_termination', 'instance_initiated_shutdown_behavior', 'private_ip_address', 'client_token', 'network_interfaces', 'iam_instance_profiles', 'ebs_optimized']   },
		'ins_StartInstances'                     : { type:'aws', url:'/aws/ec2/instance/',	method:'StartInstances',	params:['username', 'session_id', 'region_name', 'instance_ids']   },
		'ins_StopInstances'                      : { type:'aws', url:'/aws/ec2/instance/',	method:'StopInstances',	params:['username', 'session_id', 'region_name', 'instance_ids', 'force']   },
		'ins_RebootInstances'                    : { type:'aws', url:'/aws/ec2/instance/',	method:'RebootInstances',	params:['username', 'session_id', 'region_name', 'instance_ids']   },
		'ins_TerminateInstances'                 : { type:'aws', url:'/aws/ec2/instance/',	method:'TerminateInstances',	params:['username', 'session_id', 'region_name', 'instance_ids']   },
		'ins_MonitorInstances'                   : { type:'aws', url:'/aws/ec2/instance/',	method:'MonitorInstances',	params:['username', 'session_id', 'region_name', 'instance_ids']   },
		'ins_UnmonitorInstances'                 : { type:'aws', url:'/aws/ec2/instance/',	method:'UnmonitorInstances',	params:['username', 'session_id', 'region_name', 'instance_ids']   },
		'ins_BundleInstance'                     : { type:'aws', url:'/aws/ec2/instance/',	method:'BundleInstance',	params:['username', 'session_id', 'region_name', 'instance_id', 's3_bucket', 's3_prefix', 's3_access_key', 's3_upload_policy', 's3_upload_policy_signature']   },
		'ins_CancelBundleTask'                   : { type:'aws', url:'/aws/ec2/instance/',	method:'CancelBundleTask',	params:['username', 'session_id', 'region_name', 'bundle_id']   },
		'ins_ModifyInstanceAttribute'            : { type:'aws', url:'/aws/ec2/instance/',	method:'ModifyInstanceAttribute',	params:['username', 'session_id', 'region_name', 'instance_id', 'instance_type', 'kernel_id', 'ramdisk_id', 'user_data', 'disable_api_termination', 'instance_initiated_shutdown_bahavior', 'block_mapping_device', 'source_dest_check', 'group_ids', 'ebs_optimized']   },
		'ins_ResetInstanceAttribute'             : { type:'aws', url:'/aws/ec2/instance/',	method:'ResetInstanceAttribute',	params:['username', 'session_id', 'region_name', 'instance_id', 'attribute_name']   },
		'ins_ConfirmProductInstance'             : { type:'aws', url:'/aws/ec2/instance/',	method:'ConfirmProductInstance',	params:['username', 'session_id', 'region_name', 'instance_id', 'product_code']   },
		'ins_DescribeInstances'                  : { type:'aws', url:'/aws/ec2/instance/',	method:'DescribeInstances',	params:['username', 'session_id', 'region_name', 'instance_ids', 'filters']   },
		'ins_DescribeInstanceStatus'             : { type:'aws', url:'/aws/ec2/instance/',	method:'DescribeInstanceStatus',	params:['username', 'session_id', 'region_name', 'instance_ids', 'include_all_instances', 'max_results', 'next_token']   },
		'ins_DescribeBundleTasks'                : { type:'aws', url:'/aws/ec2/instance/',	method:'DescribeBundleTasks',	params:['username', 'session_id', 'region_name', 'bundle_ids', 'filters']   },
		'ins_DescribeInstanceAttribute'          : { type:'aws', url:'/aws/ec2/instance/',	method:'DescribeInstanceAttribute',	params:['username', 'session_id', 'region_name', 'instance_id', 'attribute_name']   },
		'ins_GetConsoleOutput'                   : { type:'aws', url:'/aws/ec2/instance/',	method:'GetConsoleOutput',	params:['username', 'session_id', 'region_name', 'instance_id']   },
		'ins_GetPasswordData'                    : { type:'aws', url:'/aws/ec2/instance/',	method:'GetPasswordData',	params:['username', 'session_id', 'region_name', 'instance_id', 'key_data']   },
		'kp_CreateKeyPair'                       : { type:'aws', url:'/aws/ec2/keypair/',	method:'CreateKeyPair',	params:['username', 'session_id', 'region_name', 'key_name']   },
		'kp_DeleteKeyPair'                       : { type:'aws', url:'/aws/ec2/keypair/',	method:'DeleteKeyPair',	params:['username', 'session_id', 'region_name', 'key_name']   },
		'kp_ImportKeyPair'                       : { type:'aws', url:'/aws/ec2/keypair/',	method:'ImportKeyPair',	params:['username', 'session_id', 'region_name', 'key_name', 'key_data']   },
		'kp_DescribeKeyPairs'                    : { type:'aws', url:'/aws/ec2/keypair/',	method:'DescribeKeyPairs',	params:['username', 'session_id', 'region_name', 'key_names', 'filters']   },
		'kp_upload'                              : { type:'aws', url:'/aws/ec2/keypair/',	method:'upload',	params:['username', 'session_id', 'region_name', 'key_name', 'key_data']   },
		'kp_download'                            : { type:'aws', url:'/aws/ec2/keypair/',	method:'download',	params:['username', 'session_id', 'region_name', 'key_name']   },
		'kp_remove'                              : { type:'aws', url:'/aws/ec2/keypair/',	method:'remove',	params:['username', 'session_id', 'region_name', 'key_name']   },
		'kp_list'                                : { type:'aws', url:'/aws/ec2/keypair/',	method:'list',	params:['username', 'session_id', 'region_name']   },
		'pg_CreatePlacementGroup'                : { type:'aws', url:'/aws/ec2/placementgroup/',	method:'CreatePlacementGroup',	params:['username', 'session_id', 'region_name', 'group_name', 'strategy']   },
		'pg_DeletePlacementGroup'                : { type:'aws', url:'/aws/ec2/placementgroup/',	method:'DeletePlacementGroup',	params:['username', 'session_id', 'region_name', 'group_name']   },
		'pg_DescribePlacementGroups'             : { type:'aws', url:'/aws/ec2/placementgroup/',	method:'DescribePlacementGroups',	params:['username', 'session_id', 'region_name', 'group_names', 'filters']   },
		'sg_CreateSecurityGroup'                 : { type:'aws', url:'/aws/ec2/securitygroup/',	method:'CreateSecurityGroup',	params:['username', 'session_id', 'region_name', 'group_name', 'group_desc', 'vpc_id']   },
		'sg_DeleteSecurityGroup'                 : { type:'aws', url:'/aws/ec2/securitygroup/',	method:'DeleteSecurityGroup',	params:['username', 'session_id', 'region_name', 'group_name', 'group_id']   },
		'sg_AuthorizeSecurityGroupIngress'       : { type:'aws', url:'/aws/ec2/securitygroup/',	method:'AuthorizeSecurityGroupIngress',	params:['username', 'session_id', 'region_name', 'group_name', 'group_id', 'ip_permissions']   },
		'sg_RevokeSecurityGroupIngress'          : { type:'aws', url:'/aws/ec2/securitygroup/',	method:'RevokeSecurityGroupIngress',	params:['username', 'session_id', 'region_name', 'group_name', 'group_id', 'ip_permissions']   },
		'sg_DescribeSecurityGroups'              : { type:'aws', url:'/aws/ec2/securitygroup/',	method:'DescribeSecurityGroups',	params:['username', 'session_id', 'region_name', 'group_names', 'group_ids', 'filters']   },
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
