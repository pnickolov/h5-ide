# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =
  PROP:

    LBL_REQUIRED:
      en: "Required"
      zh: "必填"

    LBL_DEFAULT:
      en: "Default"
      zh: ""

    LBL_DONE:
      en: "Done"
      zh: ""

    LBL_CANCEL:
      en: "Cancel"
      zh: ""

    LBL_LOADING:
      en: "Loading..."
      zh: ""

    LBL_CAPACITY:
      en: "Capacity"
      zh: ""

    LBL_VALIDATION:
      en: "Validation"
      zh: ""

    LBL_PROPERTY:
      en: "Property"
      zh: ""

    LBL_STATE:
      en: "States"
      zh: ""

    LBL_OWNER:
      en: "Owner"
      zh: ""

    LBL_ERROR:
      en: "Error"
      zh: ""

    LBL_WARNING:
      en: "Warning"
      zh: ""

    LBL_NOTICE:
      en: 'Notice'
      zh: ""

    LBL_STARTED:
      en: "Started"
      zh: ""

    INSTANCE_DETAIL:
      en: "Instance Details"
      zh: "实例设置"

    INSTANCE_HOSTNAME:
      en: "Hostname"
      zh: "主机名"

    INSTANCE_INSTANCE_ID:
      en: "Instance ID"
      zh: "实例ID"

    INSTANCE_LAUNCH_TIME:
      en: "Launch Time"
      zh: "创建时间"

    INSTANCE_STATE:
      en: "State"
      zh: "状态"

    INSTANCE_STATUS:
      en: "Status"
      zh: "状态"

    INSTANCE_PRIMARY_PUBLIC_IP:
      en: "Primary Public IP"
      zh: "主公网IP"

    INSTANCE_PUBLIC_IP:
      en: "Public IP"
      zh: "公网IP"

    INSTANCE_PUBLIC_DNS:
      en: "Public DNS"
      zh: "公网域名"

    INSTANCE_PRIMARY_PRIVATE_IP:
      en: "Primary Private IP"
      zh: "主内网IP"

    INSTANCE_PRIVATE_DNS:
      en: "Private DNS"
      zh: "内网域名"

    INSTANCE_NUMBER:
      en: "Number of Instance"
      zh: "实例数量"

    INSTANCE_REQUIRE:
      en: "Required"
      zh: "必须"

    INSTANCE_AMI:
      en: "AMI"
      zh: "映像"

    INSTANCE_TYPE:
      en: "Instance Type"
      zh: "实例类型"

    INSTANCE_KEY_PAIR:
      en: "Key Pair"
      zh: "秘钥"

    INSTANCE_CLOUDWATCH_DETAILED_MONITORING:
      en: "CloudWatch Detailed Monitoring"
      zh: ""

    INSTANCE_EBS_OPTIMIZED:
      en: "EBS Optimization"
      zh: "EBS 优化"

    INSTANCE_TENANCY:
      en: "Tenancy"
      zh: "租用"

    INSTANCE_TENANCY_DEFAULT:
      en: "Default"
      zh: "默认"

    INSTANCE_TENANCY_DELICATED:
      en: "Delicated"
      zh: "专用"

    INSTANCE_ROOT_DEVICE_TYPE:
      en: "Block Device Type"
      zh: "根设备类型"

    INSTANCE_BLOCK_DEVICE:
      en: "Block Devices"
      zh: "块设备"

    INSTANCE_DEFAULT_KP:
      en: "$DefaultKeyPair"
      zh: ""

    KP_NAME:
      en: "Key Pair Name"
      zh: ""

    KP_CREATED_NEED_TO_DOWNLAOD:
      en: "Key pair <span></span> is created. You have to download the private key file (*.pem file) before you can continue. Store it in a secure and accessible location. You will not be able to download the file again after it's created."
      zh: ""

    KP_CONFIRM_DELETE_1:
      en: "Confirm to delete "
      zh: ""

    KP_CONFIRM_DELETE_2:
      en: " selected"
      zh: ""

    KP_CONFIRM_DELETE_3:
      en: " key pairs"
      zh: ""

    KP_SELECT_A_FILE:
      en: "Select a file"
      zh: ""

    KP_OR_PASTE_KEY_CONTENT:
      en: "or paste the key content here."
      zh: ""

    KP_OR_PASTE_TO_UPDATE:
      en: "or paste the key content again to update."
      zh: ""

    AZ_AND_SUBNET:
      en: "AZ & subnet"
      zh: ""


    OG_NO_OPTION_GROUP:
      en: "No Option Group"
      zh: ""

    OG_CREATE_OPTION_GROUP:
      en: "Create Option Group"
      zh: ""

    OG_PORT:
      en: "Port"
      zh: ""

    KP_SECURITY_GROUP:
      en: "Security Group"
      zh: ""

    KP_OPTION_SETTING:
      en: "Option Setting"
      zh: ""








    INSTANCE_NO_KP:
      en: "No Key Pair"
      zh: ""

    INSTANCE_NEW_KP:
      en: "Create New Key Pair"
      zh: "新建秘钥"

    INSTANCE_FILTER_KP:
      en: "Filter by key pair name"
      zh: ""

    INSTANCE_MANAGE_KP:
      en: "Manage Region Key Pairs ..."
      zh: ""

    INSTANCE_FILTER_SNS:
      en: "Filter by SNS Topic name"
      zh: ""

    INSTANCE_MANAGE_SNS:
      en: "Manage SNS Topic ..."
      zh: ""

    INSTANCE_FILTER_SSL_CERT:
      en: "Filter by SSL Certificate name"
      zh: ""

    INSTANCE_MANAGE_SSL_CERT:
      en: "Manage SSL Certificate..."
      zh: ""

    INSTANCE_TIP_DEFAULT_KP:
      en: 'If you have used $DefaultKeyPair for any instance/launch configuration, you will be required to specify an existing key pair for $DefaultKeyPair. Or you can choose "No Key Pair" as $DefaultKeyPair.'
      zh: ""

    INSTANCE_TIP_NO_KP:
      en: "If you select no key pair, you will not be able to connect to the instance unless you already know the password built into this AMI."
      zh: ""

    INSTANCE_CW_ENABLED:
      en: "Enable CloudWatch Detailed Monitoring"
      zh: "打开CloudWatch监控"

    INSTANCE_ADVANCED_DETAIL:
      en: "Advanced Details"
      zh: "高级设置"

    INSTANCE_USER_DATA:
      en: "User Data"
      zh: "用户数据"

    INSTANCE_USER_DATA_DISABLE:
      en: "Can't edit user data when instance state exist"
      zh: ""

    INSTANCE_CW_WARN:
      en: "Data is available in 1-minute periods at an additional cost. For information about pricing, go to the "
      zh: "数据在一分钟内可用需要额外的话费。 获取价格信息，请去 "

    AGENT_USER_DATA_URL:
      en: "https://github.com/MadeiraCloud/OpsAgent/blob/develop/scripts/userdata.sh"
      zh: "https://github.com/MadeiraCloud/OpsAgent/blob/develop/scripts/userdata.sh"

    INSTANCE_ENI_DETAIL:
      en: "Network Interface Details"
      zh: "网卡设置"

    INSTANCE_ENI_DESC:
      en: "Description"
      zh: "描述"

    INSTANCE_ENI_SOURCE_DEST_CHECK:
      en: "Enable Source/Destination Checking"
      zh: "打开 Source/Destination 检查"

    INSTANCE_ENI_SOURCE_DEST_CHECK_DISP:
      en: "Source/Destination Checking"
      zh: "Source/Destination 检查"

    INSTANCE_ENI_AUTO_PUBLIC_IP:
      en: "Automatically assign Public IP"
      zh: "自动分配公网IP"

    INSTANCE_ENI_IP_ADDRESS:
      en: "IP Address"
      zh: "IP地址"

    INSTANCE_ENI_ADD_IP:
      en: "Add IP"
      zh: "添加IP"

    INSTANCE_SG_DETAIL:
      en: "Security Groups"
      zh: "安全组"

    INSTANCE_IP_MSG_1:
      en: "Specify an IP address or leave it as .x to automatically assign an IP."
      zh: "请提供一个IP或者保留为.x来自动分配IP"

    INSTANCE_IP_MSG_2:
      en: "Automatically assigned IP."
      zh: "自动分配IP"

    INSTANCE_IP_MSG_3:
      en: "Associate with Elastic IP"
      zh: "和Elastic IP进行关联"

    INSTANCE_IP_MSG_4:
      en: "Detach Elastic IP"
      zh: "取消关联Elastic IP"

    INSTANCE_AMI_ID:
      en: "AMI ID"
      zh: "映像ID"

    INSTANCE_AMI_NAME:
      en: "Name"
      zh: "映像名称"

    INSTANCE_AMI_DESC:
      en: "Description"
      zh: "描述"

    INSTANCE_AMI_ARCHITECH:
      en: "Architecture"
      zh: "架构"

    INSTANCE_AMI_VIRTUALIZATION:
      en: "Virtualization"
      zh: "虚拟化"

    INSTANCE_AMI_KERNEL_ID:
      en: "Kernel ID"
      zh: "内核ID"

    INSTANCE_AMI_OS_TYPE:
      en: "Type"
      zh: "操作系统类型"

    INSTANCE_AMI_SUPPORT_INSTANCE_TYPE:
      en: "Support Instance"
      zh: "支持实例类型"

    INSTANCE_KEY_MONITORING:
      en: "Monitoring"
      zh: "监控"

    INSTANCE_KEY_ZONE:
      en: "Zone"
      zh: "地区"

    INSTANCE_AMI_LAUNCH_INDEX:
      en: "AMI Launch Index"
      zh: "AMI启动序号"

    INSTANCE_AMI_NETWORK_INTERFACE:
      en: "Network Interface"
      zh: "网络接口"

    INSTANCE_TIP_GET_SYSTEM_LOG:
      en: "Get System Log"
      zh: ""

    DB_INSTANCE_TIP_GET_LOG:
      en: "Get Logs & Events"
      zh: ""

    INSTANCE_TIP_IF_THE_QUANTITY_IS_MORE_THAN_1:
      en: "If the quantity is more than 1, host name will be the string you provide plus number index."
      zh: ""

    INSTANCE_TIP_YOU_CANNOT_SPECIFY_INSTANCE_NUMBER:
      en: "You cannot specify instance number, since the instance is connected to a route table."
      zh: ""

    INSTANCE_TIP_PUBLIC_IP_CANNOT_BE_ASSOCIATED:
      en: "Public IP cannot be associated if instance is launching with more than one network interface."
      zh: ""

    INSTANCE_GET_WINDOWS_PASSWORD:
      en: "Get Windows Password"
      zh: ""

    INSTANCE_IOPS:
      en: "IOPS"
      zh: ""

    AMI_STACK_NOT_AVAILABLE:
      en: "<p>This AMI is not available. It may have been deleted by its owner or not shared with your AWS account. </p><p>Please change to another AMI.</p>"
      zh: ""

    AMI_APP_NOT_AVAILABLE:
      en: "This AMI's infomation is unavailable."
      zh: ""

    STACK_AMAZON_ARN:
      en: "Amazon ARN"
      zh: ""

    STACK_EXAMPLE_EMAIL:
      en: "example@acme.com"
      zh: ""

    STACK_E_G_1_206_555_6423:
      en: "e.g. 1-206-555-6423"
      zh: ""

    STACK_HTTP_WWW_EXAMPLE_COM:
      en: "http://www.example.com"
      zh: ""

    STACK_HTTPS_WWW_EXAMPLE_COM:
      en: "https://www.example.com"
      zh: ""

    STACK_HTTPS:
      en: "https"
      zh: ""

    STACK_HTTP:
      en: "http"
      zh: ""

    STACK_USPHONE:
      en: "usPhone"
      zh: ""

    STACK_EMAIL:
      en: "email"
      zh: ""

    STACK_ARN:
      en: "arn"
      zh: ""

    STACK_SQS:
      en: "sqs"
      zh: ""

    STACK_PENDING_CONFIRM:
      en: "pendingConfirm"
      zh: ""

    STACK_LBL_NAME:
      en: "Stack Name"
      zh: "模版名称"

    APP_LBL_NAME:
      en: "App Name"
      zh: "应用名称"

    STACK_LBL_DESCRIPTION:
      en: "Stack Description"
      zh: "模板描述"

    STACK_LBL_REGION:
      en: "Region"
      zh: "地区"

    STACK_LBL_TYPE:
      en: "Type"
      zh: "类型"

    STACK_LBL_ID:
      en: "Stack ID"
      zh: "模板标识"

    APP_LBL_ID:
      en: "App ID"
      zh: "应用标识"

    APP_LBL_INSTANCE_STATE:
      en: "Instance State"
      zh: ""

    APP_LBL_RESDIFF:
      en: "Monitor and report external resource change of this app"
      zh: ""

    APP_LBL_RESDIFF_VIEW:
      en: "Monitor and Report External Change"
      zh: ""

    APP_TIP_RESDIFF:
      en: "If resource has been changed outside VisualOps, an email notification will be sent to you."
      zh: ""

    STACK_LBL_USAGE:
      en: "Usage"
      zh: "用途"

    STACK_TIT_SG:
      en: "Security Groups"
      zh: "安全组"

    STACK_TIT_ACL:
      en: "Network ACL"
      zh: "访问控制表"

    STACK_TIT_SNS:
      en: "SNS Topic Subscription"
      zh: "SNS主题订阅"

    STACK_BTN_ADD_SUB:
      en: "Add Subscription"
      zh: "添加订阅"

    STACK_TIT_COST_ESTIMATION:
      en: "Cost Estimation"
      zh: "成本估算"

    STACK_LBL_COST_CYCLE:
      en: "month"
      zh: "月"

    STACK_COST_COL_RESOURCE:
      en: "Resource"
      zh: "资源"

    STACK_COST_COL_SIZE_TYPE:
      en: "Size/Type"
      zh: "大小/类型"

    STACK_COST_COL_FEE:
      en: "Fee($)"
      zh: "价格($)"

    STACK_LBL_AWS_EC2_PRICING:
      en: "Amazon EC2 Pricing"
      zh: "Amazon EC2 定价"

    STACK_ACL_LBL_RULE:
      en: "rules"
      zh: "条规则"

    STACK_ACL_LBL_ASSOC:
      en: "associations"
      zh: "个关联"

    STACK_ACL_BTN_DELETE:
      en: "Delete"
      zh: "删除"

    STACK_ACL_TIP_DETAIL:
      en: "Go to Network ACL Details"
      zh: "查看访问控制表详细"

    STACK_BTN_CREATE_NEW_ACL:
      en: "Create new Network ACL..."
      zh: "创建新的访问控制表..."

    APP_SNS_NONE:
      en: "This app has no SNS Subscription"
      zh: "本应用不含SNS订阅"

    AZ_LBL_SWITCH:
      en: "Quick Switch Availability Zone"
      zh: "切换可用区域"

    VPC_TIT_DETAIL:
      en: "VPC Details"
      zh: "VPC详细"

    VPC_DETAIL_LBL_NAME:
      en: "Name"
      zh: "名称"

    VPC_DETAIL_LBL_CIDR_BLOCK:
      en: "CIDR Block"
      zh: "CIDR 块"

    VPC_DETAIL_LBL_TENANCY:
      en: "Tenancy"
      zh: "租用"

    VPC_DETAIL_TENANCY_LBL_DEFAULT:
      en: "Default"
      zh: "缺省"

    VPC_DETAIL_TENANCY_LBL_DEDICATED:
      en: "Dedicated"
      zh: "专用"

    VPC_DETAIL_LBL_ENABLE_DNS_RESOLUTION:
      en: "Enable DNS resolution"
      zh: "允许DNS解析"

    VPC_DETAIL_LBL_ENABLE_DNS_HOSTNAME_SUPPORT:
      en: "Enable DNS hostname support"
      zh: "允许DNS主机名解析"

    VPC_TIT_DHCP_OPTION:
      en: "DHCP Options"
      zh: "DHCP 选项"

    VPC_DHCP_LBL_NONE:
      en: "Default"
      zh: "无"

    VPC_DHCP_LBL_DEFAULT:
      en: "Auto-assigned Set"
      zh: "缺省"

    VPC_DHCP_LBL_SPECIFIED:
      en: "Specified DHCP Options Set"
      zh: "指定的DHCP选项设置"

    VPC_DHCP_SPECIFIED_LBL_DOMAIN_NAME:
      en: "Domain Name"
      zh: "域名"

    VPC_DHCP_SPECIFIED_LBL_DOMAIN_NAME_SERVER:
      en: "Domain Name Server"
      zh: "域名服务器"

    VPC_DHCP_SPECIFIED_LBL_AMZN_PROVIDED_DNS:
      en: "AmazonProvidedDNS"
      zh: "亚马逊提供的域名服务器"

    VPC_DHCP_SPECIFIED_LBL_NTP_SERVER:
      en: "NTP Server"
      zh: "时间服务器"

    VPC_DHCP_SPECIFIED_LBL_NETBIOS_NAME_SERVER:
      en: "NetBIOS Name Server"
      zh: "NetBIOS名字服务器"

    VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE:
      en: "NetBIOS Node Type"
      zh: "NetBIOS节点类型"

    VPC_DHCP_SPECIFIED_LBL_NETBIOS_NODE_TYPE_NOT_SPECIFIED:
      en: "Not specified"
      zh: "未指定"

    VPC_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC标识"

    VPC_APP_STATE:
      en: "State"
      zh: "状态"

    VPC_APP_CIDR:
      en: "CIDR"
      zh: "CIDR"

    VPC_APP_MAIN_RT:
      en: "Main Route Table"
      zh: "主路由表"

    VPC_APP_DEFAULT_ACL:
      en: "Default Network ACL"
      zh: "缺省访问控制表"

    VPC_DHCP_OPTION_SET_ID:
      en: "DHCP Options Set ID"
      zh: "DHCP选项标识"

    VPC_MANAGE_DHCP:
      en: "Manage DHCP Options Set"
      zh: ""

    VPC_MANAGE_RDS_PG:
      en: "Manage Parameter Group"
      zh: ""

    VPC_FILTER_RDS_PG:
      en: "Filter by Parameter Group Name"
      zh: ""

    VPC_FILTER_DHCP:
      en: "Filter by DHCP Options Set ID"
      zh: ""

    VPC_TIP_AUTO_DHCP:
      en: "A DHCP Options set will be automatically assigned for the VPC by AWS."
      zh: ""

    VPC_TIP_DEFAULT_DHCP:
      en: "The VPC will use no DHCP options."
      zh: "The VPC will use no DHCP options."

    VPC_AUTO_DHCP:
      en: "Auto-assigned Set"
      zh: ""

    VPC_DEFAULT_DHCP:
      en: "Default"
      zh: "Default"

    SUBNET_TIP_CIDR_BLOCK:
      en: "e.g. 10.0.0.0/24. The range of IP addresses in the subnet must be a subset of the IP address in the VPC. Block sizes must be between a /16 netmask and /28 netmask. The size of the subnet can equal the size of the VPC."
      zh: ""

    SUBNET_TIT_DETAIL:
      en: "Subnet Details"
      zh: "子网详细"

    SUBNET_DETAIL_LBL_NAME:
      en: "Name"
      zh: "名称"

    SUBNET_DETAIL_LBL_CIDR_BLOCK:
      en: "CIDR Block"
      zh: "CIDR 块"

    SUBNET_TIT_ASSOC_ACL:
      en: "Associated Network ACL"
      zh: "相关访问控制表"

    SUBNET_BTN_CREATE_NEW_ACL:
      en: "Create new Network ACL..."
      zh: "创建新的访问控制表..."

    SUBNET_ACL_LBL_RULE:
      en: "rules"
      zh: "条规则"

    SUBNET_ACL_LBL_ASSOC:
      en: "associations"
      zh: "个关联"

    SUBNET_ACL_BTN_DELETE:
      en: "Delete"
      zh: "删除"

    SUBNET_ACL_TIP_DETAIL:
      en: "Go to Network ACL Details"
      zh: "查看访问控制表详细"

    SUBNET_APP_ID:
      en: "Subnet ID"
      zh: "子网标识"

    SUBNET_APP_STATE:
      en: "State"
      zh: "状态"

    SUBNET_APP_CIDR:
      en: "CIDR"
      zh: "CIDR"

    SUBNET_APP_AVAILABLE_IP:
      en: "Available IPs"
      zh: "可用IP"

    SUBNET_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC标识"

    SUBNET_APP_RT_ID:
      en: "Route Table ID"
      zh: "路由表标识"

    VPC_TIP_EG_10_0_0_0_16:
      en: "e.g. 10.0.0.0/16"
      zh: ""

    VPC_TIP_ENTER_THE_DOMAIN_NAME:
      en: "Enter the domain name that should be used for your hosts"
      zh: ""

    VPC_TIP_ENTER_UP_TO_4_DNS:
      en: "Enter up to 4 DNS server IP addresses"
      zh: ""

    VPC_TIP_ENTER_UP_TO_4_NTP:
      en: "Enter up to 4 NTP server IP addresses"
      zh: ""

    VPC_TIP_ENTER_UP_TO_4_NETBIOS:
      en: "Enter up to 4 NetBIOS server IP addresses"
      zh: ""

    VPC_TIP_EG_172_16_16_16:
      en: "e.g. 172.16.16.16"
      zh: ""

    VPC_TIP_SELECT_NETBIOS_NODE:
      en: "Select NetBIOS Node Type. We recommend 2. (Broadcast and multicast are currently not supported by AWS.)"
      zh: ""

    VPC_TIP_:
      en: ""
      zh: ""

    SG_TIT_DETAIL:
      en: "Security Group Details"
      zh: "安全组详细"

    SG_DETAIL_LBL_NAME:
      en: "Name"
      zh: "名称"

    SG_TIT_RULE:
      en: "Rule"
      zh: "规则"

    SG_RULE_SORT_BY:
      en: "Sort by"
      zh: "排序"

    SG_RULE_SORT_BY_DIRECTION:
      en: "Direction"
      zh: "按方向"

    SG_RULE_SORT_BY_SRC_DEST:
      en: "Source/Destination"
      zh: "按源/目的"

    SG_RULE_SORT_BY_PROTOCOL:
      en: "Protocol"
      zh: "按协议"

    SG_TIT_MEMBER:
      en: "Member"
      zh: "成员"

    SG_TIP_CREATE_RULE:
      en: "Create rule referencing IP Range"
      zh: "创建基于IP范围的规则"

    SG_TIP_REMOVE_RULE:
      en: "Remove rule"
      zh: "删除规则"

    SG_TIP_PROTOCOL:
      en: "Protocol"
      zh: "协议"

    SG_TIP_SRC:
      en: "Source"
      zh: "源"

    SG_TIP_DEST:
      en: "Destination"
      zh: "目的"

    SG_TIP_INBOUND:
      en: "Inbound"
      zh: "入方向"

    SG_TIP_OUTBOUND:
      en: "Outbound"
      zh: "出方向"

    SG_TIP_PORT_CODE:
      en: "Port or Code"
      zh: "端口或代码"

    SG_APP_SG_ID:
      en: "Security Group ID"
      zh: "安全组标识"

    SG_APP_SG_NAME:
      en: "Security Group Name"
      zh: "安全组名字"

    SG_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC标识"

    SGLIST_LBL_RULE:
      en: "rules"
      zh: "条规则"

    SGLIST_LBL_MEMBER:
      en: "members"
      zh: "个成员"

    SGLIST_LNK_DELETE:
      en: "Delete"
      zh: "删除"

    SGLIST_TIP_VIEW_DETAIL:
      en: "View details"
      zh: "查看详细"

    SGLIST_BTN_CREATE_NEW_SG:
      en: "Create new Security Group..."
      zh: "创建新安全组..."

    SGLIST_TAB_GROUP:
      en: "Group"
      zh: "组"

    SGLIST_TAB_RULE:
      en: "Rule"
      zh: "规则"

    SGRULE_DESCRIPTION:
      en: "The selected connection reflects following security group rule(s):"
      zh: "当前选中的连线反映了以下安全组的规则:"

    SGRULE_TIP_INBOUND:
      en: "Inbound"
      zh: "入方向"

    SGRULE_TIP_OUTBOUND:
      en: "Outbound"
      zh: "出方向"

    SGRULE_BTN_EDIT_RULE:
      en: "Edit Related Rule"
      zh: "编辑相关规则"

    ACL_LBL_NAME:
      en: "Name"
      zh: "名称"

    ACL_TIT_RULE:
      en: "Rule"
      zh: "规则"

    ACL_BTN_CREATE_NEW_RULE:
      en: "Create new Network ACL Rule"
      zh: "创建新的访问控制表"

    ACL_RULE_SORT_BY:
      en: "Sort by"
      zh: "排序"

    ACL_RULE_SORT_BY_NUMBER:
      en: "Rule Number"
      zh: "按规则编号"

    ACL_RULE_SORT_BY_ACTION:
      en: "Action"
      zh: "动作"

    ACL_RULE_SORT_BY_DIRECTION:
      en: "Direction"
      zh: "方向"

    ACL_RULE_SORT_BY_SRC_DEST:
      en: "Source/Destination"
      zh: "源/目的"

    ACL_TIP_ACTION_ALLOW:
      en: "allow"
      zh: "允许"

    ACL_TIP_ACTION_DENY:
      en: "deny"
      zh: "拒绝"

    ACL_TIP_INBOUND:
      en: "Inbound"
      zh: "入方向"

    ACL_TIP_OUTBOUND:
      en: "Outbound"
      zh: "出方向"

    ACL_TIP_RULE_NUMBER:
      en: "Rule Number"
      zh: "规则编号"

    ACL_TIP_CIDR_BLOCK:
      en: "CIDR Block"
      zh: "CIDR 块"

    ACL_TIP_PROTOCOL:
      en: "Protocol"
      zh: "协议"

    ACL_TIT_ASSOC:
      en: "Associations"
      zh: "关联的子网"

    ACL_TIP_REMOVE_RULE:
      en: "Remove rule"
      zh: "删除规则"

    ACL_APP_ID:
      en: "Network ACL ID"
      zh: "访问控制表标识"

    ACL_APP_IS_DEFAULT:
      en: "Default"
      zh: "是否缺省"

    ACL_APP_VPC_ID:
      en: "VPC ID"
      zh: "VPC标识"

    VGW_TXT_DESCRIPTION:
      en: "The Virtual Private Gateway is the router on the Amazon side of the VPN tunnel."
      zh: "虚拟私有网关是亚马逊一侧的VPN隧道的路由器."

    VPN_LBL_IP_PREFIX:
      en: "Network IP Prefixes"
      zh: "网络号前缀"

    VPN_TIP_EG_192_168_0_0_16:
      en: "e.g., 192.168.0.0/16"
      zh: ""

    VPN_SUMMARY:
      en: "VPN Summary"
      zh: ""

    IGW_TXT_DESCRIPTION:
      en: "The Internet gateway is the router on the AWS network that connects your VPC to the Internet."
      zh: "互联网网关是将你位于AWS网络中的VPC网络连接到互联网的路由器."

    CGW_LBL_NAME:
      en: "Name"
      zh: "名称"

    CGW_LBL_IPADDR:
      en: "IP Address"
      zh: "IP地址"

    CGW_LBL_ROUTING:
      en: "Routing"
      zh: "路由"

    CGW_LBL_STATIC:
      en: "Static"
      zh: "静态"

    CGW_LBL_DYNAMIC:
      en: "Dynamic"
      zh: "动态"

    CGW_LBL_BGP_ASN:
      en: "BGP ASN"
      zh: "BGP 自治域号"

    CGW_APP_TIT_CGW:
      en: "Customer Gateway"
      zh: "客户网关"

    CGW_APP_CGW_LBL_ID:
      en: "ID"
      zh: "标识"

    CGW_APP_CGW_LBL_STATE:
      en: "State"
      zh: "状态"

    CGW_APP_CGW_LBL_TYPE:
      en: "Type"
      zh: "类型"

    CGW_APP_TIT_VPN:
      en: "VPN Connection"
      zh: "VPN连接"

    CGW_APP_VPN_LBL_ID:
      en: "ID"
      zh: "标识"

    CGW_APP_VPN_LBL_STATE:
      en: "State"
      zh: "状态"

    CGW_APP_VPN_LBL_TYPE:
      en: "Type"
      zh: "类型"

    CGW_APP_VPN_LBL_TUNNEL:
      en: "VPN Tunnels"
      zh: "VPN隧道"

    CGW_APP_VPN_COL_TUNNEL:
      en: "Tunnel"
      zh: "隧道"

    CGW_APP_VPN_COL_IP:
      en: "IP Address"
      zh: "IP地址"

    CGW_APP_VPN_LBL_STATUS_RT:
      en: "Static Routes"
      zh: "静态路由"

    CGW_APP_VPN_COL_IP_PREFIX:
      en: "IP Prefixes"
      zh: "网络号"

    CGW_APP_VPN_COL_SOURCE:
      en: "Source"
      zh: "源"

    CGW_APP_TIT_DOWNLOAD_CONF:
      en: "Download Configuration"
      zh: "下载配置"

    CGW_APP_DOWN_LBL_VENDOR:
      en: "Vendor"
      zh: "厂商"

    CGW_APP_DOWN_LBL_PLATFORM:
      en: "Platform"
      zh: "平台"

    CGW_APP_DOWN_LBL_SOFTWARE:
      en: "Software"
      zh: "软件"

    CGW_APP_DOWN_LBL_GENERIC:
      en: "Generic"
      zh: "通用"

    CGW_APP_DOWN_LBL_VENDOR_AGNOSTIC:
      en: "Vendor Agnostic"
      zh: "厂商无关"

    CGW_APP_DOWN_BTN_DOWNLOAD:
      en: "Download"
      zh: "下载"

    CGW_TIP_THIS_ADDRESS_MUST_BE_STATIC:
      en: "This address must be static and not behind a NAT. e.g. 12.1.2.3"
      zh: ""

    CGW_TIP_1TO65534:
      en: "1 - 65534"
      zh: ""

    MSG_ERR_RESOURCE_NOT_EXIST:
      en: "Sorry, the selected resource not exist."
      zh: "抱歉，选定的资源不存在。"

    MSG_ERR_DOWNLOAD_KP_FAILED:
      en: "Sorry, there was a problem downloading this key pair."
      zh: "抱歉，下载密钥对时出现了问题。"

    MSG_WARN_NO_STACK_NAME:
      en: "Stack name empty or missing."
      zh: "模板名称不能为空。"

    MSG_WARN_REPEATED_STACK_NAME:
      en: "This stack name is already in use."
      zh: "这个模板名称已被占用。"

    MSG_WARN_ENI_IP_EXTEND:
      en: "%s Instance's Network Interface can't exceed %s Private IP Addresses."
      zh: "%s 实例的网络接口不能超过 %s 私有IP地址。"

    MSG_WARN_NO_APP_NAME:
      en: "App name empty or missing."
      zh: "应用名称不能为空。"

    MSG_WARN_REPEATED_APP_NAME:
      en: "This app name is already in use."
      zh: "这个应用名称已被占用This app name is already in use."

    MSG_WARN_INVALID_APP_NAME:
      en: "App name is invalid."
      zh: "无效的应用名称。"

    WARN_EXCEED_ENI_LIMIT:
      en: "Instance type %s supports a maximum of %s network interfaces (including the primary). Please detach additional network interfaces before changing instance type."
      zh: "实例类型：%s 支持最多 %s 个网络接口（包括主要的）， 请在改变实例类型之前删除超出数量限制的网络接口。"

    TEXT_DEFAULT_SG_DESC:
      en: "Default Security Group"
      zh: "Default Security Group"

    TEXT_CUSTOM_SG_DESC:
      en: "Custom Security Group"
      zh: "Custom Security Group"

    MSG_WARN_WHITE_SPACE:
      en: "Stack name contains white space"
      zh: "模板名称不能包含空格"

    MSG_SG_CREATE:
      en: "1 rule has been created in %s to allow %s %s %s."
      zh: "1条规则被创建到 %s 来允许 %s %s %s。"

    MSG_SG_CREATE_MULTI:
      en: "%d rules have been created in %s and %s to allow %s %s %s."
      zh: "%d条规则被创建到 %s 并且 %s 来允许 %s %s %s."

    MSG_SG_CREATE_SELF:
      en: "%d rules have been created in %s to allow %s send and receive traffic within itself."
      zh: "%d条规则被创建到 %s 来允许 %s 它内部的收发通信."

    SNAPSHOT_FILTER_REGION:
      en: "Filter by region name"
      zh: ""

    SNAPSHOT_FILTER_VOLUME:
      en: "Filter by Volume ID"
      zh: ""

    VOLUME_DEVICE_NAME:
      en: "Device Name"
      zh: "挂载设备名"

    VOLUME_SIZE:
      en: "Volume Size"
      zh: "磁盘大小"

    VOLUME_ID:
      en: "Volume ID"
      zh: "磁盘ID"

    VOLUME_STATE:
      en: "State"
      zh: "状态"

    VOLUME_CREATE_TIME:
      en: "Create Time"
      zh: "创建时间"

    VOLUME_SNAPSHOT_ID:
      en: "Snapshot ID"
      zh: "快照ID"

    VOLUME_SNAPSHOT_SELECT:
      en: "Select volume from which to create snapshot"
      zh: ""

    VOLUME_SNAPSHOT_SELECT_REGION:
      en: "Select Destination Region"
      zh: ""

    VOLUME_SNAPSHOT:
      en: "Snapshot"
      zh: "快照"

    VOLUME_ATTACHMENT_STATE:
      en: "Attachment Status"
      zh: "挂载状态"

    VOLUME_ATTACHMENT_SET:
      en: "AttachmentSet"
      zh: "挂载数据集"

    VOLUME_INSTANCE_ID:
      en: "Instance ID"
      zh: "实例ID"

    VOLUME_ATTACHMENT_TIME:
      en: "Attach Time"
      zh: "挂载时间"

    VOLUME_TYPE:
      en: "Volume Type"
      zh: "磁盘类型"

    VOLUME_ENCRYPTED:
      en: "Encrypted"
      zh: ""

    VOLUME_TYPE_STANDARD:
      en: "Magnetic"
      zh: "传统磁盘"

    VOLUME_TYPE_GP2:
      en: "General Purpose (SSD)"
      zh: "通用（SSD）"

    VOLUME_TYPE_IO1:
      en: "Provisioned IOPS (SSD)"
      zh: "预配置IOPS"

    VOLUME_MSG_WARN:
      en: "Volume size must be at least 10 GB to use Provisioned IOPS volume type."
      zh: "要使用预配置IOPS,磁盘必须最少10GB"

    VOLUME_ENCRYPTED_LABEL:
      en: "Encrypt this volume"
      zh: ""

    ENI_LBL_ATTACH_WARN:
      en: "Attach the Network Interface to an instance within the same availability zone."
      zh: "在同一个可用区域里面附加网络接口。"

    ENI_LBL_DETAIL:
      en: "Network Interface Details"
      zh: "网卡设置"

    ENI_SOURCE_DEST_CHECK:
      en: "Enable Source/Destination Checking"
      zh: "打开 Source/Destination 检查"

    ENI_AUTO_PUBLIC_IP:
      en: "Automatically assign Public IP"
      zh: "自动分配公网IP"

    ENI_IP_ADDRESS:
      en: "IP Address"
      zh: "IP地址"

    ENI_ADD_IP:
      en: "Add IP"
      zh: "添加IP"

    ENI_SG_DETAIL:
      en: "Security Groups"
      zh: "安全组"

    ENI_DEVICE_NAME:
      en: "Device Name"
      zh: "设备名称"

    ENI_STATE:
      en: "State"
      zh: "状态"

    ENI_ID:
      en: "Network Interface ID"
      zh: "网卡ID"

    ENI_SHOW_DETAIL:
      en: "More"
      zh: "更多"

    ENI_HIDE_DETAIL:
      en: "Hide"
      zh: "隐藏"

    ENI_VPC_ID:
      en: "VPC ID"
      zh: "VPC ID"

    ENI_SUBNET_ID:
      en: "Subnet ID"
      zh: "子网ID"

    ENI_ATTACHMENT_ID:
      en: "Attachment ID"
      zh: "关联ID"

    ENI_Attachment_OWNER:
      en: "Owner"
      zh: "关联拥有者"

    ENI_Attachment_STATE:
      en: "State"
      zh: "关联状态"

    ENI_MAC_ADDRESS:
      en: "MAC Address"
      zh: "MAC地址"

    ENI_IP_OWNER:
      en: "IP Owner"
      zh: "IP拥有者"

    ENI_TIP_ADD_IP_ADDRESS:
      en: "Add IP Address"
      zh: ""

    ENI_PRIMARY:
      en: "Primary"
      zh: ""

    ELB_DETAILS:
      en: "Load Balancer Details"
      zh: "负载均衡器设置"

    ELB_NAME:
      en: "Name"
      zh: "名称"

    ELB_REQUIRED:
      en: "Required"
      zh: "必须"

    ELB_SCHEME:
      en: "Scheme"
      zh: "模式"

    ELB_LISTENER_DETAIL:
      en: "Listener Configuration"
      zh: "监听设置"

    ELB_BTN_ADD_LISTENER:
      en: "+ Add Listener"
      zh: "添加监听器"

    ELB_BTN_ADD_SERVER_CERTIFICATE:
      en: "Add SSL Certificate"
      zh: "添加服务器认证"

    ELB_SERVER_CERTIFICATE:
      en: "SSL Certificate"
      zh: "服务器认证"

    ELB_LBL_LISTENER_NAME:
      en: "Name"
      zh: "名称"

    ELB_LBL_LISTENER_DESCRIPTIONS:
      en: "Listener Descriptions"
      zh: "监听器描述"

    ELB_LBL_LISTENER_CERT_NAME:
      en: "Certificate Name"
      zh: ""

    ELB_LBL_LISTENER_PRIVATE_KEY:
      en: "Private Key"
      zh: "私钥"

    ELB_LBL_LISTENER_PUBLIC_KEY:
      en: "Public Key Certificate"
      zh: "公钥"

    ELB_LBL_LISTENER_CERTIFICATE_CHAIN:
      en: "Certificate Chain"
      zh: "认证链"

    ELB_HEALTH_CHECK:
      en: "Health Check"
      zh: "健康度检查"

    ELB_HEALTH_CHECK_DETAILS:
      en: "Health Check Configuration"
      zh: "健康度检查配置"

    ELB_PING_PROTOCOL:
      en: "Ping Protocol"
      zh: "Ping协议"

    ELB_PING_PORT:
      en: "Ping\tPort"
      zh: "Ping端口"

    ELB_PING_PATH:
      en: "Ping Path"
      zh: "Ping路径"

    ELB_HEALTH_CHECK_INTERVAL:
      en: "Health Check Interval"
      zh: "健康度检查间隔"

    ELB_IDLE_TIMEOUT:
      en: "Idle Connection Timeout"
      zh: ""

    ELB_HEALTH_CHECK_INTERVAL_SECONDS:
      en: "Seconds"
      zh: "秒"

    ELB_HEALTH_CHECK_RESPOND_TIMEOUT:
      en: "Response Timeout"
      zh: "响应超时"

    ELB_HEALTH_THRESHOLD:
      en: "Healthy Threshold"
      zh: "健康界限"

    ELB_UNHEALTH_THRESHOLD:
      en: "Unhealthy Threshold"
      zh: "不健康界限"

    ELB_AVAILABILITY_ZONE:
      en: "Availability Zones"
      zh: "可用区域"

    ELB_SG_DETAIL:
      en: "Security Groups"
      zh: "安全组"

    ELB_DNS_NAME:
      en: "DNS"
      zh: "域名"

    ELB_HOST_ZONE_ID:
      en: "Hosted Zone ID"
      zh: "Hosted Zone ID"

    ELB_CROSS_ZONE:
      en: "Cross-zone Load Balancing"
      zh: "Cross-zone Load Balancing"

    ELB_CONNECTION_DRAIN:
      en: "Connection Draining"
      zh: ""

    ELB_ELB_PROTOCOL:
      en: "Load Balancer Protocol"
      zh: "负载均衡器协议"

    PORT:
      en: "Port"
      zh: "端口"

    ELB_INSTANCE_PROTOCOL:
      en: "Instance Protocol"
      zh: "实例协议"

    ELB_INSTANCES:
      en: "Instances"
      zh: ""

    ELB_HEALTH_INTERVAL_VALID:
      en: "Response timeout must be less than the health check interval value"
      zh: ""

    ELB_CONNECTION_DRAIN_TIMEOUT_INVALID:
      en: "Timeout must be an integer between 1 and 3600"
      zh: ""

    ELB_TIP_CLICK_TO_SELECT_ALL:
      en: "Click to select all"
      zh: ""

    ELB_TIP_REMOVE_LISTENER:
      en: "Remove listener"
      zh: ""

    ELB_TIP_25_80_443OR1024TO65535:
      en: "25, 80, 443 or 1024 - 65535"
      zh: ""

    ELB_TIP_1_65535:
      en: "1 - 65535"
      zh: ""

    ELB_TIP_CLICK_TO_READ_RELATED_AWS_DOCUMENT:
      en: "Click to read related AWS document"
      zh: ""

    ELB_CERT_REMOVE_CONFIRM_TITLE:
      en: "Confirm to Delete SSL Certificate"
      zh: ""

    ELB_CERT_REMOVE_CONFIRM_MAIN:
      en: "Do you confirm to delete "
      zh: ""

    ELB_CERT_REMOVE_CONFIRM_SUB:
      en: "Load Balancer currently using this server certificate will have errors."
      zh: ""

    ASG_SUMMARY:
      en: "Auto Scaling Group Summary"
      zh: "自动伸缩组摘要"

    ASG_DETAILS:
      en: "Auto Scaling Group Details"
      zh: "自动伸缩组配置"

    ASG_NAME:
      en: "Name"
      zh: "名称"

    ASG_REQUIRED:
      en: "Required"
      zh: "必须"

    ASG_CREATE_TIME:
      en: "Create Time"
      zh: "创建时间"

    ASG_MIN_SIZE:
      en: "Minimum Size"
      zh: "最小数量"

    ASG_MAX_SIZE:
      en: "Maximum Size"
      zh: "最大数量"

    ASG_DESIRE_CAPACITY:
      en: "Desired Capacity"
      zh: "期望数量"

    ASG_COOL_DOWN:
      en: "Default Cooldown"
      zh: "冷却时间"

    ASG_INSTANCE:
      en: "Instance"
      zh: "实例"

    ASG_DEFAULT_COOL_DOWN:
      en: "Default Cooldown"
      zh: "默认冷却时间"

    ASG_UNIT_SECONDS:
      en: "Seconds"
      zh: "秒"

    ASG_UNIT_MINS:
      en: "Minutes"
      zh: "分"

    ASG_HEALTH_CHECK_TYPE:
      en: "Health Check Type"
      zh: "健康度检查类型"

    ASG_HEALTH_CHECK_CRACE_PERIOD:
      en: "Health Check Grace Period"
      zh: "健康度检查时间"

    ASG_POLICY:
      en: "Policy"
      zh: "策略"

    ASG_HAS_ELB_WARN:
      en: "You need to connect this auto scaling group to a load balancer to enable this option."
      zh: "你需要连接AutoScaling组和一个负载均衡器来启动此选项"

    ASG_ELB_WARN:
      en: "If the calls to Elastic Load Balancing health check for the instance returns any state other than InService, Auto Scaling marks the instance as Unhealthy. And if the instance is marked as Unhealthy, Auto Scaling starts the termination process for the instance."
      zh: ""

    ASG_TERMINATION_POLICY:
      en: "Termination Policy"
      zh: "结束策略"

    ASG_POLICY_TLT_NAME:
      en: "Policy Name"
      zh: "策略名称"

    ASG_POLICY_TLT_ALARM_METRIC:
      en: "Alarm Metric"
      zh: "警告准则"

    ASG_POLICY_TLT_THRESHOLD:
      en: "Threshold"
      zh: "界限"

    ASG_POLICY_TLT_PERIOD:
      en: "Evaluation Period x Periords"
      zh: "评估时间"

    ASG_POLICY_TLT_ACTION:
      en: "Action Trigger"
      zh: "触发动作"

    ASG_POLICY_TLT_ADJUSTMENT:
      en: "Adjustment"
      zh: "调整"

    ASG_POLICY_TLT_EDIT:
      en: "Edit Scaling Policy"
      zh: "编辑策略"

    ASG_POLICY_TLT_REMOVE:
      en: "Remove Scaling Policy"
      zh: "删除策略"

    ASG_BTN_ADD_SCALING_POLICY:
      en: "Add Scaling Policy"
      zh: "添加扩展策略"

    ASG_LBL_NOTIFICATION:
      en: "Notification"
      zh: "通知"

    ASG_LBL_SEND_NOTIFICATION_D:
      en: "Send notification via SNS topic"
      zh: "通过SNS发送通知"

    ASG_LBL_SEND_NOTIFICATION:
      en: "Send notification via SNS topic for:"
      zh: "通过SNS发送通知"

    ASG_LBL_SUCCESS_INSTANCES_LAUNCH:
      en: "Successful instance launch"
      zh: "运行实例成功"

    ASG_LBL_FAILED_INSTANCES_LAUNCH:
      en: "Failed instance launch"
      zh: "运行实例失败"

    ASG_LBL_SUCCESS_INSTANCES_TERMINATE:
      en: "Successful instance termination"
      zh: "终止实例成功"

    ASG_LBL_FAILED_INSTANCES_TERMINATE:
      en: "Failed instance termination"
      zh: "终止实例失败"

    ASG_LBL_VALIDATE_SNS:
      en: "Validating a configuraed SNS Topic"
      zh: "验证SNS主题"

    ASG_MSG_NO_NOTIFICATION_WARN:
      en: "No notification configured for this auto scaling group"
      zh: "没有设置Notification Configuration"

    ASG_MSG_SNS_WARN:
      en: "There is no SNS subscription set up yet. Go to Stack Property to set up SNS subscription so that you will get the notification."
      zh: "现在SNS还没有设置订阅信息，请去模板属性框设置，以便收到通知"

    ASG_MSG_DROP_LC:
      en: "Drop AMI from Resrouce Panel to create Launch Configuration"
      zh: "请拖拽映像来建立Launch Configuration"

    ASG_TERMINATION_EDIT:
      en: "Edit Termination Policy"
      zh: "编辑终止策略"

    ASG_TERMINATION_TEXT_WARN:
      en: "You can either specify any one of the policies as a standalone policy, or you can list multiple policies in an ordered list. The policies are executed in the order they are listed."
      zh: "你能选择最少一种策略，策略执行顺序是从上到下"

    ASG_TERMINATION_MSG_DRAG:
      en: "Drag to sort policy"
      zh: "拖拽以便调整顺序"

    ASG_TERMINATION_POLICY_OLDEST:
      en: "OldestInstance"
      zh: "最旧的实例"

    ASG_TERMINATION_POLICY_NEWEST:
      en: "NewestInstance"
      zh: "最新的实例"

    ASG_TERMINATION_POLICY_OLDEST_LAUNCH:
      en: "OldestLaunchConfiguration"
      zh: "最旧的LaunchConfiguration"

    ASG_TERMINATION_POLICY_CLOSEST:
      en: "ClosestToNextInstanceHour"
      zh: "最近下一个实力时钟"

    ASG_ADD_POLICY_TITLE_ADD:
      en: "Add"
      zh: "添加"

    ASG_ADD_POLICY_TITLE_EDIT:
      en: "Edit"
      zh: "编辑"

    ASG_ADD_POLICY_TITLE_CONTENT:
      en: "Scaling Policy"
      zh: "扩展策略"

    ASG_ADD_POLICY_ALARM:
      en: "Alarm"
      zh: "警报"

    ASG_ADD_POLICY_WHEN:
      en: "When"
      zh: "当"

    ASG_ADD_POLICY_IS:
      en: "is"
      zh: "是"

    ASG_ADD_POLICY_FOR:
      en: "for"
      zh: "持续"

    ASG_ADD_POLICY_PERIOD:
      en: "periods of"
      zh: "周期"

    ASG_ADD_POLICY_SECONDS:
      en: "minutes, enter ALARM state."
      zh: "分时，进入警报状态"

    ASG_ADD_POLICY_START_SCALING:
      en: "Start scaling activity when in"
      zh: "执行扩展活动，当处于"

    ASG_ADD_POLICY_STATE:
      en: "state."
      zh: "状态"

    ASG_ADD_POLICY_SCALING_ACTIVITY:
      en: "Scaling Activity"
      zh: "扩展活动"

    ASG_ADD_POLICY_ADJUSTMENT:
      en: "Adjust number of instances by"
      zh: "通过以下方式调整"

    ASG_ADD_POLICY_ADJUSTMENT_OF:
      en: "of"
      zh: "数量"

    ASG_ADD_POLICY_ADJUSTMENT_CHANGE:
      en: "Change in Capacity"
      zh: ""

    ASG_ADD_POLICY_ADJUSTMENT_EXACT:
      en: "Exact Capacity"
      zh: ""

    ASG_ADD_POLICY_ADJUSTMENT_PERCENT:
      en: "Percent Change in Capacity"
      zh: ""

    ASG_ADD_POLICY_ADVANCED:
      en: "Advanced"
      zh: "高级"

    ASG_ADD_POLICY_ADVANCED_ALARM_OPTION:
      en: "Alarm Options"
      zh: "警报选项"

    ASG_ADD_POLICY_ADVANCED_STATISTIC:
      en: "Statistic"
      zh: "统计方式"

    ASG_ADD_POLICY_ADVANCED_STATISTIC_AVG:
      en: "Average"
      zh: "平均"

    ASG_ADD_POLICY_ADVANCED_STATISTIC_MIN:
      en: "Minimum"
      zh: "最小"

    ASG_ADD_POLICY_ADVANCED_STATISTIC_MAX:
      en: "Maximum"
      zh: "最大"

    ASG_ADD_POLICY_ADVANCED_STATISTIC_SAMPLE:
      en: "SampleCount"
      zh: "抽样计算"

    ASG_ADD_POLICY_ADVANCED_STATISTIC_SUM:
      en: "Sum"
      zh: "总计"

    ASG_ADD_POLICY_ADVANCED_SCALING_OPTION:
      en: "Scaling Options"
      zh: "扩展选项"

    ASG_ADD_POLICY_ADVANCED_COOLDOWN_PERIOD:
      en: "Cooldown Period"
      zh: "冷却周期"

    ASG_ADD_POLICY_ADVANCED_TIP_COOLDOWN_PERIOD:
      en: "The amount of time, in seconds, after a scaling activity completes before any further trigger-related scaling activities can start. If not specified, will use auto scaling group's default cooldown period."
      zh: "两个扩展活动之间的冷却时间(秒)，如果不提供，则使用AWS默认时间"

    ASG_ADD_POLICY_ADVANCED_MIN_ADJUST_STEP:
      en: "Minimum Adjust Step"
      zh: "最小调整数量"

    ASG_ADD_POLICY_ADVANCED_TIP_MIN_ADJUST_STEP:
      en: "Changes the DesiredCapacity of the Auto Scaling group by at least the specified number of instances."
      zh: "调整期望数量时的最小实例数量"

    ASG_TIP_CLICK_TO_SELECT:
      en: "Click to select"
      zh: ""

    ASG_TIP_YOU_CAN_ONLY_ADD_25_SCALING_POLICIES:
      en: "You can only add 25 scaling policies"
      zh: ""

    ASG_ARN:
      en: "Auto Scaling Group ARN"
      zh: ""

    LC_TITLE:
      en: "Launch Configuation"
      zh: "启动配置"

    LC_NAME:
      en: "Name"
      zh: "名称"

    LC_CREATE_TIME:
      en: "Create Time"
      zh: "创建时间"

    RT_ASSOCIATION:
      en: "This is an association of "
      zh: "这是一条路由表关联线从"

    RT_ASSOCIATION_TO:
      en: "to"
      zh: "到"

    RT_NAME:
      en: "Name"
      zh: "名称"

    RT_LBL_ROUTE:
      en: "Routes"
      zh: "路由规则"

    RT_LBL_MAIN_RT:
      en: "Main Route Table"
      zh: "主路由表"

    RT_SET_MAIN:
      en: "Set as Main Route Table"
      zh: "设置为主路由表"

    RT_TARGET:
      en: "Target"
      zh: "路由对象"

    RT_LOCAL:
      en: "local"
      zh: "本地"

    RT_DESTINATION:
      en: "Destination"
      zh: "数据包目的地"

    RT_ID:
      en: "Route ID"
      zh: "路由表ID"

    RT_VPC_ID:
      en: "VPC ID"
      zh: "VPC ID"

    RT_TIP_ACTIVE:
      en: "Active"
      zh: ""

    RT_TIP_BLACKHOLE:
      en: "Blackhole"
      zh: ""

    RT_TIP_PROPAGATED:
      en: "Propagated"
      zh: ""

    DBPG_RESMANAGER_FILTER:
      en: "Filter DB Engine by family name"
      zh: ""

    DBPG_SET_FAMILY:
      en: "Family"
      zh: ""

    DBPG_SET_NAME:
      en: "Parameter Group Name"
      zh: ""

    DBPG_CONFIRM_RESET_1:
      en: "Do you confirm to reset all parameters for "
      zh: ""

    DBPG_CONFIRM_RESET_2:
      en: " to their defaults?"
      zh: ""

    DBPG_APPLY_IMMEDIATELY_1:
      en: "Changes will apply "
      zh: ""

    DBPG_APPLY_IMMEDIATELY_2:
      en: "immediately"
      zh: ""

    DBPG_APPLY_IMMEDIATELY_3:
      en: "after rebooting"
      zh: ""

    DBPG_SET_DESC:
      en: "Description"
      zh: ""

    DBINSTANCE_TIT_DETAIL:
      en: "DB Instance Detail"
      zh: ""

    DBINSTANCE_APP_DBINSTANCE_ID:
      en: "DB Instance Identifier"
      zh: ""

    ENDPOINT:
      en: "Endpoint"
      zh: ""

    DBINSTANCE_STATUS:
      en: "Status"
      zh: ""

    ENGINE:
      en: "Engine"
      zh: ""

    DBINSTANCE_AUTO_UPGRADE:
      en: "Auto Minor Version Upgrade"
      zh: ""

    DBINSTANCE_CLASS:
      en: "DB Instance Class"
      zh: ""

    DBINSTANCE_IOPS:
      en: "IOPS"
      zh: ""

    DBINSTANCE_STORAGE:
      en: 'Storage'
      zh: ""

    DBINSTANCE_USERNAME:
      en: "Username"
      zh: ""

    DBINSTANCE_READ_REPLICAS:
      en: "Read Replicas"
      zh: ""

    DBINSTANCE_REPLICAS_SOURCE:
      en: "Read Replicas Source"
      zh: ""

    DBINSTANCE_DBCONFIG:
      en: "Database Config"
      zh: ""

    DBINSTANCE_NAME:
      en: "Database Name"
      zh: ""

    DBINSTANCE_PORT:
      en: "Database Port"
      zh: ""

    DBINSTANCE_OG:
      en: "Option Group"
      zh: ""

    DBINSTANCE_PG:
      en: "Parameter Group"
      zh: ""

    DBINSTANCE_NETWORK_AVAILABILITY:
      en: "Network & Availability"
      zh: ""

    DBINSTANCE_SUBNETGROUP:
      en: "Subnet Group"
      zh: ""

    DBINSTANCE_PREFERRED_ZONE:
      en: "Preferred Availability Zone"
      zh: ""

    DBINSTANCE_SECONDARY_ZONE:
      en: "Secondary Availability Zone"
      zh: ""

    DBINSTANCE_PUBLIC_ACCESS:
      en: "Publicly Accessible"
      zh: ""

    DBINSTANCE_LICENSE_MODEL:
      en: "License Model"
      zh: ""

    DBINSTANCE_DB_ENGINE_VERSION:
      en:"DB Engine Version"
      zh: ""

    DBINSTANCE_DB_INSTANCE_CLASS:
      en: "DB Instance Class"
      zh: ""

    DBINSTANCE_SELECT_WINDOW:
      en: "Select Window"
      zh: ""

    DBINSTANCE_NO_PREFERENCE:
      en: "No Preference"
      zh: ""

    DBINSTANCE_SOMETHING_ERROR:
      en: "Something Error."
      zh: ""

    DBINSTANCE_OPTION_GROUP:
      en: "Option Group"
      zh: ""

    DBINSTANCE_SUBNETGROUP_NOT_SETUP:
      en: "Subnet Group %s is not correctly set up yet. Assign %s to at lease 2 availability zones."
      zh: ""

    DBINSTANCE_BACKUP_MAINTENANCE:
      en: "Backup & Maintenance"
      zh: ""

    DBINSTANCE_AUTOBACKUP:
      en: "Automated Backups"
      zh: ""

    DBINSTANCE_LAST_RESTORE:
      en: "Lastest Restore Time"
      zh: ""

    DBINSTANCE_BACKUP_WINDOW:
      en: "Backup Window"
      zh: ""

    DBINSTANCE_MAINTENANCE_WINDOW:
      en: "Maintenance Window"
      zh: ""

    DBINSTANCE_SECURITY_GROUP:
      en: "Security Group"
      zh: ""

    DBINSTANCE_SUBNET_GROUP_NAME:
      en: "DB Subnet Group Name"
      zh: ""

    DBINSTANCE_SUBNET_GROUP_DESC:
      en: "DB Subnet Group Description"
      zh: ""

    DBINSTANCE_SUBNET_GROUP_STATUS:
      en: "Status"
      zh: ""

    DBINSTANCE_SUBNET_GROUP_MEMBERS:
      en: "Members"
      zh: ""

    DBINSTANCE_PROMOTE_CONFIRM_MAJOR:
      en: "The following steps show the general process for promoting a read replica to a Single-AZ DB instance."
      zh: ""

    DBINSTANCE_PROMOTE_CONFIRM_CONTENT_1:
      en: "Stop any transactions from being written to the read replica source DB instance, and then wait for all updates to be made to the read replica."
      zh: ""

    DBINSTANCE_PROMOTE_CONFIRM_CONTENT_2:
      en: "To be able to make changes to the read replica, you must the set the read_only parameter to 0 in the DB parameter group for the read replica."
      zh: ""

    DBINSTANCE_PROMOTE_CONFIRM_CONTENT_3:
      en: "Perform all needed DDL operations, such as creating indexes, on the read replica."
      zh: ""

    DBINSTANCE_PROMOTE_CONFIRM_CONTENT_4:
      en: "Promote the read replica."
      zh: ""

    DBINSTANCE_PROMOTE_NOTE:
      en: "Note"
      zh: ""

    DBINSTANCE_PROMOTE_NOTE_CONTENT:
      en: "The promotion process takes a few minutes to complete. When you promote a read replica, replication is stopped and the read replica is rebooted. When the reboot is complete, the read replica is available as a Single-AZ DB instance."
      zh: ""

    DBINSTANCE_PROMOTE_LINK_TEXT:
      en: "Read AWS Document"
      zh: ""

    DBINSTANCE_NOT_AVAILABLE:
      en: "This DB instance is not in availabe status. To apply modification made for this instance, wait for its status to be available."
      zh: ""

    DBINSTANCE_READ_REPLICA:
      en: "Promote Read Replica"
      zh: ""

    DBINSTANCE_CANCEL_PROMOTE:
      en: "Cancel Promote"
      zh: ''

    DBINSTANCE_APPLY_IMMEDIATELY:
      en: "Apply Immediately"
      zh: ""

    DBINSTANCE_DETAILS:
      en: "DB Instance Details"
      zh: ""

    DBINSTANCE_APPLY_IMMEDIATELY_LINK_TOOLTIP:
      en: "Click to read AWS documentation on modifying DB instance using Apply Immediately."
      zh: ""

    DBINSTANCE_MASTER_DB_INSTANCE:
      en: "Master DB Instance"
      zh: ""



    DBINSTANCE_DBSNAPSHOT_ID:
      en: "DB Snapshot ID"
      zh: ""

    DBINSTANCE_DBSNAPSHOT_SIZE:
      en: "DB Snapshot Size"
      zh: ""

    DBINSTANCE_PENDING_APPLY:
      en: "(Pending Apply)"
      zh: ""

    DBINSTANCE_NAME:
      en: "DB Instance Name"
      zh: ""

    DBINSTANCE_AUTO_MINOR_VERSION_UPDATE:
      en: "Auto Minor Version Update"
      zh: ""

    DBINSTANCE_ALLOCATED_STORAGE:
      en: "Allocated Storage"
      zh: ""

    DBINSTANCE_SCALLING_NOT_SUPPORT:
      en: "Scalling storage after launch a DB Instance is currently not supported for SQL Server."
      zh: ""

    DBINSTANCE_CURRENT_ALLOCATED_STORAGE:
      en: "Current Allocated Storage: "
      zh: ""

    DBINSTANCE_USE_PROVISIONED_IOPS:
      en: "Use Provisioned IOPS"
      zh: ""

    DBINSTANCE_PROVISIONED_IOPS:
      en: "Provisioned IOPS"
      zh: ""

    DBINSTANCE_IOPS_AVAILABILITY_IMPACT:
      en: "When you initiate a storage type conversion between IOPS and standard storage, your DB Instance will have an availability impact for a few minutes."
      zh: ""

    DBINSTANCE_MASTER_USERNAME:
      en: "Master Username"
      zh: ""

    DBINSTANCE_MASTER_PASSWORD:
      en: "Master Password"
      zh: ""

    DBINSTANCE_DATABASE_CONFIG:
      en: "Database Config"
      zh: ""

    DBINSTANCE_NOT_READY:
      en: "Not Ready"
      zh: ""

    DBINSTANCE_DATABASE_NAME:
      en: "Database Name"
      zh: ""

    DBINSTANCE_DATABASE_PORT:
      en: "Database Port"
      zh: ""

    DBINSTANCE_CHARACTER_SET_NAME:
      en: "Character Set Name"
      zh: ""

    DBINSTANCE_NETWORK_AZ_DEPLOYMENT:
      en: "Network & AZ Deployment"
      zh: ""

    DBINSTANCE_PUBLICLY_ACCESSIBLE:
      en: "Publicly Accessible"
      zh: ""

    DBINSTANCE_BACKUP_OPTION:
      en: 'Backup Options'
      zh: ""

    DBINSTANCE_REPLICA_MUST_ENABLE_AUTOMATIC_BACKUPS:
      en: "DB instance serving as replication source must enable automatic backups"
      zh: ""

    DBINSTANCE_ENABLE_AUTOMATIC_BACKUP:
      en: "Enable Automatic Backups"
      zh: ""

    DBINSTANCE_BACKUP_RETENTION_PERIOD:
      en: "Backup Retantion Period"
      zh: ""

    DBINSTANCE_BACK_RETANTION_PERIOD_DAY:
      en: "day(s)"
      zh: ""

    DBINSTANCE_BACKUP_WINDOW:
      en: "Backup Window"
      zh: ""

    DBINSTANCE_NO_PREFERENCE:
      en: "No Preference"
      zh: ""

    DBINSTANCE_SELECT_WINDOW:
      en: "Select Window"
      zh: ""

    DBINSTANCE_START_TIME:
      en: "Start Time:"
      zh: ""

    DBINSTANCE_DURATION:
      en: "Duration: "
      zh: ""

    DBINSTANCE_BACKUP_DURATION_HOUR:
      en: "hour(s)"
      zh: ""

    DBINSTANCE_CURRENT_BACKUP_WINDOW:
      en: "Current Backup Window: "
      zh: ""

    DBINSTANCE_MAINTENANCE_OPTION:
      en: "Maintenance Options"
      zh: ""

    DBINSTANCE_MAINTENANCE_WINDOW:
      en: "Maintenance Window"
      zh: ""

    DBINSTANCE_MAINTENANCE_START_DAY:
      en: "Start Day"
      zh: ""


    WEEKDAY_MONDAY:
      en: "Monday"
      zh: ""

    WEEKDAY_TUESDAY:
      en: "Tuesday"
      zh: ""

    WEEKDAY_WEDNESDAY:
      en: "Wednesday"
      zh: ""

    WEEKDAY_THURSDAY:
      en: "Thursday"
      zh: ""

    WEEKDAY_FRIDAY:
      en: "Friday"
      zh: ""
    WEEKDAY_SATURDAY:
      en: "Saturday"
      zh: ""

    WEEKDAY_SUNDAY:
      en: "Sunday"
      zh: ""

    SELECT_SNS_TOPIC:
      en: "Select SNS Topic"
      zh: ""

    ASG_POLICY_CPU:
      en: "CPU Utillization"
      zh: ""

    ASG_POLICY_DISC_READS:
      en: "Disk Reads"
      zh: ""

    ASG_POLICY_DISK_READ_OPERATIONS:
      en: "Disk Read Operations"
      zh: ""

    ASG_POLICY_DISK_WRITES:
      en: "Disk Writes"
      zh: ""

    ASG_POLICY_DISK_WRITE_OPERATIONS:
      en: "Disk Write Operations"
      zh: ""

    ASG_POLICY_NETWORK_IN:
      en: "Network In"
      zh: ""

    ASG_POLICY_NETWORK_OUT:
      en: "Network Out"
      zh: ""

    ASG_POLICY_STATUS_CHECK_FAILED_ANY:
      en: "Status Check Failed (Any)"
      zh: ""

    ASG_POLICY_STATUS_CHECK_FAILED_INSTANCE:
      en: "Status Check Failed (Instance)"
      zh: ""

    ASG_POLICY_STATUS_CHECK_FAILED_SYSTEM:
      en: "Status Check Failed (System)"
      zh: ""

    ASG_ADJUST_TOOLTIP_CHANGE:
      en: "Increase or decrease existing capacity by integer you input here. A positive value adds to the current capacity and a negative value removes from the current capacity."
      zh: ""

    ASG_ADJUST_TOOLTIP_EXACT:
      en: "Change the current capacity of your Auto Scaling group to the exact value specified."
      zh: ""

    ASG_ADJUST_TOOLTIP_PERCENT:
      en: "Increase or decrease the desired capacity by a percentage of the desired capacity. A positive value adds to the current capacity and a negative value removes from the current capacity"
      zh: ""

    AZ_CANNOT_EDIT_EXISTING_AZ:
      en: "Cannot edit existing availability zone. However, newly created availability zone is editable."
      zh: ""

    CGW_IP_VALIDATE_REQUIRED:
      en: "IP Address is required."
      zh: ""

    CGW_IP_VALIDATE_REQUIRED_DESC:
      en: "Please provide a IP Address of this Customer Gateway."
      zh: ""

    CGW_IP_VALIDATE_INVALID:
      en: "%s  is not a valid IP Address."
      zh: ""

    CGW_IP_VALIDATE_INVALID_DESC:
      en: "Please provide a valid IP Address. For example, 192.168.1.1."
      zh: ""

    CGW_IP_VALIDATE_INVALID_CUSTOM:
      en: "IP Address %s is invalid for customer gateway."
      zh: ""

    CGW_IP_VALIDATE_INVALID_CUSTOM_DESC:
      en: "The address must be static and can't be behind a device performing network address translation (NAT)."
      zh: ""

    CGW_REMOVE_CUSTOM_GATEWAY:
      en: "Remove Customer Gateway"
      zh: ""

    CONNECTION_ATTACHMENT_OF:
      en: "This is an attachment of %s to %s"
      zh: ""

    CONNECTION_SUBNET_ASSO_PLACEMENT:
      en: "A Virtual Network Interface is placed in %s for %s to allow traffic be routed to this availability zone."
      zh: ""

    ENI_ATTACHMENT_NAME:
      en: "Instance-ENI Attachment"
      zh: ""

    ELB_SUBNET_ASSO_NAME:
      en: "Load Balencer-Subnet Association"
      zh: ""

    ELB_INTERNET_FACING:
      en: "Internet Facing"
      zh: ""

    ELB_INTERNAL:
      en: "Internal"
      zh: ""

    ELB_ENABLE_CROSS_ZONE_BALANCING:
      en: "Enable cross-zone load balancing"
      zh: ""

    ELB_CONNECTION_DRAINING:
      en: "Enable Connection Draining"
      zh: ""

    ELB_CONNECTION_TIMEOUT:
      en: "Timeout"
      zh: ""

    ELB_CONNECTION_SECONDS:
      en: "Seconds"
      zh: ""

    ELB_LOAD_BALENCER_PROTOCOL:
      en: "Load Balancer Protocal"
      zh: ""

    ELB_INSTANCE_PROTOCOL:
      en: "Instance Protocol"
      zh: ""

    ENI_NETWORK_INTERFACE_DETAIL:
      en: "Network Interface Details"
      zh: ""

    ENI_NETWORK_INTERFACE_SUMMARY:
      en: "Network Interface Summary"
      zh: ""

    ENI_NETWORK_INTERFACE_GROUP_MEMBERS:
      en: "Network Interface Group Members"
      zh: ""

    ENI_CREATE_AFTER_APPLYING_UPDATES:
      en: "Create after applying updates"
      zh: ""

    ENI_DELETE_AFTER_APPLYING_UPDATES:
      en: "Delete after applying updates"
      zh: ""

    INSTANCE_ROOT_DEVICE:
      en: "Root Device"
      zh: ""

    INSTANCE_WATCH_LINK_TEXT:
      en: "Amazon Cloud Watch Product Page"
      zh: ""

    INSTANCE_USERDATA_DISABLED_TO_INSTALL_VISUALOPS:
      en: "User Data is disabled to allow installing OpsAgent for VisualOps."
      zh: ""

    INSTANCE_VIEW_AGENT_USER_DATA_URL_TEXT:
      en: "View content"
      zh: ""

    INSTANCE_EBS_OPTIMIZED:
      en: "EBS Optimized"
      zh: ""

    INSTANCE_IOPS:
      en: "IOPS"
      zh: ""

    LC_DELETE_CUSTUME_KEY_PAIR_CONFIRM:
      en: "<p class='modal-text-major'>Are you sure to delete %s?</p><p class='modal-text-minor'>Resources using this key pair will change automatically to use DefaultKP.</p>"
      zh: ""

    MISSING_RESOURCE_UNAVAILABLE:
      en: "Resource Unavailable"
      zh: ""

    RTB_ALLOW_PROPAGATION:
      en: "Allow Propagation"
      zh: ""

    RTB_CIDR_BLOCK_REQUIRED:
      en: "CIDR Block is required"
      zh: ""

    RTB_CIDR_BLOCK_REQUIRED_DESC:
      en: "Please provide a IP ranges for this route."
      zh: ""

    RTB_CIDR_BLOCK_INVALID:
      en: "%s is not a valid form of CIDR Block"
      zh: ""

    RTB_CIDR_BLOCK_INVALID_DESC:
      en: "Please provide a valid IP range. For example, 10.0.0.1/24."
      zh: ""

    RTB_CIDR_BLOCK_CONFLICTS:
      en: "%s conflicts with other route."
      zh: ""

    RTB_CIDR_BLOCK_CONFLICTS_DESC:
      en: "Please choose a CIDR block not conflicting with existing route."
      zh: ""

    RTB_CIDR_BLOCK_CONFLICTS_LOCAL:
      en: "%s conflicts with local route."
      zh: ""

    RTB_CIDR_BLOCK_CONFLICTS_LOCAL_DESC:
      en: "Please choose a CIDR block not conflicting with local route."
      zh: ""

    SG_INSTANCE_SUMMARY:
      en: "Instance Summary"
      zh: ""

    SG_SERVER_GROUP_MEMBERS:
      en: "Server Group Members"
      zh: ""

    SG_LAUNCH_AFTER_APPLYING_UPDATES:
      en: "Launch after applying updates"
      zh: ""

    SG_TERMINATE_AFTER_APPLYING_UPDATE:
      en: "Terminate after applying updates"
      zh: ""

    SG_UPDATE_INSTANCE_TYPE_DISABLED_FOR_INSTANCE_STORE:
      en: "Updating instance type is disabled for instances using instance store for root device."
      zh: ""

    SG_AMAZON_CLOUD_WATCH_PRODUCT_PAGE:
      en: "Amazon Cloud Watch Product Page"
      zh: ""

    SGLIST_DELETE_SG_CONFIRM_TITLE:
      en: "Are you sure you want to delete %s ?"
      zh: ""

    SGLIST_DELETE_SG_CONFIRM_DESC:
      en: "The firewall settings of %s's member will be affected. Member only has this security group will be using DefaultSG."
      zh: ""

    SGLIST_DELETE_SG_TITLE:
      en: "Delete Security Group"
      zh: ""

    SGRULE_SELECTED_CONNECTION_REFLECTS_FOLLOWING_SGR:
      en: "The selected connection reflects following security group rule(s);"
      zh: ""

    STACK_SNS_SUBSCRIPTION:
      en: " SNS Subscription"
      zh: ""

    STACK_SNS_PROTOCOL:
      en: "Protocol"
      zh: ""

    STACK_SNS_PROTOCOL_HTTPS:
      en: "HTTPS"
      zh: ""

    STACK_SNS_PROTOCOL_HTTP:
      en: "HTTP"
      zh: ""

    STACK_SNS_PROTOCOL_EMAIL:
      en: "Email"
      zh: ""

    STACK_SNS_PROTOCOL_EMAIL_JSON:
      en: "Email - JSON"
      zh: ""

    STACK_SNS_PROTOCOL_SMS:
      en: "SMS"
      zh: ""

    STACK_SNS_PROTOCOL_APPLICATION:
      en: "Application"
      zh: ""

    STACK_SNS_PROTOCOL_AMAZON_SQS:
      en: "Amazon SQS"
      zh: ""

    STACK_DELETE_NETWORK_ACL_TITLE:
      en: "Delete Network ACL"
      zh: ""

    STACK_DELETE_NETWORK_ACL_CONTENT:
      en: "Are you sure you want to delete %s"
      zh: ""

    STACK_DELETE_NETWORK_ACL_DESC:
      en: "Subnets associated with %s will use DefaultACL."
      zh: ""

    STATICSUB_VALIDATION_AMI_INFO_MISSING:
      en: "Ami info is missing, please reopen stack and try again."
      zh: ""

    STATICSUB_VALIDATION_AMI_TYPE_NOT_SUPPORT:
      en: "Changing AMI platform is not supported. To use a %s AMI, please create a new instance instead."
      zh: ""

    STATICSUB_VALIDATION_AMI_INSTANCETYPE_NOT_VALID:
      en: "%s does not support previousely used instance type %s. Please change another AMI."
      zh: ""

    SUBNET_CIDR_VALIDATION_REQUIRED:
      en: "CIDR block is required."
      zh: ""

    SUBNET_CIDR_VALIDATION_REQUIRED_DESC:
      en: "Please provide a subset of IP ranges of this VPC."
      zh: ""

    SUBNET_CIDR_VALIDATION_INVALID:
      en: "%s is not a valid form of CIDR block."
      zh: ""

    SUBNET_CIDR_VALIDATION_INVALID_DESC:
      en: "Please provide a valid IP range. For example, 10.0.0.1/24."
      zh: ""

    SUBNET_GROUP_DETAILS:
      en: "Subnet Groups Details"
      zh: ""

    SUBNET_GROUP_NAME:
      en: "Subnet Group Name"
      zh: ""

    SUBNET_GROUP_DESCRIPTION:
      en: "Subnet Group Description"
      zh: ""

    SUBNET_GROUP_MEMBER:
      en: "Member"
      zh: ""

    VOLUME_DISABLE_IOPS_TOOLTIP:
      en: "Volume size must be at least 10 GB to use Provisioned IOPS volume type."
      zh: ""

    VPC_SELECTING_DEDICATED_DESC:
      en: "Selecting 'Dedicated' forces all instances launched into this VPC to run on single-tenant hardware."
      zh: ""

    VPC_SELECTING_DEDICATED_LINK_TEXT:
      en: "Additional changes will apply."
      zh: ""

    VPN_STACK_STATIC:
      en: "Static"
      zh: ""

    VPN_STACK_DYNAMIC:
      en: "Dynamic"
      zh: ""

    VPN_GATEWAY_VPN_DYNAMIC:
      en: " Since the Customer Gateway this VPN is connected to has dynamic routing enabled no configuration is necessary."
      zh: ""

    VPN_BLUR_CIDR_REQUIRED:
      en: "CIDR block is required."
      zh: ""

    VPN_BLUR_CIDR_REQUIRED_DESC:
      en: "Please provide a IP ranges for this IP Prefix. "
      zh: ""

    VPN_BLUR_CIDR_NOT_VALID_IP:
      en: "%s is not a valid form of CIDR block."
      zh: ""

    VPN_BLUR_CIDR_NOT_VALID_IP_DESC:
      en: "Please provide a valid IP range. For example, 10.0.0.1/24."
      zh: ""

    VPN_BLUR_CIDR_CONFLICTS_IP:
      en: "%s conflicts with other IP Prefix."
      zh: ""

    VPN_BLUR_CIDR_CONFLICTS_IP_DESC:
      en: "Please choose a CIDR block not conflicting with existing IP Prefix."
      zh: ""

    VPN_REMOVE_CONNECTION:
      en: "Remove Connection"
      zh: ""

    RDS_LBL_REFRESH:
      en: "Refresh"
      zh: ""

    RDS_LBL_CLOSE:
      en: "Close"
      zh: ""

    LBL_CLOSE:
      en: "Close"
      zh: ""

    RDS_NO_RECORDS_FOUND:
      en: "No records found."
      zh: ""






    ###
    COMPONENT:
    ###
    SNAPSHOT_SET_NAME:
        en: "Snapshot Name"
        zh: ""

    SNAPSHOT_SET_NAME_TIP:
      en: "Enter the name of the snapshot that you will create."
      zh: ""

    SNAPSHOT_SOURCE_SNAPSHOT:
      en: "Source Snapshot"
      zh: ""

    SNAPSHOT_SET_NEW_NAME:
      en: "New Snapshot Name"
      zh: ""

    SNAPSHOT_DESTINATION_REGION:
      en: "Destination Region"
      zh: ""

    SNAPSHOT_SET_VOLUME:
      en: "Volume"
      zh: ""

    SNAPSHOT_SET_INSTANCE:
      en: "Instance"
      zh: ""

    INSTANCE_SNAPSHOT_SELECT:
      en: "Select DB instance from which to create snapshot"
      zh: ""

    SNAPSHOT_SET_DESC:
      en: "Description"
      zh: ""

    VPC_TIP_ENTER_THE_NEW_SNAPSHOT_NAME:
      en: "Please fill with the name of the new snapshot you will create."
      zh: ""

    SNAPSHOT_SET_DESC_TIP:
      en: "Fill in the Description"
      zh: ""

    DB_SNAPSHOT_DELETE_1:
      en: "Confirm to delete "
      zh: ""

    DB_SNAPSHOT_DELETE_2:
      en: " selected "
      zh: ""

    DB_SNAPSHOT_DELETE_3:
      en: " Snapshots"
      zh: ""

    DB_SNAPSHOT_EMPTY:
      en: "There are no available instance here."
      zh: ""

    DB_SNAPSHOT_ID:
      en: "DB Snapshot ID"
      zh: ""

    DB_SNAPSHOT_VPC_ID:
      en: "Vpc ID"
      zh: ""

    DB_SNAPSHOT_ENGINE:
      en: "DB Engine"
      zh: ""

    DB_SNAPSHOT_LICENSE_MODEL:
      en: "License Model"
      zh: ""

    DB_SNAPSHOT_STATUS:
      en: "Status"
      zh: ""

    DB_SNAPSHOT_STORAGE:
      en: "DB Storage"
      zh: ""

    DB_SNAPSHOT_CREATE_TIME:
      en: "Snapshot Creation Time"
      zh: ""

    DB_SNAPSHOT_SOURCE_REGION:
      en: "Source Region"
      zh: ""

    DB_SNAPSHOT_INSTANCE_NAME:
      en: "DB Instance Name"
      zh: ""

    DB_SNAPSHOT_TYPE:
      en: "Snapshot Type"
      zh: ""

    DB_SNAPSHOT_ENGINE_VERSION:
      en: "DB Engine Version"
      zh: ""

    DB_SNAPSHOT_MASTER_USERNAME:
      en: "Master Username"
      zh: ""

    OPTION_GROUP_NAME:
      en: "Option Group Name"
      zh: ""

    DB_SNAPSHOT_INSTANCE_CREATE_TIME:
      en: "Instance Creation Name"
      zh: ""

    DB_SNAPSHOT_ACCOUNT_NUMBER_INVALID:
      en: "Please update your Account Number with number"
      zh: ""

    LBL_DELETING:
      en: "Deleting..."
      zh: ""

    LBL_DELETE:
      en: "Delete"
      zh: ""

    LBL_FILTER:
      en: "Filter: "
      zh: ""

    LBL_SORT_BY:
      en: "Sort by: "
      zh: ""

    LBL_CANCEL:
      en: "Cancel"
      zh: "取消"

    LBL_CREATING:
      en: "Creating..."
      zh: ""

    LBL_DOWNLOAD:
      en: "Download"
      zh: ""

    LBL_DOWNLOADING:
      en: "Downloading..."
      zh: ""

    LBL_VIEW:
      en: "View"
      zh: ""

    LBL_DUPLICATE:
      en: "Duplicate"
      zh: ""

    LBL_DUPLICATING:
      en: "Duplicating..."
      zh: ""

    LBL_RESET:
      en: "Reset"
      zh: ""

    LBL_RESETTING:
      en: "Resetting..."
      zh: ""

    LBL_CREATE:
      en: "Create"
      zh: ""

    LBL_IMPORT:
      en: "Import"
      zh: ""

    LBL_SUCCESS:
      en: "Success"
      zh: ""

    LBL_IMPORTING:
      en: "Importing..."
      zh: ""

    LBL_DISABLED:
      en: "Disabled"
      zh: ""

    LBL_ENABLED:
      en: "Enabled"
      zh: ""

    LBL_PARAMETER_NAME:
      en: "Parameter Name"
      zh: ""

    LBL_ISMODIFIABLE:
      en: "Is Modifiable"
      zh: ""

    LBL_APPLY_METHOD:
      en: "Apply Method"
      zh: ""

    LBL_SOURCE:
      en: "Source"
      zh: ""

    LBL_ORIGINAL_VALUE:
      en: "Original Value"
      zh: ""

    LBL_EDIT_VALUE:
      en: "Edit Value"
      zh: ""

    LBL_PARAMETER_VALUE_REFERENCE:
      en: "Parameter Value Reference"
      zh: ""

    LBL_BACK_TO_EDITING:
      en: "Back to Editing"
      zh: ""

    LBL_APPLY_CHANGES:
      en: "Apply Changes"
      zh: "应用"

    LBL_REVIEW_CHANGES_SAVE:
      en: "Review Changes & Save"
      zh: ""

    LBL_APPLYING:
      en: "Applying..."
      zh: "应用中..."

    DELETE_SNAPSHOT_1:
      en: "Confirm to delete "
      zh: ""

    DELETE_SNAPSHOT_2:
      en: "selected "
      zh: ""

    DELETE_SNAPSHOT_3:
      en: " Snapshot(s) "
      zh: ""




    OPTION_SETTING:
      en: "Option Setting"
      zh: ""

    VALUE:
      en: "Value"
      zh: ""

    ALLOWED_VALUES:
      en: "Allowed Values"
      zh: ""

    OPTION_GROUP_DESCRIPTION:
      en: "Option Group Description"
      zh: ""

    ENGINE_VERSION:
      en: "Engine Version"
      zh: ""

    PERSISTENT:
      en: "PERSISTENT"
      zh: ""

    PERMENANT:
      en: "PERMENANT"
      zh: ""

    OPTION:
      en: "Option"
      zh: ""

    HIDE_DETAILS:
      en: "Hide details"
      zh: ""

    PORT_COLON:
      en: "Port:"
      zh: ""

    SECURITY_GROUP_COLON:
      en: "Security Group:"
      zh: ""

    SETTING:
      en: "Setting"
      zh: ""

    NO_OPTION_GROUP_PERIOD:
      en: "No Option Group."
      zh: ""

    CREATE_OPTION_GROUP:
      en: "Create Option Group"
      zh: ""

    SHOW_DETAILS:
      en: "Show details"
      zh: ""

    SECURITY_GROUP:
      en: "Security Group"
      zh: ""

    SAVE_OPTION:
      en: "Save Option"
      zh: ""

    NAME:
      en: "Name"
      zh: ""

    SAVE:
      en: "Save"
      zh: ""

    DESCRIPTION:
      en: "Description"
      zh: "描述"

    CONFIRM_TO_DELETE_THIS_OPTION_GROUP_QUESTION:
      en: "Confirm to delete this option group?"
      zh: ""

    STATIC_SUB_CHANGE_AMI:
      en: "Change AMI"
      zh: ""

    DRAG_IMAGE_DROP_TO_CHANGE:
      en: "Drag image from Resource Panel and drop below to change AMI."
      zh: ""

    DRAG_IMAGE_DROP_HERE:
      en: "Drop AMI Here"
      zh: ""

    CONFIRM_CHANGE_AMI:
      en: "Confirm Change AMI"
      zh: ""

    ROLLING_BACK:
      en: "Rolling back..."
      zh: ""

    ALLOW:
      en: "Allow"
      zh: ""

    INITIATE_TRAFFIC_TO:
      en: "initiate traffic to"
      zh: ""

    ACCEPT_TRAFFIC_FROM:
      en: "accept traffic from"
      zh: ""

    HAVE_2WAY_TRAFFIC_WITH:
      en: "have 2-way traffic with"
      zh: ""

    DESTINATION_PROTOCOL:
      en: "Destination Protocol"
      zh: ""

    PORT_RANGE_COLON:
      en: "Port Range: "
      zh: ""

    ADD_RULE:
      en: "Add Rule"
      zh: ""

    RULE_REF_ITS_OWN_SG:
      en: "You have created a rule referencing its own security group. This rule will not be visualized as the blue connection lines."
      zh: ""

    CREATE_ANOTHER_RULE:
      en: "Create another rule"
      zh: ""

    RELATED_RULE:
      en: "Related Rule"
      zh: ""

    CREATE_SECURITY_GROUP_RULE:
      en: "Create Security Group Rule"
      zh: ""

    NONE:
      en: "None"
      zh: ""

    SUBSCRIPTIONS:
      en: "Subscriptions"
      zh: ""

    SELECT_TOPIC:
      en: "Select Topic"
      zh: ""

    NEW_TOPIC:
      en: "New Topic"
      zh: ""

    TOPIC_NAME:
      en: "Topic Name"
      zh: ""

    DISPLAY_NAME:
      en: "Display Name"
      zh: ""

    CREATING_3PERIOD:
      en: "Creating..."
      zh: ""

    DELETING_3PERIOD:
      en: "Deleting..."
      zh: ""

    SUBSCRIPTION_ARN:
      en: "Subscription ARN"
      zh: ""

    CREATE_SNS_TOPIC:
      en: "Create SNS Topic"
      zh: ""


    NO_SNS_TOPIC_IN_XXX:
      en: "No SNS Topic in %s."
      zh: ""

    UPLOAD:
      en: "Upload"
      zh: ""

    UPLOAD_3PERIOD:
      en: "Upload..."
      zh: ""

    UPDATE:
      en: "Update"
      zh: ""

    UPDATING_3PERIOD:
      en: "Updating..."
      zh: ""

    SERVER_CERTIFICATE_ID:
      en: "Server Certificate ID"
      zh: ""

    SERVER_CERTIFICATE_ARN:
      en: "Server Certificate ARN"
      zh: ""

    EXPIRATION_DATE:
      en: "Expiration Date"
      zh: ""

    PATH:
      en: "Path"
      zh: ""

    NO_SSL_CERTIFICATE:
      en: "No SSL Certificate."
      zh: ""

    CREATE_SSL_CERTIFICATE:
      en: "Create SSL Certificate"
      zh: ""

    NO_FAILED_ITEM_PERIOD:
      en: "No failed item."
      zh: ""

    ALL_STATES_ARE_PENDING_PERIOLD:
      en: "All states are pending."
      zh: ""

    A_MESSAGE_WILL_SHOW_HERE:
      en: "A message will show here when a state succeeds or fails."
      zh: ""

    XXX_STATES_HAS_UPDATED_STATUS:
      en: "%s states has updated status."
      zh: ""

    FAILED_STATE:
      en: "Failed State"
      zh: ""

    EXPAND:
      en: "Expand"
      zh: ""











