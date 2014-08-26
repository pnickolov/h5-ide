###
#**********************************************************
#* Filename: lang-source.coffee
#* Creator: Tim
#* Description: I18N
#* Date: 20131015

#* Naming Rule

  #*# SYNOPSIS
  ModuleName_Type_Description

  #*# DESCRIPTION
    Module Name
      RES     : resource panel
      PROP    : property

      CVS     : canvas
      TOOL    : toolbar
      HEAD    : header
      NAV     : navigation
      DASH    : dashboard
      MSG     : notification
      TIT     : title
      LBL     : label
      POP     : popup
      TIP     : tooltip
      BTN     : button
      PARSLEY : parsley

    Resource Type Reference
      CONST.AWS_RESOURCE_SHORT_TYPE


# **********************************************************
# (c) Copyright 2013 Madeiracloud  All Rights Reserved
# **********************************************************
###

module.exports =


  ide:

    PARSLEY_MUST_BE_A_VALID_FORMAT_OF_NUMBER:
      en: "Must be a valid format of number."
      zh: ""

    PARSLEY_THE_PROTOCOL_NUMBER_RANGE_MUST_BE_0_255:
      en: "The protocol number range must be 0-255."
      zh: ""

    PARSLEY_MUST_BE_A_VALID_FORMAT_OF_PORT_RANGE:
      en: "Must be a valid format of port range."
      zh: ""

    PARSLEY_PORT_RANGE_BETWEEN_0_65535:
      en: "Port range needs to be a number or a range of numbers between 0 and 65535."
      zh: ""

    PARSLEY_VALID_RULE_NUMBER_1_TO_32767:
      en: "Valid rule number must be between 1 to 32767."
      zh: ""

    PARSLEY_RULE_NUMBER_100_HAS_EXISTED:
      en: "The DefaultACL's Rule Number 100 has existed."
      zh: ""

    PARSLEY_RULENUMBER_ALREADY_EXISTS:
      en: "Rule %s already exists."
      zh: ""

    PARSLEY_MUST_BE_CIDR_BLOCK:
      en: "Must be a valid form of CIDR block."
      zh: ""

    PARSLEY_MAX_VALUE_86400:
      en: "Max value: 86400"
      zh: ""

    PARSLEY_DUPLICATED_POLICY_NAME:
      en: "Duplicated policy name in this autoscaling group"
      zh: ""

    PARSLEY_ASG_SIZE_MUST_BE_EQUAL_OR_GREATER_THAN_1:
      en: "ASG size must be equal or greater than 1"
      zh: ""

    PARSLEY_MINIMUM_SIZE_MUST_BE_LESSTHAN_MAXIMUM_SIZE:
      en: "Minimum Size must be <= Maximum Size."
      zh: ""

    PARSLEY_MAXIMUM_SIZE_MUST_BE_MORETHAN_MINIMUM_SIZE:
      en: "Maximum Size must be >= Minimum Size."
      zh: ""

    PARSLEY_VALUE_MUST_BE_LESSTHAN_VAR:
      en: "This value should be < %s"
      zh: ""

    PARSLEY_VALUE_MUST_BE_GREATERTHAN_VAR:
      en: "This value should be > %s"
      zh: ""

    PARSLEY_VALUE_MUST_IN_ALLOW_SCOPE:
      en: "This value should be >= %s and <= %s"
      zh: ""

    PARSLEY_DESIRED_CAPACITY_EQUAL_OR_GREATER_1:
      en: "Desired Capacity must be equal or greater than 1"
      zh: ""

    PARSLEY_DESIRED_CAPACITY_IN_ALLOW_SCOPE:
      en: "Desired Capacity must be >= Minimal Size and <= Maximum Size"
      zh: ""

    PARSLEY_THIS_VALUE_SHOULD_BE_A_VALID_TYPE_NAME:
      en: "This value should be a valid %s name."
      zh: ""

    PARSLEY_TYPE_NAME_CONFLICT:
      en: "%s name \" %s \" is already in using. Please use another one."
      zh: ""

    PARSLEY_RESOURCE_NAME_ELBSG_RESERVED:
      en: "Resource name starting with \"elbsg-\" is reserved."
      zh: ""

    PARSLEY_MUST_BE_BETWEEN_1_AND_65534:
      en: "Must be between 1 and 65534"
      zh: ""

    PARSLEY_ASN_NUMBER_7224_RESERVED:
      en: "ASN number 7224 is reserved in Virginia"
      zh: ""

    PARSLEY_ASN_NUMBER_9059_RESERVED_IN_IRELAND:
      en: "ASN number 9059 is reserved in Ireland"
      zh: ""

    PARSLEY_LOAD_BALANCER_PORT_MUST_BE_SOME_PROT:
      en: "Load Balancer Port must be either 25,80,443 or 1024 to 65535 inclusive"
      zh: ""

    PARSLEY_INSTANCE_PORT_MUST_BE_BETWEEN_1_AND_65535:
      en: "Instance Port must be between 1 and 65535"
      zh: ""

    PARSLEY_THIS_NAME_IS_ALREADY_IN_USING:
      en: "This name is already in using."
      zh: ""

    PARSLEY_INVALID_IP_ADDRESS:
      en: "Invalid IP address"
      zh: ""

    PARSLEY_VOLUME_SIZE_OF_ROOTDEVICE_MUST_IN_RANGE:
      en: "Volume size of this rootDevice must in the range of %s -1024 GB."
      zh: ""

    PARSLEY_IOPS_MUST_BETWEEN_100_4000:
      en: "IOPS must be between 100 and 4000"
      zh: ""

    PARSLEY_IOPS_MUST_BE_LESS_THAN_10_TIMES_OF_VOLUME_SIZE:
      en: "IOPS must be less than 10 times of volume size."
      zh: ""

    PARSLEY_THIS_VALUE_MUST_BETWEEN_1_99:
      en: "This value must be >= 1 and <= 99"
      zh: ""

    PARSLEY_SHOULD_BE_A_VALID_STACK_NAME:
      en: "This value should be a valid Stack name"
      zh: ""

    PARSLEY_PLEASE_PROVIDE_A_VALID_AMAZON_SQS_ARN:
      en: "Please provide a valid Amazon SQS ARN"
      zh: ""

    PARSLEY_PLEASE_PROVIDE_A_VALID_APPLICATION_ARN:
      en: "Please provide a valid Application ARN"
      zh: ""

    PARSLEY_PLEASE_PROVIDE_A_VALID_PHONE_NUMBER:
      en: "Please provide a valid phone number (currently only support US phone number)"
      zh: ""

    PARSLEY_PLEASE_PROVIDE_A_VALID_URL:
      en: "Please provide a valid URL"
      zh: ""

    PARSLEY_VOLUME_SIZE_MUST_IN_1_1024:
      en: "Volume size must in the range of 1-1024 GB."
      zh: ""

    PARSLEY_DEVICENAME_LINUX:
      en: "Device name must be like /dev/hd[a-z], /dev/hd[a-z][1-15],/dev/sd[a-z] or /dev/sd[b-z][1-15]"
      zh: ""

    PARSLEY_DEVICENAME_WINDOWS:
      en: "Device name must be like xvd[f-p]."
      zh: ""

    PARSLEY_VOLUME_NAME_INUSE:
      en: "Volume name '%s' is already in using. Please use another one."
      zh: ""

    NAV_TIT_DASHBOARD:
      en: "Dashboard"
      zh: "仪表板"

    NAV_TIT_APPS:
      en: "Apps"
      zh: "应用"

    NAV_TIT_STACKS:
      en: "Stacks"
      zh: "模版"

    NAV_LBL_GLOBAL:
      en: "Global"
      zh: "我的资源"

    IDE_MSG_ERR_OPEN_OLD_STACK_APP_TAB:
      en: "Sorry, the stack/app is too old, unable to open"
      zh: "抱歉，模板/应用的格式太旧了，无法打开."

    IDE_MSG_ERR_OPEN_TAB:
      en: "Unable to open the stack/app, please try again"
      zh: "无法打开 模板/应用, 请重试"

    IDE_MSG_ERR_CONNECTION:
      en: "Unable to load some parts of the IDE, please refresh the browser"
      zh: "无法加载部分IDE内容，请重试"

    IDE_TIP_VISUALIZE_MORE_THAN_100_ENI:
      en: "Currently we do not support to visualize system has more than 300 network interfaces. Contact us by the Feedback button for details."
      zh: ""

    RES_TIT_RESOURCES:
      en: "Resources"
      zh: "资源"

    RES_TIP_SHARED_RESOURCES:
      en: "Manage other resources"
      zh: "资源"

    RES_TIT_RESOURCES_MENU_KEYPAIR:
      en: "Manage Key Pairs..."
      zh: ""

    RES_TIT_RESOURCES_MENU_SNAPSHOT:
      en: "Manage EBS Snapshots..."
      zh: ""

    RES_TIT_RESOURCES_MENU_SNS:
      en: "Manage SNS Topic & Subscriptions..."
      zh: ""

    RES_TIT_RESOURCES_MENU_SSLCERT:
      en: "Manage Server Certificates..."
      zh: ""

    RES_TIT_RESOURCES_MENU_DHCP:
      en: "Manage DHCP Option Sets..."
      zh: ""

    RES_TIT_AZ:
      en: "AZ & Subnet"
      zh: ""

    RES_TIT_AMI:
      en: "Images"
      zh: "虚拟机映像"

    RES_TIT_VOL:
      en: "Volume & Snapshot"
      zh: "虚拟磁盘和快照"

    RES_TIT_SNAPSHOT_MANAGE:
      en: "Manage EBS Snapshot"
      zh: "管理 EBS 快照"

    RES_MSG_RDS_DISABLED:
      en: "Your AWS account does not have access to this resource. Please make sure you can access to all RDS-related resources. "
      zh: "Your AWS account does not have access to this resource. Please make sure you can access to all RDS-related resources. "

    RES_TIT_RDS:
      en: "RDS & Snapshot"
      zh: ""

    RES_TIT_RDS_EMPTY:
      en: "No RDS Snapshot in"
      zh: ""

    RES_LBL_NEW_RDS_INSTANCE:
      en: "New DB Instance"
      zh: ""

    RES_LBL_NEW_RDS_INSTANCE_FROM_SNAPSHOT:
      en: "New DB from Snapshot"
      zh: ""

    RES_TIT_RDS_SNAPSHOT_MANAGE:
      en: "Manage RDS Snapshot"
      zh: "管理 RDS 快照"

    RES_TIT_RDS_SNAPSHOT_EMPTY:
      en: "No RDS Snapshot in"
      zh: ""

    RES_TIT_ELB_ASG:
      en: "Load Balancer and Auto Scaling"
      zh: "负载均衡器和自动伸缩组"

    RES_TIT_REMOVE_FROM_FAVORITE:
      en: "Remove from Favorite"
      zh: ""

    RES_TIT_ADD_TO_FAVORITE:
      en: "Add to Favorite"
      zh: ""

    RES_TIT_TOGGLE_FAVORITE:
      en: "Toggle favorite"
      zh: ""

    RES_TIT_VPC:
      en: "Network"
      zh: ""

    RES_LBL_QUICK_START_AMI:
      en: "Quick Start Images"
      zh: "推荐的映像"

    RES_LBL_MY_AMI:
      en: "My Images"
      zh: "我的映像"

    RES_LBL_FAVORITE_AMI:
      en: "Favorite Images"
      zh: "收藏的映像"

    RES_LBL_NEW_VOL:
      en: "New Volume"
      zh: "新的卷"

    RES_LBL_NEW_BLANK_VOL:
      en: "New Blank Volume"
      zh: ""

    RES_LBL_NEW_VOL_FROM_SNAPSHOT:
      en: "New Volume from Snapshot"
      zh: ""

    RES_LBL_NEW_ELB:
      en: "Load Balancer"
      zh: "负载均衡器"

    RES_LBL_NEW_ASG:
      en: "Auto Scaling Group"
      zh: "Auto Scaling 组"

    RES_LBL_NEW_ASG_NO_CONFIG:
      en: "No Config"
      zh: "无配置"

    RES_LBL_NEW_SUBNET:
      en: "Subnet"
      zh: "子网"

    RES_LBL_NEW_SUBNET_GROUP:
      en: "Subnet Group"
      zh: ""

    RES_LBL_NEW_RTB:
      en: "Route Table"
      zh: "路由表"

    RES_LBL_NEW_IGW:
      en: "Internet Gateway"
      zh: "因特网网关"

    RES_LBL_NEW_VGW:
      en: "Virtual Gateway"
      zh: "虚拟网关"

    RES_LBL_NEW_CGW:
      en: "Customer Gateway"
      zh: "客户网关"

    RES_LBL_NEW_ENI:
      en: "Network Interface"
      zh: "网络接口"

    RES_BTN_BROWSE_COMMUNITY_AMI:
      en: "Browse Community Images"
      zh: "浏览映像"

    RES_TIP_TOGGLE_RESOURCE_PANEL:
      en: "Show/Hide Resource Panel"
      zh: "显示/隐藏 资源面板"

    RES_TIP_DRAG_AZ:
      en: "Drag to the canvas to use this availability zone"
      zh: "拖放到画板来使用这个可用区域"

    RES_TIP_DRAG_NEW_VOLUME:
      en: "Drag onto an instance to attach a new volume."
      zh: "拖放到一个实例来附加一个新卷。"

    RES_TIP_DRAG_NEW_ELB:
      en: "Drag to the canvas to create a new load balancer."
      zh: "拖放到画板来创建一个新负载均衡器。"

    RES_TIP_DRAG_NEW_ASG:
      en: "Drag to the canvas to create a new auto scaling group."
      zh: "拖放到画板来创建一个新Auto Scaling组。"

    RES_TIP_DRAG_NEW_SUBNET:
      en: "Drag to an availability zone to create a new subnet."
      zh: "拖放到一个可用区域来创建一个新子网。"

    RES_TIP_DRAG_NEW_SUBNET_GROUP:
      en: "Drag to an availability zone to create a new subnet group."
      zh: ""

    RES_TIP_DRAG_NEW_RTB:
      en: "Drag to a VPC to create a new route table."
      zh: "拖放到一个VPC来创建一个路由表。"

    RES_TIP_DRAG_NEW_IGW:
      en: "Drag to the canvas to create a new internet gateway."
      zh: "拖放到画板来创建一个新互联网网关。"

    RES_TIP_DRAG_NEW_VGW:
      en: "Drag to the canvas to create a new virtual gateway."
      zh: "拖放到画板来创建一个新虚拟网关。"

    RES_TIP_DRAG_NEW_CGW:
      en: "Drag to the canvas to create a new customer gateway."
      zh: "拖放到画板来创建一个新客户网关。"

    RES_TIP_DRAG_NEW_ENI:
      en: "Drag to a subnet to create a new network interface."
      zh: "拖放到一个子网来创建一个新网络接口。"

    RES_TIP_DRAG_HAS_IGW:
      en: "This VPC already has an internet gateway."
      zh: "这个VPC已经有了一个互联网网关。"

    RES_TIP_DRAG_HAS_VGW:
      en: "This VPC already has a virtual gateway."
      zh: "这个VPC已经有了一个虚拟网关。"

    RES_MSG_WARN_GET_COMMUNITY_AMI_FAILED:
      en: "Unable to load community AMIs"
      zh: "不能加载社区映像"

    RES_MSG_INFO_ADD_AMI_FAVORITE_SUCCESS:
      en: "AMI is added to Favorite AMI"
      zh: "收藏映像成功"

    RES_MSG_ERR_ADD_FAVORITE_AMI_FAILED:
      en: "Failed to add AMI to Favorite"
      zh: "收藏映像失败"

    RES_MSG_INFO_REMVOE_FAVORITE_AMI_SUCCESS:
      en: "AMI is removed from Favorite AMI"
      zh: "映像已从收藏列表中移除"

    RES_MSG_ERR_REMOVE_FAVORITE_AMI_FAILED:
      en: "Failed to remove AMI from Favorite"
      zh: "映像从收藏列表移除失败"

    RDS_MSG_ERR_REMOVE_SUBNET_FAILED_CAUSEDBY_USEDBY_SBG:
      en: "%s is a member of subnet group %s. To delete the subnet, remove the membership first."
      zh: ""

    RDS_MSG_ERR_REMOVE_AZ_FAILED_CAUSEDBY_CHILD_USEDBY_SBG:
      en: "Cannot delete availability zone because some subnet in it is used by a subnet group."
      zh: ""

    CVS_MSG_WARN_NOTMATCH_VOLUME:
      en: "Volumes and snapshots must be dragged to an instance or image."
      zh: "卷和快照必须拖放到实例或映像。"

    CVS_MSG_ERR_SERVERGROUP_VOLUME:
      en: "Detach existing volume or snapshot of instance server group is not supported yet."
      zh: "Detach existing volume or snapshot of instance server group is not supported yet."

    CVS_MSG_ERR_SERVERGROUP_VOLUME2:
      en: "Attach existing volume from single instance to instance server group is not supported yet."
      zh: "Attach existing volume from single instance to instance server group is not supported yet."

    CVS_MSG_WARN_NOTMATCH_SUBNET:
      en: "Subnets must be dragged to an availability zone."
      zh: "子网必须拖放到可用区域。"

    CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET:
      en: "Instances must be dragged to a subnet or auto scaling group."
      zh: "实例必须拖放到子网或Auto Scaling组。"

    CVS_MSG_WARN_NOTMATCH_SGP_VPC:
      en: "Subnet Group must be dragged to a vpc."
      zh: ""

    CVS_MSG_WARN_NOTMATCH_DBINSTANCE_SGP:
      en: "DB Instance must be dragged to a subnet group."
      zh: ""

    CVS_MSG_WARN_NOTMATCH_ASG:
      en: "Auto Scaling Group must be dropped in a subnet."
      zh: "Auto Scaling组必须拖放到子网。"

    CVS_MSG_WARN_NOTMATCH_ENI:
      en: "Network interfaces must be dragged to a subnet."
      zh: "网络接口必须拖放到子网。"

    CVS_MSG_WARN_NOTMATCH_RTB:
      en: "Route tables must be dragged inside a VPC but outside an availability zone."
      zh: "路由表必须拖放到可用区域外的VPC部分。"

    CVS_MSG_WARN_NOTMATCH_ELB:
      en: "Load balancer must be dropped outside availability zone."
      zh: "负载均衡器必须拖放到可用区域以外。"

    CVS_MSG_WARN_NOTMATCH_CGW:
      en: "Customer gateways must be dragged outside the VPC."
      zh: "客户网关必须拖放到VPC以外。"

    CVS_MSG_WARN_NOTMATCH_IGW:
      en: "Internet gateways must be dragged inside a VPC."
      zh: "互联网网关必须拖放到VPC里。"

    CVS_MSG_WARN_NOTMATCH_VGW:
      en: "Virtual private gateways must be dragged inside a VPC."
      zh: "虚拟私有网关必须拖放到VPC里。"

    CVS_MSG_WARN_COMPONENT_OVERLAP:
      en: "Nodes cannot overlap each other."
      zh: "节点不能互相重叠。"

    CVS_MSG_WARN_NO_ENOUGH_SPACE:
      en: "No enough space."
      zh: "没有多余的空间。"

    CVS_WARN_EXCEED_ENI_LIMIT:
      en: "%s's type %s supports a maximum of %s network interfaces (including the primary)."
      zh: "%s 的 %s 最多支持%s个网络接口 (包括主要的)。"

    CVS_MSG_WARN_CANNOT_CONNECT_SUBNET_TO_ELB:
      en: "This subnet cannot be attached with a Load Balancer. Its CIDR mask must be smaller than /27"
      zh: ""

    CVS_MSG_ERR_CONNECT_ENI_AMI:
      en: "Network interfaces can only be attached to an instance in the same availability zone."
      zh: "网络接口只能连接到同一个可用区域的实例。"

    CVS_MSG_ERR_MOVE_ATTACHED_ENI:
      en: "Network interfaces must be in the same availability zone as the instance they are attached to."
      zh: "网络接口必须跟它附加的实例在同一个可用区域。"

    CVS_MSG_ERR_DROP_ASG:
      en: "%s is already in %s."
      zh: "%s已经存在于%s中。"

    CVS_MSG_ERR_DEL_LC:
      en: "Currently modifying the launch configuration is not supported."
      zh: "目前还不支持修改启动配置。"

    CVS_MSG_ERR_DEL_MAIN_RT:
      en: "The main route table %s cannot be deleted. Please set another route table as the main and try again."
      zh: "主路由表：%s 不能被删除。 请将其他路由表设为主路由表后再重试。"

    CVS_MSG_ERR_DEL_LINKED_RT:
      en: "Subnets must be associated to a route table. Please associate the subnets with another route table first."
      zh: "子网必须与路由表关联，请先将这个子网与一个路由表关联起来。"

    CVS_MSG_ERR_DEL_SBRT_LINE:
      en: "Subnets must be associated with a route table."
      zh: "子网必须与路由表关联。"

    CVS_MSG_ERR_DEL_ELB_LINE_1:
      en: "Load Balancer must associate with at least 1 subnet for each Availability Zone where it has registered load balanced instances."
      zh: "负载均衡器至少需要连接一个子网。"

    CVS_MSG_ERR_DEL_ELB_LINE_2:
      en: "Cannot delete or change the current attachment."
      zh: "最少要保留一条已有的负载均衡器和子网的连线。"

    CVS_MSG_ERR_DEL_LINKED_ELB:
      en: "This subnet cannot be deleted because it is associated to a load balancer."
      zh: "由于这个子网关联着负载均衡器，所以它不能被删除。"

    CVS_CFM_DEL:
      en: "Delete %s"
      zh: "删除 %s"

    CVS_CFM_DEL_IGW:
      en: "Internet-facing load balancer or public IP requires internet gateway to function."
      zh: "面向互联网的负载均衡器和公网IP需要一个互联网网关才能工作。"

    CVS_CFM_DEL_GROUP:
      en: "Deleting %s will also remove all resources inside it. Are you sure you want to delete it?"
      zh: "删除 %s 会同时删除其中的所有资源， 确定要删除它吗？"

    CVS_CFM_DEL_LC:
      en: "Are you sure to delete launch configuration %s?"
      zh: ""

    CVS_CFM_DEL_ASG:
      en: "Launch configuration %s is only used by %s. By deleting %s, %s will also be deleted.<br/>Are you sure to delete asg0?"
      zh: ""

    CVS_CFM_ADD_IGW:
      en: "An Internet Gateway is Required"
      zh: "必须要有一个互联网网关"

    CVS_CFM_ADD_IGW_MSG:
      en: "Automatically add an internet gateway for using Elastic IP or public IP"
      zh: "为设置EIP，自动添加了一个互联网网关"

    CVS_CFM_DEL_NONEXISTENT_DBINSTANCE:
      en: "Deleting <span class='resource-tag'>%s</span> will remove all read replica related to it. Are you sure to continue?"
      zh: "%s 未创建,删除它会同时删除与之相关的所有只读副本，确定要删除它吗？"

    CVS_CFM_DEL_EXISTENT_DBINSTANCE:
      en: "<span class='resource-tag'>%s</span> is a live resource. Deleting it will remove not-yet-created read replica, but keep existing ones. Are you sure to continue?"
      zh: "%s已存在，删除它会同时删除与之相关的只读副本，但会保留，确定要删除它吗？"

    CVS_MSG_ERR_ZOOMED_DROP_ERROR:
      en: "Please reset the zoom to 100% before adding new resources."
      zh: "在添加新资源前，请重设缩放至100%。"

    CVS_TIP_EXPAND_W:
      en: "Increase Canvas Width"
      zh: "增加画板宽度"

    CVS_TIP_SHRINK_W:
      en: "Decrease Canvas Width"
      zh: "减少画板宽度"

    CVS_TIP_EXPAND_H:
      en: "Increase Canvas Height"
      zh: "增加画板高度"

    CVS_TIP_SHRINK_H:
      en: "Decrease Canvas Height"
      zh: "减少画板宽度"

    TOOL_BTN_RUN_STACK:
      en: "Run Stack"
      zh: "运行"

    TOOL_TIP_BTN_RUN_STACK:
      en: "Run this stack into an app"
      zh: "运行当前模版为应用"

    TOOL_POP_TIT_RUN_STACK:
      en: "Run Stack"
      zh: "运行"

    TOOL_TIP_SAVE_STACK:
      en: "Save Stack"
      zh: "保存模版"

    TOOL_TIP_DELETE_STACK:
      en: "Delete Stack"
      zh: "删除模版"

    TOOL_TIP_DELETE_NEW_STACK:
      en: "This stack is not saved yet."
      zh: "当前模版未保存"

    TOOL_POP_TIT_DELETE_STACK:
      en: "Delete Stack"
      zh: "删除模版"

    TOOL_POP_BODY_DELETE_STACK:
      en: "Do you confirm to delete stack '%s'?"
      zh: "确认删除模版'%s'吗?"

    TOOL_POP_BTN_DELETE_STACK:
      en: "Delete"
      zh: "删除"

    TOOL_POP_BTN_CANCEL:
      en: "Cancel"
      zh: "取消"

    TOOL_POP_EXPORT_CF:
      en: "Export to AWS CloudFormation Template"
      zh: "导出为亚马逊云编排模板"

    TOOL_POP_EXPORT_CF_INFO:
      en: "Download the template file when it's ready, then you can upload it in AWS console to create CloudFormation Stack."
      zh: "请在数据转换后下载这个云编排模板文件，并把它上传到亚马逊管理控制台来创建云编排模块。"

    TOOL_POP_BTN_EXPORT_CF:
      en: "Download Template File"
      zh: "下载模板文件"

    TOOL_TIP_DUPLICATE_STACK:
      en: "Duplicate Stack"
      zh: "复制模版"

    TOOL_TIT_CLOSE_TAB:
      en: "Close Tab"
      zh: ""

    TOOL_POP_TIT_DUPLICATE_STACK:
      en: "Duplicate Stack"
      zh: "复制模版"

    TOOL_POP_BODY_DUPLICATE_STACK:
      en: "New Stack Name:"
      zh: "模版名称:"

    TOOL_POP_BODY_APP_To_STACK:
      en: "New Stack Name:"
      zh: "模版名称:"

    TOOL_POP_BTN_DUPLICATE_STACK:
      en: "Duplicate"
      zh: "复制"

    TOOL_POP_BTN_SAVE_TO_STACK:
        en: "Save"
        zh: "保存"

    TOOL_TIP_CREATE_STACK:
      en: "Create New Stack"
      zh: "创建新模版"

    TOOL_TIP_ZOOM_IN:
      en: "Zoom In"
      zh: "放大"

    TOOL_TIP_SAVE_APP_TO_STACK:
      en: "Save App as Stack"
      zh: "App 保存为 Stack"
    TOOL_TIP_ZOOM_OUT:
      en: "Zoom Out"
      zh: "缩小"

    TOOL_EXPORT:
      en: "Export..."
      zh: "导出..."

    TOOL_EXPORT_AS_JSON:
      en: "Export to JSON"
      zh: "导出JSON文件"

    TOOL_POP_TIT_EXPORT_AS_JSON:
      en: "Export"
      zh: "导出"

    TOOL_POP_TIT_APP_TO_STACK:
      en: "Save App as Stack"
      zh: "将 App 保存为 Stack"
    TOOL_POP_INTRO_1:
      en: "Saving app as stack helps you to revert changes made during app editing back to stack."
      zh: ""
    TOOL_POP_INTRO_2:
      en: "Canvas design, resource properties and instance states will be saved."
      zh: ""

    TOOL_POP_REPLACE_STACK:
      en: "Replace the original stack"
      zh: ""

    TOOL_POP_REPLACE_STACK_INTRO:
      en: "This app is launched from stack"
      zh: ""

    TOOL_POP_REPLACE_STACK_INTRO_END:
      en: ". Entirely replace the stack with current app design."
      zh: ""

    TOOL_POP_SAVE_NEW_STACK:
      en: "Save as new stack"
      zh: ""

    TOOL_POP_SAVE_STACK_INSTRUCTION:
      en: "Specify a name for new stack:"
      zh: ""

    TOOL_POP_STACK_NAME_ERROR:
      en: "The stack name is already in use. Please use another one."
      zh: ""

    TOOL_POP_BODY_EXPORT_AS_JSON:
      en: "The stack is ready to export. Please click the Download button to save the file."
      zh: "The stack is ready to export. Please click the Download button to save the file."

    TOOL_POP_BTN_DOWNLOAD:
      en: "Download"
      zh: "保存"

    TOOL_EXPORT_AS_PNG:
      en: "Export to PNG"
      zh: "导出图片"

    TOOL_SAVE_AS_APP:
      en: "Save as App"
      zh: "保存为应用"


    TOOL_EXPORT_AS_CF:
      en: "Convert to CloudFormation Format"
      zh: "导出JSON文件"

    TOOL_TIP_STOP_APP:
      en: "Stop This App's Resources."
      zh: "暂停应用"

    TOOL_TIP_CONTAINS_INSTANCE_STORED:
      en: "This app cannot be stopped since it contains instance-stored AMI."
      zh: "不能暂停这个应用，因为它包含实例存储映像"

    TOOL_POP_TIT_STOP_APP:
      en: "Confirm to Stop App"
      zh: "确认暂停"

    TOOL_POP_BODY_STOP_APP_LEFT:
      en: "Do you confirm to stop app"
      zh: "本操作将暂停应用中的相关资源，您确认暂停当前应用"

    TOOL_POP_BODY_STOP_APP_RIGHT:
      en: "?"
      zh: " 吗"

    TOOL_POP_TIT_STOP_PRD_APP:
      en: "Confirm to Stop App for Production"
      zh: "确认暂停产品应用"

    TOOL_POP_BTN_STOP_APP:
      en: "Stop"
      zh: "暂停"

    TOOL_TIP_START_APP:
      en: "Start App"
      zh: "恢复应用"

    TOOL_POP_TIT_START_APP:
      en: "Confirm to Start App"
      zh: "确认恢复"

    TOOL_POP_BODY_START_APP:
      en: "Do you confirm that you would like to start the app?"
      zh: "本操作将恢复应用中的相关资源，您确认恢复当前应用吗?"

    TOOL_POP_BTN_START_APP:
      en: "Start"
      zh: "恢复"

    TOOL_TIP_UPDATE_APP:
      en: "Edit App"
      zh: "更新应用"

    TOOL_TIP_SAVE_UPDATE_APP:
      en: "Apply Updates"
      zh: "保存应用更新"

    TOOL_TIP_CANCEL_UPDATE_APP:
      en: "Discard Updates"
      zh: "取消应用更新"

    TOOL_TIP_TERMINATE_APP:
      en: "Permanently Terminate This App's Resources"
      zh: "销毁应用"

    TOOL_POP_TIT_TERMINATE_APP:
      en: "Confirm to Terminate App"
      zh: "确认销毁"

    TOOL_POP_BODY_TERMINATE_APP_LEFT:
      en: "Warning: all resources in the app will be permanantly deleted. <br/>Do you confirm to terminate app"
      zh: "本操作将销毁应用中的相关资源，您确认销毁当前应用"

    TOOL_POP_BODY_TERMINATE_APP_RIGHT:
      en: "?"
      zh: " 吗"

    TOOL_POP_BTN_TERMINATE_APP:
      en: "Terminate"
      zh: "销毁"

    TOOL_POP_TIT_TERMINATE_PRD_APP:
      en: "Confirm to Terminate App for Production"
      zh: "确认销毁产品应用"

    TOOL_MSG_INFO_REQ_SUCCESS:
      en: "Sending request to %s %s..."
      zh: "正在发送 %s %s 请求..."

    TOOL_MSG_ERR_REQ_FAILED:
      en: "Sending request to %s %s failed."
      zh: "发送 %s %s 请求失败。"

    TOOL_MSG_INFO_HDL_SUCCESS:
      en: "%s %s successfully."
      zh: "%s %s 成功。"

    TOOL_MSG_ERR_HDL_FAILED:
      en: "%s %s failed."
      zh: "%s %s 失败。"

    TOOL_MSG_ERR_SAVE_FAILED:
      en: "Save stack %s failed, please check and save it again."
      zh: "保存模块 %s 失败，请您检查并重新保存。"

    TOOL_MSG_ERR_SAVE_SUCCESS:
      en: "Save stack %s successfully."
      zh: "保存 %s 成功。"

    TOOL_MSG_ERR_DEL_STACK_SUCCESS:
      en: "Delete stack %s successfully."
      zh: "删除 %s 成功。"

    TOOL_MSG_ERR_DEL_STACK_FAILED:
      en: "Delete stack %s failed."
      zh: "删除 %s 失败。"

    TOOLBAR_HANDLE_SAVE_STACK:
      en: "Save stack"
      zh: "保存模块"

    TOOLBAR_HANDLE_CREATE_STACK:
      en: "Create stack"
      zh: "创建模块"

    TOOLBAR_HANDLE_DUPLICATE_STACK:
      en: "Copy stack"
      zh: "复制模块"

    TOOLBAR_HANDLE_REMOVE_STACK:
      en: "Delete stack"
      zh: "删除模块"

    TOOLBAR_HANDLE_RUN_STACK:
      en: "Run stack"
      zh: "运行模块"

    TOOLBAR_HANDLE_START_APP:
      en: "Start app"
      zh: "恢复应用"

    TOOLBAR_HANDLE_STOP_APP:
      en: "Stop app"
      zh: "暂停应用"

    TOOLBAR_HANDLE_TERMINATE_APP:
      en: "Terminate app"
      zh: "销毁应用"

    TOOLBAR_HANDLE_EXPORT_CLOUDFORMATION:
      en: "Convert to CloudFormation template"
      zh: "导出云编排模板"

    TOOL_MSG_INFO_APP_REFRESH_FINISH:
      en: "Refresh resources for app( %s ) complete."
      zh: "完成应用( %s )的资源刷新。"

    TOOL_MSG_INFO_APP_REFRESH_FAILED:
      en: "Refresh resources for app( %s ) falied, please click refresh tool button to retry."
      zh: "刷新应用( %s )的资源失败, 请点击刷新按钮来重试。"

    TOOL_MSG_INFO_APP_REFRESH_START:
      en: "Refresh resources for app( %s ) start ..."
      zh: "开始刷新应用( %s )的资源 ..."

    TOOL_POP_BODY_APP_UPDATE_EC2:
      en: "The public and private addresses will be reassigned after the restart.",
      zh: "重启后，公有/私有的IP地址将会被重新分配。"

    TOOL_POP_BODY_APP_UPDATE_VPC:
      en: "If any of the instance(s) has been automatically assigned public IP, the IP will change after restart.",
      zh: "重启后，已分配公有IP地址的实例将会被重新分配。"


    TOOL_MSG_ERR_CONVERT_CLOUDFORMATION:
      en: "Convert to stack json to CloudFormation format error"
      zh: "转换成CloudFormation出错"

    TOOL_TIP_REFRESH_REOURCES:
      en: "Refresh Reources"
      zh: ""

    TOOL_TIP_JSON_DIFF:
      en: "JSON Diff"
      zh: ""

    TOOL_TIP_JSON_VIEW:
      en: "JSON View"
      zh: ""

    TOOL_TIP_CUSTOM_USER_DATA:
      en: "Custom User Data will be overridden and disabled to allow installing OpsAgent. (Currently only support Linux platform)"
      zh: ""

    TOOL_TIP_NO_CLASSIC_DATA_STACK:
      en: "We will drop support for EC2 Classic and Default VPC soon. We have disabled create new stack, run app or edit app in those platforms. You can export existing stacks as CloudFormation template or as a PNG file. Click to read detailed announcement."
      zh: ""

    TOOL_TIP_NO_CLASSIC_DATA_APP:
      en: "We will drop support for EC2 Classic and Default VPC soon. We have disabled create new stack, run app or edit app in those platforms. You can still manage the lifecycle of existing apps.  Click to read detailed announcement."
      zh: ""

    TOOL_TIP_LINESTYLE:
      en: "Line Style"
      zh: "连线类型"

    TOOL_LBL_LINESTYLE_STRAIGHT:
      en: "Straight"
      zh: "直线"

    TOOL_LBL_LINESTYLE_ELBOW:
      en: "Elbow"
      zh: "折线"

    TOOL_LBL_LINESTYLE_CURVE:
      en: "Curve"
      zh: "曲线"

    TOOL_LBL_LINESTYLE_SMOOTH_QUADRATIC_BELZIER:
      en: "Smooth quadratic Belzier curve"
      zh: "光滑的二次贝塞尔曲线"

    TOOL_LBL_LINESTYLE_HIDE_SG:
      en: "Hide SecurityGroup line"
      zh: "隐藏SecurityGroup线"

    TOOL_LBL_LINESTYLE_SHOW_SG:
      en: "Show SecurityGroup line"
      zh: "显示SecurityGroup线"

    TOOL_EXPERIMENT:
      en: "Experimental Feature!"
      zh: ""

    TOOL_TOGGLE_VISUALOPS_ON:
      en: "instance state on"
      zh: ""

    TOOL_TOGGLE_VISUALOPS_OFF:
      en: "instance state off"
      zh: ""

    TOOL_LBL_NO_CLASSIC:
      en: "Where are the missing buttons?"
      zh: ""

    TOOL_EDIT_APP:
      en: "Edit App"
      zh: ""

    TOOL_APPLY_EDIT:
      en: "Apply"
      zh: ""

    TOOL_START_APP:
      en: "Start App"
      zh: ""



    PROC_STEP_REQUEST:
      en: "Processing"
      zh: "处理中"

    PROC_FAILED_TITLE:
      en: "Oops! Starting app failed."
      zh: "启动应用错误"

    REG_MSG_WARN_APP_PENDING:
      en: "Your app is in Processing. Please wait a moment."
      zh: "您的应用正在处理中，请稍等一会。"

    NOTIFY_MSG_WARN_AUTH_FAILED:
      en : "Authentication failed."
      zh : ""

    NOTIFY_MSG_INFO_STATE_COPY_TO_CLIPBOARD:
      en : "State(s) copied to clipboard"
      zh : ""

    NOTIFY_MSG_INFO_STATE_PARSE_COMMAND_FAILED:
      en : "The states are from a different version. Some module may be incompatible."
      zh : ""

    NOTIFY_MSG_INFO_STATE_PARSE_REFRENCE_FAILED:
      en : "The states contains @references which cannot pass on. Validate to see details."
      zh : ""

    NOTIFY_MSG_WARN_OPERATE_NOT_SUPPORT_YET:
      en : "This operation is not supported yet."
      zh : ""

    NOTIFY_MSG_WARN_ASG_CAN_ONLY_CONNECT_TO_ELB_ON_LAUNCH:
      en : "Auto Scaling Group can only register with Load Balancer on launch."
      zh : ""

    NOTIFY_MSG_WARN_AMI_NOT_EXIST_TRY_USE_OTHER:
      en : "The AMI(%s) is not exist now, try to use another AMI."
      zh : ""

    NOTIFY_MSG_WARN_ATTACH_VOLUME_REACH_INSTANCE_LIMIT:
      en : "Attached volume has reached instance limit."
      zh : ""

    NOTIFY_MSG_WARN_KEYPAIR_NAME_ALREADY_EXISTS:
      en : "KeyPair with the same name already exists."
      zh : ""

    NOTIFY_MSG_WARN_CANNT_AUTO_ASSIGN_CIDR_FOR_SUBNET:
      en : "Cannot auto-assign cidr for subnets, please manually update subnets' cidr before changing vpc's cidr."
      zh : ""

    NOTIFY_MSG_WARN_VPC_DOES_NOT_EXIST:
      en : "VPC does not exist."
      zh : ""

    CFM_BTN_DELETE:
      en: "Delete"
      zh: "删除"

    CFM_BTN_CANCEL:
      en: "Cancel"
      zh: "取消"

    CFM_BTN_ADD:
      en: "Add"
      zh: "添加"

    CFM_BTN_DONT_ADD:
      en: "Don't add"
      zh: "不要添加"

    HEAD_LABEL_BLANK_NOTIFICATION:
      en: "No news is good news."
      zh: "没有通知。"

    HEAD_LABEL_BLANK_NOTIFICATION_DESC:
      en: "Results of running, stopping or terminating apps will show up here."
      zh: ""

    HEAD_LABEL_MENUITEM_USER_TOUR:
      en: "User Tour"
      zh: "用户教程"

    HEAD_LABEL_MENUITEM_KEY_SHORT:
      en: "Keyboard Shortcuts"
      zh: ""

    HEAD_LABEL_MENUITEM_DOC:
      en: "Documentation"
      zh: "使用文档"

    HEAD_LABEL_MENUITEM_SETTING:
      en: "Settings"
      zh: "账号设置"

    HEAD_LABEL_MENUITEM_LOGOUT:
      en: "Log Out"
      zh: "登出"

    HEAD_LABEL_SETTING:
      en: "Settings"
      zh: "用户设置"

    HEAD_LABEL_ACCOUNT:
      en: "Account"
      zh: "账号"

    HEAD_LABEL_CREDENTIAL:
      en: "AWS Credentials"
      zh: "AWS 证书"

    HEAD_LABEL_ACCOUNT_USERNAME:
      en: "Username"
      zh: "用户名"

    HEAD_LABEL_ACCOUNT_EMAIL:
      en: "Email Address"
      zh: "电子邮件地址"

    HEAD_LABEL_CHANGE_PASSWORD:
      en: "Change Password"
      zh: "修改密码"

    HEAD_LABEL_CHANGE_EMAIL:
      en: "Change Email"
      zh: "修改电子邮箱"

    HEAD_LABEL_NEW_EMAIL:
      en: "Email Address"
      zh: "电子邮箱"

    HEAD_LABEL_CURRENT_PASSWORD:
      en: "Current Password"
      zh: "当前密码"

    HAED_LABEL_NEW_PASSWORD:
      en: "New Password"
      zh: "新密码"

    HEAD_LABEL_ACCOUNT_CHANGE:
      en: "Change"
      zh: "修改"

    HEAD_LABEL_ACCOUNT_PERIOD:
      en: "."
      zh: "。"

    HEAD_LABEL_ACCOUNT_QUESTION:
      en: "?"
      zh: "？"

    HEAD_LABEL_WELCOME:
      en: "Welcome"
      zh: "欢迎"

    HEAD_LABEL_PROVIDE_CREDENTIAL:
      en: "Provide AWS Credentials"
      zh: "请提供AWS证书"

    HEAD_LABEL_ACCOUNT_SKIP:
      en: "Skip"
      zh: "跳过"

    HEAD_BTN_CHANGE:
      en: "Change"
      zh: "修改"

    HEAD_BTN_UPDATE:
      en: "Update"
      zh: "更新"

    HEAD_BTN_CANCEL:
      en: "Cancel"
      zh: "取消"

    HEAD_BTN_SUBMIT:
      en: "Submit"
      zh: "提交"

    HEAD_BTN_CLOSE:
      en: "Close"
      zh: "关闭"

    HEAD_BTN_BACK:
      en: "Back"
      zh: "后退"

    HEAD_BTN_DONE:
      en: "Done"
      zh: "完成"

    HEAD_INFO_LOADING:
      en: "loading..."
      zh: "加载中..."

    HEAD_INFO_LOADING_RESOURCE:
      en: "Loading resources..."
      zh: "加载资源中..."


    SETTINGS_CRED_DEMO_TIT:
      en : "You are using a demo AWS account. Set up your own credential to run stack into live resources, or visualize your existing VPC."
      zh : "You are using a demo AWS account. Set up your own credential to run stack into live resources, or visualize your existing VPC."

    SETTINGS_CRED_DEMO_TEXT:
      en : "Some stack you build in demo mode may report error after setting up credential due to resource inconsistency between different accounts."
      zh : "Some stack you build in demo mode may report error after setting up credential due to resource inconsistency between different accounts."

    SETTINGS_CRED_DEMO_SETUP:
      en : "Set up AWS Credentials"
      zh : "连接AWS账号"

    SETTINGS_TIP_CRED_ACCOUNTID:
      en: "Your AWS account number is shown in the upper-right area of your browser window when you are logged into your AWS Account. e.g., 123456789000"
      zh: "当您登陆到您的AWS账号时，您的AWS账号编号将显示在您浏览器窗口的右上角区域。 比如123456789000"

    SETTINGS_TIP_CRED_ACCESSKEY:
      en: "You will find those keys in Account > Security Credentials menu under Access Keys tab in the box at the middle of the page. e.g., ABCDEFGHIJ1LMNOPQR2S"
      zh: "通过点击&nbsp;账号&nbsp;&gt;安全性认证&nbsp;菜单，然后切换到页面中间的&nbsp;访问码&nbsp;页面，您将能找到您的访问码。 例如ABCDEFGHIJ1LMNOPQR2S"

    SETTINGS_TIP_CRED_SECRETKEY:
      en: "You will find those keys in Account > Security Credentials menu under Access Keys tab in the box at the middle of the page. e.g., aBCDefgH/ Ijklmnopq1Rs2tUVWXY3AbcDeFGhijk"
      zh: "通过点击&nbsp;账号&nbsp;&gt;安全性认证&nbsp;菜单，然后切换到页面中间的&nbsduplp;访问码&nbsp;页面，您将能找到您的访问码。 例如aBCDefgH/ Ijklmnopq1Rs2tUVWXY3AbcDeFGhijk"

    SETTINGS_LABEL_ACCOUNTID:
      en: "Account Number"
      zh: "账户编号"

    SETTINGS_LABEL_ACCESSKEY:
      en: "Access Key ID"
      zh: "访问码编号"

    SETTINGS_LABEL_SECRETKEY:
      en: "Secret Key"
      zh: "密匙"

    SETTINGS_LABEL_REMOVE_CREDENTIAL:
      en: "Remove Credential"
      zh: "移除证书"

    SETTINGS_LABEL_ACCOUNT_CANCEL:
      en: "Cancel"
      zh: "取消"

    SETTINGS_LABEL_ACCOUNT_UPDATE:
      en: "Update"
      zh: "更新"

    SETTINGS_LABEL_ACCESSTOKEN:
      en: "Access Token"
      zh: "Access Token"

    SETTINGS_INFO_TOKEN:
      en: "Use token within API calls to initiate automatic states update. "
      zh: "Use token within API calls to initiate automatic states update. "

    SETTINGS_BTN_TOKEN_CREATE:
      en: "Generate Token"
      zh: "Generate Token"

    SETTINGS_BTN_TOKEN_REMOVE:
      en: "Delete Token"
      zh: "Delete Toekn"

    SETTINGS_INFO_TOKEN_LINK:
      en: "Read detailed documentation."
      zh: "Read detailed documentation."

    SETTINGS_INFO_TOKEN_EMPTY:
      en: "You currently have no token."
      zh: "You currently have no token."

    SETTINGS_CONFIRM_TOKEN_RM_TIT:
      en: 'Do you confirm to delete the "%s"?'
      zh: 'Do you confirm to delete the "%s"?'

    SETTINGS_LABEL_TOKENTABLE_NAME:
      en: "Token Name"
      zh: "Token Name"

    SETTINGS_LABEL_TOKENTABLE_TOKEN:
      en: "Access Token"
      zh: "Access Token"

    SETTINGS_CONFIRM_TOKEN_RM:
      en: 'Any applications or scripts using this token will no longer be able to access the
