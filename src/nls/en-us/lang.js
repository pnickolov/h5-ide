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

		/******ide******/
		// Add new strings below this comment. Move above once English has been confirmed
		'IDE_MSG_ERR_OPEN_TAB'        : 'Unable to open the stack/app, please try again',
		'IDE_MSG_ERR_CONNECTION'      : 'Unable to load some parts of the IDE, please refresh the browser',

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
		'RES_LBL_NEW_ELB'             : 'Load Balancer',
		'RES_LBL_NEW_ASG'             : 'Auto Scaling Group',
		'RES_LBL_NEW_ASG_NO_CONFIG'   : 'No Config',
		'RES_LBL_NEW_SUBNET'          : 'Subnet',
		'RES_LBL_NEW_RTB'             : 'Route Table',
		'RES_LBL_NEW_IGW'             : 'Internet Gateway',
		'RES_LBL_NEW_VGW'             : 'Virtual Gateway',
		'RES_LBL_NEW_CGW'             : 'Customer Gateway',
		'RES_LBL_NEW_ENI'             : 'Network Interface',
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

		'RES_MSG_WARN_GET_COMMUNITY_AMI_FAILED'		: 'Unable to load community AMIs',
		'RES_MSG_INFO_ADD_AMI_FAVORITE_SUCCESS'		: 'AMI is added to Favorite AMI',
		'RES_MSG_ERR_ADD_FAVORITE_AMI_FAILED'		: 'Failed to add AMI to Favorite',
		'RES_MSG_INFO_REMVOE_FAVORITE_AMI_SUCCESS'	: 'AMI is removed from Favorite AMI',
		'RES_MSG_ERR_REMOVE_FAVORITE_AMI_FAILED'	: 'Failed to remove AMI from Favorite',
		// Add new strings below this comment. Move above once English has been confirmed

		/******canvas module******/
		'CVS_MSG_WARN_NOTMATCH_VOLUME'          : 'Volumes and snapshots must be dragged to an instance or image.',
		'CVS_MSG_WARN_NOTMATCH_SUBNET'          : 'Subnets must be dragged to an availability zone.',
		'CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET' : 'Instances must be dragged to a subnet or auto scaling group.',
		'CVS_MSG_WARN_NOTMATCH_INSTANCE_AZ'     : 'Instances must be dragged to an availability zone.',
		'CVS_MSG_WARN_NOTMATCH_ENI'             : 'Network interfaces must be dragged to a subnet.',
		'CVS_MSG_WARN_NOTMATCH_RTB'             : 'Route tables must be dragged inside a VPC but outside an availability zone.',
		'CVS_MSG_WARN_NOTMATCH_ELB'             : 'Load balancer must be dropped outside availability zone.',
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
		'CVS_TIP_EXPAND_W'						: 'Increase Canvas Width',
		'CVS_TIP_SHRINK_W'						: 'Decrease Canvas Width',
		'CVS_TIP_EXPAND_H'						: 'Increase Canvas Height',
		'CVS_TIP_SHRINK_H'						: 'Decrease Canvas Height',
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
		'TOOL_EXPORT_AS_JSON'                   : 'Export to JSON',
		'TOOL_POP_TIT_EXPORT_AS_JSON'           : 'Export',
		'TOOL_POP_BODY_EXPORT_AS_JSON'          : 'Do you confirm to download this file?',
		'TOOL_POP_BTN_DOWNLOAD'                 : 'Download',
		'TOOL_EXPORT_AS_PNG'                    : 'Export to PNG',

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
		'TOOL_POP_BODY_TERMINATE_APP'           : 'Do you confirm to terminate app',
		'TOOL_POP_BTN_TERMINATE_APP'            : 'Terminate',

		//toolbar handler
		'TOOL_MSG_INFO_REQ_SUCCESS'             : 'Sending request to %s %s...',
		'TOOL_MSG_ERR_REQ_FAILED'               : 'Sending request to %s %s failed.',
		'TOOL_MSG_INFO_HDL_SUCCESS'             : '%s %s successfully.',
		'TOOL_MSG_ERR_HDL_FAILED'               : '%s %s failed.',
		'TOOL_MSG_ERR_SAVE_FAILED'              : 'Save stack %s failed, please check and save it again.',
		// Add new strings below this comment. Move above once English has been confirmed
		//refresh button
		'TOOL_MSG_INFO_APP_REFRESH_FINISH'      : 'Refresh resources for app( %s ) complete.',
		'TOOL_MSG_INFO_APP_REFRESH_FAILED'      : 'Refresh resources for app( %s ) falied, please click refresh tool button to retry.',
		'TOOL_MSG_INFO_APP_REFRESH_START'       : 'Refresh resources for app( %s ) start ...',
		'TOOL_MSG_ERR_CONVERT_CLOUDFORMATION'   : 'Convert to stack json to CloudFormation format error',

		//linestyle
		'TOOL_TIP_LINESTYLE'                          : 'Security Group Rule Line Style...',
		'TOOL_LBL_LINESTYLE_STRAIGHT'                 : 'Straight',
		'TOOL_LBL_LINESTYLE_ELBOW'                    : 'Elbow',
		'TOOL_LBL_LINESTYLE_QUADRATIC_BELZIER'        : 'Quadratic Belzier curve',
		'TOOL_LBL_LINESTYLE_SMOOTH_QUADRATIC_BELZIER' : 'Smooth quadratic Belzier curve',



		/******property module******/

		'PROP_LBL_REQUIRED'                     : 'Required',

		//##### stack property module
		'PROP_STACK_LBL_NAME'                       : 'Stack Name',
		'PROP_STACK_LBL_REGION'                     : 'Region',
		'PROP_STACK_LBL_TYPE'                       : 'Type',
		'PROP_STACK_TIT_SG'                         : 'Security Groups',
		'PROP_STACK_TIT_ACL'                        : 'Network ACL',
		'PROP_STACK_TIT_SNS'                        : 'SNS Topic Subscription',
		'PROP_STACK_BTN_ADD_SUB'                    : 'Add Subscription',
		'PROP_STACK_TIT_COST_ESTIMATION'            : 'Cost Estimation',
		'PROP_STACK_LBL_COST_CYCLE'                 : 'month',
		'PROP_STACK_COST_COL_RESOURCE'              : 'Resource',
		'PROP_STACK_COST_COL_SIZE_TYPE'             : 'Size/Type',
		'PROP_STACK_COST_COL_FEE'                   : 'Fee($)',
		'PROP_STACK_LBL_AWS_EC2_PRICING'            : 'Amazon EC2 Pricing',
		'PROP_STACK_ACL_LBL_RULE'                   : 'rules',
		'PROP_STACK_ACL_LBL_ASSOC'                  : 'associations',
		'PROP_STACK_ACL_BTN_DELETE'                 : 'Delete',
		'PROP_STACK_ACL_TIP_DETAIL'                 : 'Go to Network ACL Details',
		'PROP_STACK_BTN_CREATE_NEW_ACL'             : 'Create new Network ACL...',
		//##### stack property module


		//##### app property module
		'PROP_APP_SNS_NONE'                         : 'This app has no SNS Topic',
		//##### app property module


		//##### az property module
		'PROP_AZ_LBL_SWITCH'                            : 'Quick Switch Availability Zone',
		//##### az property module


		//##### vpc property module
		'PROP_VPC_TIT_DETAIL'                                            : 'VPC Details',
		'PROP_VPC_DETAIL_LBL_NAME'                                       : 'Name',
		'PROP_VPC_DETAIL_LBL_CIDR_BLOCK'                                 : 'CIDR Block',
		'PROP_VPC_DETAIL_LBL_TENANCY'                                    : 'Tenancy',
		'PROP_VPC_DETAIL_TENANCY_LBL_DEFAULT'                            : 'Default',
		'PROP_VPC_DETAIL_TENANCY_LBL_DEDICATED'                          : 'Dedicated',
		'PROP_VPC_DETAIL_LBL_ENABLE_DNS_RESOLUTION'                      : 'Enable DNS resolution',
		'PROP_VPC_DETAIL_LBL_ENABLE_DNS_HOSTNAME_SUPPORT'                : 'Enable DNS hostname support',
		'PROP_VPC_TIT_DHCP_OPTION'                                       : 'DHCP Options',
		'PROP_VPC_DHCP_LBL_NONE'                                         : 'None',
		'PROP_VPC_DHCP_LBL_DEFAULT'                                      : 'Default DHCP',
		'PROP_VPC_DHCP_LBL_SPECIFIED'                                    : 'Specified DHCP Options Set',
		'PROP_VPC_DHCP_SPECIFIED_LBL_DOMAIN_NAME'                        : 'Domain Name',
		'PROP_VPC_DHCP_SPECIFIED_LBL_DOMAIN_NAME_SERVER'                 : 'Domain Name Server',
		'PROP_VPC_DHCP_SPECIFIED_LBL_AMZN_PROVIDED_DNS'                  : 'AmazonProvidedDNS',
		'PROP_VPC_DHCP_SPECIFIED_LBL_NTP_SERVER'                         : 'NTP Server',
		'PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NAME_SERVER'                : 'NetBIOS Name Server',
		'PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE'                  : 'NetBIOS Node Type',
		'PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE_NOT_SPECIFIED'    : 'Not specified',
		'PROP_VPC_APP_VPC_ID'                                            : 'VPC ID',
		'PROP_VPC_APP_STATE'                                             : 'State',
		'PROP_VPC_APP_CIDR'                                              : 'CIDR',
		'PROP_VPC_APP_MAIN_RT'                                           : 'Main Route Table',
		'PROP_VPC_APP_DEFAULT_ACL'                                       : 'Default Network ACL',
		'PROP_VPC_DHCP_OPTION_SET_ID'                                    : 'DHCP Options Set ID',
		//##### vpc property module


		//##### subnet property module
		'PROP_SUBNET_TIT_DETAIL'                                         : 'Subnet Details',
		'PROP_SUBNET_DETAIL_LBL_NAME'                                    : 'Name',
		'PROP_SUBNET_DETAIL_LBL_CIDR_BLOCK'                              : 'CIDR Block',
		'PROP_SUBNET_TIT_ASSOC_ACL'                                      : 'Associated Network ACL',
		'PROP_SUBNET_BTN_CREATE_NEW_ACL'                                 : 'Create new Network ACL...',
		'PROP_SUBNET_ACL_LBL_RULE'                                       : 'rules',
		'PROP_SUBNET_ACL_LBL_ASSOC'                                      : 'associations',
		'PROP_SUBNET_ACL_BTN_DELETE'                                     : 'Delete',
		'PROP_SUBNET_ACL_TIP_DETAIL'                                     : 'Go to Network ACL Details',
		'PROP_SUBNET_APP_ID'                                             : 'Subnet ID',
		'PROP_SUBNET_APP_STATE'                                          : 'State',
		'PROP_SUBNET_APP_CIDR'                                           : 'CIDR',
		'PROP_SUBNET_APP_AVAILABLE_IP'                                   : 'Available IPs',
		'PROP_SUBNET_APP_VPC_ID'                                         : 'VPC ID',
		'PROP_SUBNET_APP_RT_ID'                                          : 'Route Table ID',
		//##### subnet property module


		//##### sg property module
		'PROP_SG_TIT_DETAIL'                                             : 'Security Group Details',
		'PROP_SG_DETAIL_LBL_NAME'                                        : 'Name',
		'PROP_SG_DETAIL_LBL_DESCRIPTION'                                 : 'Description',
		'PROP_SG_TIT_RULE'                                               : 'Rule',
		'PROP_SG_RULE_SORT_BY'                                           : 'Sort by',
		'PROP_SG_RULE_SORT_BY_DIRECTION'                                 : 'Direction',
		'PROP_SG_RULE_SORT_BY_SRC_DEST'                                  : 'Source/Destination',
		'PROP_SG_RULE_SORT_BY_PROTOCOL'                                  : 'Protocol',
		'PROP_SG_TIT_MEMBER'                                             : 'Member',
		'PROP_SG_TIP_CREATE_RULE'                                        : 'Create rule referencing IP Range',
		'PROP_SG_TIP_REMOVE_RULE'                                        : 'Remove rule',
		'PROP_SG_TIP_PROTOCOL'                                           : 'Protocol',
		'PROP_SG_TIP_SRC'                                                : 'Source',
		'PROP_SG_TIP_DEST'                                               : 'Destination',
		'PROP_SG_TIP_INBOUND'                                            : 'Inbound',
		'PROP_SG_TIP_OUTBOUND'                                           : 'Outbound',
		'PROP_SG_TIP_PORT_CODE'                                          : 'Port or Code',
		'PROP_SG_APP_SG_ID'                                              : 'Security Group ID',
		'PROP_SG_APP_VPC_ID'                                             : 'VPC ID',
		//##### sg property module


		//##### sg list property module
		'PROP_SGLIST_LBL_RULE'                                           : 'rules',
		'PROP_SGLIST_LBL_MEMBER'                                         : 'members',
		'PROP_SGLIST_LNK_DELETE'                                         : 'Delete',
		'PROP_SGLIST_TIP_VIEW_DETAIL'                                    : 'View details',
		'PROP_SGLIST_BTN_CREATE_NEW_SG'                                  : 'Create new Security Group...',
		'PROP_SGLIST_TAB_GROUP'                                          : 'Group',
		'PROP_SGLIST_TAB_RULE'                                           : 'Rule',
		//##### sg list property module


		//##### sg rule property module
		'PROP_SGRULE_DESCRIPTION'                                        : 'The selected connection reflects following security group rule(s):',
		'PROP_SGRULE_TIP_INBOUND'                                        : 'Inbound',
		'PROP_SGRULE_TIP_OUTBOUND'                                       : 'Outbound',
		'PROP_SGRULE_BTN_EDIT_RULE'                                      : 'Edit Related Rule',
		//##### sg rule property module


		//##### acl property module
		'PROP_ACL_LBL_NAME'                                              : 'Name',
		'PROP_ACL_TIT_RULE'                                              : 'Rule',
		'PROP_ACL_BTN_CREATE_NEW_RULE'                                   : 'Create new Network ACL Rule',
		'PROP_ACL_RULE_SORT_BY'                                          : 'Sort by',
		'PROP_ACL_RULE_SORT_BY_NUMBER'                                   : 'Rule Number',
		'PROP_ACL_RULE_SORT_BY_ACTION'                                   : 'Action',
		'PROP_ACL_RULE_SORT_BY_DIRECTION'                                : 'Direction',
		'PROP_ACL_RULE_SORT_BY_SRC_DEST'                                 : 'Source/Destination',
		'PROP_ACL_TIP_ACTION_ALLOW'                                      : 'allow',
		'PROP_ACL_TIP_ACTION_DENY'                                       : 'deny',
		'PROP_ACL_TIP_INBOUND'                                           : 'Inbound',
		'PROP_ACL_TIP_OUTBOUND'                                          : 'Outbound',
		'PROP_ACL_TIP_RULE_NUMBER'                                       : 'Rule Number',
		'PROP_ACL_TIP_CIDR_BLOCK'                                        : 'CIDR Block',
		'PROP_ACL_TIP_PROTOCOL'                                          : 'Protocol',
		'PROP_ACL_TIP_PORT'                                              : 'Port',
		'PROP_ACL_TIT_ASSOC'                                             : 'Associations',
		'PROP_ACL_TIP_REMOVE_RULE'                                       : 'Remove rule',
		'PROP_ACL_APP_ID'                                                : 'Network ACL ID',
		'PROP_ACL_APP_IS_DEFAULT'                                        : 'Default',
		'PROP_ACL_APP_VPC_ID'                                            : 'VPC ID',
		//##### acl property module


		//##### vgw property module
		'PROP_VGW_TXT_DESCRIPTION'           : 'The Virtual Private Gateway is the router on the Amazon side of the VPN tunnel.',
		//##### vgw property module


		//##### vpn property module
		'PROP_VPN_LBL_IP_PREFIX'             : 'Network IP Prefixes',
		//##### vpn property module


		//##### igw property module
		'PROP_IGW_TXT_DESCRIPTION'           : 'The Internet gateway is the router on the AWS network that connects your VPC to the Internet.',
		//##### igw property module


		//##### cgw property module
		'PROP_CGW_LBL_NAME'                     : 'Name',
		'PROP_CGW_LBL_IPADDR'                   : 'IP Address',
		'PROP_CGW_LBL_ROUTING'                  : 'Routing',
		'PROP_CGW_LBL_STATIC'                   : 'Static',
		'PROP_CGW_LBL_DYNAMIC'                  : 'Dynamic',
		'PROP_CGW_LBL_BGP_ASN'                  : 'BGP ASN',
		'PROP_CGW_APP_TIT_CGW'                  : 'Customer Gateway',
		'PROP_CGW_APP_CGW_LBL_ID'               : 'ID',
		'PROP_CGW_APP_CGW_LBL_STATE'            : 'State',
		'PROP_CGW_APP_CGW_LBL_TYPE'             : 'Type',
		'PROP_CGW_APP_TIT_VPN'                  : 'VPN Connection',
		'PROP_CGW_APP_VPN_LBL_ID'               : 'ID',
		'PROP_CGW_APP_VPN_LBL_STATE'            : 'State',
		'PROP_CGW_APP_VPN_LBL_TYPE'             : 'Type',
		'PROP_CGW_APP_VPN_LBL_TUNNEL'           : 'VPN Tunnels',
		'PROP_CGW_APP_VPN_COL_TUNNEL'           : 'Tunnel',
		'PROP_CGW_APP_VPN_COL_IP'               : 'IP Address',
		'PROP_CGW_APP_VPN_LBL_STATUS_RT'        : 'Status Routes',
		'PROP_CGW_APP_VPN_COL_IP_PREFIX'        : 'IP Prefixes',
		'PROP_CGW_APP_VPN_COL_SOURCE'           : 'Source',
		'PROP_CGW_APP_TIT_DOWNLOAD_CONF'        : 'Download Configuration',
		'PROP_CGW_APP_DOWN_LBL_VENDOR'          : 'Vendor',
		'PROP_CGW_APP_DOWN_LBL_PLATFORM'        : 'Platform',
		'PROP_CGW_APP_DOWN_LBL_SOFTWARE'        : 'Software',
		'PROP_CGW_APP_DOWN_LBL_GENERIC'         : 'Generic',
		'PROP_CGW_APP_DOWN_LBL_VENDOR_AGNOSTIC' : 'Vendor Agnostic',
		'PROP_CGW_APP_DOWN_BTN_DOWNLOAD'        : 'Download',
		//##### cgw property module


		'PROP_MSG_ERR_DOWNLOAD_KP_FAILED'       : 'Sorry, there was a problem downloading this key pair.',
		'PROP_MSG_WARN_NO_STACK_NAME'           : 'Stack name empty or missing.',
		'PROP_MSG_WARN_REPEATED_STACK_NAME'     : 'This stack name is already in use.',
		'PROP_MSG_WARN_ENI_IP_EXTEND'           : '%s Instance\'s Network Interface can\'t exceed %s Private IP Addresses.',
		'PROP_MSG_WARN_NO_APP_NAME'             : 'App name empty or missing.',
		'PROP_MSG_WARN_REPEATED_APP_NAME'       : 'This app name is already in use.',
		'PROP_MSG_WARN_INVALID_APP_NAME'		: 'App name is invalid.',
		'PROP_WARN_EXCEED_ENI_LIMIT'            : 'Instance type %s supports a maximum of %s network interfaces (including the primary). Please detach additional network interfaces before changing instance type.',
		'PROP_TEXT_DEFAULT_SG_DESC'             : 'Stack Default Security Group',
		'PROP_TEXT_CUSTOM_SG_DESC'              : 'Custom Security Group',
		'PROP_MSG_WARN_WHITE_SPACE'				: 'Stack name contains white space',
		// Add new strings below this comment. Move above once English has been confirmed

		//###### instance property module
		'PROP_INSTANCE_DETAIL'					: 'Instance Details',
		'PROP_INSTANCE_HOSTNAME'				: 'Hostname',
		'PROP_INSTANCE_NUMBER'					: 'Number of Instance',
		'PROP_INSTANCE_REQUIRE'					: 'Required',
		'PROP_INSTANCE_AMI'						: 'AMI',
		'PROP_INSTANCE_TYPE'					: 'Instance Type',
		'PROP_INSTANCE_KEY_PAIR'				: 'Key Pair',
		'PROP_INSTANCE_TENANCY'					: 'Tenancy',
		'PROP_INSTANCE_TENANCY_DEFAULT'			: 'Default',
		'PROP_INSTANCE_TENANCY_DELICATED'		: 'Delicated',
		'PROP_INSTANCE_NEW_KP'					: 'Create New Key Pair',
		'PROP_INSTANCE_CW_ENABLED'				: 'Enable CloudWatch Detailed Monitoring',
		'PROP_INSTANCE_ADVANCED_DETAIL'			: 'Advanced Details',
		'PROP_INSTANCE_USER_DATA'				: 'User Data',
		'PROP_INSTANCE_CW_WARN'					: 'Data is available in 1-minute periods at an additional cost. For information about pricing, go to the ',
		'PROP_INSTANCE_ENI_DETAIL'				: 'Network Interface Details',
		'PROP_INSTANCE_ENI_DESC'				: 'Description',
		'PROP_INSTANCE_ENI_SOURCE_DEST_CHECK'	: 'Enable Source/Destination Checking',
		'PROP_INSTANCE_ENI_AUTO_PUBLIC_IP'		: 'Automatically assign Public IP',
		'PROP_INSTANCE_ENI_IP_ADDRESS'			: 'IP Address',
		'PROP_INSTANCE_ENI_ADD_IP'				: 'Add IP',
		'PROP_INSTANCE_SG_DETAIL'				: 'Security Groups',
		//###### instance property module

		// ---
		'PROP_MSG_ERR_GET_PASSWD_FAILED'        : 'Sorry, there was a problem getting password data for instance ',
		'PROP_MSG_ERR_AMI_NOT_FOUND'            : 'Can not find information for selected AMI( %s ), try to drag another AMI.',

		// sg property
		'PROP_MSG_SG_CREATE'                    : "1 rule has been created in %s to allow %s %s %s.",
		'PROP_MSG_SG_CREATE_MULTI'              : "%d rules have been created in %s and %s to allow %s %s %s.",
		'PROP_MSG_SG_CREATE_SELF'               : "%d rules have been created in %s to allow %s send and receive traffic within itself.",

		//###### volume property
		'PROP_VOLUME_DEVICE_NAME'				: 'Device Name',
		'PROP_VOLUME_SIZE'						: 'Volume Size',
		'PROP_VOLUME_TYPE'						: 'Volume Type',
		'PROP_VOLUME_TYPE_STANDARD'				: 'Standard',
		'PROP_VOLUME_TYPE_IOPS'					: 'Provisioned IOPS',
		'PROP_VOLUME_MSG_WARN'					: 'Volume size must be at least 10 GB to use Provisioned IOPS volume type.',
		//###### volume property

		//###### eni property
		'PROP_ENI_LBL_ATTACH_WARN'				: 'Attach the Network Interface to an instance within the same availability zone.',
		'PROP_ENI_LBL_DETAIL'					: 'Network Interface Details',
		'PROP_ENI_LBL_DESC'						: 'Description',
		'PROP_ENI_SOURCE_DEST_CHECK'			: 'Enable Source/Destination Checking',
		'PROP_ENI_AUTO_PUBLIC_IP'				: 'Automatically assign Public IP',
		'PROP_ENI_IP_ADDRESS'					: 'IP Address',
		'PROP_ENI_ADD_IP'						: 'Add IP',
		'PROP_ENI_SG_DETAIL'					: 'Security Groups',

		//###### eni property

		//###### elb property
		'PROP_ELB_DETAILS'						: 'Load Balancer Details',
		'PROP_ELB_NAME'							: 'Name',
		'PROP_ELB_REQUIRED'						: 'Required',
		'PROP_ELB_SCHEME'						: 'Scheme',
		'PROP_ELB_LISTENER_DETAIL'				: 'Listener Configuration',
		'PROP_ELB_BTN_ADD_LISTENER'				: 'Add Listener',
		'PROP_ELB_BTN_ADD_SERVER_CERTIFICATE'	: 'Add Server Certificate',
		'PROP_ELB_LBL_LISTENER_NAME'			: 'Name',
		'PROP_ELB_LBL_LISTENER_PRIVATE_KEY'		: 'Private Key',
		'PROP_ELB_LBL_LISTENER_PUBLIC_KEY'		: 'Public Key Certificate',
		'PROP_ELB_LBL_LISTENER_CERTIFICATE_CHAIN': 'Certificate Chain',
		'PROP_ELB_HEALTH_CHECK_DETAILS'			: 'Health Check Configuration',
		'PROP_ELB_PING_PROTOCOL'				: 'Ping Protocol',
		'PROP_ELB_PING_PORT'					: 'Ping	Port',
		'PROP_ELB_PING_PATH'					: 'Ping Path',
		'PROP_ELB_HEALTH_CHECK_INTERVAL'		: 'Health Check Interval',
		'PROP_ELB_HEALTH_CHECK_INTERVAL_SECONDS': 'Seconds',
		'PROP_ELB_HEALTH_CHECK_RESPOND_TIMEOUT'	: 'Response Timeout',
		'PROP_ELB_HEALTH_THRESHOLD'				: 'Healthy Threshold',
		'PROP_ELB_UNHEALTH_THRESHOLD'			: 'Unhealthy Threshold',
		'PROP_ELB_AVAILABILITY_ZONE'			: 'Availability Zones',
		'PROP_ELB_SG_DETAIL'					: 'Security Groups',
		//###### elb property

		//###### autoscaling group property
		'PROP_ASG_DETAILS'						: 'Auto Scaling Group Details',
		'PROP_ASG_NAME'							: 'Name',
		'PROP_ASG_REQUIRED'						: 'Required',
		'PROP_ASG_CREATE_TIME'					: 'Create Time',
		'PROP_ASG_MIN_SIZE'						: 'Minimum Size',
		'PROP_ASG_MAX_SIZE'						: 'Maximum Size',
		'PROP_ASG_DESIRE_CAPACITY'				: 'Desired Capacity',
		'PROP_ASG_COOL_DOWN'					: 'Default Cooldown',
		'PROP_ASG_DEFAULT_COOL_DOWN'			: 'Default Cooldown',
		'PROP_ASG_INSTANCE'						: 'Instance',
		'PROP_ASG_UNIT_SECONDS'					: 'Seconds',
		'PROP_ASG_HEALTH_CHECK_TYPE'			: 'Health Check Type',
		'PROP_ASG_HEALTH_CHECK_CRACE_PERIOD'	: 'Health Check Grace Period',
		'PROP_ASG_POLICY'						: 'Policy',
		'PROP_ASG_HAS_ELB_WARN'					: 'You need to connect this auto scaling group to a load balancer to enable this option.',
		'PROP_ASG_TERMINATION_POLICY'			: 'Termination Policy',
		'PROP_ASG_POLICY_TLT_NAME'				: 'Policy Name',
		'PROP_ASG_POLICY_TLT_ALARM_METRIC'		: 'Alarm Metric',
		'PROP_ASG_POLICY_TLT_THRESHOLD'			: 'Threshold',
		'PROP_ASG_POLICY_TLT_PERIOD'			: 'Evaluation Period x Periords',
		'PROP_ASG_POLICY_TLT_ACTION'			: 'Action Trigger',
		'PROP_ASG_POLICY_TLT_ADJUSTMENT'		: 'Adjustment',
		'PROP_ASG_POLICY_TLT_EDIT'				: 'Edit Scaling Policy',
		'PROP_ASG_POLICY_TLT_REMOVE'			: 'Remove Scaling Policy',
		'PROP_ASG_BTN_ADD_SCALING_POLICY'		: 'Add Scaling Policy',
		'PROP_ASG_LBL_NOTIFICATION'				: 'Notification',
		'PROP_ASG_LBL_SEND_NOTIFICATION'		: 'Send notification via SNS topic for:',
		'PROP_ASG_LBL_SUCCESS_INSTANCES_LAUNCH'	: 'Successful instance launch',
		'PROP_ASG_LBL_FAILED_INSTANCES_LAUNCH'	: 'Failed instance launch',
		'PROP_ASG_LBL_SUCCESS_INSTANCES_TERMINATE'	: 'Successful instance termination',
		'PROP_ASG_LBL_FAILED_INSTANCES_TERMINATE'	: 'Failed instance termination',
		'PROP_ASG_LBL_VALIDATE_SNS'				: 'Validating a configuraed SNS Topic',
		'PROP_ASG_MSG_NO_NOTIFICATION_WARN'		: 'No notification configured for this auto scaling group',
		'PROP_ASG_MSG_SNS_WARN'					: 'There is no SNS subscription set up yet. Go to Stack Property to set up SNS subscription so that you will get the notification.',
		'PROP_ASG_MSG_DROP_LC'					: 'Drop AMI from Resrouce Panel to create Launch Configuration',
		'PROP_ASG_TERMINATION_EDIT'				: 'Edit Termination Policy',
		'PROP_ASG_TERMINATION_TEXT_WARN'		: 'You can either specify any one of the policies as a standalone policy, or you can list multiple policies in an ordered list. The policies are executed in the order they are listed.',
		'PROP_ASG_TERMINATION_MSG_DRAG'			: 'Drag to sort policy',
		'PROP_ASG_TERMINATION_POLICY_OLDEST'	: 'OldestInstance',
		'PROP_ASG_TERMINATION_POLICY_NEWEST'	: 'NewestInstance',
		'PROP_ASG_TERMINATION_POLICY_OLDEST_LAUNCH'	: 'OldestLaunchConfiguration',
		'PROP_ASG_TERMINATION_POLICY_CLOSEST'	: 'ClosestToNextInstanceHour',
		'PROP_ASG_ADD_POLICY_TITLE_ADD'			: 'Add',
		'PROP_ASG_ADD_POLICY_TITLE_EDIT'		: 'Edit',
		'PROP_ASG_ADD_POLICY_TITLE_CONTENT'		: 'Scaling Policy',
		'PROP_ASG_ADD_POLICY_ALARM'				: 'Alarm',
		'PROP_ASG_ADD_POLICY_WHEN'				: 'When',
		'PROP_ASG_ADD_POLICY_IS'				: 'is',
		'PROP_ASG_ADD_POLICY_FOR'				: 'for',
		'PROP_ASG_ADD_POLICY_PERIOD'			: 'periods of',
		'PROP_ASG_ADD_POLICY_SECONDS'			: 'seconds, enter ALARM state.',
		'PROP_ASG_ADD_POLICY_START_SCALING'		: 'Start scaling activity when in',
		'PROP_ASG_ADD_POLICY_STATE'				: 'state.',
		'PROP_ASG_ADD_POLICY_SCALING_ACTIVITY'	: 'Scaling Activity',
		'PROP_ASG_ADD_POLICY_ADJUSTMENT'		: 'Adjust number of instances by',
		'PROP_ASG_ADD_POLICY_ADJUSTMENT_OF'		: 'of',
		'PROP_ASG_ADD_POLICY_ADVANCED'			: 'Advanced',
		'PROP_ASG_ADD_POLICY_ADVANCED_ALARM_OPTION'	: 'Alarm Options',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC'	: 'Statistic',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_AVG'	: 'Average',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_MIN'	: 'Minimum',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_MAX'	: 'Maximum',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_SAMPLE'	: 'SampleCount',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_SUM'	: 'Sum',
		'PROP_ASG_ADD_POLICY_ADVANCED_SCALING_OPTION'	: 'Scaling Options',
		'PROP_ASG_ADD_POLICY_ADVANCED_COOLDOWN_PERIOD'	: 'Cooldown Period',
		'PROP_ASG_ADD_POLICY_ADVANCED_TIP_COOLDOWN_PERIOD'	: "The amount of time, in seconds, after a scaling activity completes before any further trigger-related scaling activities can start. If not specified, will use auto scaling group's default cooldown period.",
		'PROP_ASG_ADD_POLICY_ADVANCED_MIN_ADJUST_STEP'	: 'Minimum Adjust Step',
		'PROP_ASG_ADD_POLICY_ADVANCED_TIP_MIN_ADJUST_STEP'	: 'Changes the DesiredCapacity of the Auto Scaling group by at least the specified number of instances.',

		//###### autoscaling group property

		//###### launch configuration property
		'PROP_LC_TITLE'							: 'Launch Configuation',
		'PROP_LC_NAME'							: 'Name',
		//###### launch configuration property

		//###### route table property
		'PROP_RT_ASSOCIATION'							: 'This is an association of ',
		'PROP_RT_ASSOCIATION_TO'						: 'to',
		'PROP_RT_NAME'									: 'Name',
		'PROP_RT_LBL_ROUTE'								: 'Routes',
		'PROP_RT_LBL_MAIN_RT'							: 'Main Route Table',
		'PROP_RT_SET_MAIN'								: 'Set as Main Route Table',
		'PROP_RT_TARGET'								: 'Target',
		'PROP_RT_DESTINATION'							: 'Destination',
		//###### route table property

		/******navigation module******/
		'NAV_DESMOD_NOT_FINISH_LOAD'            : 'Sorry, the designer module is loading now. Please try again after several seconds.',


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
		'PROC_FAILED_TITLE'          :  'Starting App Failed',

		/****** region module *****/
		'REG_MSG_WARN_APP_PENDING'	 : 'Your app is in Processing. Please wait a moment.',
		// Add new strings below this comment. Move above once English has been confirmed

		/****** miscellaneous ******/
		'CFM_BTN_DELETE'   : 'Delete',
		'CFM_BTN_CANCEL'   : 'Cancel',
		'CFM_BTN_ADD'      : 'Add',
		'CFM_BTN_DONT_ADD' : "Don't add",
		// Add new strings below this comment. Move above once English has been confirmed

		/****** account credential module ******/
		'HEAD_MSG_ERR_INVALID_ACCOUNT_ID' : 'Invalid accout id',
		'HEAD_MSG_ERR_INVALID_ACCESS_KEY' : 'Invalid access key',
		'HEAD_MSG_ERR_INVALID_SECRET_KEY' : 'Invalid secret key',

		// account profile
		'HEAD_MSG_ERR_NULL_PASSWORD'      : 'Provide both current and new password to change password.',
		'HEAD_MSG_ERR_INVALID_PASSWORD'	  : 'Password must contain at least 6 characters and not the same with your username.',
		'HEAD_MSG_ERR_ERROR_PASSWORD'     : 'Current password is wrong.',
		'HEAD_MSG_ERR_RESET_PASSWORD'     : 'Forget password?',
		'HEAD_MSG_INFO_UPDATE_EMAIL'      : 'Email Address has been updated.',
		'HEAD_MSG_INFO_UPDATE_PASSWORD'   : 'Password has been updated.',
		'HEAD_MSG_ERR_UPDATE_EMAIL'       : 'Update email address failed.',
		'HEAD_MSG_ERR_UPDATE_PASSWORD'    : 'Update password failed.',
		// Add new strings below this comment. Move above once English has been confirmed

		/****** base_main.cofffee for module(x) ******/
		'MODULE_RELOAD_MESSAGE'           : 'Sorry, there is some connectivity issue, IDE is trying to reload',
		'MODULE_RELOAD_FAILED'            : 'Sorry, there is some connectivity issue, IDE cannot load, please refresh the browser',
		// Add new strings below this comment. Move above once English has been confirmed

		'BEFOREUNLOAD_MESSAGE'            : 'You have unsaved changes.',

		//###### dashboard module
		'DASH_MSG_RELOAD_AWS_RESOURCE_SUCCESS'     	: 'Status of resources is up to date.',


		'DASH_TIP_UNMANAGED_RESOURCE'				: 'Unmanaged Resource',
		'DASH_TIP_NO_RESOURCE_LEFT'					: 'There is no ',
		'DASH_TIP_NO_RESOURCE_RIGHT'				: ' in this region',



		'DASH_BTN_GLOBAL'							: 'Global',


		'DASH_LBL_UNMANAGED'         				: 'Unmanaged',
		'DASH_LBL_APP'								: 'App',
		'DASH_LBL_STACK'						    : 'Stack',
		'DASH_LBL_RECENT_EDITED_STACK'			    : 'Recently Edited Stack',
		'DASH_LBL_RECENT_LAUNCHED_STACK'		    : 'Recently Launched App',
		'DASH_LBL_NO_APP'							: 'There is no App in this region',
		'DASH_LBL_NO_STACK'							: 'There is no stack in this region yet',
		'DASH_LBL_CREATE_NEW_APP_FROM_STACK'		: 'You can run app from a stack',
		'DASH_LBL_CREATE_NEW_STACK_HERE'			: 'Create a new stack from here',


		'DASH_LBL_RUNNING_INSTANCE'				    : 'Running Instance',
		'DASH_LBL_ELASTIC_IP'					    : 'Elastic IP',
		'DASH_LBL_VOLUME'		  				    : 'Volume',
		'DASH_LBL_LOAD_BALANCER'				    : 'Load Balancer',
		'DASH_LBL_VPN'	    	    				: 'VPN',

		'DASH_LBL_INSTANCE'		        		    : 'Instance',
		'DASH_LBL_VPC'		    	      		    : 'VPC',
		'DASH_LBL_AUTO_SCALING_GROUP'		       	: 'Auto Scaling Group',
		'DASH_LBL_CLOUDWATCH_ALARM'		        	: 'CloudWatch Alarm',
		'DASH_LBL_SNS_SUBSCRIPTION'		        	: 'SNS Subscription',

		'DASH_LBL_ID'	    	    				: 'ID',
		'DASH_LBL_INSTANCE_NAME'	    	 		: 'Instance Name',
		'DASH_LBL_NAME'	    				 		: 'Name',
		'DASH_LBL_STATUS'	    	    			: 'Status',
		'DASH_LBL_STATE'	    	    			: 'State',
		'DASH_LBL_LAUNCH_TIME'	    	    		: 'Launch Time',
		'DASH_LBL_AMI'	    	    				: 'AMI',
		'DASH_LBL_AVAILABILITY_ZONE'	    		: 'Availability Zone',
		'DASH_LBL_DETAIL'	    	    			: 'Detail',
		'DASH_LBL_IP'	    	    				: 'IP',
		'DASH_LBL_ASSOCIATED_INSTANCE'	    	    : 'Associated Instance',
		'DASH_LBL_CREATE_TIME'	    	   		 	: 'Create Time',
		'DASH_LBL_DEVICE_NAME'	    	    		: 'Device Name',
		'DASH_LBL_ATTACHMENT_STATUS'	    	    : 'Attachment Status',
		'DASH_LBL_CIDR'	    	    				: 'CIDR',
		'DASH_LBL_DHCP_SETTINGS'	    	    	: 'DHCP Settings',
		'DASH_LBL_VIRTUAL_PRIVATE_GATEWAY'	    	: 'Virtual Private Gateway',
		'DASH_LBL_CUSTOMER_GATEWAY'	    	    	: 'Customer Gateway',
		'DASH_LBL_DNS_NAME'	    	    			: 'DNS Name',
		'DASH_LBL_CURRENT'	    	    			: 'Current',
		'DASH_LBL_LAST_ACTIVITY'	    	    	: 'Last Activity',
		'DASH_LBL_ACTIVITY_STATUS'	    	    	: 'Activity Status',
		'DASH_LBL_DIMENSION'	    	    		: 'Dimension',
		'DASH_LBL_THRESHOLD'	    	    		: 'Threshold',
		'DASH_LBL_TOPIC_NAME'	    	    		: 'Topic Name',
		'DASH_LBL_ENDPOINT_AND_PROTOCOL'	    	: 'Endpoint and Protocol',
		'DASH_LBL_CONFIRMATION'	    	    		: 'Confirmation',




		//###### dashboard module

		//###### ide

		'IDE_COM_CREATE_NEW_STACK'						: 'Create new stack',

		'IDE_LBL_REGION_NAME_us-east-1'					: 'US East',
		'IDE_LBL_REGION_NAME_us-west-1'	  				: 'US West',
		'IDE_LBL_REGION_NAME_us-west-2'	  				: 'US West',
		'IDE_LBL_REGION_NAME_eu-west-1'	  				: 'EU West',
		'IDE_LBL_REGION_NAME_ap-southeast-1'    		: 'Asia Pacific',
		'IDE_LBL_REGION_NAME_ap-southeast-2'			: 'Asia Pacific',
		'IDE_LBL_REGION_NAME_ap-northeast-1'			: 'Asia Pacific',
		'IDE_LBL_REGION_NAME_sa-east-1'	    			: 'South America',

		'IDE_LBL_REGION_NAME_SHORT_us-east-1'	  		: 'Virginia',
		'IDE_LBL_REGION_NAME_SHORT_us-west-1'	  		: 'California',
		'IDE_LBL_REGION_NAME_SHORT_us-west-2'	  		: 'Oregon',
		'IDE_LBL_REGION_NAME_SHORT_eu-west-1'	  		: 'Ireland',
		'IDE_LBL_REGION_NAME_SHORT_ap-southeast-1'  	: 'Singapore',
		'IDE_LBL_REGION_NAME_SHORT_ap-northeast-1'		: 'Tokyo',
		'IDE_LBL_REGION_NAME_SHORT_sa-east-1'	    	: 'Sao Paulo',

		//###### ide





		/****** popup ******/
		'POP_DOWNLOAD_KP_NOT_AVAILABLE'   : 'Not available yet. Password generation and encryption can sometimes take more than 30 minutes. Please wait at least 15 minutes after launching an instance before trying to retrieve the generated password.'

	},
	'service' : {
		'ERROR_CODE_0_MESSAGE'  : '',//invoke API succeeded
		'ERROR_CODE_1_MESSAGE'  : 'Sorry, AWS is suffering from some technical issues, please try again later',
		'ERROR_CODE_2_MESSAGE'  : 'Sorry, we are suffering from some technical issues, please try again later',
		'ERROR_CODE_3_MESSAGE'  : '',//no use
		'ERROR_CODE_4_MESSAGE'  : '',//no use
		'ERROR_CODE_5_MESSAGE'  : 'Sorry, AWS is suffering from some technical issues, please try again later',
		'ERROR_CODE_6_MESSAGE'  : '',//no use
		'ERROR_CODE_7_MESSAGE'  : '',//for guest
		'ERROR_CODE_8_MESSAGE'  : '',//no use
		'ERROR_CODE_9_MESSAGE'  : 'Sorry, your AWS credentials have not sufficient permissions',
		'ERROR_CODE_10_MESSAGE' : '',//no use
		'ERROR_CODE_11_MESSAGE' : '',//no use
		'ERROR_CODE_12_MESSAGE' : 'Sorry, we are suffering from some technical issues, please try again later',
		'ERROR_CODE_13_MESSAGE' : '',//no use
		'ERROR_CODE_14_MESSAGE' : '',//no use
		'ERROR_CODE_15_MESSAGE' : 'Sorry, AWS is suffering from some technical issues, please try again later',
		'ERROR_CODE_16_MESSAGE' : 'Sorry, AWS is suffering from some technical issues, please try again later',
		'ERROR_CODE_17_MESSAGE' : '',//no use
		'ERROR_CODE_18_MESSAGE' : 'Sorry, AWS is suffering from some technical issues, please try again later',
		'ERROR_CODE_19_MESSAGE' : 'Sorry, your session has expired, please login again',
		'ERROR_CODE_20_MESSAGE' : 'Sorry, this invitation has finished',//for guest
		'ERROR_CODE_21_MESSAGE' : 'User has been blocked'
		// Add new strings below this comment. Move above once English has been confirmed
	}
});
