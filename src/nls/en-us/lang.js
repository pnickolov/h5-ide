define({
	'login' : {
		'login'          : 'Log In',
		'login-register' : 'New to MadeiraCloud? ',
		'link-register'  : 'Register',
		'error-msg-1'    : 'Username or email does not match the password.',
		'error-msg-2'    : 'Hey, you forgot to enter a username or email.',
		'link-foget'     : 'Forgot your Password?',
		'login-user'     : 'Username or email',
		'login-password' : 'Password',
		'login-btn'      : 'Log In',
		'login-loading'  : 'Logging In'
		// Add new strings below this comment. Move above once English has been confirmed
	},
	'ide' : {
		'NAV_TIT_DASHBOARD' : 'Dashboard',
		'NAV_TIT_APPS'      : 'Apps',
		'NAV_TIT_STACKS'    : 'Stacks',
		'NAV_LBL_GLOBAL'    : 'Global',
		'account-settings'  : 'Account Settings',
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
		'CVS_MSG_ERR_DEL_ELB_INSTANCE_LINE'     : 'Load balancer must attach to one subnet per Availability Zone.',
		'CVS_MSG_ERR_DEL_LINKED_ELB'            : 'This subnet cannot be deleted because it is associated to a load balancer.',
		'CVS_CFM_DEL'                           : 'Delete %s',
		'CVS_CFM_DEL_IGW'                       : 'Internet-facing load balancers and elastic IPs will not function without an internet gateway. Are you sure you want to delete it?',
		'CVS_CFM_DEL_GROUP'                     : "Deleting %s will also remove all resources inside it. Are you sure you want to delete it?",
		'CVS_CFM_DEL_ASG'                       : 'Deleting this will delete the entire %s. Are you sure you want to delete it?',
		'CVS_CFM_ADD_IGW'                       : 'An Internet Gateway is Required',
		'CVS_CFM_ADD_IGW_MSG'                   : 'Automatically add an internet gateway to allow this %s to be publicly addressable?',
		'CVS_MSG_ERR_ZOOMED_DROP_ERROR'         : 'Please reset the zoom to 100% before adding new resources.',
		'CVS_TIP_EXPAND_W'   					: 'Increase Canvas Width',
		'CVS_TIP_SHRINK_W'   					: 'Decrease Canvas Width',
		'CVS_TIP_EXPAND_H'   					: 'Increase Canvas Height',
		'CVS_TIP_SHRINK_H'   					: 'Decrease Canvas Height',
		// Add new strings below this comment. Move above once English has been confirmed


		/****** toolbar module ******/
		// Add new strings below this comment. Move above once English has been confirmed

		//run stack
		'TOOL_BTN_RUN_STACK'                    : 'Run Stack',
		'TOOL_TIP_BTN_RUN_STACK'                : 'Run this stack into an app',
		'TOOL_POP_TIT_RUN_STACK'                : 'Run Stack',

		//save stack
		'TOOL_TIP_SAVE_STACK'                   : 'Save Stack',

		//delete stack
		'TOOL_TIP_DELETE_STACK'                 : 'Delete Stack',
		'TOOL_TIP_DELETE_NEW_STACK'             : 'This stack is not saved yet.',
		'TOOL_POP_TIT_DELETE_STACK'             : 'Delete Stack',
		'TOOL_POP_BODY_DELETE_STACK'            : 'Do you confirm to delete stack',
		'TOOL_POP_BTN_DELETE_STACK'             : 'Delete',

		//duplicate stack
		'TOOL_TIP_DUPLICATE_STACK'              : 'Duplicate Stack',
		'TOOL_POP_TIT_DUPLICATE_STACK'          : 'Duplicate Stack',
		'TOOL_POP_BODY_DUPLICATE_STACK'         : 'New Stack Name:',
		'TOOL_POP_BTN_DUPLICATE_STACK'          : 'Duplicate',

		//create stack
		'TOOL_TIP_CREATE_STACK'                 : 'Create New Stack',

		//zoom
		'TOOL_TIP_ZOOM_IN'                      : 'Zoom In',
		'TOOL_TIP_ZOOM_OUT'                     : 'Zoom Out',

		//export
		'TOOL_EXPORT'                           : 'Export...',
		'TOOL_EXPORT_AS_JSON'                   : 'Export as JSON',
		'TOOL_POP_TIT_EXPORT_AS_JSON'           : 'Export JSON',
		'TOOL_POP_BODY_EXPORT_AS_JSON'          : 'Do you confirm to download the json file?',
		'TOOL_POP_BTN_DOWNLOAD'                 : 'Download',
		'TOOL_EXPORT_AS_PNG'                    : 'Export as PNG',

		//stop app
		'TOOL_TIP_STOP_APP'                     : "Stop this app's resources.",
		'TOOL_POP_TIT_STOP_APP'                 : 'Confirm to stop app',
		'TOOL_POP_BODY_STOP_APP'                : 'Do you confirm to stop app',
		'TOOL_POP_BTN_STOP_APP'                 : 'Stop',

		//start app
		'TOOL_TIP_START_APP'                    : "Start this app's resources.",
		'TOOL_POP_TIT_START_APP'                : 'Confirm to start app',
		'TOOL_POP_BODY_START_APP'               : 'Do you confirm to start app',
		'TOOL_POP_BTN_START_APP'                : 'Start',

		//terminate app
		'TOOL_TIP_TERMINATE_APP'                : "Permanently terminate this app's resources",
		'TOOL_POP_TIT_TERMINATE_APP'            : 'Confirm to terminate app',
		'TOOL_POP_BODY_TERMINATE_APP'           : 'Do you confirm to terminate app?',
		'TOOL_POP_BTN_TERMINATE_APP'            : 'Terminate',

		/******property module******/
		// instance property module
		'PROP_MSG_ERR_DOWNLOAD_KP_FAILED'       : 'Sorry, there was a problem downloading this key pair.',
		'PROP_MSG_WARN_NO_STACK_NAME'           : 'Stack name empty or missing.',
		'PROP_MSG_WARN_REPEATED_STACK_NAME'     : 'This stack name is already in use.',
		'PROP_MSG_WARN_NO_APP_NAME'             : 'App name empty or missing.',
		'PROP_MSG_WARN_REPEATED_APP_NAME'       : 'This app name is already in use.',
		'PROP_MSG_WARN_INVALID_APP_NAME'		: 'App name is invalid.',
		'PROP_WARN_EXCEED_ENI_LIMIT'            : 'Instance type %s supports a maximum of %s network interfaces (including the primary). Please detach additional network interfaces before changing instance type.',
		'PROP_TEXT_DEFAULT_SG_DESC'             : 'VPC Default Security Group',
		'PROP_TEXT_CUSTOM_SG_DESC'              : 'Custom Security Group',
		// Add new strings below this comment. Move above once English has been confirmed

		// sg property
		'PROP_MSG_SG_CREATE'                    : "1 rule has been created in %s to allow %s %s %s.",
		'PROP_MSG_SG_CREATE_MULTI'              : "%d rules have been created in %s and %s to allow %s %s %s.",
		'PROP_MSG_SG_CREATE_SELF'               : "%d rules have been created in %s to allow %s send and receive traffic within itself.",

		/******navigation module******/
		'NAV_DESMOD_NOT_FINISH_LOAD'            : 'Sorry, there was an error loading the designer. Please check your connection and try again or contact support@madeiracloud.com',
		// Add new strings below this comment. Move above once English has been confirmed

		/****** process module ******/
		'PROC_TITLE'                 : 'Starting your app...',
		'PROC_RLT_DONE_TITLE'        : 'Everything went smoothly!',
		'PROC_RLT_DONE_SUB_TITLE'    : 'Your app will automatically open soon.',
		'PROC_STEP_PREPARE'          : 'Preparing to start app...',
		'PROC_RLT_FAILED_TITLE'      : 'Error Starting App.',
		'PROC_RLT_FAILED_SUB_TITLE'  : 'Please fix the following issues and try again:',
		'PROC_ERR_INFO'              : 'Error Details',
		'PROC_CLOSE_TAB'             : 'Close Tab',
		'PROC_STEP_REQUEST'          : 'Processing',
		// Add new strings below this comment. Move above once English has been confirmed

		/****** miscellaneous ******/
		'CFM_BTN_DELETE'   : 'Delete',
		'CFM_BTN_CANCEL'   : 'Cancel',
		'CFM_BTN_ADD'      : 'Add',
		'CFM_BTN_DONT_ADD' : "Don't add"
		// Add new strings below this comment. Move above once English has been confirmed
	},
	'service' : {
		'ERROR_CODE_0_MESSAGE'  : '',//invoke API succeeded
		'ERROR_CODE_1_MESSAGE'  : 'No data',
		'ERROR_CODE_2_MESSAGE'  : 'Invalid API Parameters',
		'ERROR_CODE_3_MESSAGE'  : '',//no use
		'ERROR_CODE_4_MESSAGE'  : '',//no use
		'ERROR_CODE_5_MESSAGE'  : 'Request AWS resource exception',
		'ERROR_CODE_6_MESSAGE'  : '',//no use
		'ERROR_CODE_7_MESSAGE'  : '',//for guest
		'ERROR_CODE_8_MESSAGE'  : '',//no use
		'ERROR_CODE_9_MESSAGE'  : 'Insufficient permissions',
		'ERROR_CODE_10_MESSAGE' : '',//no use
		'ERROR_CODE_11_MESSAGE' : '',//no use
		'ERROR_CODE_12_MESSAGE' : 'Sorry, we are suffering from some technical issues, please try again later',
		'ERROR_CODE_13_MESSAGE' : '',//no use
		'ERROR_CODE_14_MESSAGE' : '',//no use
		'ERROR_CODE_15_MESSAGE' : 'Unknown AWS Error',
		'ERROR_CODE_16_MESSAGE' : 'Sorry, AWS is suffering from some technical issues, please try again later',
		'ERROR_CODE_17_MESSAGE' : '',//no use
		'ERROR_CODE_18_MESSAGE' : 'Invalid API Parameters',
		'ERROR_CODE_19_MESSAGE' : 'Invalid session, please login again',
		'ERROR_CODE_20_MESSAGE' : 'Sorry, this invitation has finished',//for guest
		'ERROR_CODE_21_MESSAGE' : 'User has been blocked',
		'ERROR_CODE_21_MESSAGE' : ''//no use
		// Add new strings below this comment. Move above once English has been confirmed
	}
});