VisualOps API. You cannot UNDO this action.'
      zh: 'Any applications or scripts using this token will no longer be able to access the
VisualOps API. You cannot UNDO this action.'

    SETTINGS_CRED_CONNECTED_TIT:
      en: "You have connected with following AWS account:"
      zh: "您已经使用如下AWS账号连接:"

    SETTINGS_CRED_REMOVE_TIT:
      en: "Do you confirm to remove AWS Credentials of account %s?"
      zh: "您确定要移除账号%s的AWS证书吗？"

    SETTINGS_CRED_REMOVE_TEXT:
      en: "<p>By removing Credentials, you will be in the demo mode.</p><p>If you want to launch stack into app, you need to provide valid AWS Credentials. </p><p>The stacks you designed in demo mode may not be able to launch with your AWS Credentials due to resource inconsistency.</p><p>If you have existing apps, they will become unmanageable and can only be forced to delete.</p>"
      zh: "<p>By removing Credentials, you will be in the demo mode.</p><p>If you want to launch stack into app, you need to provide valid AWS Credentials. </p><p>The stacks you designed in demo mode may not be able to launch with your AWS Credentials due to resource inconsistency.</p><p>If you have existing apps, they will become unmanageable and can only be forced to delete.</p>"

    SETTINGS_CRED_REMOVING:
      en : "Removing credential..."
      zh : "正在移除证书..."

    SETTINGS_CRED_UPDATING:
      en : "Updating credential..."
      zh : "正在更新证书..."

    SETTINGS_CRED_RES_LOADING:
      en : "Loading resources..."
      zh : "正在刷新资源..."

    SETTINGS_ERR_CRED_VALIDATE:
      en : "Fail to validate your credential."
      zh : "Fail to validate your credential."

    SETTINGS_ERR_CRED_UPDATE:
      en : "Fail to update your credential, please retry."
      zh : "Fail to update your credential, please retry."

    SETTINGS_ERR_CRED_REMOVE:
      en : "Fail to remove your credential, please retry."
      zh : "Fail to remove your credential, please retry."

    SETTINGS_CRED_UPDATE_CONFIRM_TIT:
      en : "<span>You have running or stopped app(s).</span> Do you confirm to update the AWS credential?"
      zh : "<span>You have running or stopped app(s).</span> Do you confirm to update the AWS credential?"

    SETTINGS_CRED_UPDATE_CONFIRM_TEXT:
      en : "If you continue to use the new credential, existing apps might become unmanageable. If the new AWS credential does not have sufficient privileges to manage the existing apps, we strongly recommend to TERMINATE existing apps first."
      zh : "If you continue to use the new credential, existing apps might become unmanageable. If the new AWS credential does not have sufficient privileges to manage the existing apps, we strongly recommend to TERMINATE existing apps first."

    SETTINGS_LABEL_UPDATE_CONFIRM:
      en: "Confirm to update"
      zh: "Confirm to update"

    SETTINGS_ERR_INVALID_PWD:
      en: "New password must contain at least 6 characters."
      zh: "新密码最少6位且不能和您的用户名相同"

    SETTINGS_UPDATE_PWD_SUCCESS:
      en: "Password has been updated."
      zh: "密码修改成功。"

    SETTINGS_UPDATE_EMAIL_SUCCESS:
      en: "Email has been updated."
      zh: "电子邮箱修改成功。"

    SETTINGS_UPDATE_EMAIL_FAIL1:
      en: "To change email, please provide correct password."
      zh: "修改电子邮箱失败。请确认当前密码输入正确。"

    SETTINGS_UPDATE_EMAIL_FAIL2:
      en: "This email is already taken. Please use another."
      zh: "电子邮箱已被使用。"

    SETTINGS_UPDATE_EMAIL_FAIL3:
      en: "This email is invalid. Please enter a valid email."
      zh: "无效的电子邮箱，请重试。"

    SETTINGS_UPDATE_PWD_FAILURE:
      en: "Update password failed. Make sure current password is correct."
      zh: "修改密码失败。请确认当前密码输入正确。"

    SETTINGS_ERR_WRONG_PWD:
      en: "Current password is wrong."
      zh: "密码错误"

    SETTINGS_INFO_FORGET_PWD:
      en: "Forget password?"
      zh: "是否重置密码?"

    WELCOME_DIALOG_TIT:
      en: "Welcome to VisualOps"
      zh: "欢迎使用 VisualOps"

    WELCOME_PROVIDE_CRED_TIT:
      en: "Please provide new AWS credentials"
      zh: "Please provide new AWS credentials"

    WELCOME_PROVIDE_CRED_DESC:
      en: "We cannot validate your AWS credentials, please provide new ones."
      zh: "We cannot validate your AWS credentials, please provide new ones."

    WELCOME_TIT:
      en: "Welcome to VisualOps, "
      zh: "Welcome to VisualOps, "

    WELCOME_DESC:
      en: "To start designing cloud architecture, please provide your AWS credentials"
      zh: "To start designing cloud architecture, please provide your AWS credentials"

    WELCOME_SKIP_TIT:
      en: "Skip providing AWS Credentials now?"
      zh: "Skip providing AWS Credentials now?"

    WELCOME_SKIP_SUBTIT:
      en: "You can design stack in the demo mode. Yet, with following drawbacks:"
      zh: "You can design stack in the demo mode. Yet, with following drawbacks:"

    WELCOME_SKIP_MSG:
      en: "<ul><li>The demo mode may not reflect the real condition of resources available for your account.</li> <li>If you want to provide credentials later, design previously created in demo mode may not work due to resource inconsistency.</li>"
      zh: "<ul><li>The demo mode may not reflect the real condition of resources available for your account.</li> <li>If you want to provide credentials later, design previously created in demo mode may not work due to resource inconsistency.</li>"

    WELCOME_SKIP_MSG_EXTRA:
      en: "You can provide AWS Credentials later from Settings in the top-right drop down."
      zh: "You can provide AWS Credentials later from Settings in the top-right drop down."

    WELCOME_DONE_TIT:
      en: "Get started with VisualOps"
      zh: "Get started with VisualOps"

    WELCOME_DONE_HINT:
      en: "You have connected to AWS account: "
      zh: "You have connected to AWS account: "

    WELCOME_DONE_HINT_DEMO:
      en: "You are using a demo AWS account."
      zh: "You are using a demo AWS account."

    WELCOME_DONE_MSG:
      en: "<li>Play with the 5 sample stacks prebuilt in Virginia region.</li>
