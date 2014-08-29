# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =
  IDE:

    PROP_LBL_REQUIRED:
      en: "Required"
      zh: "必填"

    PROP_LBL_DEFAULT:
      en: "Default"
      zh: ""

    PROP_LBL_DONE:
      en: "Done"
      zh: ""

    PROP_LBL_CANCEL:
      en: "Cancel"
      zh: ""

    PROP_LBL_LOADING:
      en: "Loading..."
      zh: ""

    PROP_INSTANCE_DETAIL:
      en: "Instance Details"
      zh: "实例设置"

    PROP_INSTANCE_HOSTNAME:
      en: "Hostname"
      zh: "主机名"

    PROP_INSTANCE_INSTANCE_ID:
      en: "Instance ID"
      zh: "实例ID"

    PROP_INSTANCE_LAUNCH_TIME:
      en: "Launch Time"
      zh: "创建时间"

    PROP_INSTANCE_STATE:
      en: "State"
      zh: "状态"

    PROP_INSTANCE_STATUS:
      en: "Status"
      zh: "状态"

    PROP_INSTANCE_PRIMARY_PUBLIC_IP:
      en: "Primary Public IP"
      zh: "主公网IP"

    PROP_INSTANCE_PUBLIC_IP:
      en: "Public IP"
      zh: "公网IP"

    PROP_INSTANCE_PUBLIC_DNS:
      en: "Public DNS"
      zh: "公网域名"

    PROP_INSTANCE_PRIMARY_PRIVATE_IP:
      en: "Primary Private IP"
      zh: "主内网IP"

    PROP_INSTANCE_PRIVATE_DNS:
      en: "Private DNS"
      zh: "内网域名"

    PROP_INSTANCE_NUMBER:
      en: "Number of Instance"
      zh: "实例数量"

    PROP_INSTANCE_REQUIRE:
      en: "Required"
      zh: "必须"

    PROP_INSTANCE_AMI:
      en: "AMI"
      zh: "映像"

    PROP_INSTANCE_TYPE:
      en: "Instance Type"
      zh: "实例类型"

    PROP_INSTANCE_KEY_PAIR:
      en: "Key Pair"
      zh: "秘钥"

    PROP_INSTANCE_CLOUDWATCH_DETAILED_MONITORING:
      en: "CloudWatch Detailed Monitoring"
      zh: ""

    PROP_INSTANCE_EBS_OPTIMIZED:
      en: "EBS Optimization"
      zh: "EBS 优化"

    PROP_INSTANCE_TENANCY:
      en: "Tenancy"
      zh: "租用"

    PROP_INSTANCE_TENANCY_DEFAULT:
      en: "Default"
      zh: "默认"

    PROP_INSTANCE_TENANCY_DELICATED:
      en: "Delicated"
      zh: "专用"

    PROP_INSTANCE_ROOT_DEVICE_TYPE:
      en: "Block Device Type"
      zh: "根设备类型"

    PROP_INSTANCE_BLOCK_DEVICE:
      en: "Block Devices"
      zh: "块设备"

    PROP_INSTANCE_DEFAULT_KP:
      en: "$DefaultKeyPair"
      zh: ""

    PROP_INSTANCE_NO_KP:
      en: "No Key Pair"
      zh: ""

    PROP_INSTANCE_NEW_KP:
      en: "Create New Key Pair"
      zh: "新建秘钥"

    PROP_INSTANCE_FILTER_KP:
      en: "Filter by key pair name"
      zh: ""

    PROP_INSTANCE_MANAGE_KP:
      en: "Manage Region Key Pairs ..."
      zh: ""

    PROP_INSTANCE_FILTER_SNS:
      en: "Filter by SNS Topic name"
      zh: ""

    PROP_INSTANCE_MANAGE_SNS:
      en: "Manage SNS Topic ..."
      zh: ""

    PROP_INSTANCE_FILTER_SSL_CERT:
      en: "Filter by SSL Certificate name"
      zh: ""

    PROP_INSTANCE_MANAGE_SSL_CERT:
      en: "Manage SSL Certificate..."
      zh: ""

    PROP_INSTANCE_TIP_DEFAULT_KP:
      en: 'If you have used $DefaultKeyPair for any instance/launch configuration, you will be required to specify an existing key pair for $DefaultKeyPair. Or you can choose "No Key Pair" as $DefaultKeyPair.'
      zh: ""

    PROP_INSTANCE_TIP_NO_KP:
      en: "If you select no key pair, you will not be able to connect to the instance unless you already know the password built into this AMI."
      zh: ""

    PROP_INSTANCE_CW_ENABLED:
      en: "Enable CloudWatch Detailed Monitoring"
      zh: "打开CloudWatch监控"

    PROP_INSTANCE_ADVANCED_DETAIL:
      en: "Advanced Details"
      zh: "高级设置"

    PROP_INSTANCE_USER_DATA:
      en: "User Data"
      zh: "用户数据"

    PROP_INSTANCE_USER_DATA_DISABLE:
      en: "Can't edit user data when instance state exist"
      zh: ""

    PROP_INSTANCE_CW_WARN:
      en: "Data is available in 1-minute periods at an additional cost. For information about pricing, go to the "
      zh: "数据在一分钟内可用需要额外的话费。 获取价格信息，请去 "

    PROP_AGENT_USER_DATA_URL:
      en: "https://github.com/MadeiraCloud/OpsAgent/blob/develop/scripts/userdata.sh"
      zh: "https://github.com/MadeiraCloud/OpsAgent/blob/develop/scripts/userdata.sh"

    PROP_INSTANCE_ENI_DETAIL:
      en: "Network Interface Details"
      zh: "网卡设置"

    PROP_INSTANCE_ENI_DESC:
      en: "Description"
      zh: "描述"

    PROP_INSTANCE_ENI_SOURCE_DEST_CHECK:
      en: "Enable Source/Destination Checking"
      zh: "打开 Source/Destination 检查"

    PROP_INSTANCE_ENI_SOURCE_DEST_CHECK_DISP:
      en: "Source/Destination Checking"
      zh: "Source/Destination 检查"

    PROP_INSTANCE_ENI_AUTO_PUBLIC_IP:
      en: "Automatically assign Public IP"
      zh: "自动分配公网IP"

    PROP_INSTANCE_ENI_IP_ADDRESS:
      en: "IP Address"
      zh: "IP地址"

    PROP_INSTANCE_ENI_ADD_IP:
      en: "Add IP"
      zh: "添加IP"

    PROP_INSTANCE_SG_DETAIL:
      en: "Security Groups"
      zh: "安全组"

    PROP_INSTANCE_IP_MSG_1:
      en: "Specify an IP address or leave it as .x to automatically assign an IP."
      zh: "请提供一个IP或者保留为.x来自动分配IP"

    PROP_INSTANCE_IP_MSG_2:
      en: "Automatically assigned IP."
      zh: "自动分配IP"

    PROP_INSTANCE_IP_MSG_3:
      en: "Associate with Elastic IP"
      zh: "和Elastic IP进行关联"

    PROP_INSTANCE_IP_MSG_4:
      en: "Detach Elastic IP"
      zh: "取消关联Elastic IP"

    PROP_INSTANCE_AMI_ID:
      en: "AMI ID"
      zh: "映像ID"

    PROP_INSTANCE_AMI_NAME:
      en: "Name"
      zh: "映像名称"

    PROP_INSTANCE_AMI_DESC:
      en: "Description"
      zh: "描述"

    PROP_INSTANCE_AMI_ARCHITECH:
      en: "Architecture"
      zh: "架构"

    PROP_INSTANCE_AMI_VIRTUALIZATION:
      en: "Virtualization"
      zh: "虚拟化"

    PROP_INSTANCE_AMI_KERNEL_ID:
      en: "Kernel ID"
      zh: "内核ID"

    PROP_INSTANCE_AMI_OS_TYPE:
      en: "Type"
      zh: "操作系统类型"

    PROP_INSTANCE_AMI_SUPPORT_INSTANCE_TYPE:
      en: "Support Instance"
      zh: "支持实例类型"

    PROP_INSTANCE_KEY_MONITORING:
      en: "Monitoring"
      zh: "监控"

    PROP_INSTANCE_KEY_ZONE:
      en: "Zone"
      zh: "地区"

    PROP_INSTANCE_AMI_LAUNCH_INDEX:
      en: "AMI Launch Index"
      zh: "AMI启动序号"

    PROP_INSTANCE_AMI_NETWORK_INTERFACE:
      en: "Network Interface"
      zh: "网络接口"

    PROP_INSTANCE_TIP_GET_SYSTEM_LOG:
      en: "Get System Log"
      zh: ""

    PROP_DB_INSTANCE_TIP_GET_LOG:
      en: "Get Logs & Events"
      zh: ""

    PROP_INSTANCE_TIP_IF_THE_QUANTITY_IS_MORE_THAN_1:
      en: "If the quantity is more than 1, host name will be the string you provide plus number index."
      zh: ""

    PROP_INSTANCE_TIP_YOU_CANNOT_SPECIFY_INSTANCE_NUMBER:
      en: "You cannot specify instance number, since the instance is connected to a route table."
      zh: ""

    PROP_INSTANCE_TIP_PUBLIC_IP_CANNOT_BE_ASSOCIATED:
      en: "Public IP cannot be associated if instance is launching with more than one network interface."
      zh: ""

    PROP_AMI_STACK_NOT_AVAILABLE:
      en: "<p>This AMI is not available. It may have been deleted by its owner or not shared with your AWS account. </p><p>Please change to another AMI.</p>"
      zh: ""

    PROP_AMI_APP_NOT_AVAILABLE:
      en: "This AMI's infomation is unavailable."
      zh: ""

    PROP_STACK_AMAZON_ARN:
      en: "Amazon ARN"
      zh: ""

    PROP_STACK_EXAMPLE_EMAIL:
      en: "example@acme.com"
      zh: ""

    PROP_STACK_E_G_1_206_555_6423:
      en: "e.g. 1-206-555-6423"
      zh: ""

    PROP_STACK_HTTP_WWW_EXAMPLE_COM:
      en: "http://www.example.com"
      zh: ""

    PROP_STACK_HTTPS_WWW_EXAMPLE_COM:
      en: "https://www.example.com"
      zh: ""

    PROP_STACK_HTTPS:
      en: "https"
      zh: ""

    PROP_STACK_HTTP:
      en: "http"
      zh: ""

    PROP_STACK_USPHONE:
      en: "usPhone"
      zh: ""

    PROP_STACK_EMAIL:
      en: "email"
      zh: ""

    PROP_STACK_ARN:
      en: "arn"
      zh: ""

    PROP_STACK_SQS:
      en: "sqs"
      zh: ""

    PROP_STACK_PENDING_CONFIRM:
      en: "pendingConfirm"
      zh: ""

    PROP_STACK_LBL_NAME:
      en: "Stack Name"
      zh: "模版名称"

    PROP_APP_LBL_NAME:
      en: "App Name"
      zh: "应用名称"

    PROP_STACK_LBL_DESCRIPTION:
      en: "Stack Description"
      zh: "模板描述"

    PROP_STACK_LBL_DESC:
      en: "Description"
      zh: "描述"

    PROP_STACK_LBL_REGION:
      en: "Region"
      zh: "地区"

    PROP_STACK_LBL_TYPE:
      en: "Type"
      zh: "类型"

    PROP_STACK_LBL_ID:
      en: "Stack ID"
      zh: "模板标识"

    PROP_APP_LBL_ID:
      en: "App ID"
      zh: "应用标识"

    PROP_APP_LBL_INSTANCE_STATE:
      en: "Instance State"
      zh: ""

    PROP_APP_LBL_RESDIFF:
      en: "Monitor and report external resource change of this app"
      zh: ""

    PROP_APP_LBL_RESDIFF_VIEW:
      en: "Monitor and Report External Change"
      zh: ""

    PROP_APP_TIP_RESDIFF:
      en: "If resource has been changed outside VisualOps, an email notification will be sent to you."
      zh: ""

    PROP_STACK_LBL_USAGE:
      en: "Usage"
      zh: "用途"

    PROP_STACK_TIT_SG:
      en: "Security Groups"
      zh: "安全组"

    PROP_STACK_TIT_ACL:
      en: "Network ACL"
      zh: "访问控制表"

    PROP_STACK_TIT_SNS:
      en: "SNS Topic Subscription"
      zh: "SNS主题订阅"

    PROP_STACK_BTN_ADD_SUB:
      en: "Add Subscription"
      zh: "添加订阅"

    PROP_STACK_TIT_COST_ESTIMATION:
      en: "Cost Estimation"
      zh: "成本估算"

    PROP_STACK_LBL_COST_CYCLE:
      en: "month"
      zh: "月"

    PROP_STACK_COST_COL_RESOURCE:
      en: "Resource"
      zh: "资源"

    PROP_STACK_COST_COL_SIZE_TYPE:
      en: "Size/Type"
      zh: "大小/类型"

    PROP_STACK_COST_COL_FEE:
      en: "Fee($)"
      zh: "价格($)"

    PROP_STACK_LBL_AWS_EC2_PRICING:
      en: "Amazon EC2 Pricing"
      zh: "Amazon EC2 定价"

    PROP_STACK_ACL_LBL_RULE:
      en: "rules"
      zh: "条规则"

    PROP_STACK_ACL_LBL_ASSOC:
      en: "associations"
      zh: "个关联"

    PROP_STACK_ACL_BTN_DELETE:
      en: "Delete"
      zh: "删除"

    PROP_STACK_ACL_TIP_DETAIL:
      en: "Go to Network ACL Details"
      zh: "查看访问控制表详细"

    PROP_STACK_BTN_CREATE_NEW_ACL:
      en: "Create new Network ACL..."
      zh: "创建新的访问控制表..."

    PROP_APP_SNS_NONE:
      en: "This app has no SNS Subscription"
      zh: "本应用不含SNS订阅"

    PROP_AZ_LBL_SWITCH:
      en: "Quick Switch Availability Zone"
      zh: "切换可用区域"

    PROP_VPC_TIT_DETAIL:
      en: "VPC Details"
      zh: "VPC详细"

    PROP_VPC_DETAIL_LBL_NAME:
      en: "Name"
      zh: "名称"

    PROP_VPC_DETAIL_LBL_CIDR_BLOCK:
      en: "CIDR Block"
      zh: "CIDR 块"

    PROP_VPC_DETAIL_LBL_TENANCY:
      en: "Tenancy"
      zh: "租用"

    PROP_VPC_DETAIL_TENANCY_LBL_DEFAULT:
      en: "Default"
      zh: "缺省"

    PROP_VPC_DETAIL_TENANCY_LBL_DEDICATED:
      en: "Dedicated"
      zh: "专用"

    PROP_VPC_DETAIL_LBL_ENABLE_DNS_RESOLUTION:
      en: "Enable DNS resolution"
      zh: "允许DNS解析"

    PROP_VPC_DETAIL_LBL_ENABLE_DNS_HOSTNAME_SUPPORT:
      en: "Enable DNS hostname support"
      zh: "允许DNS主机名解析"

    PROP_VPC_TIT_DHCP_OPTION:
      en: "DHCP Options"
      zh: "DHCP 选项"

    PROP_VPC_DHCP_LBL_NONE:
      en: "Default"
      zh: "无"

    PROP_VPC_DHCP_LBL_DEFAULT:
      en: "Auto-assigned Set"
      zh: "缺省"

    PROP_VPC_DHCP_LBL_SPECIFIED:
      en: "Specified DHCP Options Set"
      zh: "指定的DHCP选项设置"

    PROP_VPC_DHCP_SPECIFIED_LBL_DOMAIN_NAME:
      en: "Domain Name"
      zh: "域名"

    PROP_VPC_DHCP_SPECIFIED_LBL_DOMAIN_NAME_SERVER:
      en: "Domain Name Server"
      zh: "域名服务器"

    PROP_VPC_DHCP_SPECIFIED_LBL_AMZN_PROVIDED_DNS:
      en: "AmazonProvidedDNS"
      zh: "亚马逊提供的域名服务器"

    PROP_VPC_DHCP_SPECIFIED_LBL_NTP_SERVER:
      en: "NTP Server"
      zh: "时间服务器"

    PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NAME_SERVER:
      en: "NetBIOS Name Server"
      zh: "NetBIOS名字服务器"

    PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE:
      en: "NetBIOS Node Type"
      zh: "NetBIOS节点类型"

    PROP_VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE_NOT_SPECIFIED:
      en: "Not specified"
      zh: "未指定"

    PROP_VPC_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC标识"

    PROP_VPC_APP_STATE:
      en: "State"
      zh: "状态"

    PROP_VPC_APP_CIDR:
      en: "CIDR"
      zh: "CIDR"

    PROP_VPC_APP_MAIN_RT:
      en: "Main Route Table"
      zh: "主路由表"

    PROP_VPC_APP_DEFAULT_ACL:
      en: "Default Network ACL"
      zh: "缺省访问控制表"

    PROP_VPC_DHCP_OPTION_SET_ID:
      en: "DHCP Options Set ID"
      zh: "DHCP选项标识"

    PROP_VPC_MANAGE_DHCP:
      en: "Manage DHCP Options Set"
      zh: ""

    PROP_VPC_MANAGE_RDS_PG:
      en: "Manage Parameter Group"
      zh: ""

    PROP_VPC_FILTER_RDS_PG:
      en: "Filter by Parameter Group Name"
      zh: ""

    PROP_VPC_FILTER_DHCP:
      en: "Filter by DHCP Options Set ID"
      zh: ""

    PROP_VPC_TIP_AUTO_DHCP:
      en: "A DHCP Options set will be automatically assigned for the VPC by AWS."
      zh: ""

    PROP_VPC_TIP_DEFAULT_DHCP:
      en: "The VPC will use no DHCP options."
      zh: "The VPC will use no DHCP options."

    PROP_VPC_AUTO_DHCP:
      en: "Auto-assigned Set"
      zh: ""

    PROP_VPC_DEFAULT_DHCP:
      en: "Default"
      zh: "Default"

    PROP_SUBNET_TIP_CIDR_BLOCK:
      en: "e.g. 10.0.0.0/24. The range of IP addresses in the subnet must be a subset of the IP address in the VPC. Block sizes must be between a /16 netmask and /28 netmask. The size of the subnet can equal the size of the VPC."
      zh: ""

    PROP_SUBNET_TIT_DETAIL:
      en: "Subnet Details"
      zh: "子网详细"

    PROP_SUBNET_DETAIL_LBL_NAME:
      en: "Name"
      zh: "名称"

    PROP_SUBNET_DETAIL_LBL_CIDR_BLOCK:
      en: "CIDR Block"
      zh: "CIDR 块"

    PROP_SUBNET_TIT_ASSOC_ACL:
      en: "Associated Network ACL"
      zh: "相关访问控制表"

    PROP_SUBNET_BTN_CREATE_NEW_ACL:
      en: "Create new Network ACL..."
      zh: "创建新的访问控制表..."

    PROP_SUBNET_ACL_LBL_RULE:
      en: "rules"
      zh: "条规则"

    PROP_SUBNET_ACL_LBL_ASSOC:
      en: "associations"
      zh: "个关联"

    PROP_SUBNET_ACL_BTN_DELETE:
      en: "Delete"
      zh: "删除"

    PROP_SUBNET_ACL_TIP_DETAIL:
      en: "Go to Network ACL Details"
      zh: "查看访问控制表详细"

    PROP_SUBNET_APP_ID:
      en: "Subnet ID"
      zh: "子网标识"

    PROP_SUBNET_APP_STATE:
      en: "State"
      zh: "状态"

    PROP_SUBNET_APP_CIDR:
      en: "CIDR"
      zh: "CIDR"

    PROP_SUBNET_APP_AVAILABLE_IP:
      en: "Available IPs"
      zh: "可用IP"

    PROP_SUBNET_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC标识"

    PROP_SUBNET_APP_RT_ID:
      en: "Route Table ID"
      zh: "路由表标识"

    PROP_VPC_TIP_EG_10_0_0_0_16:
      en: "e.g. 10.0.0.0/16"
      zh: ""

    PROP_VPC_TIP_ENTER_THE_DOMAIN_NAME:
      en: "Enter the domain name that should be used for your hosts"
      zh: ""

    PROP_VPC_TIP_ENTER_UP_TO_4_DNS:
      en: "Enter up to 4 DNS server IP addresses"
      zh: ""

    PROP_VPC_TIP_ENTER_UP_TO_4_NTP:
      en: "Enter up to 4 NTP server IP addresses"
      zh: ""

    PROP_VPC_TIP_ENTER_UP_TO_4_NETBIOS:
      en: "Enter up to 4 NetBIOS server IP addresses"
      zh: ""

    PROP_VPC_TIP_EG_172_16_16_16:
      en: "e.g. 172.16.16.16"
      zh: ""

    PROP_VPC_TIP_SELECT_NETBIOS_NODE:
      en: "Select NetBIOS Node Type. We recommend 2. (Broadcast and multicast are currently not supported by AWS.)"
      zh: ""

    PROP_VPC_TIP_:
      en: ""
      zh: ""

    PROP_SG_TIT_DETAIL:
      en: "Security Group Details"
      zh: "安全组详细"

    PROP_SG_DETAIL_LBL_NAME:
      en: "Name"
      zh: "名称"

    PROP_SG_DETAIL_LBL_DESCRIPTION:
      en: "Description"
      zh: "描述"

    PROP_SG_TIT_RULE:
      en: "Rule"
      zh: "规则"

    PROP_SG_RULE_SORT_BY:
      en: "Sort by"
      zh: "排序"

    PROP_SG_RULE_SORT_BY_DIRECTION:
      en: "Direction"
      zh: "按方向"

    PROP_SG_RULE_SORT_BY_SRC_DEST:
      en: "Source/Destination"
      zh: "按源/目的"

    PROP_SG_RULE_SORT_BY_PROTOCOL:
      en: "Protocol"
      zh: "按协议"

    PROP_SG_TIT_MEMBER:
      en: "Member"
      zh: "成员"

    PROP_SG_TIP_CREATE_RULE:
      en: "Create rule referencing IP Range"
      zh: "创建基于IP范围的规则"

    PROP_SG_TIP_REMOVE_RULE:
      en: "Remove rule"
      zh: "删除规则"

    PROP_SG_TIP_PROTOCOL:
      en: "Protocol"
      zh: "协议"

    PROP_SG_TIP_SRC:
      en: "Source"
      zh: "源"

    PROP_SG_TIP_DEST:
      en: "Destination"
      zh: "目的"

    PROP_SG_TIP_INBOUND:
      en: "Inbound"
      zh: "入方向"

    PROP_SG_TIP_OUTBOUND:
      en: "Outbound"
      zh: "出方向"

    PROP_SG_TIP_PORT_CODE:
      en: "Port or Code"
      zh: "端口或代码"

    PROP_SG_APP_SG_ID:
      en: "Security Group ID"
      zh: "安全组标识"

    PROP_SG_APP_SG_NAME:
      en: "Security Group Name"
      zh: "安全组名字"

    PROP_SG_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC标识"

    PROP_SGLIST_LBL_RULE:
      en: "rules"
      zh: "条规则"

    PROP_SGLIST_LBL_MEMBER:
      en: "members"
      zh: "个成员"

    PROP_SGLIST_LNK_DELETE:
      en: "Delete"
      zh: "删除"

    PROP_SGLIST_TIP_VIEW_DETAIL:
      en: "View details"
      zh: "查看详细"

    PROP_SGLIST_BTN_CREATE_NEW_SG:
      en: "Create new Security Group..."
      zh: "创建新安全组..."

    PROP_SGLIST_TAB_GROUP:
      en: "Group"
      zh: "组"

    PROP_SGLIST_TAB_RULE:
      en: "Rule"
      zh: "规则"

    PROP_SGRULE_DESCRIPTION:
      en: "The selected connection reflects following security group rule(s):"
      zh: "当前选中的连线反映了以下安全组的规则:"

    PROP_SGRULE_TIP_INBOUND:
      en: "Inbound"
      zh: "入方向"

    PROP_SGRULE_TIP_OUTBOUND:
      en: "Outbound"
      zh: "出方向"

    PROP_SGRULE_BTN_EDIT_RULE:
      en: "Edit Related Rule"
      zh: "编辑相关规则"

    PROP_ACL_LBL_NAME:
      en: "Name"
      zh: "名称"

    PROP_ACL_TIT_RULE:
      en: "Rule"
      zh: "规则"

    PROP_ACL_BTN_CREATE_NEW_RULE:
      en: "Create new Network ACL Rule"
      zh: "创建新的访问控制表"

    PROP_ACL_RULE_SORT_BY:
      en: "Sort by"
      zh: "排序"

    PROP_ACL_RULE_SORT_BY_NUMBER:
      en: "Rule Number"
      zh: "按规则编号"

    PROP_ACL_RULE_SORT_BY_ACTION:
      en: "Action"
      zh: "动作"

    PROP_ACL_RULE_SORT_BY_DIRECTION:
      en: "Direction"
      zh: "方向"

    PROP_ACL_RULE_SORT_BY_SRC_DEST:
      en: "Source/Destination"
      zh: "源/目的"

    PROP_ACL_TIP_ACTION_ALLOW:
      en: "allow"
      zh: "允许"

    PROP_ACL_TIP_ACTION_DENY:
      en: "deny"
      zh: "拒绝"

    PROP_ACL_TIP_INBOUND:
      en: "Inbound"
      zh: "入方向"

    PROP_ACL_TIP_OUTBOUND:
      en: "Outbound"
      zh: "出方向"

    PROP_ACL_TIP_RULE_NUMBER:
      en: "Rule Number"
      zh: "规则编号"

    PROP_ACL_TIP_CIDR_BLOCK:
      en: "CIDR Block"
      zh: "CIDR 块"

    PROP_ACL_TIP_PROTOCOL:
      en: "Protocol"
      zh: "协议"

    PROP_ACL_TIP_PORT:
      en: "Port"
      zh: "端口"

    PROP_ACL_TIT_ASSOC:
      en: "Associations"
      zh: "关联的子网"

    PROP_ACL_TIP_REMOVE_RULE:
      en: "Remove rule"
      zh: "删除规则"

    PROP_ACL_APP_ID:
      en: "Network ACL ID"
      zh: "访问控制表标识"

    PROP_ACL_APP_IS_DEFAULT:
      en: "Default"
      zh: "是否缺省"

    PROP_ACL_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC标识"

    PROP_VGW_TXT_DESCRIPTION:
      en: "The Virtual Private Gateway is the router on the Amazon side of the VPN tunnel."
      zh: "虚拟私有网关是亚马逊一侧的VPN隧道的路由器."

    PROP_VPN_LBL_IP_PREFIX:
      en: "Network IP Prefixes"
      zh: "网络号前缀"

    PROP_VPN_TIP_EG_192_168_0_0_16:
      en: "e.g., 192.168.0.0/16"
      zh: ""

    PROP_IGW_TXT_DESCRIPTION:
      en: "The Internet gateway is the router on the AWS network that connects your VPC to the Internet."
      zh: "互联网网关是将你位于AWS网络中的VPC网络连接到互联网的路由器."

    PROP_CGW_LBL_NAME:
      en: "Name"
      zh: "名称"

    PROP_CGW_LBL_IPADDR:
      en: "IP Address"
      zh: "IP地址"

    PROP_CGW_LBL_ROUTING:
      en: "Routing"
      zh: "路由"

    PROP_CGW_LBL_STATIC:
      en: "Static"
      zh: "静态"

    PROP_CGW_LBL_DYNAMIC:
      en: "Dynamic"
      zh: "动态"

    PROP_CGW_LBL_BGP_ASN:
      en: "BGP ASN"
      zh: "BGP 自治域号"

    PROP_CGW_APP_TIT_CGW:
      en: "Customer Gateway"
      zh: "客户网关"

    PROP_CGW_APP_CGW_LBL_ID:
      en: "ID"
      zh: "标识"

    PROP_CGW_APP_CGW_LBL_STATE:
      en: "State"
      zh: "状态"

    PROP_CGW_APP_CGW_LBL_TYPE:
      en: "Type"
      zh: "类型"

    PROP_CGW_APP_TIT_VPN:
      en: "VPN Connection"
      zh: "VPN连接"

    PROP_CGW_APP_VPN_LBL_ID:
      en: "ID"
      zh: "标识"

    PROP_CGW_APP_VPN_LBL_STATE:
      en: "State"
      zh: "状态"

    PROP_CGW_APP_VPN_LBL_TYPE:
      en: "Type"
      zh: "类型"

    PROP_CGW_APP_VPN_LBL_TUNNEL:
      en: "VPN Tunnels"
      zh: "VPN隧道"

    PROP_CGW_APP_VPN_COL_TUNNEL:
      en: "Tunnel"
      zh: "隧道"

    PROP_CGW_APP_VPN_COL_IP:
      en: "IP Address"
      zh: "IP地址"

    PROP_CGW_APP_VPN_LBL_STATUS_RT:
      en: "Static Routes"
      zh: "静态路由"

    PROP_CGW_APP_VPN_COL_IP_PREFIX:
      en: "IP Prefixes"
      zh: "网络号"

    PROP_CGW_APP_VPN_COL_SOURCE:
      en: "Source"
      zh: "源"

    PROP_CGW_APP_TIT_DOWNLOAD_CONF:
      en: "Download Configuration"
      zh: "下载配置"

    PROP_CGW_APP_DOWN_LBL_VENDOR:
      en: "Vendor"
      zh: "厂商"

    PROP_CGW_APP_DOWN_LBL_PLATFORM:
      en: "Platform"
      zh: "平台"

    PROP_CGW_APP_DOWN_LBL_SOFTWARE:
      en: "Software"
      zh: "软件"

    PROP_CGW_APP_DOWN_LBL_GENERIC:
      en: "Generic"
      zh: "通用"

    PROP_CGW_APP_DOWN_LBL_VENDOR_AGNOSTIC:
      en: "Vendor Agnostic"
      zh: "厂商无关"

    PROP_CGW_APP_DOWN_BTN_DOWNLOAD:
      en: "Download"
      zh: "下载"

    PROP_CGW_TIP_THIS_ADDRESS_MUST_BE_STATIC:
      en: "This address must be static and not behind a NAT. e.g. 12.1.2.3"
      zh: ""

    PROP_CGW_TIP_1TO65534:
      en: "1 - 65534"
      zh: ""

    PROP_MSG_ERR_RESOURCE_NOT_EXIST:
      en: "Sorry, the selected resource not exist."
      zh: "抱歉，选定的资源不存在。"

    PROP_MSG_ERR_DOWNLOAD_KP_FAILED:
      en: "Sorry, there was a problem downloading this key pair."
      zh: "抱歉，下载密钥对时出现了问题。"

    PROP_MSG_WARN_NO_STACK_NAME:
      en: "Stack name empty or missing."
      zh: "模板名称不能为空。"

    PROP_MSG_WARN_REPEATED_STACK_NAME:
      en: "This stack name is already in use."
      zh: "这个模板名称已被占用。"

    PROP_MSG_WARN_ENI_IP_EXTEND:
      en: "%s Instance's Network Interface can't exceed %s Private IP Addresses."
      zh: "%s 实例的网络接口不能超过 %s 私有IP地址。"

    PROP_MSG_WARN_NO_APP_NAME:
      en: "App name empty or missing."
      zh: "应用名称不能为空。"

    PROP_MSG_WARN_REPEATED_APP_NAME:
      en: "This app name is already in use."
      zh: "这个应用名称已被占用This app name is already in use."

    PROP_MSG_WARN_INVALID_APP_NAME:
      en: "App name is invalid."
      zh: "无效的应用名称。"

    PROP_WARN_EXCEED_ENI_LIMIT:
      en: "Instance type %s supports a maximum of %s network interfaces (including the primary). Please detach additional network interfaces before changing instance type."
      zh: "实例类型：%s 支持最多 %s 个网络接口（包括主要的）， 请在改变实例类型之前删除超出数量限制的网络接口。"

    PROP_TEXT_DEFAULT_SG_DESC:
      en: "Default Security Group"
      zh: "Default Security Group"

    PROP_TEXT_CUSTOM_SG_DESC:
      en: "Custom Security Group"
      zh: "Custom Security Group"

    PROP_MSG_WARN_WHITE_SPACE:
      en: "Stack name contains white space"
      zh: "模板名称不能包含空格"

    PROP_MSG_SG_CREATE:
      en: "1 rule has been created in %s to allow %s %s %s."
      zh: "1条规则被创建到 %s 来允许 %s %s %s。"

    PROP_MSG_SG_CREATE_MULTI:
      en: "%d rules have been created in %s and %s to allow %s %s %s."
      zh: "%d条规则被创建到 %s 并且 %s 来允许 %s %s %s."

    PROP_MSG_SG_CREATE_SELF:
      en: "%d rules have been created in %s to allow %s send and receive traffic within itself."
      zh: "%d条规则被创建到 %s 来允许 %s 它内部的收发通信."

    PROP_SNAPSHOT_FILTER_REGION:
      en: "Filter by region name"
      zh: ""

    PROP_SNAPSHOT_FILTER_VOLUME:
      en: "Filter by Volume ID"
      zh: ""

    PROP_VOLUME_DEVICE_NAME:
      en: "Device Name"
      zh: "挂载设备名"

    PROP_VOLUME_SIZE:
      en: "Volume Size"
      zh: "磁盘大小"

    PROP_VOLUME_ID:
      en: "Volume ID"
      zh: "磁盘ID"

    PROP_VOLUME_STATE:
      en: "State"
      zh: "状态"

    PROP_VOLUME_CREATE_TIME:
      en: "Create Time"
      zh: "创建时间"

    PROP_VOLUME_SNAPSHOT_ID:
      en: "Snapshot ID"
      zh: "快照ID"

    PROP_VOLUME_SNAPSHOT_SELECT:
      en: "Select volume from which to create snapshot"
      zh: ""

    PROP_VOLUME_SNAPSHOT_SELECT_REGION:
      en: "Select Destination Region"
      zh: ""

    PROP_VOLUME_SNAPSHOT:
      en: "Snapshot"
      zh: "快照"

    PROP_VOLUME_ATTACHMENT_STATE:
      en: "Attachment Status"
      zh: "挂载状态"

    PROP_VOLUME_ATTACHMENT_SET:
      en: "AttachmentSet"
      zh: "挂载数据集"

    PROP_VOLUME_INSTANCE_ID:
      en: "Instance ID"
      zh: "实例ID"

    PROP_VOLUME_ATTACHMENT_TIME:
      en: "Attach Time"
      zh: "挂载时间"

    PROP_VOLUME_TYPE:
      en: "Volume Type"
      zh: "磁盘类型"

    PROP_VOLUME_ENCRYPTED:
      en: "Encrypted"
      zh: ""

    PROP_VOLUME_TYPE_STANDARD:
      en: "Magnetic"
      zh: "传统磁盘"

    PROP_VOLUME_TYPE_GP2:
      en: "General Purpose (SSD)"
      zh: "通用（SSD）"

    PROP_VOLUME_TYPE_IO1:
      en: "Provisioned IOPS (SSD)"
      zh: "预配置IOPS"

    PROP_VOLUME_MSG_WARN:
      en: "Volume size must be at least 10 GB to use Provisioned IOPS volume type."
      zh: "要使用预配置IOPS,磁盘必须最少10GB"

    PROP_VOLUME_ENCRYPTED_LABEL:
      en: "Encrypt this volume"
      zh: ""

    PROP_ENI_LBL_ATTACH_WARN:
      en: "Attach the Network Interface to an instance within the same availability zone."
      zh: "在同一个可用区域里面附加网络接口。"

    PROP_ENI_LBL_DETAIL:
      en: "Network Interface Details"
      zh: "网卡设置"

    PROP_ENI_LBL_DESC:
      en: "Description"
      zh: "描述"

    PROP_ENI_SOURCE_DEST_CHECK:
      en: "Enable Source/Destination Checking"
      zh: "打开 Source/Destination 检查"

    PROP_ENI_AUTO_PUBLIC_IP:
      en: "Automatically assign Public IP"
      zh: "自动分配公网IP"

    PROP_ENI_IP_ADDRESS:
      en: "IP Address"
      zh: "IP地址"

    PROP_ENI_ADD_IP:
      en: "Add IP"
      zh: "添加IP"

    PROP_ENI_SG_DETAIL:
      en: "Security Groups"
      zh: "安全组"

    PROP_ENI_DEVICE_NAME:
      en: "Device Name"
      zh: "设备名称"

    PROP_ENI_STATE:
      en: "State"
      zh: "状态"

    PROP_ENI_ID:
      en: "Network Interface ID"
      zh: "网卡ID"

    PROP_ENI_SHOW_DETAIL:
      en: "More"
      zh: "更多"

    PROP_ENI_HIDE_DETAIL:
      en: "Hide"
      zh: "隐藏"

    PROP_ENI_VPC_ID:
      en: "VPC ID"
      zh: "VPC ID"

    PROP_ENI_SUBNET_ID:
      en: "Subnet ID"
      zh: "子网ID"

    PROP_ENI_ATTACHMENT_ID:
      en: "Attachment ID"
      zh: "关联ID"

    PROP_ENI_Attachment_OWNER:
      en: "Owner"
      zh: "关联拥有者"

    PROP_ENI_Attachment_STATE:
      en: "State"
      zh: "关联状态"

    PROP_ENI_MAC_ADDRESS:
      en: "MAC Address"
      zh: "MAC地址"

    PROP_ENI_IP_OWNER:
      en: "IP Owner"
      zh: "IP拥有者"

    PROP_ENI_TIP_ADD_IP_ADDRESS:
      en: "Add IP Address"
      zh: ""

    PROP_ELB_DETAILS:
      en: "Load Balancer Details"
      zh: "负载均衡器设置"

    PROP_ELB_NAME:
      en: "Name"
      zh: "名称"

    PROP_ELB_REQUIRED:
      en: "Required"
      zh: "必须"

    PROP_ELB_SCHEME:
      en: "Scheme"
      zh: "模式"

    PROP_ELB_LISTENER_DETAIL:
      en: "Listener Configuration"
      zh: "监听设置"

    PROP_ELB_BTN_ADD_LISTENER:
      en: "+ Add Listener"
      zh: "添加监听器"

    PROP_ELB_BTN_ADD_SERVER_CERTIFICATE:
      en: "Add SSL Certificate"
      zh: "添加服务器认证"

    PROP_ELB_SERVER_CERTIFICATE:
      en: "SSL Certificate"
      zh: "服务器认证"

    PROP_ELB_LBL_LISTENER_NAME:
      en: "Name"
      zh: "名称"

    PROP_ELB_LBL_LISTENER_DESCRIPTIONS:
      en: "Listener Descriptions"
      zh: "监听器描述"

    PROP_ELB_LBL_LISTENER_CERT_NAME:
      en: "Certificate Name"
      zh: ""

    PROP_ELB_LBL_LISTENER_PRIVATE_KEY:
      en: "Private Key"
      zh: "私钥"

    PROP_ELB_LBL_LISTENER_PUBLIC_KEY:
      en: "Public Key Certificate"
      zh: "公钥"

    PROP_ELB_LBL_LISTENER_CERTIFICATE_CHAIN:
      en: "Certificate Chain"
      zh: "认证链"

    PROP_ELB_HEALTH_CHECK:
      en: "Health Check"
      zh: "健康度检查"

    PROP_ELB_HEALTH_CHECK_DETAILS:
      en: "Health Check Configuration"
      zh: "健康度检查配置"

    PROP_ELB_PING_PROTOCOL:
      en: "Ping Protocol"
      zh: "Ping协议"

    PROP_ELB_PING_PORT:
      en: "Ping\tPort"
      zh: "Ping端口"

    PROP_ELB_PING_PATH:
      en: "Ping Path"
      zh: "Ping路径"

    PROP_ELB_HEALTH_CHECK_INTERVAL:
      en: "Health Check Interval"
      zh: "健康度检查间隔"

    PROP_ELB_IDLE_TIMEOUT:
      en: "Idle Connection Timeout"
      zh: ""

    PROP_ELB_HEALTH_CHECK_INTERVAL_SECONDS:
      en: "Seconds"
      zh: "秒"

    PROP_ELB_HEALTH_CHECK_RESPOND_TIMEOUT:
      en: "Response Timeout"
      zh: "响应超时"

    PROP_ELB_HEALTH_THRESHOLD:
      en: "Healthy Threshold"
      zh: "健康界限"

    PROP_ELB_UNHEALTH_THRESHOLD:
      en: "Unhealthy Threshold"
      zh: "不健康界限"

    PROP_ELB_AVAILABILITY_ZONE:
      en: "Availability Zones"
      zh: "可用区域"

    PROP_ELB_SG_DETAIL:
      en: "Security Groups"
      zh: "安全组"

    PROP_ELB_DNS_NAME:
      en: "DNS"
      zh: "域名"

    PROP_ELB_HOST_ZONE_ID:
      en: "Hosted Zone ID"
      zh: "Hosted Zone ID"

    PROP_ELB_CROSS_ZONE:
      en: "Cross-zone Load Balancing"
      zh: "Cross-zone Load Balancing"

    PROP_ELB_CONNECTION_DRAIN:
      en: "Connection Draining"
      zh: ""

    PROP_ELB_ELB_PROTOCOL:
      en: "Load Balancer Protocol"
      zh: "负载均衡器协议"

    PROP_ELB_PORT:
      en: "Port"
      zh: "端口"

    PROP_ELB_INSTANCE_PROTOCOL:
      en: "Instance Protocol"
      zh: "实例协议"

    PROP_ELB_INSTANCES:
      en: "Instances"
      zh: ""

    PROP_ELB_HEALTH_INTERVAL_VALID:
      en: "Response timeout must be less than the health check interval value"
      zh: ""

    PROP_ELB_CONNECTION_DRAIN_TIMEOUT_INVALID:
      en: "Timeout must be an integer between 1 and 3600"
      zh: ""

    PROP_ELB_TIP_CLICK_TO_SELECT_ALL:
      en: "Click to select all"
      zh: ""

    PROP_ELB_TIP_REMOVE_LISTENER:
      en: "Remove listener"
      zh: ""

    PROP_ELB_TIP_25_80_443OR1024TO65535:
      en: "25, 80, 443 or 1024 - 65535"
      zh: ""

    PROP_ELB_TIP_1_65535:
      en: "1 - 65535"
      zh: ""

    PROP_ELB_TIP_CLICK_TO_READ_RELATED_AWS_DOCUMENT:
      en: "Click to read related AWS document"
      zh: ""

    PROP_ELB_CERT_REMOVE_CONFIRM_TITLE:
      en: "Confirm to Delete SSL Certificate"
      zh: ""

    PROP_ELB_CERT_REMOVE_CONFIRM_MAIN:
      en: "Do you confirm to delete "
      zh: ""

    PROP_ELB_CERT_REMOVE_CONFIRM_SUB:
      en: "Load Balancer currently using this server certificate will have errors."
      zh: ""

    PROP_ASG_SUMMARY:
      en: "Auto Scaling Group Summary"
      zh: "自动伸缩组摘要"

    PROP_ASG_DETAILS:
      en: "Auto Scaling Group Details"
      zh: "自动伸缩组配置"

    PROP_ASG_NAME:
      en: "Name"
      zh: "名称"

    PROP_ASG_REQUIRED:
      en: "Required"
      zh: "必须"

    PROP_ASG_CREATE_TIME:
      en: "Create Time"
      zh: "创建时间"

    PROP_ASG_MIN_SIZE:
      en: "Minimum Size"
      zh: "最小数量"

    PROP_ASG_MAX_SIZE:
      en: "Maximum Size"
      zh: "最大数量"

    PROP_ASG_DESIRE_CAPACITY:
      en: "Desired Capacity"
      zh: "期望数量"

    PROP_ASG_COOL_DOWN:
      en: "Default Cooldown"
      zh: "冷却时间"

    PROP_ASG_INSTANCE:
      en: "Instance"
      zh: "实例"

    PROP_ASG_DEFAULT_COOL_DOWN:
      en: "Default Cooldown"
      zh: "默认冷却时间"

    PROP_ASG_UNIT_SECONDS:
      en: "Seconds"
      zh: "秒"

    PROP_ASG_UNIT_MINS:
      en: "Minutes"
      zh: "分"

    PROP_ASG_HEALTH_CHECK_TYPE:
      en: "Health Check Type"
      zh: "健康度检查类型"

    PROP_ASG_HEALTH_CHECK_CRACE_PERIOD:
      en: "Health Check Grace Period"
      zh: "健康度检查时间"

    PROP_ASG_POLICY:
      en: "Policy"
      zh: "策略"

    PROP_ASG_HAS_ELB_WARN:
      en: "You need to connect this auto scaling group to a load balancer to enable this option."
      zh: "你需要连接AutoScaling组和一个负载均衡器来启动此选项"

    PROP_ASG_ELB_WARN:
      en: "If the calls to Elastic Load Balancing health check for the instance returns any state other than InService, Auto Scaling marks the instance as Unhealthy. And if the instance is marked as Unhealthy, Auto Scaling starts the termination process for the instance."
      zh: ""

    PROP_ASG_TERMINATION_POLICY:
      en: "Termination Policy"
      zh: "结束策略"

    PROP_ASG_POLICY_TLT_NAME:
      en: "Policy Name"
      zh: "策略名称"

    PROP_ASG_POLICY_TLT_ALARM_METRIC:
      en: "Alarm Metric"
      zh: "警告准则"

    PROP_ASG_POLICY_TLT_THRESHOLD:
      en: "Threshold"
      zh: "界限"

    PROP_ASG_POLICY_TLT_PERIOD:
      en: "Evaluation Period x Periords"
      zh: "评估时间"

    PROP_ASG_POLICY_TLT_ACTION:
      en: "Action Trigger"
      zh: "触发动作"

    PROP_ASG_POLICY_TLT_ADJUSTMENT:
      en: "Adjustment"
      zh: "调整"

    PROP_ASG_POLICY_TLT_EDIT:
      en: "Edit Scaling Policy"
      zh: "编辑策略"

    PROP_ASG_POLICY_TLT_REMOVE:
      en: "Remove Scaling Policy"
      zh: "删除策略"

    PROP_ASG_BTN_ADD_SCALING_POLICY:
      en: "Add Scaling Policy"
      zh: "添加扩展策略"

    PROP_ASG_LBL_NOTIFICATION:
      en: "Notification"
      zh: "通知"

    PROP_ASG_LBL_SEND_NOTIFICATION_D:
      en: "Send notification via SNS topic"
      zh: "通过SNS发送通知"

    PROP_ASG_LBL_SEND_NOTIFICATION:
      en: "Send notification via SNS topic for:"
      zh: "通过SNS发送通知"

    PROP_ASG_LBL_SUCCESS_INSTANCES_LAUNCH:
      en: "Successful instance launch"
      zh: "运行实例成功"

    PROP_ASG_LBL_FAILED_INSTANCES_LAUNCH:
      en: "Failed instance launch"
      zh: "运行实例失败"

    PROP_ASG_LBL_SUCCESS_INSTANCES_TERMINATE:
      en: "Successful instance termination"
      zh: "终止实例成功"

    PROP_ASG_LBL_FAILED_INSTANCES_TERMINATE:
      en: "Failed instance termination"
      zh: "终止实例失败"

    PROP_ASG_LBL_VALIDATE_SNS:
      en: "Validating a configuraed SNS Topic"
      zh: "验证SNS主题"

    PROP_ASG_MSG_NO_NOTIFICATION_WARN:
      en: "No notification configured for this auto scaling group"
      zh: "没有设置Notification Configuration"

    PROP_ASG_MSG_SNS_WARN:
      en: "There is no SNS subscription set up yet. Go to Stack Property to set up SNS subscription so that you will get the notification."
      zh: "现在SNS还没有设置订阅信息，请去模板属性框设置，以便收到通知"

    PROP_ASG_MSG_DROP_LC:
      en: "Drop AMI from Resrouce Panel to create Launch Configuration"
      zh: "请拖拽映像来建立Launch Configuration"

    PROP_ASG_TERMINATION_EDIT:
      en: "Edit Termination Policy"
      zh: "编辑终止策略"

    PROP_ASG_TERMINATION_TEXT_WARN:
      en: "You can either specify any one of the policies as a standalone policy, or you can list multiple policies in an ordered list. The policies are executed in the order they are listed."
      zh: "你能选择最少一种策略，策略执行顺序是从上到下"

    PROP_ASG_TERMINATION_MSG_DRAG:
      en: "Drag to sort policy"
      zh: "拖拽以便调整顺序"

    PROP_ASG_TERMINATION_POLICY_OLDEST:
      en: "OldestInstance"
      zh: "最旧的实例"

    PROP_ASG_TERMINATION_POLICY_NEWEST:
      en: "NewestInstance"
      zh: "最新的实例"

    PROP_ASG_TERMINATION_POLICY_OLDEST_LAUNCH:
      en: "OldestLaunchConfiguration"
      zh: "最旧的LaunchConfiguration"

    PROP_ASG_TERMINATION_POLICY_CLOSEST:
      en: "ClosestToNextInstanceHour"
      zh: "最近下一个实力时钟"

    PROP_ASG_ADD_POLICY_TITLE_ADD:
      en: "Add"
      zh: "添加"

    PROP_ASG_ADD_POLICY_TITLE_EDIT:
      en: "Edit"
      zh: "编辑"

    PROP_ASG_ADD_POLICY_TITLE_CONTENT:
      en: "Scaling Policy"
      zh: "扩展策略"

    PROP_ASG_ADD_POLICY_ALARM:
      en: "Alarm"
      zh: "警报"

    PROP_ASG_ADD_POLICY_WHEN:
      en: "When"
      zh: "当"

    PROP_ASG_ADD_POLICY_IS:
      en: "is"
      zh: "是"

    PROP_ASG_ADD_POLICY_FOR:
      en: "for"
      zh: "持续"

    PROP_ASG_ADD_POLICY_PERIOD:
      en: "periods of"
      zh: "周期"

    PROP_ASG_ADD_POLICY_SECONDS:
      en: "minutes, enter ALARM state."
      zh: "分时，进入警报状态"

    PROP_ASG_ADD_POLICY_START_SCALING:
      en: "Start scaling activity when in"
      zh: "执行扩展活动，当处于"

    PROP_ASG_ADD_POLICY_STATE:
      en: "state."
      zh: "状态"

    PROP_ASG_ADD_POLICY_SCALING_ACTIVITY:
      en: "Scaling Activity"
      zh: "扩展活动"

    PROP_ASG_ADD_POLICY_ADJUSTMENT:
      en: "Adjust number of instances by"
      zh: "通过以下方式调整"

    PROP_ASG_ADD_POLICY_ADJUSTMENT_OF:
      en: "of"
      zh: "数量"

    PROP_ASG_ADD_POLICY_ADJUSTMENT_CHANGE:
      en: "Change in Capacity"
      zh: ""

    PROP_ASG_ADD_POLICY_ADJUSTMENT_EXACT:
      en: "Exact Capacity"
      zh: ""

    PROP_ASG_ADD_POLICY_ADJUSTMENT_PERCENT:
      en: "Percent Change in Capacity"
      zh: ""

    PROP_ASG_ADD_POLICY_ADVANCED:
      en: "Advanced"
      zh: "高级"

    PROP_ASG_ADD_POLICY_ADVANCED_ALARM_OPTION:
      en: "Alarm Options"
      zh: "警报选项"

    PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC:
      en: "Statistic"
      zh: "统计方式"

    PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_AVG:
      en: "Average"
      zh: "平均"

    PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_MIN:
      en: "Minimum"
      zh: "最小"

    PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_MAX:
      en: "Maximum"
      zh: "最大"

    PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_SAMPLE:
      en: "SampleCount"
      zh: "抽样计算"

    PROP_ASG_ADD_POLICY_ADVANCED_STATISTIC_SUM:
      en: "Sum"
      zh: "总计"

    PROP_ASG_ADD_POLICY_ADVANCED_SCALING_OPTION:
      en: "Scaling Options"
      zh: "扩展选项"

    PROP_ASG_ADD_POLICY_ADVANCED_COOLDOWN_PERIOD:
      en: "Cooldown Period"
      zh: "冷却周期"

    PROP_ASG_ADD_POLICY_ADVANCED_TIP_COOLDOWN_PERIOD:
      en: "The amount of time, in seconds, after a scaling activity completes before any further trigger-related scaling activities can start. If not specified, will use auto scaling group's default cooldown period."
      zh: "两个扩展活动之间的冷却时间(秒)，如果不提供，则使用AWS默认时间"

    PROP_ASG_ADD_POLICY_ADVANCED_MIN_ADJUST_STEP:
      en: "Minimum Adjust Step"
      zh: "最小调整数量"

    PROP_ASG_ADD_POLICY_ADVANCED_TIP_MIN_ADJUST_STEP:
      en: "Changes the DesiredCapacity of the Auto Scaling group by at least the specified number of instances."
      zh: "调整期望数量时的最小实例数量"

    PROP_ASG_TIP_CLICK_TO_SELECT:
      en: "Click to select"
      zh: ""

    PROP_ASG_TIP_YOU_CAN_ONLY_ADD_25_SCALING_POLICIES:
      en: "You can only add 25 scaling policies"
      zh: ""

    PROP_LC_TITLE:
      en: "Launch Configuation"
      zh: "启动配置"

    PROP_LC_NAME:
      en: "Name"
      zh: "名称"

    PROP_LC_CREATE_TIME:
      en: "Create Time"
      zh: "创建时间"

    PROP_RT_ASSOCIATION:
      en: "This is an association of "
      zh: "这是一条路由表关联线从"

    PROP_RT_ASSOCIATION_TO:
      en: "to"
      zh: "到"

    PROP_RT_NAME:
      en: "Name"
      zh: "名称"

    PROP_RT_LBL_ROUTE:
      en: "Routes"
      zh: "路由规则"

    PROP_RT_LBL_MAIN_RT:
      en: "Main Route Table"
      zh: "主路由表"

    PROP_RT_SET_MAIN:
      en: "Set as Main Route Table"
      zh: "设置为主路由表"

    PROP_RT_TARGET:
      en: "Target"
      zh: "路由对象"

    PROP_RT_LOCAL:
      en: "local"
      zh: "本地"

    PROP_RT_DESTINATION:
      en: "Destination"
      zh: "数据包目的地"

    PROP_RT_ID:
      en: "Route ID"
      zh: "路由表ID"

    PROP_RT_VPC_ID:
      en: "VPC ID"
      zh: "VPC ID"

    PROP_RT_TIP_ACTIVE:
      en: "Active"
      zh: ""

    PROP_RT_TIP_BLACKHOLE:
      en: "Blackhole"
      zh: ""

    PROP_RT_TIP_PROPAGATED:
      en: "Propagated"
      zh: ""

    PROP_DBPG_RESMANAGER_FILTER:
      en: "Filter DB Engine by family name"
      zh: ""

    PROP_DBPG_SET_FAMILY:
      en: "Family"
      zh: ""

    PROP_DBPG_SET_NAME:
      en: "Parameter Group Name"
      zh: ""

    PROP_DBPG_CONFIRM_RESET_1:
      en: "Do you confirm to reset all parameters for "
      zh: ""

    PROP_DBPG_CONFIRM_RESET_2:
      en: " to their defaults?"
      zh: ""

    PROP_DBPG_APPLY_IMMEDIATELY_1:
      en: "Changes will apply "
      zh: ""

    PROP_DBPG_APPLY_IMMEDIATELY_2:
      en: "immediately"
      zh: ""

    PROP_DBPG_APPLY_IMMEDIATELY_3:
      en: "after rebooting"
      zh: ""

    PROP_DBPG_SET_DESC:
      en: "Description"
      zh: ""

    PROP_DBINSTANCE_TIT_DETAIL:
      en: "DB Instance Detail"
      zh: ""

    PROP_DBINSTANCE_APP_DBINSTANCE_ID:
      en: "DB Instance Identifier"
      zh: ""

    PROP_DBINSTANCE_ENDPOINT:
      en: "Endpoint"
      zh: ""

    PROP_DBINSTANCE_STATUS:
      en: "Status"
      zh: ""

    PROP_DBINSTANCE_ENGINE:
      en: "Engine"
      zh: ""

    PROP_DBINSTANCE_AUTO_UPGRADE:
      en: "Auto Minor Version Upgrade"
      zh: ""

    PROP_DBINSTANCE_CLASS:
      en: "DB Instance Class"
      zh: ""

    PROP_DBINSTANCE_IOPS:
      en: "IOPS"
      zh: ""

    PROP_DBINSTANCE_STORAGE:
      en: 'Storage'
      zh: ""

    PROP_DBINSTANCE_USERNAME:
      en: "Username"
      zh: ""

    PROP_DBINSTANCE_READ_REPLICAS:
      en: "Read Replicas"
      zh: ""

    PROP_DBINSTANCE_REPLICAS_SOURCE:
      en: "Read Replicas Source"
      zh: ""

    PROP_DBINSTANCE_DBCONFIG:
      en: "Database Config"
      zh: ""

    PROP_DBINSTANCE_NAME:
      en: "Database Name"
      zh: ""

    PROP_DBINSTANCE_PORT:
      en: "Database Port"
      zh: ""

    PROP_DBINSTANCE_OG:
      en: "Option Group"
      zh: ""

    PROP_DBINSTANCE_PG:
      en: "Parameter Group"
      zh: ""

    PROP_DBINSTANCE_NETWORK_AVAILABILITY:
      en: "Network & Availability"
      zh: ""

    PROP_DBINSTANCE_SUBNETGROUP:
      en: "Subnet Group"
      zh: ""

    PROP_DBINSTANCE_PREFERRED_ZONE:
      en: "Preferred Availability Zone"
      zh: ""

    PROP_DBINSTANCE_SECONDARY_ZONE:
      en: "Secondary Availability Zone"
      zh: ""

    PROP_DBINSTANCE_PUBLIC_ACCESS:
      en: "Publicly Accessible"
      zh: ""

    PROP_DBINSTANCE_LICENSE_MODEL:
      en: "License Model"
      zh: ""

    PROP_DBINSTANCE_BACKUP_MAINTENANCE:
      en: "Backup & Maintenance"
      zh: ""

    PROP_DBINSTANCE_AUTOBACKUP:
      en: "Automated Backups"
      zh: ""

    PROP_DBINSTANCE_LAST_RESTORE:
      en: "Lastest Restore Time"
      zh: ""

    PROP_DBINSTANCE_BACKUP_WINDOW:
      en: "Backup Window"
      zh: ""

    PROP_DBINSTANCE_MAINTENANCE_WINDOW:
      en: "Maintenance Window"
      zh: ""

    PROP_DBINSTANCE_SECURITY_GROUP:
      en: "Security Group"
      zh: ""

    PROP_DBINSTANCE_SUBNET_GROUP_NAME:
      en: "DB Subnet Group Name"
      zh: ""

    PROP_DBINSTANCE_SUBNET_GROUP_DESC:
      en: "DB Subnet Group Description"
      zh: ""

    PROP_DBINSTANCE_SUBNET_GROUP_STATUS:
      en: "Status"
      zh: ""

    PROP_DBINSTANCE_SUBNET_GROUP_MEMBERS:
      en: "Members"
      zh: ""

    PROP_SELECT_SNS_TOPIC:
      en: "Select SNS Topic"
      zh: ""

    PROP_ASG_POLICY_CPU:
      en: "CPU Utillization"
      zh: ""

    PROP_ASG_POLICY_DISC_READS:
      en: "Disk Reads"
      zh: ""

    PROP_ASG_POLICY_DISK_READ_OPERATIONS:
      en: "Disk Read Operations"
      zh: ""

    PROP_ASG_POLICY_DISK_WRITES:
      en: "Disk Writes"
      zh: ""

    PROP_ASG_POLICY_DISK_WRITE_OPERATIONS:
      en: "Disk Write Operations"
      zh: ""

    PROP_ASG_POLICY_NETWORK_IN:
      en: "Network In"
      zh: ""

    PROP_ASG_POLICY_NETWORK_OUT:
      en: "Network Out"
      zh: ""

    PROP_ASG_POLICY_STATUS_CHECK_FAILED_ANY:
      en: "Status Check Failed (Any)"
      zh: ""

    PROP_ASG_POLICY_STATUS_CHECK_FAILED_INSTANCE:
      en: "Status Check Failed (Instance)"
      zh: ""

    PROP_ASG_POLICY_STATUS_CHECK_FAILED_SYSTEM:
      en: "Status Check Failed (System)"
      zh: ""

    PROP_ASG_ADJUST_TOOLTIP_CHANGE:
      en: "Increase or decrease existing capacity by integer you input here. A positive value adds to the current capacity and a negative value removes from the current capacity."
      zh: ""

    PROP_ASG_ADJUST_TOOLTIP_EXACT:
      en: "Change the current capacity of your Auto Scaling group to the exact value specified."
      zh: ""

    PROP_ASG_ADJUST_TOOLTIP_PERCENT:
      en: "Increase or decrease the desired capacity by a percentage of the desired capacity. A positive value adds to the current capacity and a negative value removes from the current capacity"
      zh: ""

    PROP_AZ_CANNOT_EDIT_EXISTING_AZ:
      en: "Cannot edit existing availability zone. However, newly created availability zone is editable."
      zh: ""

    PROP_CGW_IP_VALIDATE_REQUIRED:
      en: "IP Address is required."
      zh: ""

    PROP_CGW_IP_VALIDATE_REQUIRED_DESC:
      en: "Please provide a IP Address of this Customer Gateway."
      zh: ""

    PROP_CGW_IP_VALIDATE_INVALID:
      en: "%s  is not a valid IP Address."
      zh: ""

    PROP_CGW_IP_VALIDATE_INVALID_DESC:
      en: "Please provide a valid IP Address. For example, 192.168.1.1."
      zh: ""

    PROP_CGW_IP_VALIDATE_INVALID_CUSTOM:
      en: "IP Address %s is invalid for customer gateway."
      zh: ""

    PROP_CGW_IP_VALIDATE_INVALID_CUSTOM_DESC:
      en: "The address must be static and can't be behind a device performing network address translation (NAT)."
      zh: ""

    PROP_CGW_REMOVE_CUSTOM_GATEWAY:
      en: "Remove Customer Gateway"
      zh: ""

    PROP_CONNECTION_ATTACHMENT_OF:
      en: "This is an attachment of %s to %s"
      zh: ""

    PROP_CONNECTION_SUBNET_ASSO_PLACEMENT:
      en: "A Virtual Network Interface is placed in %s for %s to allow traffic be routed to this availability zone."
      zh: ""

    PROP_ENI_ATTACHMENT_NAME:
      en: "Instance-ENI Attachment"
      zh: ""

    PROP_ELB_SUBNET_ASSO_NAME:
      en: "Load Balencer-Subnet Association"
      zh: ""

    PROP_ELB_INTERNET_FACING:
      en: "Internet Facing"
      zh: ""

    PROP_ELB_INTERNAL:
      en: "Internal"
      zh: ""

    PROP_ELB_ENABLE_CROSS_ZONE_BALANCING:
      en: "Enable cross-zone load balancing"
      zh: ""

    PROP_ELB_CONNECTION_DRAINING:
      en: "Enable Connection Draining"
      zh: ""

    PROP_ELB_CONNECTION_TIMEOUT:
      en: "Timeout"
      zh: ""

    PROP_ELB_CONNECTION_SECONDS:
      en: "Seconds"
      zh: ""

    PROP_ELB_LOAD_BALENCER_PROTOCOL:
      en: "Load Balancer Protocal"
      zh: ""

    PROP_ELB_LBL_PORT:
      en: "Port"
      zh: ""

    PROP_ELB_INSTANCE_PROTOCOL:
      en: "Instance Protocol"
      zh: ""

    PROP_ENI_NETWORK_INTERFACE_DETAIL:
      en: "Network Interface Details"
      zh: ""

    PROP_ENI_NETWORK_INTERFACE_SUMMARY:
      en: "Network Interface Summary"
      zh: ""

    PROP_ENI_NETWORK_INTERFACE_GROUP_MEMBERS:
      en: "Network Interface Group Members"
      zh: ""

    PROP_ENI_CREATE_AFTER_APPLYING_UPDATES:
      en: "Create after applying updates"
      zh: ""

    PROP_ENI_DELETE_AFTER_APPLYING_UPDATES:
      en: "Delete after applying updates"
      zh: ""