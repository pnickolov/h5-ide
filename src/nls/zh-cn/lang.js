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
		'NAV_TIT_DASHBOARD' : '仪表板',
		'NAV_TIT_APPS'      : '应用',
		'NAV_TIT_STACKS'    : '模版',
		'NAV_LBL_GLOBAL'    : '我的资源',
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
		'RES_TIT_RESOURCES'           : '资源',
		'RES_TIT_AZ'                  : '可用区',
		'RES_TIT_AMI'                 : '虚拟机映像',
		'RES_TIT_VOL'                 : '虚拟磁盘和快照',
		'RES_TIT_ELB_ASG'             : '负载均衡器和自动伸缩组',
		'RES_TIT_VPC'                 : '虚拟私有云',
		'RES_LBL_QUICK_START_AMI'     : '推荐的映像',
		'RES_LBL_MY_AMI'              : '我的映像',
		'RES_LBL_FAVORITE_AMI'        : '收藏的映像',
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
		'RES_BTN_BROWSE_COMMUNITY_AMI': '浏览映像',
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
		'TOOL_BTN_RUN_STACK'                    : '运行',
		'TOOL_TIP_BTN_RUN_STACK'                : '运行当前模版为应用',
		'TOOL_POP_TIT_RUN_STACK'                : '运行',

		//save stack
		'TOOL_TIP_SAVE_STACK'                   : '保存模版',

		//delete stack
		'TOOL_TIP_DELETE_STACK'                 : '删除模版',
		'TOOL_TIP_DELETE_NEW_STACK'             : '当前模版未保存',
		'TOOL_POP_TIT_DELETE_STACK'             : '删除模版',
		'TOOL_POP_BODY_DELETE_STACK'            : '确认删除模版吗?',
		'TOOL_POP_BTN_DELETE_STACK'             : '删除',
		'TOOL_POP_BTN_CANCEL'     		        : '取消',

		//duplicate stack
		'TOOL_TIP_DUPLICATE_STACK'              : '复制模版',
		'TOOL_POP_TIT_DUPLICATE_STACK'          : '复制模版',
		'TOOL_POP_BODY_DUPLICATE_STACK'         : '模版名称:',
		'TOOL_POP_BTN_DUPLICATE_STACK'          : '复制',

		//create stack
		'TOOL_TIP_CREATE_STACK'                 : '创建新模版',

		//zoom
		'TOOL_TIP_ZOOM_IN'                      : '放大',
		'TOOL_TIP_ZOOM_OUT'                     : '缩小',

		//export
		'TOOL_EXPORT'                           : '导出...',
		'TOOL_EXPORT_AS_JSON'                   : '导出JSON文件',
		'TOOL_POP_TIT_EXPORT_AS_JSON'           : '导出',
		'TOOL_POP_BODY_EXPORT_AS_JSON'          : '您确认保存JSON文件吗?',
		'TOOL_POP_BTN_DOWNLOAD'                 : '保存',
		'TOOL_EXPORT_AS_PNG'                    : '导出图片',

		//stop app
		'TOOL_TIP_STOP_APP'                     : "暂停应用",
		'TOOL_POP_TIT_STOP_APP'                 : '确认暂停',
		'TOOL_POP_BODY_STOP_APP_LEFT'           : '本操作将暂停应用中的相关资源，您确认暂停当前应用',
		'TOOL_POP_BODY_STOP_APP_RIGHT'          : ' 吗',
		'TOOL_POP_BTN_STOP_APP'                 : '暂停',

		//start app
		'TOOL_TIP_START_APP'                    : "恢复应用",
		'TOOL_POP_TIT_START_APP'                : '确认恢复',
		'TOOL_POP_BODY_START_APP_LEFT'          : '本操作将恢复应用中的相关资源，您确认恢复当前应用',
		'TOOL_POP_BODY_START_APP_RIGHT'         : ' 吗',
		'TOOL_POP_BTN_START_APP'                : '恢复',

		//terminate app
		'TOOL_TIP_TERMINATE_APP'                : "销毁应用",
		'TOOL_POP_TIT_TERMINATE_APP'            : '确认销毁',
		'TOOL_POP_BODY_TERMINATE_APP_LEFT'      : '本操作将销毁应用中的相关资源，您确认销毁当前应用',
		'TOOL_POP_BODY_TERMINATE_APP_RIGHT'     : ' 吗',
		'TOOL_POP_BTN_TERMINATE_APP'            : '销毁',

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
		'TOOL_TIP_LINESTYLE'                          : '安全组规则连线类型...',
		'TOOL_LBL_LINESTYLE_STRAIGHT'                 : '直线',
		'TOOL_LBL_LINESTYLE_ELBOW'                    : '肘型线',
		'TOOL_LBL_LINESTYLE_QUADRATIC_BELZIER'        : '二次贝赛尔曲线',
		'TOOL_LBL_LINESTYLE_SMOOTH_QUADRATIC_BELZIER' : '光滑的二次贝塞尔曲线',

		/******property module******/

		//###### instance property module
		'PROP_INSTANCE_DETAIL'					: '实例设置',
		'PROP_INSTANCE_HOSTNAME'				: '主机名',
		'PROP_INSTANCE_INSTANCE_ID'				: '实例ID',
		'PROP_INSTANCE_LAUNCH_TIME'				: '创建时间',
		'PROP_INSTANCE_STATE'					: '状态',
		'PROP_INSTANCE_PRIMARY_PUBLIC_IP'		: '主公网IP',
		'PROP_INSTANCE_PUBLIC_IP'				: '公网IP',
		'PROP_INSTANCE_PUBLIC_DNS'				: '公网域名',
		'PROP_INSTANCE_PRIMARY_PRIVATE_IP'		: '主内网IP',
		'PROP_INSTANCE_PRIVATE_DNS'				: '内网域名',
		'PROP_INSTANCE_NUMBER'					: '实例数量',
		'PROP_INSTANCE_REQUIRE'					: '必须',
		'PROP_INSTANCE_AMI'						: '镜像',
		'PROP_INSTANCE_TYPE'					: '实例类型',
		'PROP_INSTANCE_KEY_PAIR'				: '秘钥',
		'PROP_INSTANCE_EBS_OPTIMIZED'			: 'EBS 优化',
		'PROP_INSTANCE_TENANCY'					: '专用',
		'PROP_INSTANCE_TENANCY_DEFAULT'			: '默认',
		'PROP_INSTANCE_TENANCY_DELICATED'		: '专用',
		'PROP_INSTANCE_ROOT_DEVICE_TYPE'		: '根设备类型',
		'PROP_INSTANCE_BLOCK_DEVICE'			: '块设备',
		'PROP_INSTANCE_NEW_KP'					: '新建秘钥',
		'PROP_INSTANCE_CW_ENABLED'				: '打开CloudWatch监控',
		'PROP_INSTANCE_ADVANCED_DETAIL'			: '高级设置',
		'PROP_INSTANCE_USER_DATA'				: '用户数据',
		'PROP_INSTANCE_CW_WARN'					: 'Data is available in 1-minute periods at an additional cost. For information about pricing, go to the ',
		'PROP_INSTANCE_ENI_DETAIL'				: '网卡设置',
		'PROP_INSTANCE_ENI_DESC'				: '描述',
		'PROP_INSTANCE_ENI_SOURCE_DEST_CHECK'	: '打开 Source/Destination 检查',
		'PROP_INSTANCE_ENI_SOURCE_DEST_CHECK_DISP': 'Source/Destination 检查',
		'PROP_INSTANCE_ENI_AUTO_PUBLIC_IP'		: '自动分配公网IP',
		'PROP_INSTANCE_ENI_IP_ADDRESS'			: 'IP地址',
		'PROP_INSTANCE_ENI_ADD_IP'				: '添加IP',
		'PROP_INSTANCE_SG_DETAIL'				: '安全组',
		'PROP_INSTANCE_IP_MSG_1'				: '请提供一个IP或者保留为.x来自动分配IP',
		'PROP_INSTANCE_IP_MSG_2'				: '自动分配IP',
		'PROP_INSTANCE_IP_MSG_3'				: '和Elastic IP进行关联',
		'PROP_INSTANCE_IP_MSG_4'				: '取消关联Elastic IP',
		//###### instance property module



		'PROP_LBL_REQUIRED'                     : '必填',

		//##### stack property module
		'PROP_STACK_LBL_NAME'                       : '模版名称',
		'PROP_STACK_LBL_REGION'                     : '区域',
		'PROP_STACK_LBL_TYPE'                       : '类型',
		'PROP_STACK_TIT_SG'                         : '安全组',
		'PROP_STACK_TIT_ACL'                        : '访问控制表',
		'PROP_STACK_TIT_SNS'                        : 'SNS主题订阅',
		'PROP_STACK_BTN_ADD_SUB'                    : '添加订阅',
		'PROP_STACK_TIT_COST_ESTIMATION'            : '成本估算',
		'PROP_STACK_LBL_COST_CYCLE'                 : '月',
		'PROP_STACK_COST_COL_RESOURCE'              : '资源',
		'PROP_STACK_COST_COL_SIZE_TYPE'             : '大小/类型',
		'PROP_STACK_COST_COL_FEE'                   : '价格($)',
		'PROP_STACK_LBL_AWS_EC2_PRICING'            : 'Amazon EC2 定价',
		'PROP_STACK_ACL_LBL_RULE'                   : '条规则',
		'PROP_STACK_ACL_LBL_ASSOC'                  : '个关联',
		'PROP_STACK_ACL_BTN_DELETE'                 : '删除',
		'PROP_STACK_ACL_TIP_DETAIL'                 : '查看访问控制表详细',
		'PROP_STACK_BTN_CREATE_NEW_ACL'             : '创建新的访问控制表...',
		//##### stack property module


		//##### app property module
		'PROP_APP_SNS_NONE'                         : '本应用不含SNS主题',
		//##### app property module


		//##### az property module
		'PROP_AZ_LBL_SWITCH'                            : '切换可用区',
		//##### az property module


		//##### vpc property module
		'PROP_VPC_TIT_DETAIL'                                            : 'VPC详细',
		'PROP_VPC_DETAIL_LBL_NAME'                                       : '名称',
		'PROP_VPC_DETAIL_LBL_CIDR_BLOCK'                                 : 'CIDR 块',
		'PROP_VPC_DETAIL_LBL_TENANCY'                                    : '租用',
		'PROP_VPC_DETAIL_TENANCY_LBL_DEFAULT'                            : '缺省',
		'PROP_VPC_DETAIL_TENANCY_LBL_DEDICATED'                          : '专用',
		'PROP_VPC_DETAIL_LBL_ENABLE_DNS_RESOLUTION'                      : '允许DNS解析',
		'PROP_VPC_DETAIL_LBL_ENABLE_DNS_HOSTNAME_SUPPORT'                : '允许DNS主机名解析',
		'PROP_VPC_TIT_DHCP_OPTION'                                       : 'DHCP 选项',
		'PROP_VPC_DHCP_LBL_NONE'                                         : '无',
		'PROP_VPC_DHCP_LBL_DEFAULT'                                      : '缺省',
		'PROP_VPC_DHCP_LBL_SPECIFIED'                                    : '指定的DHCP选项设置',
		'PROP_VPC_DHCP_SPECIFIED_LBL_DOMAIN_NAME'                        : '域名',
		'PROP_VPC_DHCP_SPECIFIED_LBL_DOMAIN_NAME_SERVER'                 : '域名服务器',
		'PROP_VPC_DHCP_SPECIFIED_LBL_AMZN_PROVIDED_DNS'                  : '亚马逊提供的域名服务器',
		'PROP_VPC_DHCP_SPECIFIED_LBL_NTP_SERVER'                         : '时间服务器',
		'PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NAME_SERVER'                : 'NetBIOS名字服务器',
		'PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE'                  : 'NetBIOS节点类型',
		'PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE_NOT_SPECIFIED'    : '未指定',
		'PROP_VPC_APP_VPC_ID'                                            : 'VPC标识',
		'PROP_VPC_APP_STATE'                                             : '状态',
		'PROP_VPC_APP_CIDR'                                              : 'CIDR',
		'PROP_VPC_APP_MAIN_RT'                                           : '主路由表',
		'PROP_VPC_APP_DEFAULT_ACL'                                       : '缺省访问控制表',
		'PROP_VPC_DHCP_OPTION_SET_ID'                                    : 'DHCP选项标识',
		//##### vpc property module


		//##### subnet property module
		'PROP_SUBNET_TIT_DETAIL'                                         : '子网详细',
		'PROP_SUBNET_DETAIL_LBL_NAME'                                    : '名称',
		'PROP_SUBNET_DETAIL_LBL_CIDR_BLOCK'                              : 'CIDR 块',
		'PROP_SUBNET_TIT_ASSOC_ACL'                                      : '相关访问控制表',
		'PROP_SUBNET_BTN_CREATE_NEW_ACL'                                 : '创建新的访问控制表...',
		'PROP_SUBNET_ACL_LBL_RULE'                                       : '条规则',
		'PROP_SUBNET_ACL_LBL_ASSOC'                                      : '个关联',
		'PROP_SUBNET_ACL_BTN_DELETE'                                     : '删除',
		'PROP_SUBNET_ACL_TIP_DETAIL'                                     : '查看访问控制表详细',
		'PROP_SUBNET_APP_ID'                                             : '子网标识',
		'PROP_SUBNET_APP_STATE'                                          : '状态',
		'PROP_SUBNET_APP_CIDR'                                           : 'CIDR',
		'PROP_SUBNET_APP_AVAILABLE_IP'                                   : '可用IP',
		'PROP_SUBNET_APP_VPC_ID'                                         : 'VPC标识',
		'PROP_SUBNET_APP_RT_ID'                                          : '路由表标识',
		//##### subnet property module


		//##### sg property module
		'PROP_SG_TIT_DETAIL'                                             : '安全组详细',
		'PROP_SG_DETAIL_LBL_NAME'                                        : '名称',
		'PROP_SG_DETAIL_LBL_DESCRIPTION'                                 : '描述',
		'PROP_SG_TIT_RULE'                                               : '规则',
		'PROP_SG_RULE_SORT_BY'                                           : '排序',
		'PROP_SG_RULE_SORT_BY_DIRECTION'                                 : '按方向',
		'PROP_SG_RULE_SORT_BY_SRC_DEST'                                  : '按源/目的',
		'PROP_SG_RULE_SORT_BY_PROTOCOL'                                  : '按协议',
		'PROP_SG_TIT_MEMBER'                                             : '成员',
		'PROP_SG_TIP_CREATE_RULE'                                        : '创建基于IP范围的规则',
		'PROP_SG_TIP_REMOVE_RULE'                                        : '删除规则',
		'PROP_SG_TIP_PROTOCOL'                                           : '协议',
		'PROP_SG_TIP_SRC'                                                : '源',
		'PROP_SG_TIP_DEST'                                               : '目的',
		'PROP_SG_TIP_INBOUND'                                            : '入方向',
		'PROP_SG_TIP_OUTBOUND'                                           : '出方向',
		'PROP_SG_TIP_PORT_CODE'                                          : '端口或代码',
		'PROP_SG_APP_SG_ID'                                              : '安全组标识',
		'PROP_SG_APP_VPC_ID'                                             : 'VPC标识',
		//##### sg property module


		//##### sg list property module
		'PROP_SGLIST_LBL_RULE'                                           : '条规则',
		'PROP_SGLIST_LBL_MEMBER'                                         : '个成员',
		'PROP_SGLIST_LNK_DELETE'                                         : '删除',
		'PROP_SGLIST_TIP_VIEW_DETAIL'                                    : '查看详细',
		'PROP_SGLIST_BTN_CREATE_NEW_SG'                                  : '创建新安全组...',
		'PROP_SGLIST_TAB_GROUP'                                          : '组',
		'PROP_SGLIST_TAB_RULE'                                           : '规则',
		//##### sg list property module


		//##### sg rule property module
		'PROP_SGRULE_DESCRIPTION'                                        : '当前选中的连线反映了以下安全组的规则:',
		'PROP_SGRULE_TIP_INBOUND'                                        : '入方向',
		'PROP_SGRULE_TIP_OUTBOUND'                                       : '出方向',
		'PROP_SGRULE_BTN_EDIT_RULE'                                      : '编辑相关规则',
		//##### sg rule property module


		//##### add sg rule pop - modalSGRule
		'POP_SGRULE_TITLE_ADD'                                           : '添加安全组规则',
		'POP_SGRULE_TITLE_EDIT'                                          : '修改安全组规则',
		'POP_SGRULE_LBL_DIRECTION'                                       : '方向',
		'POP_SGRULE_LBL_INBOUND'                                         : '入方向',
		'POP_SGRULE_LBL_OUTBOUND'                                        : '出方向',
		'POP_SGRULE_LBL_SOURCE'                                          : '源',
		'POP_SGRULE_LBL_DEST'                                            : '目的',
		'POP_SGRULE_LBL_PROTOCOL'                                        : '协议',
		'POP_SGRULE_PROTOCOL_TCP'                                        : 'TCP',
		'POP_SGRULE_PROTOCOL_UDP'                                        : 'UDP',
		'POP_SGRULE_PROTOCOL_ICMP'                                       : 'ICMP',
		'POP_SGRULE_PROTOCOL_CUSTOM'                                     : '自定义',
		'POP_SGRULE_PROTOCOL_ALL'                                        : '全部',
		'POP_SGRULE_BTN_SAVE'                                            : '保存',
		'POP_SGRULE_BTN_CANCEL'                                          : '取消',
		'POP_SGRULE_PLACEHOLD_SOURCE'                                    : '如192.168.2.0/24',
		'POP_SGRULE_PLACEHOLD_PORT_RANGE'                                : '端口范围，如80或49152-65535',
		//##### add sg rule pop - modalSGRule


		//##### acl property module
		'PROP_ACL_LBL_NAME'                                              : '名称',
		'PROP_ACL_TIT_RULE'                                              : '规则',
		'PROP_ACL_BTN_CREATE_NEW_RULE'                                   : '创建新的访问控制表',
		'PROP_ACL_RULE_SORT_BY'                                          : '排序',
		'PROP_ACL_RULE_SORT_BY_NUMBER'                                   : '按规则编号',
		'PROP_ACL_RULE_SORT_BY_ACTION'                                   : '动作',
		'PROP_ACL_RULE_SORT_BY_DIRECTION'                                : '方向',
		'PROP_ACL_RULE_SORT_BY_SRC_DEST'                                 : '源/目的',
		'PROP_ACL_TIP_ACTION_ALLOW'                                      : '允许',
		'PROP_ACL_TIP_ACTION_DENY'                                       : '拒绝',
		'PROP_ACL_TIP_INBOUND'                                           : '入方向',
		'PROP_ACL_TIP_OUTBOUND'                                          : '出方向',
		'PROP_ACL_TIP_RULE_NUMBER'                                       : '规则编号',
		'PROP_ACL_TIP_CIDR_BLOCK'                                        : 'CIDR 块',
		'PROP_ACL_TIP_PROTOCOL'                                          : '协议',
		'PROP_ACL_TIP_PORT'                                              : '端口',
		'PROP_ACL_TIT_ASSOC'                                             : '关联的子网',
		'PROP_ACL_TIP_REMOVE_RULE'                                       : '删除规则',
		'PROP_ACL_APP_ID'                                                : '访问控制表标识',
		'PROP_ACL_APP_IS_DEFAULT'                                        : '是否缺省',
		'PROP_ACL_APP_VPC_ID'                                            : 'VPC标识',
		//##### acl property module

		//##### add sg rule pop - component/aclrule
		'POP_ACLRULE_TITLE_ADD'                                           : '添加访问控制表规则',
		'POP_ACLRULE_LBL_RULE_NUMBER'                                     : '规则编号',
		'POP_ACLRULE_LBL_ACTION'                                          : '动作',
		'POP_ACLRULE_LBL_ACTION_ALLOW'                                    : '允许',
		'POP_ACLRULE_LBL_ACTION_DENY'                                     : '拒绝',
		'POP_ACLRULE_LBL_DIRECTION'                                       : '方向',
		'POP_ACLRULE_LBL_INBOUND'                                         : '入方向',
		'POP_ACLRULE_LBL_OUTBOUND'                                        : '出方向',
		'POP_ACLRULE_LBL_SOURCE'                                          : '源',
		'POP_ACLRULE_LBL_DEST'                                            : '目的',
		'POP_ACLRULE_LBL_PROTOCOL'                                        : '协议',
		'POP_ACLRULE_PROTOCOL_TCP'                                        : 'TCP',
		'POP_ACLRULE_PROTOCOL_UDP'                                        : 'UDP',
		'POP_ACLRULE_PROTOCOL_ICMP'                                       : 'ICMP',
		'POP_ACLRULE_PROTOCOL_CUSTOM'                                     : '自定义',
		'POP_ACLRULE_PROTOCOL_ALL'                                        : '全部',
		'POP_ACLRULE_BTN_SAVE'                                            : '保存',
		'POP_ACLRULE_BTN_CANCEL'                                          : '取消',
		'POP_ACLRULE_PLACEHOLD_SOURCE'                                    : '如192.168.2.0/24',
		'POP_ACLRULE_PLACEHOLD_PORT_RANGE'                                : '端口范围,如80或49152-65535',
		'POP_ACLRULE_LBL_PORT_RANGE_ALL'                                  : '端口范围:0-65535',
		//##### add sg rule pop - component/aclrule


		//##### vgw property module
		'PROP_VGW_TXT_DESCRIPTION'           : '虚拟私有网关是亚马逊一侧的VPN隧道的路由器.',
		//##### vgw property module


		//##### vpn property module
		'PROP_VPN_LBL_IP_PREFIX'             : '网络号前缀',
		//##### vpn property module


		//##### igw property module
		'PROP_IGW_TXT_DESCRIPTION'          : '互联网网关是将你位于AWS网络中的VPC网络连接到互联网的路由器.',
		//##### igw property module


		//##### cgw property module
		'PROP_CGW_LBL_NAME'                     : '名称',
		'PROP_CGW_LBL_IPADDR'                   : 'IP地址',
		'PROP_CGW_LBL_ROUTING'                  : '路由',
		'PROP_CGW_LBL_STATIC'                   : '静态',
		'PROP_CGW_LBL_DYNAMIC'                  : '动态',
		'PROP_CGW_LBL_BGP_ASN'                  : 'BGP 自治域号',
		'PROP_CGW_APP_TIT_CGW'                  : '客户网关',
		'PROP_CGW_APP_CGW_LBL_ID'               : '标识',
		'PROP_CGW_APP_CGW_LBL_STATE'            : '状态',
		'PROP_CGW_APP_CGW_LBL_TYPE'             : '类型',
		'PROP_CGW_APP_TIT_VPN'                  : 'VPN连接',
		'PROP_CGW_APP_VPN_LBL_ID'               : '标识',
		'PROP_CGW_APP_VPN_LBL_STATE'            : '状态',
		'PROP_CGW_APP_VPN_LBL_TYPE'             : '类型',
		'PROP_CGW_APP_VPN_LBL_TUNNEL'           : 'VPN隧道',
		'PROP_CGW_APP_VPN_COL_TUNNEL'           : '隧道',
		'PROP_CGW_APP_VPN_COL_IP'               : 'IP地址',
		'PROP_CGW_APP_VPN_LBL_STATUS_RT'        : '路由状态',
		'PROP_CGW_APP_VPN_COL_IP_PREFIX'        : '网络号',
		'PROP_CGW_APP_VPN_COL_SOURCE'           : '源',
		'PROP_CGW_APP_TIT_DOWNLOAD_CONF'        : '下载配置',
		'PROP_CGW_APP_DOWN_LBL_VENDOR'          : '厂商',
		'PROP_CGW_APP_DOWN_LBL_PLATFORM'        : '平台',
		'PROP_CGW_APP_DOWN_LBL_SOFTWARE'        : '软件',
		'PROP_CGW_APP_DOWN_LBL_GENERIC'         : '通用',
		'PROP_CGW_APP_DOWN_LBL_VENDOR_AGNOSTIC' : '厂商无关',
		'PROP_CGW_APP_DOWN_BTN_DOWNLOAD'        : '下载',
		//##### cgw property module


		// instance property module
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
		'PROP_MSG_ERR_GET_PASSWD_FAILED'        : 'Sorry, there was a problem getting password data for instance ',
		'PROP_MSG_ERR_AMI_NOT_FOUND'            : 'Can not find information for selected AMI( %s ), try to drag another AMI.',

		// sg property
		'PROP_MSG_SG_CREATE'                    : "1 rule has been created in %s to allow %s %s %s.",
		'PROP_MSG_SG_CREATE_MULTI'              : "%d rules have been created in %s and %s to allow %s %s %s.",
		'PROP_MSG_SG_CREATE_SELF'               : "%d rules have been created in %s to allow %s send and receive traffic within itself.",

		//###### volume property
		'PROP_VOLUME_DEVICE_NAME'				: '挂载设备名',
		'PROP_VOLUME_SIZE'						: '磁盘大小',
		'PROP_VOLUME_ID'						: '磁盘ID',
		'PROP_VOLUME_STATE'						: '状态',
		'PROP_VOLUME_CREATE_TIME'				: '创建时间',
		'PROP_VOLUME_SNAPSHOT_ID'				: '快照ID',
		'PROP_VOLUME_SNAPSHOT'					: '快照',
		'PROP_VOLUME_ATTACHMENT_STATE'			: '挂载状态',
		'PROP_VOLUME_INSTANCE_ID'				: '实例ID',
		'PROP_VOLUME_ATTACHMENT_TIME'			: '挂载时间',
		'PROP_VOLUME_TYPE'						: '磁盘类型',
		'PROP_VOLUME_TYPE_STANDARD'				: '标准',
		'PROP_VOLUME_TYPE_IOPS'					: '预配置IOPS',
		'PROP_VOLUME_MSG_WARN'					: '要使用预配置IOPS,磁盘必须最少10GB',
		//###### volume property

		//###### eni property
		'PROP_ENI_LBL_ATTACH_WARN'				: 'Attach the Network Interface to an instance within the same availability zone.',
		'PROP_ENI_LBL_DETAIL'					: '网卡设置',
		'PROP_ENI_LBL_DESC'						: '描述',
		'PROP_ENI_SOURCE_DEST_CHECK'			: '打开 Source/Destination 检查',
		'PROP_ENI_AUTO_PUBLIC_IP'				: '自动分配公网IP',
		'PROP_ENI_IP_ADDRESS'					: 'IP地址',
		'PROP_ENI_ADD_IP'						: '添加IP',
		'PROP_ENI_SG_DETAIL'					: '安全组',
		'PROP_ENI_DEVICE_NAME'					: '设备名称',
		'PROP_ENI_STATE'						: '状态',
		'PROP_ENI_ID'							: '网卡ID',
		'PROP_ENI_SHOW_DETAIL'					: '更多',
		'PROP_ENI_HIDE_DETAIL'					: '隐藏',
		'PROP_ENI_VPC_ID'						: 'VPC ID',
		'PROP_ENI_SUBNET_ID'					: '子网ID',
		'PROP_ENI_ATTACHMENT_ID'				: '关联ID',
		'PROP_ENI_Attachment_OWNER'				: '关联拥有者',
		'PROP_ENI_Attachment_STATE'				: '关联状态',
		'PROP_ENI_MAC_ADDRESS'					: 'MAC地址',
		'PROP_ENI_IP_OWNER'						: 'IP拥有者',
		//###### eni property

		//###### elb property
		'PROP_ELB_DETAILS'						: '负载均衡器设置',
		'PROP_ELB_NAME'							: '名称',
		'PROP_ELB_REQUIRED'						: '必须',
		'PROP_ELB_SCHEME'						: '模式',
		'PROP_ELB_LISTENER_DETAIL'				: '监听设置',
		'PROP_ELB_BTN_ADD_LISTENER'				: '添加监听器',
		'PROP_ELB_BTN_ADD_SERVER_CERTIFICATE'	: '添加服务器认证',
		'PROP_ELB_SERVER_CERTIFICATE'			: '服务器认证',
		'PROP_ELB_LBL_LISTENER_NAME'			: '名称',
		'PROP_ELB_LBL_LISTENER_PRIVATE_KEY'		: '私钥',
		'PROP_ELB_LBL_LISTENER_PUBLIC_KEY'		: '公钥',
		'PROP_ELB_LBL_LISTENER_CERTIFICATE_CHAIN': '认证链',
		'PROP_ELB_HEALTH_CHECK_DETAILS'			: '健康度检查配置',
		'PROP_ELB_PING_PROTOCOL'				: 'Ping协议',
		'PROP_ELB_PING_PORT'					: 'Ping端口',
		'PROP_ELB_PING_PATH'					: 'Ping路径',
		'PROP_ELB_HEALTH_CHECK_INTERVAL'		: '健康度检查间隔',
		'PROP_ELB_HEALTH_CHECK_INTERVAL_SECONDS': '秒',
		'PROP_ELB_HEALTH_CHECK_RESPOND_TIMEOUT'	: '响应超时',
		'PROP_ELB_HEALTH_THRESHOLD'				: '健康界限',
		'PROP_ELB_UNHEALTH_THRESHOLD'			: '不健康界限',
		'PROP_ELB_AVAILABILITY_ZONE'			: '可用区',
		'PROP_ELB_SG_DETAIL'					: '安全组',
		'PROP_ELB_DNS_NAME'						: '域名',
		'PROP_ELB_HOST_ZONE_ID'					: 'Hosted Zone ID',
		'PROP_ELB_ELB_PROTOCOL'					: '负载均衡器协议',
		'PROP_ELB_PORT'							: '端口',
		'PROP_ELB_INSTANCE_PROTOCOL'			: '实例协议',
		'PROP_ELB_DISTRIBUTION'					: '分布',
		//###### elb property

		//###### autoscaling group property
		'PROP_ASG_DETAILS'						: '自动伸缩组配置',
		'PROP_ASG_NAME'							: '名称',
		'PROP_ASG_REQUIRED'						: '必须',
		'PROP_ASG_CREATE_TIME'					: '创建时间',
		'PROP_ASG_MIN_SIZE'						: '最小数量',
		'PROP_ASG_MAX_SIZE'						: '最大数量',
		'PROP_ASG_DESIRE_CAPACITY'				: '期望数量',
		'PROP_ASG_COOL_DOWN'					: '冷却时间',
		'PROP_ASG_INSTANCE'						: '实例',
		'PROP_ASG_DEFAULT_COOL_DOWN'			: '默认冷却时间',
		'PROP_ASG_UNIT_SECONDS'					: '秒',
		'PROP_ASG_HEALTH_CHECK_TYPE'			: '健康度检查类型',
		'PROP_ASG_HEALTH_CHECK_CRACE_PERIOD'	: '健康度检查时间',
		'PROP_ASG_POLICY'						: '策略',
		'PROP_ASG_HAS_ELB_WARN'					: '你需要连接AutoScaling组和一个负载均衡器来启动此选项',
		'PROP_ASG_TERMINATION_POLICY'			: '结束策略',
		'PROP_ASG_POLICY_TLT_NAME'				: '策略名称',
		'PROP_ASG_POLICY_TLT_ALARM_METRIC'		: '警告准则',
		'PROP_ASG_POLICY_TLT_THRESHOLD'			: '界限',
		'PROP_ASG_POLICY_TLT_PERIOD'			: '评估时间',
		'PROP_ASG_POLICY_TLT_ACTION'			: '触发动作',
		'PROP_ASG_POLICY_TLT_ADJUSTMENT'		: '调整',
		'PROP_ASG_POLICY_TLT_EDIT'				: '编辑策略',
		'PROP_ASG_POLICY_TLT_REMOVE'			: '删除策略',
		'PROP_ASG_BTN_ADD_SCALING_POLICY'		: '添加扩展策略',
		'PROP_ASG_LBL_NOTIFICATION'				: '通知',
		'PROP_ASG_LBL_SEND_NOTIFICATION'		: '通过SNS发送通知',
		'PROP_ASG_LBL_SUCCESS_INSTANCES_LAUNCH'	: '运行实例成功',
		'PROP_ASG_LBL_FAILED_INSTANCES_LAUNCH'	: '运行实例失败',
		'PROP_ASG_LBL_SUCCESS_INSTANCES_TERMINATE'	: '终止实例成功',
		'PROP_ASG_LBL_FAILED_INSTANCES_TERMINATE'	: '终止实例失败',
		'PROP_ASG_LBL_VALIDATE_SNS'				: '验证SNS主题',
		'PROP_ASG_MSG_NO_NOTIFICATION_WARN'		: '没有设置Notification Configuration',
		'PROP_ASG_MSG_SNS_WARN'					: '现在SNS还没有设置订阅信息，请去模板属性框设置，以便收到通知',
		'PROP_ASG_MSG_DROP_LC'					: '请拖拽镜像来建立Launch Configuration',
		'PROP_ASG_TERMINATION_EDIT'				: '编辑终止策略',
		'PROP_ASG_TERMINATION_TEXT_WARN'		: '你能选择最少一种策略，策略执行顺序是从上到下',
		'PROP_ASG_TERMINATION_MSG_DRAG'			: '拖拽以便调整顺序',
		'PROP_ASG_TERMINATION_POLICY_OLDEST'	: '最旧的实例',
		'PROP_ASG_TERMINATION_POLICY_NEWEST'	: '最新的实例',
		'PROP_ASG_TERMINATION_POLICY_OLDEST_LAUNCH'	: '最旧的LaunchConfiguration',
		'PROP_ASG_TERMINATION_POLICY_CLOSEST'	: '最近下一个实力时钟',
		'PROP_ASG_ADD_POLICY_TITLE_ADD'			: '添加',
		'PROP_ASG_ADD_POLICY_TITLE_EDIT'		: '编辑',
		'PROP_ASG_ADD_POLICY_TITLE_CONTENT'		: '扩展策略',
		'PROP_ASG_ADD_POLICY_ALARM'				: '警报',
		'PROP_ASG_ADD_POLICY_WHEN'				: '当',
		'PROP_ASG_ADD_POLICY_IS'				: '是',
		'PROP_ASG_ADD_POLICY_FOR'				: '持续',
		'PROP_ASG_ADD_POLICY_PERIOD'			: '周期',
		'PROP_ASG_ADD_POLICY_SECONDS'			: '秒时，进入警报状态',
		'PROP_ASG_ADD_POLICY_START_SCALING'		: '执行扩展活动，当处于',
		'PROP_ASG_ADD_POLICY_STATE'				: '状态',
		'PROP_ASG_ADD_POLICY_SCALING_ACTIVITY'	: '扩展活动',
		'PROP_ASG_ADD_POLICY_ADJUSTMENT'		: '通过以下方式调整',
		'PROP_ASG_ADD_POLICY_ADJUSTMENT_OF'		: '数量',
		'PROP_ASG_ADD_POLICY_ADVANCED'			: '高级',
		'PROP_ASG_ADD_POLICY_ADVANCED_ALARM_OPTION'	: '警报选项',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC'	: '统计方式',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_AVG'	: '平均',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_MIN'	: '最小',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_MAX'	: '最大',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_SAMPLE'	: '抽样计算',
		'PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_SUM'	: '总计',
		'PROP_ASG_ADD_POLICY_ADVANCED_SCALING_OPTION'	: '扩展选项',
		'PROP_ASG_ADD_POLICY_ADVANCED_COOLDOWN_PERIOD'	: '冷却周期',
		'PROP_ASG_ADD_POLICY_ADVANCED_TIP_COOLDOWN_PERIOD'	: '两个扩展活动之间的冷却时间(秒)，如果不提供，则使用AWS默认时间',
		'PROP_ASG_ADD_POLICY_ADVANCED_MIN_ADJUST_STEP'	: '最小调整数量',
		'PROP_ASG_ADD_POLICY_ADVANCED_TIP_MIN_ADJUST_STEP'	: '调整期望数量时的最小实例数量',
		//###### autoscaling group property

		//###### launch configuration property
		'PROP_LC_TITLE'									: 'Launch Configuation',
		'PROP_LC_NAME'									: '名称',
		'PROP_LC_CREATE_TIME'							: '创建时间',
		//###### launch configuration property

		//###### route table property
		'PROP_RT_ASSOCIATION'							: '这是一条路由表关联线从',
		'PROP_RT_ASSOCIATION_TO'						: '到',
		'PROP_RT_NAME'									: '名称',
		'PROP_RT_LBL_ROUTE'								: '路由规则',
		'PROP_RT_LBL_MAIN_RT'							: '主路由表',
		'PROP_RT_SET_MAIN'								: '设置为主路由表',
		'PROP_RT_TARGET'								: '路由对象',
		'PROP_RT_DESTINATION'							: '数据包目的地',
		'PROP_RT_ID'									: '路由表ID',
		'PROP_RT_VPC_ID'								: 'VPC ID',
		//###### route table property

		/******navigation module******/
		'NAV_DESMOD_NOT_FINISH_LOAD'            : 'Sorry, the designer module is loading now. Please try again after several seconds.',
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

		'DASH_MSG_RELOAD_AWS_RESOURCE_SUCCESS'     	: '资源更新完毕',


		'DASH_TIP_UNMANAGED_RESOURCE'				: '非托管资源',
		'DASH_TIP_NO_RESOURCE_LEFT'					: '该地区没有',
		'DASH_TIP_NO_RESOURCE_RIGHT'				: '',


		'DASH_BTN_GLOBAL'							: '全局',

		'DASH_LBL_UNMANAGED'        				: '非托管的',
		'DASH_LBL_APP'								: '应用',
		'DASH_LBL_STACK'						    : '模板',
		'DASH_LBL_RECENT_EDITED_STACK'			    : '最近修改的模板',
		'DASH_LBL_RECENT_LAUNCHED_STACK'		    : '最近启动的实例',
		'DASH_LBL_NO_APP'							: '该地区没有应用',
		'DASH_LBL_NO_STACK'							: '该地区还没有模板',
		'DASH_LBL_CREATE_NEW_APP_FROM_STACK'		: '你可以通过模板创建应用',
		'DASH_LBL_CREATE_NEW_STACK_HERE'			: '点击这里创建新模板',

		'DASH_LBL_RUNNING_INSTANCE'				    : '运行的实例',
		'DASH_LBL_ELASTIC_IP'					    : '弹性IP',
		'DASH_LBL_VOLUME'		  				    : '卷',
		'DASH_LBL_LOAD_BALANCER'				    : '负载均衡器',
		'DASH_LBL_VPN'								: 'VPN',

		'DASH_LBL_INSTANCE'		        		    : '实例',
		'DASH_LBL_VPC'		    	      		    : 'VPC',
		'DASH_LBL_AUTO_SCALING_GROUP'		       	: 'Auto Scaling 组',
		'DASH_LBL_CLOUDWATCH_ALARM'		        	: 'CloudWatch 警报',
		'DASH_LBL_SNS_SUBSCRIPTION'		        	: 'SNS 订阅',

		'DASH_LBL_ID'	    	    				: 'ID',
		'DASH_LBL_INSTANCE_NAME'	    	 		: '实例名',
		'DASH_LBL_NAME'	    				 		: '名称',
		'DASH_LBL_STATUS'	    	    			: '状态',
		'DASH_LBL_STATE'	    	    			: '状态',
		'DASH_LBL_LAUNCH_TIME'	    	    		: '启动时间',
		'DASH_LBL_AMI'	    	    				: 'AMI',
		'DASH_LBL_AVAILABILITY_ZONE'	    		: '可用区域',
		'DASH_LBL_DETAIL'	    	    			: '详细',
		'DASH_LBL_IP'	    	    				: 'IP',
		'DASH_LBL_ASSOCIATED_INSTANCE'	    	    : '关联实例',
		'DASH_LBL_CREATE_TIME'	    	   		 	: '创建时间',
		'DASH_LBL_DEVICE_NAME'	    	    		: '设备名',
		'DASH_LBL_ATTACHMENT_STATUS'	    	    : '附加状态',
		'DASH_LBL_CIDR'	    	    				: 'CIDR',
		'DASH_LBL_DHCP_SETTINGS'	    	    	: 'DHCP设置',
		'DASH_LBL_VIRTUAL_PRIVATE_GATEWAY'	    	: '虚拟专用网关',
		'DASH_LBL_CUSTOMER_GATEWAY'	    	    	: '客户网关',
		'DASH_LBL_DNS_NAME'	    	    			: '域名',
		'DASH_LBL_CURRENT'	    	    			: '当前',
		'DASH_LBL_LAST_ACTIVITY'	    	    	: '最近活动',
		'DASH_LBL_ACTIVITY_STATUS'	    	    	: '活动状态',
		'DASH_LBL_DIMENSION'	    	    		: '维度',
		'DASH_LBL_THRESHOLD'	    	    		: '阈值',
		'DASH_LBL_TOPIC_NAME'	    	    		: '主题名',
		'DASH_LBL_ENDPOINT_AND_PROTOCOL'	    	: '终端和协议',
		'DASH_LBL_CONFIRMATION'	    	    		: '确认',


		'DASH_POP_CREATE_STACK_CREATE_THIS_STACK_IN'	: '将模板创建为',
		'DASH_POP_CREATE_STACK_CLASSIC'					: '传统模式',
		'DASH_POP_CREATE_STACK_CLASSIC_INTRO'			: '资源将被创建在传统的平台中',
		'DASH_POP_CREATE_STACK_VPC'						: 'VPC模式',
		'DASH_POP_CREATE_STACK_VPC_INTRO'				: '资源将被创建在新创建的VPC中',
		'DASH_POP_CREATE_STACK_DEFAULT_VPC'				: '默认VPC',
		'DASH_POP_CREATE_STACK_CUSTOM_VPC'				: '定制VPC',
		'DASH_POP_CREATE_STACK_DEFAULT_VPC_INTRO'		: '资源将被创建在新默认的VPC中',

		//###### dashboard module

		//###### ide

		'IDE_COM_CREATE_NEW_STACK'						: '创建模板',

		'IDE_LBL_REGION_NAME_us-east-1'					: '美国东部',
		'IDE_LBL_REGION_NAME_us-west-1'	  				: '美国西部',
		'IDE_LBL_REGION_NAME_us-west-2'	  				: '美国西部',
		'IDE_LBL_REGION_NAME_eu-west-1'	  				: '欧洲西部',
		'IDE_LBL_REGION_NAME_ap-southeast-1'    		: '亚太地区',
		'IDE_LBL_REGION_NAME_ap-southeast-2'			: '亚太地区',
		'IDE_LBL_REGION_NAME_ap-northeast-1'			: '亚太地区',
		'IDE_LBL_REGION_NAME_sa-east-1'	    			: '南美洲',

		'IDE_LBL_REGION_NAME_SHORT_us-east-1'	  		: '弗吉尼亚',
		'IDE_LBL_REGION_NAME_SHORT_us-west-1'	  		: '加利福尼亚北部',
		'IDE_LBL_REGION_NAME_SHORT_us-west-2'	  		: '俄勒冈',
		'IDE_LBL_REGION_NAME_SHORT_eu-west-1'	  		: '爱尔兰',
		'IDE_LBL_REGION_NAME_SHORT_ap-southeast-1'  	: '新加坡',
		'IDE_LBL_REGION_NAME_SHORT_ap-southeast-2'		: '悉尼',
		'IDE_LBL_REGION_NAME_SHORT_ap-northeast-1'		: '东京',
		'IDE_LBL_REGION_NAME_SHORT_sa-east-1'	    	: '圣保罗',

		//###### ide

		/****** popup ******/
		'POP_DOWNLOAD_KP_NOT_AVAILABLE'   : 'Not available yet. Password generation and encryption can sometimes take more than 30 minutes. Please wait at least 15 minutes after launching an instance before trying to retrieve the generated password.'

	}
});