<li>Read <a href='http://docs.visualops.io/' target='_blank'>Documentation</a>.</li>
<li>Watch short <a href='http://docs.visualops.io/example/video.html' target='_blank'>Tutorial Videos</a>. </li>"
      zh: "<li>Play with the 5 sample stacks prebuilt in Virginia region.</li>
<li>Read <a href='http://docs.visualops.io/' target='_blank'>Documentation</a>.</li>
<li>Watch short <a href='http://docs.visualops.io/example/video.html' target='_blank'>Tutorial Videos</a>. </li>"

    HEAD_MSG_ERR_UPDATE_EMAIL3:
      en: "Please provide a valid email address."
      zh: "请提供有效邮箱地址"

    HEAD_LABEL_TOUR_DESIGN_DIAGRAM:
      en: "Drag and Drop to Design Diagram"
      zh: "拖放到设计图"

    HEAD_LABEL_TOUR_CONNECT_PORT:
      en: "Connect Ports"
      zh: "连接端口"

    HEAD_LABEL_TOUR_CONFIG_PROPERTY:
      en: "Configure Properties"
      zh: "配置属性"

    HEAD_LABEL_TOUR_DO_MORE:
      en: "Do More with Toolbar"
      zh: "使用工具栏"

    HEAD_INFO_TOUR_DESIGN_DIAGRAM:
      en: "Add availability zone, instance, volume and all other resources to the canvas with easy drag and drop"
      zh: "轻松拖拽就可以添加可用区域、\t主机、磁盘和所有其它的资源到画布中。"

    HEAD_INFO_TOUR_CONNECT_PORT:
      en: "Setting up security group rule, establishing attachment, creating route and a lot more can be done by connecting ports."
      zh: "通过端口可以设置安全组规则、建立依赖、生成路由以及其它很多。"

    HEAD_INFO_TOUR_CONFIG_PROPERTY:
      en: "Detailed configurations are done from the right side Property Panel."
      zh: "右侧的面板可以进行详细设置。"

    HEAD_INFO_TOUR_DO_MORE:
      en: "Running stack into live resources, customize the visualization or exporting from the toolbar."
      zh: "通过工具栏可以运行模板、自定义可视化数据以及导出数据和资源。"

    MODULE_RELOAD_MESSAGE:
      en: "Sorry, there is some connectivity issue, IDE is trying to reload"
      zh: "抱歉，网络连接失败，IDE正在重新加载"

    MODULE_RELOAD_FAILED:
      en: "Sorry, there is some connectivity issue, IDE cannot load, please refresh the browser"
      zh: "抱歉，网络连接失败，IDE不能加载，请刷新浏览器"

    BEFOREUNLOAD_MESSAGE:
      en: "You have unsaved changes."
      zh: "您有未保存的更改。"




    AMI_LBL_COMMUNITY_AMIS:
      en: "Community AMIs"
      zh: "社区映像"

    AMI_LBL_ALL_SEARCH_AMI_BY_NAME_OR_ID:
      en: "Search AMI by name or ID"
      zh: "根据名称或ID搜索映像"

    AMI_LBL_ALL_PLATFORMS:
      en: "All Platforms"
      zh: "所有平台"

    AMI_LBL_VISIBILITY:
      en: "Visibility"
      zh: "可见性"

    AMI_LBL_ARCHITECTURE:
      en: "Architecture"
      zh: "架构"

    AMI_LBL_SIZE:
      en: "Size(GB)"
      zh: "大小（GB）"

    AMI_LBL_ROOT_DEVICE_TYPE:
      en: "Root Device Type"
      zh: "根设备类型"

    AMI_LBL_PUBLIC:
      en: "Public"
      zh: "公用"

    AMI_LBL_PRIVATE:
      en: "Private"
      zh: "私有"

    AMI_LBL_32_BIT:
      en: "32-bit"
      zh: "32位"

    AMI_LBL_64_BIT:
      en: "64-bit"
      zh: "64位"

    AMI_LBL_EBS:
      en: "EBS"
      zh: "EBS"

    AMI_LBL_INSTANCE_STORE:
      en: "Instance Store"
      zh: "实例存储"

    AMI_LBL_SEARCH:
      en: "Search"
      zh: "搜索"

    AMI_LBL_SEARCHING:
      en: "Searching..."
      zh: "搜索中..."

    AMI_LBL_AMI_ID:
      en: "AMI ID"
      zh: "映像 ID"

    AMI_LBL_AMI_NAME:
      en: "AMI Name"
      zh: "映像名称"

    AMI_LBL_ARCH:
      en: "Arch"
      zh: "架构"

    AMI_LBL_PAGEINFO:
      en: "Showing %s-%s items of %s results"
      zh: "当前显示 %s-%s 条，共有 %s 条"

    IDE_COM_CREATE_NEW_STACK:
      en: "Create new stack"
      zh: "创建模板"

    "IDE_LBL_REGION_NAME_us-east-1":
      en: "US East"
      zh: "美国东部"

    "IDE_LBL_REGION_NAME_us-west-1":
      en: "US West"
      zh: "美国西部"

    "IDE_LBL_REGION_NAME_us-west-2":
      en: "US West"
      zh: "美国西部"

    "IDE_LBL_REGION_NAME_eu-west-1":
      en: "EU West"
      zh: "欧洲西部"

    "IDE_LBL_REGION_NAME_ap-southeast-1":
      en: "Asia Pacific"
      zh: "亚太地区"

    "IDE_LBL_REGION_NAME_ap-southeast-2":
      en: "Asia Pacific"
      zh: "亚太地区"

    "IDE_LBL_REGION_NAME_ap-northeast-1":
      en: "Asia Pacific"
      zh: "亚太地区"

    "IDE_LBL_REGION_NAME_sa-east-1":
      en: "South America"
      zh: "南美洲"

    "IDE_LBL_REGION_NAME_SHORT_us-east-1":
      en: "Virginia"
      zh: "弗吉尼亚"

    "IDE_LBL_REGION_NAME_SHORT_us-west-1":
      en: "California"
      zh: "加利福尼亚北部"

    "IDE_LBL_REGION_NAME_SHORT_us-west-2":
      en: "Oregon"
      zh: "俄勒冈"

    "IDE_LBL_REGION_NAME_SHORT_eu-west-1":
      en: "Ireland"
      zh: "爱尔兰"

    "IDE_LBL_REGION_NAME_SHORT_ap-southeast-1":
      en: "Singapore"
      zh: "新加坡"

    "IDE_LBL_REGION_NAME_SHORT_ap-southeast-2":
      en: "Sydney"
      zh: "悉尼"

    "IDE_LBL_REGION_NAME_SHORT_ap-northeast-1":
      en: "Tokyo"
      zh: "东京"

    "IDE_LBL_REGION_NAME_SHORT_sa-east-1":
      en: "Sao Paulo"
      zh: "圣保罗"

    IDE_LBL_LAST_STATUS_CHANGE:
      en: "Last Changed"
      zh: "最近修改时间"

    POP_DOWNLOAD_KP_NOT_AVAILABLE:
      en: "<p>Your password is not ready. Password generation can sometimes take more than 30 minutes. Please wait at least 15 minutes after launching an instance before trying to retrieve the generated password.</p>
