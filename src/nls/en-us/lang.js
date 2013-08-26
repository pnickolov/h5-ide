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
		// Add new strings below this comment. Move above once English has been confirmed
	},
	'ide' : {
		'dashboard' : 'Dashboard',
		'account-settings' : 'Account Settings',
		// Add new strings below this comment. Move above once English has been confirmed

		/** RESOURCE NAMING CONVENTIONS
		 *
		 * Do not use camel case (e.g., 'KeyPair' should be 'Key Pair')
		 * If using in a sentence use lowercase (e.g., 'View your instances.')
		 *
		 * AZ = Availability Zones
		 * EC2 AMI = Image
		 * EC2 Instance = Instance
		 * EBS Volume = Volume
		 * EBS Snapshot = Snapshot
		 * EIP = Elastic IP
		 * ELB = Load Balancer
		 * ASG = Auto Scaling Group
		 * KP = Key Pair
		 * VPC = 'Virtual Private Cloud' for titles but 'VPC' in other references is OK
		 * Subnet = Subnet
		 * RT = Route Table
		 * ENI = Network Interface
		 * IGW = Internet Gateway
		 * VGW = Virtual Gateway
		 * CGW = Customer Gateway
		 * VPN = VPN
		 *
		 */

		/******resource panel module******/
		'RES_TIT_RESOURCES'           : 'Resources',
		'RES_TIT_AZ'                  : 'Availability Zones',
		'RES_TIT_AMI'                 : 'Images',
		'RES_TIT_VOL'                 : 'Volume and Snapshots',
		'RES_TIT_ELB_ASG'             : 'Load Balancer and Auto Scaling',
		'RES_TIT_VPC'                 : 'Virtual Private Cloud',
		'RES_LBL_QUICK_START_AMI'     : 'Quick Start Images',
		'RES_LBL_MY_AMI'              : 'My Images',
		'RES_LBL_FAVORITE_AMI'        : 'Favorite Images',
		'RES_LBL_NEW_VOL'             : 'New Volume',
		'RES_LBL_NEW_ELB'             : 'New Load Balancer',
		'RES_LBL_NEW_ASG'             : 'New Auto Scaling Group',
		'RES_LBL_NEW_ASG_NO_CONFIG'   : 'No Config',
		'RES_LBL_NEW_SUBNET'          : 'New Subnet',
		'RES_LBL_NEW_RTB'             : 'New Route Table',
		'RES_LBL_NEW_IGW'             : 'New Internet Gateway',
		'RES_LBL_NEW_VGW'             : 'New Virtual Gateway',
		'RES_LBL_NEW_CGW'             : 'New Customer Gateway',
		'RES_LBL_NEW_ENI'             : 'New Network Interface',
		'RES_BTN_BROWSE_COMMUNITY_AMI': 'Browse Community Images',
		// Add new strings below this comment. Move above once English has been confirmed

		'RES_TIP_TOGGLE_RESOURCE_PANEL' : 'Show/Hide Resource Panel',
		'RES_TIP_DRAG_AZ'               : 'Drag to the canvas to use this availability zone',
		'RES_TIP_DRAG_NEW_VOLUME'       : 'Drag onto an instance to attach a new volume.',
		'RES_TIP_DRAG_NEW_ELB'          : 'Drag to the canvas to create a new load balancer.',
		'RES_TIP_DRAG_NEW_ASG'          : 'Drag to the canvas to create a new auto scaling group.',
		'RES_TIP_DRAG_NEW_SUBNET'       : 'Drag to an availability zone to create a new subnet.',
		'RES_TIP_DRAG_NEW_RTB'          : 'Drag to a VPC to create a new route table.',
		'RES_TIP_DRAG_NEW_IGW'          : 'Drag to the canvas to create a new internet gateway.',
		'RES_TIP_DRAG_NEW_VGW'          : 'Drag to the canvas to create a new virtual gateway.',
		'RES_TIP_DRAG_NEW_CGW'          : 'Drag to the canvas to create a new customer gateway.',
		'RES_TIP_DRAG_NEW_ENI'          : 'Drag to a subnet to create a new network interface.',
		'RES_TIP_DRAG_HAS_IGW'          : 'This VPC already has an internet gateway.',
		'RES_TIP_DRAG_HAS_VGW'          : 'This VPC already has a virtual gateway.',
		// Add new strings below this comment. Move above once English has been confirmed

		/******canvas module******/
		'CVS_MSG_WARN_NOTMATCH_VOLUME'          : 'Volumes and snapshots must be dragged to an instance or image.',
		'CVS_MSG_WARN_NOTMATCH_SUBNET'          : 'Subnets must be dragged to an availability zone.',
		'CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET' : 'Instances must be dragged to a subnet or auto scaling group.',
		'CVS_MSG_WARN_NOTMATCH_INSTANCE_AZ'     : 'Instances must be dragged to an availability zone.',
		'CVS_MSG_WARN_NOTMATCH_ENI'             : 'Network interfaces must be dragged to a subnet.',
		'CVS_MSG_WARN_NOTMATCH_RTB'             : 'Route tables must be dragged inside a VPC but outside an availability zone.',
		'CVS_MSG_WARN_NOTMATCH_ELB'             : 'Load balancers must be dragged inside a VPC but outside an availability zone.',
		'CVS_MSG_WARN_NOTMATCH_CGW'             : 'Customer gateways must be dragged outside the VPC.',
		'CVS_MSG_WARN_COMPONENT_OVERLAP'        : 'Nodes cannot overlap eachother.',
		'CVS_WARN_EXCEED_ENI_LIMIT'             : "%s's type %s supports a maximum of %s network interfaces (including the primary).",
		'CVS_MSG_ERR_CONNECT_ENI_AMI'           : 'Network interfaces can only be attached to an instance in the same availability zone.',
		'CVS_MSG_ERR_MOVE_ATTACHED_ENI'         : 'Network interfaces must be in the same availability zone as the instance they are attached to.',
		'CVS_MSG_ERR_DROP_ASG'                  : '%s is already in %s.',
		'CVS_MSG_ERR_DEL_LC'                    : 'Currently modifying the launch configuration is not supported.',
		'CVS_MSG_ERR_DEL_MAIN_RT'               : 'The main route table %s cannot be deleted. Please set another route table as the main and try again.',
		'CVS_MSG_ERR_DEL_LINKED_RT'             : 'Subnets must be associated to a route table. Please associate the subnets with another route table first.',
		'CVS_MSG_ERR_DEL_SBRT_LINE'             : 'Subnets must be associated with a route table.',
		'CVS_MSG_ERR_DEL_LINKED_ELB'            : 'This subnet cannot be deleted because it is associated to a load balancer.',
		'CVS_CFM_DEL'                           : 'Are you sure you want to delete %s?',
		'CVS_CFM_DEL_IGW'                       : 'Internet-facing load balancers and elastic IPs will not function without an internet gateway, are you sure you want to delete it?',
		'CVS_CFM_DEL_GROUP'                     : "Deleting %s will also remove all resources inside it. Are you sure you want to delete it?",
		'CVS_CFM_DEL_ASG'                       : 'Deleting this will delete the entire %s. Are you sure you want to delete it?',
		'CVS_CFM_ADD_IGW'                       : 'An Internet Gateway is Required',
		'CVS_CFM_ADD_IGW_MSG'                   : 'Automatically add an internet gateway to allow this %s to be publicly addressable?',
		// Add new strings below this comment. Move above once English has been confirmed


		/******property module******/
		// instance property module
		'PROP_MSG_ERR_DOWNLOAD_KP_FAILED'       : 'Sorry, there was a problem downloading this key pair.',
		'PROP_MSG_WARN_NO_STACK_NAME'           : 'Stack name empty or missing.',
		'PROP_MSG_WARN_REPEATED_STACK_NAME'     : 'This stack name is already in use.',
		'PROP_MSG_WARN_NO_APP_NAME'             : 'App name empty or missing.',
		'PROP_MSG_WARN_REPEATED_APP_NAME'       : 'This app name is already in use.',
		'PROP_WARN_EXCEED_ENI_LIMIT'            : 'Instance type %s supports a maximum of %s network interfaces (including the primary). Please detach additional network interfaces before changing instance type.',
		// Add new strings below this comment. Move above once English has been confirmed

		/******navigation module******/
		'NAV_DESMOD_NOT_FINISH_LOAD'            : 'Sorry, there was an error loading the designer. Please check your connection and try again or contact support@madeiracloud.com',
		// Add new strings below this comment. Move above once English has been confirmed

		/****** miscellaneous ******/
		'CFM_BTN_DELETE'   : 'Delete',
		'CFM_BTN_CANCEL'   : 'Cancel',
		'CFM_BTN_ADD'      : 'Add',
		'CFM_BTN_DONT_ADD' : "Don't add"
		// Add new strings below this comment. Move above once English has been confirmed
	},
	'service' : {
		'ERROR_CODE_1_MESSAGE' : 'Service Message',
		'ERROR_CODE_2_MESSAGE' : 'Service Message',
		'ERROR_CODE_3_MESSAGE' : 'Service Message',
		'ERROR_CODE_4_MESSAGE' : 'Service Message',
		'ERROR_CODE_5_MESSAGE' : 'Service Message',
		'ERROR_CODE_6_MESSAGE' : 'Service Message',
		'ERROR_CODE_7_MESSAGE' : 'Service Message',
		'ERROR_CODE_8_MESSAGE' : 'Service Message',
		'ERROR_CODE_9_MESSAGE' : 'Service Message',
		'ERROR_CODE_10_MESSAGE' : 'Service Message',
		'ERROR_CODE_11_MESSAGE' : 'Service Message',
		'ERROR_CODE_12_MESSAGE' : 'Service Message',
		'ERROR_CODE_13_MESSAGE' : 'Service Message',
		'ERROR_CODE_14_MESSAGE' : 'Service Message',
		'ERROR_CODE_15_MESSAGE' : 'Service Message',
		'ERROR_CODE_16_MESSAGE' : 'Service Message',
		'ERROR_CODE_17_MESSAGE' : 'Service Message',
		'ERROR_CODE_18_MESSAGE' : 'Service Message',
		'ERROR_CODE_19_MESSAGE' : 'Service Message',
		'ERROR_CODE_20_MESSAGE' : 'Service Message',
		'ERROR_CODE_21_MESSAGE' : 'Service Message'
	}
});
