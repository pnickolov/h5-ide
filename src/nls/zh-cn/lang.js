define({
	'login' : {
		'login'          			: '登录',
		'login-register' 			: '注册新用户？ ',
		'link-register'  			: '注册',
		'error-msg-1'    			: '邮件地址或用户名不正确',
		'error-msg-2'    			: '邮件地址错误',
		'link-foget'     			: '忘记密码？',
		'login-user'     			: '邮件地址或用户名',
		'login-password' 			: '密码',
		'login-btn'      			: '登录',
		'login-loading'  			: '正在登录',
		'login_waiting'	 			: '稍等...',
		'madeira-offered-in'		: '&copy; MadeiraCloud 还提供'
		// Add new strings below this comment. Move above once English has been confirmed
	},
	'register' : {
		'register'					: '注册',
		'register-login'			: '已经有帐号？',
		'link-login'				: '登录',
		'register-username'			: '用户名',
		'register-email'			: '邮件地址',
		'register-password'			: '密码',
		'register-policy'			: '单击“创建账户”按钮，表示您已经同意我们的',
		'link-policy'				: '服务条款',
		'register-btn'				: '创建帐号',
		'register-success'			: '注册成功',
		'account-instruction'		: '非常感谢您注册 MadeiraCloud。',
		'register-get-start'		: '开始',

		'username_available'		: '用户名可用。',
		'username_not_matched'		: '用户名不匹配。',
		'username_required'			: '用户名不能为空。',
		'username_taken'			: '此用户名已经被注册，请选择其它用户名。',
		'email_available'			: '邮件地址可用。',
		'email_not_valid'			: '邮件地址非法。',
		'email_used'				: '此邮件地址已经被注册。',
		'password_ok'				: '密码可用。',
		'password_shorter'			: '密码至少包含6个字符、数字或者特殊字符。',
		'password_required'			: '密码不能为空。',
		'reginster_waiting'			: '稍等...'
	},
	'reset' : {
		'pre-reset'					: '忘记密码',
		'reset'						: '重置密码',
		'reset-register'			: '注册',
		'reset-login'				: '登录',
		'email-label'				: '请提供您在MadeiraCloud注册时的邮件地址或者用户名。包含重置链接的邮件马上将会发送给您。',
		'account-label'				: '用户名 or 邮件地址',
		'reset-btn'					: '发送密码重置请求邮件',
		'send-email-info'			: '包含密码重置链接的电子邮件已经发送到您注册的邮件地址中，请查收。',
		'check-email-info'			: '请检查您的收件箱（收件箱中如果没有，还请查看您的垃圾邮件文件夹）',
		'expired-info'				: '密码重置链接非法或者过期。',
		'reset-relogin'				: '登录MadeiraCloud',
		'reset-new-password'		: '新密码',
		'reset-done-btn'			: '完成',
		'reset-success-info'		: '成功重置密码。',

		'reset_waiting'				: '稍等...',
		'reset_password_shorter'	: '密码至少包含6个字符、数字或者特殊字符。',
		'reset_password_required'	: '密码已经过期。',
		'reset_btn'					: '发送密码重置请求邮件',
		'reset_error_state'			: '用户名或邮件地址还没有在MadeiraCloud注册过。'
	},
	'ide' : {
		'NAV_TIT_DASHBOARD' 		: '仪表板',
		'NAV_TIT_APPS'      		: '应用',
		'NAV_TIT_STACKS'    		: '模版',
		'NAV_LBL_GLOBAL'    		: '我的资源',
		'account-settings'  		: 'Account Settings',
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
		'IDE_MSG_ERR_OPEN_OLD_STACK_APP_TAB' : '抱歉，模板/应用的格式太旧了，无法打开.',
		'IDE_MSG_ERR_OPEN_TAB'        : '无法打开 模板/应用, 请重试',
		'IDE_MSG_ERR_CONNECTION'      : '无法加载部分IDE内容，请重试',

		/******resource panel module******/
		'RES_TIT_RESOURCES'           : '资源',
		'RES_TIT_AZ'                  : '可用区域',
		'RES_TIT_AMI'                 : '虚拟机映像',
		'RES_TIT_VOL'                 : '虚拟磁盘和快照',
		'RES_TIT_ELB_ASG'             : '负载均衡器和自动伸缩组',
		'RES_TIT_VPC'                 : '虚拟私有云',
		'RES_LBL_QUICK_START_AMI'     : '推荐的映像',
		'RES_LBL_MY_AMI'              : '我的映像',
		'RES_LBL_FAVORITE_AMI'        : '收藏的映像',
		'RES_LBL_NEW_VOL'             : '新的卷',
		'RES_LBL_NEW_ELB'             : '负载均衡器',
		'RES_LBL_NEW_ASG'             : 'Auto Scaling 组',
		'RES_LBL_NEW_ASG_NO_CONFIG'   : '无配置',
		'RES_LBL_NEW_SUBNET'          : '子网',
		'RES_LBL_NEW_RTB'             : '路由表',
		'RES_LBL_NEW_IGW'             : '因特网网关',
		'RES_LBL_NEW_VGW'             : '虚拟网关',
		'RES_LBL_NEW_CGW'             : '客户网关',
		'RES_LBL_NEW_ENI'             : '网络接口',
		'RES_BTN_BROWSE_COMMUNITY_AMI': '浏览映像',
		// Add new strings below this comment. Move above once English has been confirmed

		'RES_TIP_TOGGLE_RESOURCE_PANEL' : '显示/隐藏 资源面板',
		'RES_TIP_DRAG_AZ'               : '拖放到画板来使用这个可用区域',
		'RES_TIP_DRAG_NEW_VOLUME'       : '拖放到一个实例来附加一个新卷。',
		'RES_TIP_DRAG_NEW_ELB'          : '拖放到画板来创建一个新负载均衡器。',
		'RES_TIP_DRAG_NEW_ASG'          : '拖放到画板来创建一个新Auto Scaling组。',
		'RES_TIP_DRAG_NEW_SUBNET'       : '拖放到一个可用区域来创建一个新子网。',
		'RES_TIP_DRAG_NEW_RTB'          : '拖放到一个VPC来创建一个路由表。',
		'RES_TIP_DRAG_NEW_IGW'          : '拖放到画板来创建一个新互联网网关。',
		'RES_TIP_DRAG_NEW_VGW'          : '拖放到画板来创建一个新虚拟网关。',
		'RES_TIP_DRAG_NEW_CGW'          : '拖放到画板来创建一个新客户网关。',
		'RES_TIP_DRAG_NEW_ENI'          : '拖放到一个子网来创建一个新网络接口。',
		'RES_TIP_DRAG_HAS_IGW'          : '这个VPC已经有了一个互联网网关。',
		'RES_TIP_DRAG_HAS_VGW'          : '这个VPC已经有了一个虚拟网关。',
		// Add new strings below this comment. Move above once English has been confirmed

		'RES_MSG_WARN_GET_COMMUNITY_AMI_FAILED'		: '不能加载社区映像',
		'RES_MSG_INFO_ADD_AMI_FAVORITE_SUCCESS'		: '收藏映像成功',
		'RES_MSG_ERR_ADD_FAVORITE_AMI_FAILED'		: '收藏映像失败',
		'RES_MSG_INFO_REMVOE_FAVORITE_AMI_SUCCESS'	: '映像已从收藏列表中移除',
		'RES_MSG_ERR_REMOVE_FAVORITE_AMI_FAILED'	: '映像从收藏列表移除失败',
		// Add new strings below this comment. Move above once English has been confirmed

		/******canvas module******/
		'CVS_MSG_WARN_NOTMATCH_VOLUME'          : '卷和快照必须拖放到实例或映像。',
		'CVS_MSG_WARN_NOTMATCH_SUBNET'          : '子网必须拖放到可用区域。',
		'CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET' : '实例必须拖放到子网或Auto Scaling组。',
		'CVS_MSG_WARN_NOTMATCH_INSTANCE_AZ'     : '实例必须拖放到可用区域。',
		'CVS_MSG_WARN_NOTMATCH_ENI'             : '网络接口必须拖放到子网。',
		'CVS_MSG_WARN_NOTMATCH_RTB'             : '路由表必须拖放到可用区域外的VPC部分。',
		'CVS_MSG_WARN_NOTMATCH_ELB'             : '负载均衡器必须拖放到可用区域以外。',
		'CVS_MSG_WARN_NOTMATCH_CGW'             : '客户网关必须拖放到VPC以外。',
		'CVS_MSG_WARN_COMPONENT_OVERLAP'        : '节点不能互相重叠。',
		'CVS_WARN_EXCEED_ENI_LIMIT'             : "%s 的 %s 最多支持%s个网络接口 (包括主要的)。",
		'CVS_MSG_ERR_CONNECT_ENI_AMI'           : '网络接口只能连接到同一个可用区域的实例。',
		'CVS_MSG_ERR_MOVE_ATTACHED_ENI'         : '网络接口必须跟它附加的实例在同一个可用区域。',
		'CVS_MSG_ERR_DROP_ASG'                  : '%s已经存在于%s中。',
		'CVS_MSG_ERR_DEL_LC'                    : '目前还不支持修改启动配置。',
		'CVS_MSG_ERR_DEL_MAIN_RT'               : '主路由表：%s 不能被删除。 请将其他路由表设为主路由表后再重试。',
		'CVS_MSG_ERR_DEL_LINKED_RT'             : '子网必须与路由表关联，请先将这个子网与一个路由表关联起来。',
		'CVS_MSG_ERR_DEL_SBRT_LINE'             : '子网必须与路由表关联。',
		'CVS_MSG_ERR_DEL_ELB_INSTANCE_LINE'     : '每个可用区域中的负载均衡器只能连接一个子网。',
		'CVS_MSG_ERR_DEL_LINKED_ELB'            : '由于这个子网关联着负载均衡器，所以它不能被删除。',
		'CVS_CFM_DEL'                           : '删除 %s',
		'CVS_CFM_DEL_IGW'                       : '如果没有互联网网关，面向互联网的负载均衡器和弹性IP将失去作用。确定要删除它吗？',
		'CVS_CFM_DEL_GROUP'                     : "删除 %s 会同时删除其中的所有资源， 确定要删除它吗？",
		'CVS_CFM_DEL_ASG'                       : '删除它会删除整个 %s，确定要删除它吗?',
		'CVS_CFM_ADD_IGW'                       : '必须要有一个互联网网关',
		'CVS_CFM_ADD_IGW_MSG'                   : '自动添加一个互联网网关允许这个 %s 被公开寻址?',
		'CVS_MSG_ERR_ZOOMED_DROP_ERROR'         : '在添加新资源前，请重设缩放至100%。',
		'CVS_TIP_EXPAND_W'						: '增加画板宽度',
		'CVS_TIP_SHRINK_W'						: '减少画板宽度',
		'CVS_TIP_EXPAND_H'						: '增加画板高度',
		'CVS_TIP_SHRINK_H'						: '减少画板宽度',
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
		'TOOL_MSG_INFO_REQ_SUCCESS'             : '正在发送 %s %s 请求...',
		'TOOL_MSG_ERR_REQ_FAILED'               : '发送 %s %s 请求失败。',
		'TOOL_MSG_INFO_HDL_SUCCESS'             : '%s %s 成功。',
		'TOOL_MSG_ERR_HDL_FAILED'               : '%s %s 失败。',
		'TOOL_MSG_ERR_SAVE_FAILED'              : '保存模块 %s 失败，请您检查并重新保存。',
		// Add new strings below this comment. Move above once English has been confirmed
		'TOOLBAR_HANDLE_SAVE_STACK'             : '保存模块',
		'TOOLBAR_HANDLE_CREATE_STACK'           : '创建模块',
		'TOOLBAR_HANDLE_DUPLICATE_STACK'        : '复制模块',
		'TOOLBAR_HANDLE_REMOVE_STACK'           : '删除模块',
		'TOOLBAR_HANDLE_RUN_STACK'              : '运行模块',
		'TOOLBAR_HANDLE_START_APP'              : '恢复应用',
		'TOOLBAR_HANDLE_STOP_APP'               : '暂停应用',
		'TOOLBAR_HANDLE_TERMINATE_APP'          : '销毁应用',

		//refresh button
		'TOOL_MSG_INFO_APP_REFRESH_FINISH'      : '完成应用( %s )的资源刷新。',
		'TOOL_MSG_INFO_APP_REFRESH_FAILED'      : '刷新应用( %s )的资源失败, 请点击刷新按钮来重试。',
		'TOOL_MSG_INFO_APP_REFRESH_START'       : '开始刷新应用( %s )的资源 ...',
		'TOOL_MSG_ERR_CONVERT_CLOUDFORMATION'   : '转换成CloudFormation出错',

		//linestyle
		'TOOL_TIP_LINESTYLE'                          : '安全组规则连线类型...',
		'TOOL_LBL_LINESTYLE_STRAIGHT'                 : '直线',
		'TOOL_LBL_LINESTYLE_ELBOW'                    : '肘型线',
		'TOOL_LBL_LINESTYLE_QUADRATIC_BELZIER'        : '二次贝赛尔曲线',
		'TOOL_LBL_LINESTYLE_SMOOTH_QUADRATIC_BELZIER' : '光滑的二次贝塞尔曲线',

		/******property module******/

		'PROP_LBL_REQUIRED'                     : '必填',

		//###### instance property module
		'PROP_INSTANCE_DETAIL'					: '实例设置',
		'PROP_INSTANCE_HOSTNAME'				: '主机名',
		'PROP_INSTANCE_INSTANCE_ID'				: '实例ID',
		'PROP_INSTANCE_LAUNCH_TIME'				: '创建时间',
		'PROP_INSTANCE_STATE'					: '状态',
		'PROP_INSTANCE_STATUS'					: '状态',
		'PROP_INSTANCE_PRIMARY_PUBLIC_IP'		: '主公网IP',
		'PROP_INSTANCE_PUBLIC_IP'				: '公网IP',
		'PROP_INSTANCE_PUBLIC_DNS'				: '公网域名',
		'PROP_INSTANCE_PRIMARY_PRIVATE_IP'		: '主内网IP',
		'PROP_INSTANCE_PRIVATE_DNS'				: '内网域名',
		'PROP_INSTANCE_NUMBER'					: '实例数量',
		'PROP_INSTANCE_REQUIRE'					: '必须',
		'PROP_INSTANCE_AMI'						: '映像',
		'PROP_INSTANCE_TYPE'					: '实例类型',
		'PROP_INSTANCE_KEY_PAIR'				: '秘钥',
		'PROP_INSTANCE_EBS_OPTIMIZED'			: 'EBS 优化',
		'PROP_INSTANCE_TENANCY'					: '租用',
		'PROP_INSTANCE_TENANCY_DEFAULT'			: '默认',
		'PROP_INSTANCE_TENANCY_DELICATED'		: '专用',
		'PROP_INSTANCE_ROOT_DEVICE_TYPE'		: '根设备类型',
		'PROP_INSTANCE_BLOCK_DEVICE'			: '块设备',
		'PROP_INSTANCE_NEW_KP'					: '新建秘钥',
		'PROP_INSTANCE_CW_ENABLED'				: '打开CloudWatch监控',
		'PROP_INSTANCE_ADVANCED_DETAIL'			: '高级设置',
		'PROP_INSTANCE_USER_DATA'				: '用户数据',
		'PROP_INSTANCE_CW_WARN'					: '数据在一分钟内可用需要额外的话费。 获取价格信息，请去 ',
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
		'PROP_INSTANCE_AMI_ID'					: '映像ID',
		'PROP_INSTANCE_AMI_NAME'				: '映像名称',
		'PROP_INSTANCE_AMI_DESC'				: '描述',
		'PROP_INSTANCE_AMI_ARCHITECH'			: '架构',
		'PROP_INSTANCE_AMI_VIRTUALIZATION'		: '虚拟化',
		'PROP_INSTANCE_AMI_KERNEL_ID'			: '内核ID',
		'PROP_INSTANCE_AMI_OS_TYPE'				: '操作系统类型',
		'PROP_INSTANCE_AMI_SUPPORT_INSTANCE_TYPE'	: '支持实例类型',

		'PROP_INSTANCE_KEY_MONITORING'			: '监控',
		'PROP_INSTANCE_KEY_ZONE'				: '地区',
		'PROP_INSTANCE_AMI_LAUNCH_INDEX'		: 'AMI启动序号',
		'PROP_INSTANCE_AMI_NETWORK_INTERFACE'	: '网络接口',

		//###### instance property module



		//##### stack property module
		'PROP_STACK_LBL_NAME'                       : '模版名称',
		'PROP_STACK_LBL_REGION'                     : '地区',
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
		'PROP_AZ_LBL_SWITCH'                            : '切换可用区域',
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
		'PROP_IGW_TXT_DESCRIPTION'           : '互联网网关是将你位于AWS网络中的VPC网络连接到互联网的路由器.',
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
		'PROP_MSG_ERR_RESOURCE_NOT_EXIST'       : '抱歉，选定的资源不存在。',
		'PROP_MSG_ERR_DOWNLOAD_KP_FAILED'       : '抱歉，下载密钥对时出现了问题。',
		'PROP_MSG_WARN_NO_STACK_NAME'           : '模板名称不能为空。',
		'PROP_MSG_WARN_REPEATED_STACK_NAME'     : '这个模板名称已被占用。',
		'PROP_MSG_WARN_ENI_IP_EXTEND'           : '%s 实例的网络接口不能超过 %s 私有IP地址。',
		'PROP_MSG_WARN_NO_APP_NAME'             : '应用名称不能为空。',
		'PROP_MSG_WARN_REPEATED_APP_NAME'       : '这个应用名称已被占用This app name is already in use.',
		'PROP_MSG_WARN_INVALID_APP_NAME'		: '无效的应用名称。',
		'PROP_WARN_EXCEED_ENI_LIMIT'            : '实例类型：%s 支持最多 %s 个网络接口（包括主要的）， 请在改变实例类型之前删除超出数量限制的网络接口。',
		'PROP_TEXT_DEFAULT_SG_DESC'             : '模板默认安全组',
		'PROP_TEXT_CUSTOM_SG_DESC'              : '客户安全组',
		'PROP_MSG_WARN_WHITE_SPACE'				: '模板名称不能包含空格',
		// Add new strings below this comment. Move above once English has been confirmed
		'PROP_MSG_ERR_GET_PASSWD_FAILED'        : '抱歉，获取实例口令信息时出现了问题。',
		'PROP_MSG_ERR_AMI_NOT_FOUND'            : '无法获取选中的( %s )AMI的信息，请拖拽其他的AMI。',

		// sg property
		'PROP_MSG_SG_CREATE'                    : "1条规则被创建到 %s 来允许 %s %s %s。",
		'PROP_MSG_SG_CREATE_MULTI'              : "%d条规则被创建到 %s 并且 %s 来允许 %s %s %s.",
		'PROP_MSG_SG_CREATE_SELF'               : "%d条规则被创建到 %s 来允许 %s 它内部的收发通信.",

		//###### volume property
		'PROP_VOLUME_DEVICE_NAME'				: '挂载设备名',
		'PROP_VOLUME_SIZE'						: '磁盘大小',
		'PROP_VOLUME_ID'						: '磁盘ID',
		'PROP_VOLUME_STATE'						: '状态',
		'PROP_VOLUME_CREATE_TIME'				: '创建时间',
		'PROP_VOLUME_SNAPSHOT_ID'				: '快照ID',
		'PROP_VOLUME_SNAPSHOT'					: '快照',
		'PROP_VOLUME_ATTACHMENT_STATE'			: '挂载状态',
		'PROP_VOLUME_ATTACHMENT_SET'			: '挂载数据集',
		'PROP_VOLUME_INSTANCE_ID'				: '实例ID',
		'PROP_VOLUME_ATTACHMENT_TIME'			: '挂载时间',
		'PROP_VOLUME_TYPE'						: '磁盘类型',
		'PROP_VOLUME_TYPE_STANDARD'				: '标准',
		'PROP_VOLUME_TYPE_IOPS'					: '预配置IOPS',
		'PROP_VOLUME_MSG_WARN'					: '要使用预配置IOPS,磁盘必须最少10GB',
		//###### volume property

		//###### eni property
		'PROP_ENI_LBL_ATTACH_WARN'				: '在同一个可用区域里面附加网络接口。',
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
		'PROP_ELB_LBL_LISTENER_DESCRIPTIONS'	: '监听器描述',
		'PROP_ELB_LBL_LISTENER_PRIVATE_KEY'		: '私钥',
		'PROP_ELB_LBL_LISTENER_PUBLIC_KEY'		: '公钥',
		'PROP_ELB_LBL_LISTENER_CERTIFICATE_CHAIN': '认证链',
		'PROP_ELB_HEALTH_CHECK'					: '健康度检查',
		'PROP_ELB_HEALTH_CHECK_DETAILS'			: '健康度检查配置',
		'PROP_ELB_PING_PROTOCOL'				: 'Ping协议',
		'PROP_ELB_PING_PORT'					: 'Ping端口',
		'PROP_ELB_PING_PATH'					: 'Ping路径',
		'PROP_ELB_HEALTH_CHECK_INTERVAL'		: '健康度检查间隔',
		'PROP_ELB_HEALTH_CHECK_INTERVAL_SECONDS': '秒',
		'PROP_ELB_HEALTH_CHECK_RESPOND_TIMEOUT'	: '响应超时',
		'PROP_ELB_HEALTH_THRESHOLD'				: '健康界限',
		'PROP_ELB_UNHEALTH_THRESHOLD'			: '不健康界限',
		'PROP_ELB_AVAILABILITY_ZONE'			: '可用区域',
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
		'PROP_ASG_MSG_DROP_LC'					: '请拖拽映像来建立Launch Configuration',
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
		'PROP_LC_TITLE'							: '启动配置',
		'PROP_LC_NAME'							: '名称',
		'PROP_LC_CREATE_TIME'				    : '创建时间',
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
		'NAV_DESMOD_NOT_FINISH_LOAD'            : '抱歉，设计模块正在加载，请稍后重试。',
		// Add new strings below this comment. Move above once English has been confirmed

		/****** process module ******/
		'PROC_TITLE'                 : '启动您的应用...',
		'PROC_RLT_DONE_TITLE'        : '一切顺利!',
		'PROC_RLT_DONE_SUB_TITLE'    : '您的应用将被自动打开。',
		'PROC_STEP_PREPARE'          : '准备启动应用...',
		'PROC_RLT_FAILED_TITLE'      : '启动应用错误。',
		'PROC_RLT_FAILED_SUB_TITLE'  : '请先解决以下下问题，然后重试。',
		'PROC_ERR_INFO'              : '错误详情',
		'PROC_CLOSE_TAB'             : '关闭标签',
		'PROC_STEP_REQUEST'          : '处理中',
		// Add new strings below this comment. Move above once English has been confirmed
		'PROC_FAILED_TITLE'          :  '启动应用错误',

		/****** region module *****/
		'REG_MSG_WARN_APP_PENDING'	 : '您的应用正在处理中，请稍等一会。',
		// Add new strings below this comment. Move above once English has been confirmed

		/****** miscellaneous ******/
		'CFM_BTN_DELETE'   : '删除',
		'CFM_BTN_CANCEL'   : '取消',
		'CFM_BTN_ADD'      : '添加',
		'CFM_BTN_DONT_ADD' : "不要添加",
		// Add new strings below this comment. Move above once English has been confirmed

		//#### topmenu
		'HEAD_LABEL_MENUITEM_USER_TOUR'  : '用户教程',
		'HEAD_LABEL_MENUITEM_DOC'        : '使用文档',
		'HEAD_LABEL_MENUITEM_SETTING'    : '账号设置',
		'HEAD_LABEL_MENUITEM_LOGOUT'     : '登出',
		//#### topmenu

		/****** account credential module ******/
		'HEAD_LABEL_SETTING'			  : '用户设置',
		'HEAD_LABEL_ACCOUNT'			  : '账号',
		'HEAD_LABEL_CREDENTIAL'			  : 'AWS 证书',
		'HEAD_LABEL_ACCOUNT_USERNAME'	  : '用户名',
		'HEAD_LABEL_ACCOUNT_EMAIL'		  : '电子邮件地址',
		'HEAD_LABEL_CHANGE_PASSWORD'	  : '修改密码',
		'HEAD_LABEL_CURRENT_PASSWORD'	  : '当前密码',
		'HAED_LABEL_NEW_PASSWORD'		  : '新密码',
		'HEAD_LABEL_REMOVE_CREDENTIAL'    : '移除证书',
		'HEAD_LABEL_ACCOUNT_CHANGE'		  : '修改',
		'HEAD_LABEL_ACCOUNT_UPDATE' 	  : '更新',
		'HEAD_LABEL_ACCOUNT_CANCEL'		  : '取消',
		'HEAD_LABEL_ACCOUNT_PERIOD'		  : '。',
		'HEAD_LABEL_ACCOUNT_QUESTION'	  : '？',
		'HEAD_LABEL_WELCOME'			  : '欢迎',
		'HEAD_LABEL_PROVIDE_CREDENTIAL'	  : '请提供AWS证书',
		'HEAD_LABEL_ACCOUNT_SKIP'		  : '跳过',
		'HEAD_LABEL_ACCOUNT_ID'			  : '账户编号',
		'HEAD_LABEL_ACCOUNT_ACCESS_KEY'   : '访问码编号',
		'HEAD_LABEL_ACCOUNT_SECRET_KEY'	  : '密匙',

		'HEAD_BTN_CHANGE'			  	  : '修改',
		'HEAD_BTN_UPDATE'			  	  : '更新',
		'HEAD_BTN_CANCEL'				  : '取消',
		'HEAD_BTN_SUBMIT'				  : '提交',
		'HEAD_BTN_CLOSE'				  : '关闭',
		'HEAD_BTN_DONE'					  : '完成',

		'HEAD_INFO_ACCOUNT_LIST'		  : '您已经使用如下AWS账号连接:',
		'HEAD_INFO_REMOVE_CREDENTIAL1'	  : '移除证书后，您还可以使用试用证书。',
		'HEAD_INFO_REMOVE_CREDENTIAL2'	  : '如果想启动应用，您需要提供有效的AWS证书。',
		'HEAD_INFO_REMOVE_CREDENTIAL3'	  : '因为资源不一致的原因，在更新为可用的AWS证书后，您使用试用证书设计的模块不能被启动。',
		'HEAD_INFO_LOADING'			  	  : '加载中...',
		'HEAD_INFO_LOADING_RESOURCE'	  : '加载资源中...',
		'HEAD_WARN_UPDATE_CREDENTIAL'	  : '还有没被销毁的应用，您现在不能修改当前AWS证书。如果你想修改AWS证书，首先需要销毁所有已有应用。',

		'HEAD_INFO_PROVIDE_CREDENTIAL1'   : '现在想提供AWS证书吗？',
		'HEAD_INFO_DEMO_MODE'			  : '您可以使用试用证书进行模板设计，但有以下缺点：',
		'HEAD_INFO_WELCOME'				  : '欢迎来到MadeiraCloud, %s。',
		'HEAD_INFO_PROVIDE_CREDENTIAL2'	  : '在开始您的云架构设计之前，请提供AWS证书：',
		'HEAD_INFO_PROVIDE_CREDENTIAL3'   : '请提供您好AWS证书来加载和管理AWS资源。',
		'HEAD_ERR_AUTHENTICATION' 		  : '授权失败，请检查您的AWS证书并重试。',
		'HEAD_CHANGE_CREDENTIAL'		  : '如果您修改AWS证书，因为资源不一致性的原因，您之前创建的设计成果将不能使用。',
		'HEAD_INFO_CONFIRM_REMOVE'		  : '您确定要移除账号%s的AWS证书吗？',
		'HEAD_INFO_CONNECTING'			  : '正在连接AWS账号',

		'HEAD_TIP_AWS_ACCOUNT_ID' 		  : "当您登陆到您的AWS账号时，您的AWS账号编号将显示在您浏览器窗口的左上角区域。 比如123456789000",
		'HEAD_TIP_ACCOUNT_ACCESS_KEY' 	  : "通过点击&nbsp;账号&nbsp;&gt;安全性认证&nbsp;菜单，然后切换到页面中间的&nbsp;访问码&nbsp;页面，您将能找到您的访问码。 例如ABCDEFGHIJ1LMNOPQR2S",
		'HEAD_TIP_ACCOUNT_SECRET_KEY'	  : "通过点击&nbsp;账号&nbsp;&gt;安全性认证&nbsp;菜单，然后切换到页面中间的&nbsp;访问码&nbsp;页面，您将能找到您的访问码。 例如aBCDefgH/ Ijklmnopq1Rs2tUVWXY3AbcDeFGhijk",
		'HEAD_MSG_ERR_INVALID_ACCOUNT_ID' : '无效的帐户ID',
		'HEAD_MSG_ERR_INVALID_ACCESS_KEY' : '无效的访问密钥',
		'HEAD_MSG_ERR_INVALID_SECRET_KEY' : '无效的密钥',
		'HEAD_MSG_ERR_INVALID_SAME_ID'    : '账号相同，请输入不同的账号',
		'HEAD_MSG_ERR_KEY_UPDATE'         : '修改账号失败，恢复上一个账号',
		'HEAD_MSG_ERR_RESTORE_DEMO_KEY'   : '恢复到演示账号',

		// account profile
		'HEAD_MSG_ERR_NULL_PASSWORD'      : '请提供旧密码和新密码来完成重设密码操作。',
		'HEAD_MSG_ERR_INVALID_PASSWORD'	  : '密码最少6位且不能和您的用户名相同',
		'HEAD_MSG_ERR_ERROR_PASSWORD'     : '密码错误',
		'HEAD_MSG_ERR_RESET_PASSWORD'     : '忘记密码?',
		'HEAD_MSG_INFO_UPDATE_PASSWORD'   : '密码修改成功。',
		'HEAD_MSG_ERR_UPDATE_PASSWORD'    : '修改密码失败。',
		'HEAD_MSG_ERR_WRONG_PASSWORD'	  : '密码错误',
		'HEAD_MSG_INFO_FORGET_PASSWORD'	  : '是否重置密码?',
		'HEAD_MSG_INFO_UPDATE_EMAIL'      : '电子邮件地址修改成功。',
		'HEAD_MSG_ERR_UPDATE_EMAIL1'      : '修改邮箱地址失败',
		'HEAD_MSG_ERR_UPDATE_EMAIL2'	  : '邮箱地址已被使用',
		'HEAD_MSG_ERR_UPDATE_EMAIL3'	  : '非有效邮箱地址',

		'HEAD_LABEL_TOUR_DESIGN_DIAGRAM'  : '拖放到设计图',
		'HEAD_LABEL_TOUR_CONNECT_PORT'    : '连接端口',
		'HEAD_LABEL_TOUR_CONFIG_PROPERTY' : '配置属性',
		'HEAD_LABEL_TOUR_DO_MORE'		  : '使用工具栏',

		'HEAD_INFO_TOUR_DESIGN_DIAGRAM'   : '轻松拖拽就可以添加可用区域、	主机、磁盘和所有其它的资源到画布中。',
		'HEAD_INFO_TOUR_CONNECT_PORT' 	  : '通过端口可以设置安全组规则、建立依赖、生成路由以及其它很多。',
		'HEAD_LABEL_TOUR_CONFIG_PROPERTY' : '右侧的面板可以进行详细设置。',
		'HEAD_INFO_TOUR_DO_MORE'		  : '通过工具栏可以运行模板、自定义可视化数据以及导出数据和资源。',
		// Add new strings below this comment. Move above once English has been confirmed

		/****** base_main.cofffee for module(x) ******/
		'MODULE_RELOAD_MESSAGE'           : '抱歉，网络连接失败，IDE正在重新加载',
		'MODULE_RELOAD_FAILED'            : '抱歉，网络连接失败，IDE不能加载，请刷新浏览器',
		// Add new strings below this comment. Move above once English has been confirmed

		'BEFOREUNLOAD_MESSAGE'            : '您有未保存的更改。',

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
		'DASH_LBL_NO_APP'							: '该地区没有应用<br />你可以通过模板创建应用',
		'DASH_LBL_NO_STACK'							: '该地区还没有模板<br />点击这里创建新模板',

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
		'DASH_LBL_INSTANCE_ID'	    	 		    : '实例ID',
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
		'DASH_LBL_DOMAIN'	    	    			: '域',
		'DASH_LBL_CURRENT'	    	    			: '当前',
		'DASH_LBL_LAST_ACTIVITY'	    	    	: '最近活动',
		'DASH_LBL_ACTIVITY_STATUS'	    	    	: '活动状态',
		'DASH_LBL_DIMENSION'	    	    		: '维度',
		'DASH_LBL_THRESHOLD'	    	    		: '阈值',
		'DASH_LBL_TOPIC_NAME'	    	    		: '主题名',
		'DASH_LBL_ENDPOINT_AND_PROTOCOL'	    	: '终端和协议',
		'DASH_LBL_CONFIRMATION'	    	    		: '确认',
		'DASH_LBL_SUBNETS'	    	    			: '子网',
		'DASH_LBL_ASSOCIATION_ID'	    	    	: '关联 ID',
		'DASH_LBL_ALLOCATION_ID'	    	    	: '分配 ID',
		'DASH_LBL_NETWORK_INTERFACE_ID'	    	    : '网络接口 ID',
		'DASH_LBL_PRIVATE_IP_ADDRESS'	    	    : '内网IP地址',

		'DASH_LBL_AUTOSCALING_GROUP_NAME'	    	: 'Auto Scaling组名',
		'DASH_LBL_AUTOSCALING_GROUP_ARN'	    	: 'Auto Scaling组ARN',
		'DASH_LBL_ENABLED_METRICS'	    			: '开启的指标',
		'DASH_LBL_LAUNCH_CONFIGURATION_NAME'	    : '启动配置名称',
		'DASH_LBL_LOADBALANCER_NAMES'	    		: '负载均衡器名称',
		'DASH_LBL_MIN_SIZE'	    					: '最小值',
		'DASH_LBL_MAX_SIZE'	    					: '最大值',
		'DASH_LBL_TERMINATION_POLICIES'	    		: '结束策略',
		'DASH_LBL_VPC_ZONE_IDENTIFIER'	    		: 'VPC区域标识符',

		'DASH_LBL_ACTIONS_ENABLED'                  : '操作启用',
		'DASH_LBL_ALARM_ACTIONS'                    : '警报操作',
		'DASH_LBL_ALARM_ARN'                        : '警报 ARN',
		'DASH_LBL_ALARM_DESCRIPTION'                : '警报描述',
		'DASH_LBL_ALARM_NAME'                       : '警报名称',
		'DASH_LBL_COMPARISON_OPERATOR'              : '比较操作符',
		'DASH_LBL_DIMENSIONS'                       : '维度',
		'DASH_LBL_EVALUATION_PERIODS'               : '评估周期',
		'DASH_LBL_INSUFFICIENT_DATA_ACTIONS'        : '数据不足操作',
		'DASH_LBL_METRIC_NAME'                      : '指标名称',
		'DASH_LBL_NAMESPACE'                        : '命名空间',
		'DASH_LBL_OK_ACTIONS'                       : 'OK操作',
		'DASH_LBL_PERIOD'                           : '周期',
		'DASH_LBL_STATISTIC'                        : '统计数据',
		'DASH_LBL_STATE_VALUE'                      : '状态值',
		'DASH_LBL_THRESHOLD'                        : '阈值',
		'DASH_LBL_UNIT'                             : '单位',

		'DASH_LBL_ENDPOINT'                         : '终端',
		'DASH_LBL_OWNER'                            : '拥有者',
		'DASH_LBL_PROTOCOL'                         : '协议',
		'DASH_LBL_SUBSCRIPTION_ARN'                 : '订阅 ARN',
		'DASH_LBL_TOPIC_ARN'                        : '主题 ARN',

		'DASH_BUB_NAME'	    	    				: '名称',
		'DASH_BUB_DESCRIPTION'						: '描述',
		'DASH_BUB_ARCHITECTURE'	    	    		: '架构',
		'DASH_BUB_IMAGELOCATION'	    	    	: '映像位置',
		'DASH_BUB_ISPUBLIC'	    	    			: '是否公用',
		'DASH_BUB_KERNELID'	    	    			: '内核ID',
		'DASH_BUB_ROOTDEVICENAME'	    	    	: '根设备名',
		'DASH_BUB_ROOTDEVICETYPE'	    	    	: '根设备类型',


		'DASH_POP_CREATE_STACK_CREATE_THIS_STACK_IN'	: '将模板创建为',
		'DASH_POP_CREATE_STACK_CLASSIC'					: '传统模式',
		'DASH_POP_CREATE_STACK_CLASSIC_INTRO'			: '资源将被创建在传统的平台中',
		'DASH_POP_CREATE_STACK_VPC'						: 'VPC模式',
		'DASH_POP_CREATE_STACK_VPC_INTRO'				: '资源将被创建在新创建的VPC中',
		'DASH_POP_CREATE_STACK_DEFAULT_VPC'				: '默认VPC',
		'DASH_POP_CREATE_STACK_CUSTOM_VPC'				: '定制VPC',
		'DASH_POP_CREATE_STACK_DEFAULT_VPC_INTRO'		: '资源将被创建在新默认的VPC中',

		//###### dashboard module

		//###### community amis module

		'AMI_LBL_COMMUNITY_AMIS'                    : '社区映像',
		'AMI_LBL_ALL_SEARCH_AMI_BY_NAME_OR_ID'      : '根据名称或ID搜索映像',
		'AMI_LBL_ALL_PLATFORMS'                     : '所有平台',

		'AMI_LBL_VISIBILITY'                        : '可见性',
		'AMI_LBL_ARCHITECTURE'                      : '架构',
		'AMI_LBL_ROOT_DEVICE_TYPE'                  : '根设备类型',

		'AMI_LBL_PUBLIC'                            : '公用',
		'AMI_LBL_PRIVATE'                           : '私有',
		'AMI_LBL_32_BIT'                            : '32位',
		'AMI_LBL_64_BIT'                            : '64位',
		'AMI_LBL_EBS'                               : 'EBS',
		'AMI_LBL_INSTANCE_STORE'                    : '实例存储',

		'AMI_LBL_SEARCH'                            : '搜索',
		'AMI_LBL_SEARCHING'                         : '搜索中...',

		'AMI_LBL_AMI_ID'                            : '映像 ID',
		'AMI_LBL_AMI_NAME'                          : '映像名称',
		'AMI_LBL_ARCH'                              : '架构',

		'AMI_LBL_PAGEINFO'                          : '当前显示 %s 条，共有 %s 条',


		//###### community amis module

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

		'IDE_LBL_LAST_STATUS_CHANGE'					: "最近修改时间",

		//###### ide

		//###### popup

		'POP_DOWNLOAD_KP_NOT_AVAILABLE'   : '当前不可用。口令生成和加密通常需要30分钟时间。启动实例后在拿到生成的口令前，请至少等待15分钟。',
		'POP_BTN_CLOSE'     		      : '关闭'

		//###### popup

	},
	'service' : {
		'ERROR_CODE_0_MESSAGE'  : '',//invoke API succeeded
		'ERROR_CODE_1_MESSAGE'  : '对不起,AWS有一些技术问题,请稍后再试',
		'ERROR_CODE_2_MESSAGE'  : '对不起,我们有一些技术问题,请稍后再试',
		'ERROR_CODE_3_MESSAGE'  : '',//no use
		'ERROR_CODE_4_MESSAGE'  : '',//no use
		'ERROR_CODE_5_MESSAGE'  : '对不起,AWS有一些技术问题,请稍后再试',
		'ERROR_CODE_6_MESSAGE'  : '',//no use
		'ERROR_CODE_7_MESSAGE'  : '',//for guest
		'ERROR_CODE_8_MESSAGE'  : '',//no use
		'ERROR_CODE_9_MESSAGE'  : '对不起,您的AWS凭证没有足够的权限',
		'ERROR_CODE_10_MESSAGE' : '',//no use
		'ERROR_CODE_11_MESSAGE' : '',//no use
		'ERROR_CODE_12_MESSAGE' : '对不起,我们有一些技术问题,请稍后再试',
		'ERROR_CODE_13_MESSAGE' : '',//no use
		'ERROR_CODE_14_MESSAGE' : '',//no use
		'ERROR_CODE_15_MESSAGE' : '对不起,AWS有一些技术问题,请稍后再试',
		'ERROR_CODE_16_MESSAGE' : '对不起,AWS有一些技术问题,请稍后再试',
		'ERROR_CODE_17_MESSAGE' : '',//no use
		'ERROR_CODE_18_MESSAGE' : '对不起,AWS有一些技术问题,请稍后再试',
		'ERROR_CODE_19_MESSAGE' : '对不起，你的会话已过期，请重新登录',
		'ERROR_CODE_20_MESSAGE' : '对不起，邀请已经结束',//for guest
		'ERROR_CODE_21_MESSAGE' : '对不起，此账号已被锁住'
		// Add new strings below this comment. Move above once English has been confirmed
	}
});
