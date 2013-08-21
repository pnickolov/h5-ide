define({
	'login' : {
		'login'          : '登录',
		'login-register' : '注册新用户？ ',
		'link-register'  : '注册',
		'error-msg-1'    : '邮件地址或用户名不正确',
		'error-msg-2'    : '邮件地址错误',
		'link-foget'     : '忘记密码？',
		'login-user'     : '邮件地址或用户名',
		'login-password' : '密码',
		'login-btn'      : '登录',
		'login-loading'  : 'Logging In'
	},
	'ide' : {
		'dashboard' : '仪表盘',
		'account-settings' : '账户设置',
		
		/** Resource Naming Conventions
		 * 
		 * AZ = 
		 * EC2 AMI = 
		 * EC2 Instance = 
		 * EBS Volume = 
		 * EBS Snapshot = 
		 * EIP = 
		 * ELB = 
		 * ASG = 
		 * KP = 
		 * VPC = 
		 * Subnet = 
		 * RT = 
		 * ENI = 
		 * IGW = 
		 * VGW = 
		 * CGW = 
		 * VPN = 
		 * 
		 */

		/******resource panel module******/
		'RES_TIT_RESOURCES'           : 'Resources',
		'RES_TIT_AZ'                  : 'Availability Zones',
		'RES_TIT_AMI'                 : 'AMIs',
		'RES_LBL_QUICK_START_AMI'     : 'Quick Start AMIs',
		'RES_LBL_MY_AMI'              : 'My AMIs',
		'RES_LBL_FAVORITE_AMI'        : 'Favorite AMIs',
		'RES_BTN_BROWSE_COMMUNITY_AMI': 'Browse Community AMIs',
		'RES_TIT_VOL'                 : 'Volume & Snapshots',
		'RES_TIT_ELB_ASG'             : 'ELB & AutoScaling',
		'RES_TIT_VPC'                 : 'VPC',
		'RES_LBL_NEW_VOL'             : 'New Volume',
		'RES_LBL_NEW_ELB'             : 'New ELB',
		'RES_LBL_NEW_SUBNET'          : 'New Subnet',
		'RES_LBL_NEW_RTB'             : 'New Route Table',
		'RES_LBL_NEW_IGW'             : 'New Internet Gateway',
		'RES_LBL_NEW_VGW'             : 'New Virtual Gateway',
		'RES_LBL_NEW_CGW'             : 'New Customer Gateway',
		'RES_LBL_NEW_ENI'             : 'New Network Interface',

		'RES_TIP_TOGGLE_RESOURCE_PANEL' : 'Show/Hide Resource Panel',
		'RES_TIP_DRAG_NEW_VOLUME'       : 'Drag onto an instance to attach a new volume.',
		'RES_TIP_DRAG_NEW_ELB'          : 'Drag to the canvas to create a new load balancer.',
		'RES_TIP_DRAG_NEW_ASG'          : 'Drag to the canvas to create a new autoscaling group.',
		'RES_TIP_DRAG_AZ'               : 'Drag to the canvas to use this availability zone',
		'RES_TIP_DRAG_NEW_SUBNET'       : 'Drag to a VPC to create a new subnet.',
		'RES_TIP_DRAG_NEW_RTB'          : 'Drag to a VPC to create a new route table.',
		'RES_TIP_DRAG_NEW_IGW'          : 'Drag to the canvas to create a new internet gateway.',
		'RES_TIP_DRAG_NEW_VGW'          : 'Drag to the canvas to create a new virtual gateway.',
		'RES_TIP_DRAG_NEW_CGW'          : 'Drag to the canvas to create a new customer gateway.',
		'RES_TIP_DRAG_NEW_ENI'          : 'Drag to a subnet to create a new network interface.',
		
		'RES_TIP_DRAG_HAS_IGW'          : 'This VPC already has an internet gateway.',
		'RES_TIP_DRAG_HAS_VGW'          : 'VPC can only have one VGW. There is already one VGW in current VPC.',

		/******canvas module******/
		'CVS_MSG_WARN_NOTMATCH_VOLUME'          : 'Drop volume or snapshot on instance to attach.',
		'CVS_MSG_WARN_NOTMATCH_SUBNET'          : 'Subnet must be dropped within availability zone.',
		'CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET' : 'Instance must be dropped in subnet or autoscaling group.',
		'CVS_MSG_WARN_NOTMATCH_INSTANCE_AZ'     : 'Instance must be dropped in availability zone.',
		'CVS_MSG_WARN_NOTMATCH_ENI'             : 'Network Interface must be dropped in subnet.',
		'CVS_MSG_WARN_NOTMATCH_RTB'             : 'Route table must be dropped within VPC but outside availability zone.',
		'CVS_MSG_WARN_NOTMATCH_ELB'             : 'Load balancer must be dropped within VPC but outside availability zone.',
		'CVS_MSG_WARN_NOTMATCH_CGW'             : 'Customer Gateway must be dropped outside VPC.',

		'CVS_MSG_WARN_COMPONENT_OVERLAP'        : 'There is a little overlapping. Make more space and try again.',
		'CVS_WARN_EXCEED_ENI_LIMIT'             : "[ %s ]'s Instance Type: [ %s ] only support at most [ %s ] Network Interfaces (including the primary).",
		'CVS_CFM_DEL_GROUP'                     : "Deleting [ %s ] will also remove all resources inside. Do you confirm to delete?",


		/******property module******/
		// instance property module
		'PROP_MSG_ERR_DOWNLOAD_KP_FAILED'       : 'Cannot download keypair:',
		'PROP_MSG_WARN_NO_STACK_NAME'           : 'No stack name.',
		'PROP_MSG_WARN_REPEATED_STACK_NAME'     : 'Repeated stack name.',
		'PROP_MSG_WARN_NO_APP_NAME'             : 'No app app.',
		'PROP_MSG_WARN_REPEATED_APP_NAME'       : 'Repeated app name.',
		'PROP_WARN_EXCEED_ENI_LIMIT'            : 'Instance Type: [ %s ] only support at most [ %s ] Network Interface(including the primary). Please detach extra Network Interface before changing Instance Type',

		/******navigation module******/
		'NAV_DESMOD_NOT_FINISH_LOAD'            : 'Design Module no download complete.'

	}
});
