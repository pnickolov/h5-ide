define({
	'login' : {
		'login'          : 'Log In',
		'login-register' : 'New to MadeiraCloud? ',
		'link-register'  : 'Register',
		'error-msg-1'    : 'Username or email does not match the password.',
		'error-msg-2'    : 'Hey, you fogot to provide a username or email.',
		'link-foget'     : 'Forgot your Password?',
		'login-user'     : 'Username or email',
		'login-password' : 'Password',
		'login-btn'      : 'Log In',
		'login-loading'  : 'Logging In'
	},
	'ide' : {
		'dashboard' : 'Dashboard',
		'account-settings' : 'Account Settings',

		/******resource panel module******/
		'RES_TIT_RESOURCES'           : 'Resources',
		'RES_TIT_AZ'                  : 'Availability Zone',
		'RES_TIT_AMI'                 : 'AMIs',
		'RES_LBL_QUICK_START_AMI'     : 'Quick Start AMIs',
		'RES_LBL_MY_AMI'              : 'My AMIs',
		'RES_LBL_FAVORITE_AMI'        : 'Favorite AMIs',
		'RES_BTN_BROWSE_COMMUNITY_AMI': '[Browse Community AMIs]',
		'RES_TIT_VOL'                 : 'Volume & Snapshot',
		'RES_TIT_ELB_ASG'             : 'ELB & AutoScaling',
		'RES_TIT_VPC'                 : 'VPC',
		'RES_LBL_NEW_VOL'             : 'New Volume',
		'RES_LBL_NEW_ELB'             : 'New ELB',
		'RES_LBL_NEW_SUBNET'          : 'New Subnet',
		'RES_LBL_NEW_RTB'             : 'New RouteTable',
		'RES_LBL_NEW_IGW'             : 'New Internet Gateway',
		'RES_LBL_NEW_VGW'             : 'New Virtual Gateway',
		'RES_LBL_NEW_CGW'             : 'New Customer Gateway',
		'RES_LBL_NEW_ENI'             : 'New NetworkInterface',


		/******canvas module******/
		'CVS_MSG_WARN_NOTMATCH_VOLUME'          : 'Drop volume or snapshot on instance to attach.',
		'CVS_MSG_WARN_NOTMATCH_SUBNET'          : 'Subnet must be dropped within availability zone.',
		'CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET' : 'Instance must be dropped in subnet.',
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
		'PROP_MSG_WARN_REPEATED_STACK_NAME'     : 'Repeated app name.',
		'PROP_MSG_WARN_NO_APP_NAME'             : 'No app name.',
		'PROP_MSG_WARN_REPEATED_APP_NAME'       : 'Repeated app name.',
		'PROP_WARN_EXCEED_ENI_LIMIT'            : 'Instance Type: [ %s ] only support at most [ %s ] Network Interface(including the primary). Please detach extra Network Interface before changing Instance Type',

		/******navigation module******/
		'NAV_DESMOD_NOT_FINISH_LOAD'            : 'Design Module no download complete.'

	}
});