<p>If you launched this instance from your own AMI, the password is the same as for the instance from which you created the AMI, unless this setting was modified in the EC2Config service settings.</p>"
      zh: "当前不可用。口令生成和加密通常需要30分钟时间。启动实例后在拿到生成的口令前，请至少等待15分钟。"

    POP_BTN_CLOSE:
      en: "Close"
      zh: "关闭"

    POP_TIP_PEM_ENCODED:
      en: "PEM Encoded"
      zh: ""

    RUN_STACK_MODAL_TITLE:
      en: "Run Stack"
      zh: "运行"

    RUN_STACK_MODAL_NEED_CREDENTIAL:
      en: "Set Up Credential First"
      zh: "请先设置 AWS 凭证"

    RUN_STACK_MODAL_KP_WARNNING:
      en: "Specify a key pair as $DefaultKeyPair for this app."
      zh: ""

    RUN_STACK_MODAL_CONFIRM_BTN:
      en: "Run Stack"
      zh: "运行"

    UPDATE_APP_MODAL_TITLE:
      en: "Update App"
      zh: "更新 App"

    CANT_UPDATE_APP:
      en: "Cannot Update App Now"
      zh: ""

    UPDATE_APP_CONFIRM_BTN:
      en: "Update App"
      zh: ""
    RUN_STACK:
      en: "run stack"
      zh: "运行"

    UPDATE_APP_MODAL_NEED_CREDENTIAL:
      en: "Please set Up Credential First"
      zh: "请先设置 AWS 凭证"

    START_APP:
      en: "start app"
      zh: "启动APP"

    STOP_APP:
      en: "stop app"
      zh: "停止APP"

    TERMINATE_APP:
      en: "terminate app"
      zh: "删除APP"

    UPDATE_APP:
      en: "update"
      zh: "更新错误"

    #  port tooltip

    PORT_TIP_A:
      en: 'Connect to subnet to make association'
      zh: ''

    PORT_TIP_B:
      en: 'Connect to Internet Gateway, Virtual Private Gateway, instance or network interface to create route.'
      zh: ''

    PORT_TIP_C:
        en: 'Connect to route table to create route'
        zh: ''

    PORT_TIP_D:
        en: 'Connect to instance, auto scaling group, network interface or load balancer to create security group rule.'
        zh: ''

    PORT_TIP_E:
      en: 'Connect to network interface to attach.'
      zh: ''

    PORT_TIP_F:
      en: 'Connect to instance, auto scaling group or network interface to create security group rule.'
      zh: ''

    PORT_TIP_G:
      en: 'Connect to instance to attach'
      zh: ''

    PORT_TIP_H:
      en: 'Connect to Customer Gateway to create VPN'
      zh: ''

    PORT_TIP_I:
      en: 'Connect to Virtua Private Gateway to create VPN'
      zh: ''

    PORT_TIP_J:
      en: 'Connect to instance or launch configuration to register it behind load balancer'
      zh: ''

    PORT_TIP_K:
      en: 'Connect to subnet to associate'
      zh: ''

    PORT_TIP_L:
      en: 'Connect to load balancer to associate'
      zh: ''

    PORT_TIP_M:
      en: 'Connect to route table to assoicate'
      zh: ''

  ##### Modal Confirm Stop/Terminate App

    POP_CONFIRM_STOP_ASG:
      en: "Any auto scaling group will be deleted when application is stopped."
      zh: ""

    POP_CONFIRM_PROD_APP_WARNING_MSG:
      en: " is for PRODUCTION."
      zh: ""

    POP_CONFIRM_STOP_PROD_APP_MSG:
      en: " Stopping it will make your service unavailable."
      zh: ""

    POP_CONFIRM_STOP_PROD_APP_INPUT_LBL:
      en: "Please type in the name of this app to confirm stopping it."
      zh: ""

    POP_CONFIRM_TERMINATE_PROD_APP_MSG:
      en: " Terminating it will make your service unavailable. Any auto scaling group will be deleted when application is stopped."
      zh: ""

    POP_CONFIRM_STOP_PROD_APP_MSG:
      en: " Stopping it will make your service unavailable."
      zh: ""

    POP_CONFIRM_TERMINATE_PROD_APP_INPUT_LBL:
      en: "Please type in the name of this app to confirm terminating it."
      zh: ""

    ##### Modal Import JSON

    POP_IMPORT_JSON_TIT:
      en: "Import Stack from JSON file"
      zh: ""

    POP_IMPORT_DROP_LBL:
      en: "Drop JSON file here or "
      zh: ""

    POP_IMPORT_SELECT_LBL:
      en: " select a file."
      zh: ""

    POP_IMPORT_ERROR:
      en: "An error occured when reading the file. Please try again."
      zh: ""

    POP_IMPORT_FORMAT_ERROR:
      en: "The json file is malformed."
      zh: ""

    POP_IMPORT_MODIFIED_ERROR:
      en: "We do not support user modified json."
      zh: ""

    ##### Modal Confirm Update

    POP_CONFIRM_UPDATE_TIT:
      en: "Confirm to Update App"
      zh: ""

    POP_CONFIRM_UPDATE_MAJOR_TEXT_RUNNING:
      en: "Do you confirm to apply the changes?"
      zh: ""

    POP_CONFIRM_UPDATE_MAJOR_TEXT_STOPPED:
      en: "Do you confirm to apply the changes and start the app?"
      zh: ""

    POP_CONFIRM_UPDATE_MINOR_TEXT_STOPPED:
      en: "The app is currently stopped. To apply updates, the app will be started automatically."
      zh: ""

    POP_CONFIRM_UPDATE_TABLE_TYPE:
      en: "Type"
      zh: ""

    POP_CONFIRM_UPDATE_TABLE_NAME:
      en: "Name"
      zh: ""

    POP_CONFIRM_UPDATE_TABLE_CHANGE:
      en: "Change"
      zh: ""

    POP_CONFIRM_UPDATE_VALIDATION:
      en: "Validation"
      zh: ""

    POP_CONFIRM_UPDATE_VALIDATING:
      en: "Validating your app..."
      zh: ""

    POP_CONFIRM_UPDATE_CONFIRM_BTN:
      en: "Continue to Update"
      zh: ""

    POP_CONFIRM_UPDATE_CANCEL_BTN:
      en: "Cancel"
      zh: ""


    ##### RDS
    RDS_VALUE_IS_NOT_ALLOWED:
      en: "The value %s is not an allowed value."
      zh: ""

    RDS_EDIT_OPTION_GROUP:
      en: "Edit Option Group"
      zh: ""

    RDS_SOME_ERROR_OCCURED:
      en: "Some error occured"
      zh: ""

    RDS_PORT_CHANGE_REQUIRES_APPLIED_IMMEDIATELY:
      en: "Edits with port change requires changes to be applied immediately."
      zh: ""



    ##### RDS



    TIP_KEYPAIR_USED_DEFAULT_KP:
      en: "One or more instance/launch configuration has used $DefaultKeyPair. You need to specify which key pair (or no key pair) should be used for $DefaultKeyPair."
      zh: ""


