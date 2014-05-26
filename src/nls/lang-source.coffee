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
  login:
    login:
      en: "Log In"
      zh: "登录"

    "login-register":
      en: "New to VisualOps? "
      zh: "注册新用户？ "

    "link-register":
      en: "Register"
      zh: "注册"

    "error-msg-1":
      en: "Username or email does not match the password."
      zh: "邮件地址或用户名不正确"

    "error-msg-2":
      en: "Hey, you forgot to enter a username or email."
      zh: "邮件地址错误"

    "link-foget":
      en: "Forgot your Password?"
      zh: "忘记密码？"

    "login-user":
      en: "Username or email"
      zh: "邮件地址或用户名"

    "login-password":
      en: "Password"
      zh: "密码"

    "login-btn":
      en: "Log In"
      zh: "登录"

    "login-loading":
      en: "Logging In"
      zh: "正在登录"

    login_waiting:
      en: "Please wait..."
      zh: "稍等..."

    "madeira-offered-in":
      en: "&copy; VisualOps offered in"
      zh: "&copy; VisualOps 还提供"

  register:
    register:
      en: "Register"
      zh: "注册"

    "register-login":
      en: "Already a user?"
      zh: "已经有帐号？"

    "link-login":
      en: "Log in"
      zh: "登录"

    "register-username":
      en: "Username"
      zh: "用户名"

    "register-email":
      en: "Email"
      zh: "邮件地址"

    "register-password":
      en: "Password"
      zh: "密码"

    "register-policy":
      en: "By clicking the create account button, you agree to our"
      zh: "单击“创建账户”按钮，表示您已经同意我们的"

    "link-policy":
      en: "Terms of Service"
      zh: "服务条款"

    "register-btn":
      en: "Create Account"
      zh: "创建帐号"

    "register-success":
      en: "Registered Successfully"
      zh: "注册成功"

    "account-instruction":
      en: "Thanks for signing up with VisualOps."
      zh: "非常感谢您注册 VisualOps。"

    "register-get-start":
      en: "Get Started"
      zh: "开始"

    username_available:
      en: "This username is available."
      zh: "此用户名可用。"

    username_not_matched:
      en: "Username can only include alpha-number."
      zh: "用户名只能包含字母。"

    username_maxlength:
      en: "User name cannot be more than 40 characters."
      zh: "用户名不能超过40个字符。"

    username_required:
      en: "Username is required."
      zh: "用户名不能为空。"

    username_taken:
      en: "Username is already taken. Please choose another."
      zh: "此用户名已经被注册，请选择其它用户名。"

    email_available:
      en: "This email address is available."
      zh: "此邮件地址可用。"

    email_not_valid:
      en: "Enter a valid email address."
      zh: "请输入有效的邮件地址。"

    email_used:
      en: "This email has already been used."
      zh: "此邮件地址已经被使用。"

    email_required:
      en: "Email address is required."
      zh: "邮件地址不能为空。"

    password_ok:
      en: "This password is OK."
      zh: "密码可用。"

    password_shorter:
      en: "Password should at least contain 6 characters."
      zh: "密码至少包含6个字符、数字或者特殊字符。"

    password_required:
      en: "Password is required."
      zh: "密码不能为空。"

    reginster_waiting:
      en: "Please wait..."
      zh: "稍等..."

  reset:
    "pre-reset":
      en: "Forgot Password"
      zh: "忘记密码"

    reset:
      en: "Reset Password"
      zh: "重置密码"

    "reset-register":
      en: "Register"
      zh: "注册"

    "reset-login":
      en: "Log in"
      zh: "登录"

    "email-label":
      en: "Provide the email address or username you registered with VisualOps. An email with link to reset password will be sent to you soon."
      zh: "请提供您在VisualOps注册时的邮件地址或者用户名。包含重置链接的邮件马上将会发送给您。"

    "account-label":
      en: "Username or Email Address"
      zh: "用户名 or 邮件地址"

    "reset-btn":
      en: "Send Reset Password Email"
      zh: "发送密码重置请求邮件"

    "send-email-info":
      en: "An email with link to reset password has been sent to your registered email address."
      zh: "包含密码重置链接的电子邮件已经发送到您注册的邮件地址中，请查收。"

    "check-email-info":
      en: "Check your inbox (or look in your spam folder, you never know)."
      zh: "请检查您的收件箱（收件箱中如果没有，还请查看您的垃圾邮件文件夹）"

    "expired-info":
      en: "Password reset URL is invalid or has expired."
      zh: "密码重置链接非法或者过期。"

    "reset-relogin":
      en: "Log in VisualOps"
      zh: "登录VisualOps"

    "reset-new-password":
      en: "New Password"
      zh: "新密码"

    "reset-done-btn":
      en: "Done"
      zh: "完成"

    "reset-success-info":
      en: "You have successfully reset password."
      zh: "成功重置密码。"

    reset_waiting:
      en: "Please wait..."
      zh: "稍等..."

    reset_password_shorter:
      en: "Password must contain at least 6 characters."
      zh: "密码至少包含6个字符、数字或者特殊字符。"

    reset_password_required:
      en: "Password is required."
      zh: "密码已经过期。"

    reset_btn:
      en: "Send Reset Password Email"
      zh: "发送密码重置请求邮件"

    reset_error_state:
      en: "The username or email address is not registered with VisualOps."
      zh: "用户名或邮件地址还没有在VisualOps注册过。"

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
      en: "Currently we do not support to visualize system has more than 100 network interfaces. Contact us by the Feedback button for details."
      zh: ""

    RES_TIT_RESOURCES:
      en: "Resources"
      zh: "资源"

    RES_TIT_AZ:
      en: "Availability Zones"
      zh: "可用区域"

    RES_TIT_AMI:
      en: "Images"
      zh: "虚拟机映像"

    RES_TIT_VOL:
      en: "Volume and Snapshots"
      zh: "虚拟磁盘和快照"

    RES_TIT_ELB_ASG:
      en: "Load Balancer and Auto Scaling"
      zh: "负载均衡器和自动伸缩组"

    RES_TIT_REMOVE_FROM_FAVORITE:
      en: "Remove from Favorite"
      zh: ""

    RES_TIT_ADD_TO_FAVORITE:
      en: "Add to Favorite"
      zh: ""

    RES_TIT_VPC:
      en: "Virtual Private Cloud"
      zh: "虚拟私有云"

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

    CVS_MSG_WARN_NOTMATCH_ASG:
      en: "Asg must be dragged to a subnet."
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

    CVS_MSG_WARN_COMPONENT_OVERLAP:
      en: "Nodes cannot overlap each other."
      zh: "节点不能互相重叠。"

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
      en: "Load balancer must attach to at least one subnet."
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

    CVS_CFM_DEL_ASG:
      en: "Deleting this will delete the entire %s. Are you sure you want to delete it?"
      zh: "删除它会删除整个 %s，确定要删除它吗?"

    CVS_CFM_ADD_IGW:
      en: "An Internet Gateway is Required"
      zh: "必须要有一个互联网网关"

    CVS_CFM_ADD_IGW_MSG:
      en: "Automatically add an internet gateway for using Elastic IP or public IP"
      zh: "为设置EIP，自动添加了一个互联网网关"

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
      en: "Do you confirm to delete stack"
      zh: "确认删除模版吗?"

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
      en: "This stack has been converted to AWS CloudFormation Template format. Download the template file and upload it in AWS console to create CloudFormation Stack."
      zh: "这个模块已经被转换成为亚马逊云编排模板格式。请下载这个云编排模板文件并把它上传到亚马逊管理控制台来创建云编排模块。"

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
      en: "Save app as Stack"
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
      en: "Start This App's Resources."
      zh: "恢复应用"

    TOOL_POP_TIT_START_APP:
      en: "Confirm to Start App"
      zh: "确认恢复"

    TOOL_POP_BODY_START_APP_LEFT:
      en: "Do you confirm to start app"
      zh: "本操作将恢复应用中的相关资源，您确认恢复当前应用"

    TOOL_POP_BODY_START_APP_RIGHT:
      en: "?"
      zh: " 吗"

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
      en: "Do you confirm to terminate app"
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
      en: "Security Group Rule Line Style..."
      zh: "安全组规则连线类型..."

    TOOL_LBL_LINESTYLE_STRAIGHT:
      en: "Straight"
      zh: "直线"

    TOOL_LBL_LINESTYLE_ELBOW:
      en: "Elbow"
      zh: "肘型线"

    TOOL_LBL_LINESTYLE_QUADRATIC_BELZIER:
      en: "Quadratic Belzier curve"
      zh: "二次贝赛尔曲线"

    TOOL_LBL_LINESTYLE_SMOOTH_QUADRATIC_BELZIER:
      en: "Smooth quadratic Belzier curve"
      zh: "光滑的二次贝塞尔曲线"

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

    PROP_LBL_REQUIRED:
      en: "Required"
      zh: "必填"

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
      en: "https://github.com/VisualOps/OpsAgent/blob/develop/scripts/userdata.sh"
      zh: "https://github.com/VisualOps/OpsAgent/blob/develop/scripts/userdata.sh"

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
      en: "None"
      zh: "无"

    PROP_VPC_DHCP_LBL_DEFAULT:
      en: "Default DHCP"
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
      en: "Manage Region DHCP options"
      zh: ""

    PROP_VPC_FILTER_DHCP:
      en: "Filter by DHCP name"
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

    POP_SGRULE_TITLE_ADD:
      en: "Add Security Group Rule"
      zh: "添加安全组规则"

    POP_SGRULE_TITLE_EDIT:
      en: "Edit Security Group Rule"
      zh: "修改安全组规则"

    POP_SGRULE_LBL_DIRECTION:
      en: "Direction"
      zh: "方向"

    POP_SGRULE_LBL_INBOUND:
      en: "Inbound"
      zh: "入方向"

    POP_SGRULE_LBL_OUTBOUND:
      en: "Outbound"
      zh: "出方向"

    POP_SGRULE_LBL_SOURCE:
      en: "Source"
      zh: "源"

    POP_SGRULE_LBL_DEST:
      en: "Destination"
      zh: "目的"

    POP_SGRULE_LBL_PROTOCOL:
      en: "Protocol"
      zh: "协议"

    POP_SGRULE_PROTOCOL_TCP:
      en: "TCP"
      zh: "TCP"

    POP_SGRULE_PROTOCOL_UDP:
      en: "UDP"
      zh: "UDP"

    POP_SGRULE_PROTOCOL_ICMP:
      en: "ICMP"
      zh: "ICMP"

    POP_SGRULE_PROTOCOL_CUSTOM:
      en: "Custom"
      zh: "自定义"

    POP_SGRULE_PROTOCOL_ALL:
      en: "All"
      zh: "全部"

    POP_SGRULE_BTN_SAVE:
      en: "Save"
      zh: "保存"

    POP_SGRULE_BTN_CANCEL:
      en: "Cancel"
      zh: "取消"

    POP_SGRULE_PLACEHOLD_SOURCE:
      en: "e.g., 192.168.2.0/24"
      zh: "如192.168.2.0/24"

    POP_SGRULE_PLACEHOLD_PORT_RANGE:
      en: "Port Range.eg.80 or 49152-65535"
      zh: "端口范围，如80或49152-65535"

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

    POP_ACLRULE_TITLE_ADD:
      en: "Add Network ACL Rule"
      zh: "添加访问控制表规则"

    POP_ACLRULE_LBL_RULE_NUMBER:
      en: "Rule Number"
      zh: "规则编号"

    POP_ACLRULE_LBL_ACTION:
      en: "Action"
      zh: "动作"

    POP_ACLRULE_LBL_ACTION_ALLOW:
      en: "Allow"
      zh: "允许"

    POP_ACLRULE_LBL_ACTION_DENY:
      en: "Deny"
      zh: "拒绝"

    POP_ACLRULE_LBL_DIRECTION:
      en: "Direction"
      zh: "方向"

    POP_ACLRULE_LBL_INBOUND:
      en: "Inbound"
      zh: "入方向"

    POP_ACLRULE_LBL_OUTBOUND:
      en: "Outbound"
      zh: "出方向"

    POP_ACLRULE_LBL_SOURCE:
      en: "Source"
      zh: "源"

    POP_ACLRULE_LBL_DEST:
      en: "Destination"
      zh: "目的"

    POP_ACLRULE_LBL_PROTOCOL:
      en: "Protocol"
      zh: "协议"

    POP_ACLRULE_PROTOCOL_TCP:
      en: "TCP"
      zh: "TCP"

    POP_ACLRULE_PROTOCOL_UDP:
      en: "UDP"
      zh: "UDP"

    POP_ACLRULE_PROTOCOL_ICMP:
      en: "ICMP"
      zh: "ICMP"

    POP_ACLRULE_PROTOCOL_CUSTOM:
      en: "Custom"
      zh: "自定义"

    POP_ACLRULE_PROTOCOL_ALL:
      en: "All"
      zh: "全部"

    POP_ACLRULE_BTN_SAVE:
      en: "Save"
      zh: "保存"

    POP_ACLRULE_BTN_CANCEL:
      en: "Cancel"
      zh: "取消"

    POP_ACLRULE_PLACEHOLD_SOURCE:
      en: "e.g., 192.168.2.0/24"
      zh: "如192.168.2.0/24"

    POP_ACLRULE_PLACEHOLD_PORT_RANGE:
      en: "Port Range.eg.80 or 49152-65535"
      zh: "端口范围,如80或49152-65535"

    POP_ACLRULE_LBL_PORT_RANGE_ALL:
      en: "Port Range:0-65535"
      zh: "端口范围:0-65535"

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

    PROP_WARN_SG_RULE_EXIST:
      en: "The adding rule already exist."
      zh: ""

    PROP_TEXT_DEFAULT_SG_DESC:
      en: "Default Security Group"
      zh: "Default Security Group"

    PROP_TEXT_CUSTOM_SG_DESC:
      en: "Custom Security Group"
      zh: "Custom Security Group"

    PROP_MSG_WARN_WHITE_SPACE:
      en: "Stack name contains white space"
      zh: "模板名称不能包含空格"

    PROP_MSG_ERR_GET_PASSWD_FAILED:
      en: "There was an error decrypting your password. Please ensure that you have entered your private key correctly."
      zh: "解密出错，请确认您是否上传了正确的私钥。"


    PROP_MSG_ERR_AMI_NOT_FOUND:
      en: "Can not find information for selected AMI( %s ), try to drag another AMI."
      zh: "无法获取选中的( %s )AMI的信息，请拖拽其他的AMI。"

    PROP_MSG_SG_CREATE:
      en: "1 rule has been created in %s to allow %s %s %s."
      zh: "1条规则被创建到 %s 来允许 %s %s %s。"

    PROP_MSG_SG_CREATE_MULTI:
      en: "%d rules have been created in %s and %s to allow %s %s %s."
      zh: "%d条规则被创建到 %s 并且 %s 来允许 %s %s %s."

    PROP_MSG_SG_CREATE_SELF:
      en: "%d rules have been created in %s to allow %s send and receive traffic within itself."
      zh: "%d条规则被创建到 %s 来允许 %s 它内部的收发通信."

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

    PROP_VOLUME_TYPE_STANDARD:
      en: "Standard"
      zh: "标准"

    PROP_VOLUME_TYPE_IOPS:
      en: "Provisioned IOPS"
      zh: "预配置IOPS"

    PROP_VOLUME_MSG_WARN:
      en: "Volume size must be at least 10 GB to use Provisioned IOPS volume type."
      zh: "要使用预配置IOPS,磁盘必须最少10GB"

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
      en: "Add Server Certificate"
      zh: "添加服务器认证"

    PROP_ELB_SERVER_CERTIFICATE:
      en: "Server Certificate"
      zh: "服务器认证"

    PROP_ELB_LBL_LISTENER_NAME:
      en: "Name"
      zh: "名称"

    PROP_ELB_LBL_LISTENER_DESCRIPTIONS:
      en: "Listener Descriptions"
      zh: "监听器描述"

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
      en: "Response timeout must be less than or equal to the health check interval value"
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
      en: "Confirm to Delete Server Certificate"
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

    PROPERTY_ASG_ELB_WARN:
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

    NAV_DESMOD_NOT_FINISH_LOAD:
      en: "Sorry, the designer module is loading now. Please try again after several seconds."
      zh: "抱歉，设计模块正在加载，请稍后重试。"

    PROC_TITLE:
      en: "Starting your app..."
      zh: "启动您的应用..."

    PROC_RLT_DONE_TITLE:
      en: "Everything went smoothly!"
      zh: "一切顺利!"

    PROC_RLT_DONE_SUB_TITLE:
      en: "Your app will automatically open soon."
      zh: "您的应用将被自动打开。"

    PROC_STEP_PREPARE:
      en: "Preparing to start app..."
      zh: "准备启动应用..."

    PROC_RLT_FAILED_TITLE:
      en: "Error Starting App."
      zh: "启动应用错误。"

    PROC_RLT_FAILED_SUB_TITLE:
      en: "Please fix the following issues and try again:"
      zh: "请先解决以下下问题，然后重试。"

    PROC_ERR_INFO:
      en: "Error Details"
      zh: "错误详情"

    PROC_CLOSE_TAB:
      en: "Close"
      zh: "关闭标签"

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
<li>Watch short <a href='http://docs.visualops.io/source/tutorial/video.html' target='_blank'>Tutorial Videos</a>. </li>"
      zh: "<li>Play with the 5 sample stacks prebuilt in Virginia region.</li>
<li>Read <a href='http://docs.visualops.io/' target='_blank'>Documentation</a>.</li>
<li>Watch short <a href='http://docs.visualops.io/source/tutorial/video.html' target='_blank'>Tutorial Videos</a>. </li>"

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


    DASH_CREATE_NEW_STACK:
      en: "Create new stack"
      zh: "创建模板"

    DASH_IMPORT_JSON:
      en: "Import stack"
      zh: "导入Stack"

    DASH_VISUALIZE_VPC:
      en: "Visualize existing VPC"
      zh: "可视化VPC"


    DASH_TIT_VIEW_RESOURCE_DETAIL:
      en: "View resource detail"
      zh: ""

    DASH_MSG_RELOAD_AWS_RESOURCE_SUCCESS:
      en: "Status of resources is up to date."
      zh: "资源更新完毕"

    DASH_TIP_UNMANAGED_RESOURCE:
      en: "Unmanaged Resource"
      zh: "非托管资源"

    DASH_TIP_NO_RESOURCE_LEFT:
      en: "There is no "
      zh: "该地区没有"

    DASH_TIP_NO_RESOURCE_RIGHT:
      en: " in this region"
      zh: ""

    DASH_TIP_APP_CREATED_BY:
      en: "App created by "
      zh: ""

    DASH_TIP_APP_CREATED_BY_OTHER_USER:
      en: "App created by other user"
      zh: ""

    DASH_BTN_GLOBAL:
      en: "Global"
      zh: "全局"

    DASH_LBL_UNMANAGED:
      en: "Unmanaged"
      zh: "非托管的"

    DASH_LBL_APP:
      en: "App"
      zh: "应用"

    DASH_LBL_STACK:
      en: "Stack"
      zh: "模板"

    DASH_LBL_RECENT_EDITED_STACK:
      en: "Recently Edited Stack"
      zh: "最近修改的模板"

    DASH_LBL_RECENT_LAUNCHED_STACK:
      en: "Recently Launched App"
      zh: "最近启动的实例"

    DASH_LBL_NO_APP:
      en: "There is no app launched yet.<br />You can launch an app from a stack."
      zh: "该地区没有应用<br />你可以通过模板创建应用"

    DASH_LBL_NO_STACK:
      en: "There is no stack in this region yet.<br />Create a new stack from here."
      zh: "该地区还没有模板<br />点击这里创建新模板"

    DASH_LBL_RUNNING_INSTANCE:
      en: "Running Instance"
      zh: "运行的实例"

    DASH_LBL_ELASTIC_IP:
      en: "Elastic IP"
      zh: "弹性IP"

    DASH_LBL_VOLUME:
      en: "Volume"
      zh: "卷"

    DASH_LBL_LOAD_BALANCER:
      en: "Load Balancer"
      zh: "负载均衡器"

    DASH_LBL_VPN:
      en: "VPN"
      zh: "VPN"

    DASH_LBL_INSTANCE:
      en: "Instance"
      zh: "实例"

    DASH_LBL_VPC:
      en: "VPC"
      zh: "VPC"

    DASH_LBL_AUTO_SCALING_GROUP:
      en: "Auto Scaling Group"
      zh: "Auto Scaling 组"

    DASH_LBL_CLOUDWATCH_ALARM:
      en: "CloudWatch Alarm"
      zh: "CloudWatch 警报"

    DASH_LBL_SNS_SUBSCRIPTION:
      en: "SNS Subscription"
      zh: "SNS 订阅"

    DASH_LBL_ID:
      en: "ID"
      zh: "ID"

    DASH_LBL_INSTANCE_ID:
      en: "Instance ID"
      zh: "实例ID"

    DASH_LBL_INSTANCE_NAME:
      en: "Instance Name"
      zh: "实例名"

    DASH_LBL_NAME:
      en: "Name"
      zh: "名称"

    DASH_LBL_STATUS:
      en: "Status"
      zh: "状态"

    DASH_LBL_STATE:
      en: "State"
      zh: "状态"

    DASH_LBL_LAUNCH_TIME:
      en: "Launch Time"
      zh: "启动时间"

    DASH_LBL_AMI:
      en: "AMI"
      zh: "AMI"

    DASH_LBL_AVAILABILITY_ZONE:
      en: "Availability Zone"
      zh: "可用区域"

    DASH_LBL_DETAIL:
      en: "Detail"
      zh: "详细"

    DASH_LBL_IP:
      en: "IP"
      zh: "IP"

    DASH_LBL_ASSOCIATED_INSTANCE:
      en: "Associated Instance"
      zh: "关联实例"

    DASH_LBL_CREATE_TIME:
      en: "Create Time"
      zh: "创建时间"

    DASH_LBL_DEVICE_NAME:
      en: "Device Name"
      zh: "设备名"

    DASH_LBL_ATTACHMENT_STATUS:
      en: "Attachment Status"
      zh: "附加状态"

    DASH_LBL_CIDR:
      en: "CIDR"
      zh: "CIDR"

    DASH_LBL_DHCP_SETTINGS:
      en: "DHCP Settings"
      zh: "DHCP设置"

    DASH_LBL_VIRTUAL_PRIVATE_GATEWAY:
      en: "Virtual Private Gateway"
      zh: "虚拟专用网关"

    DASH_LBL_CUSTOMER_GATEWAY:
      en: "Customer Gateway"
      zh: "客户网关"

    DASH_LBL_DNS_NAME:
      en: "DNS Name"
      zh: "域名"

    DASH_LBL_DOMAIN:
      en: "Domain"
      zh: "域"

    DASH_LBL_CURRENT:
      en: "Current"
      zh: "当前"

    DASH_LBL_LAST_ACTIVITY:
      en: "Last Activity"
      zh: "最近活动"

    DASH_LBL_ACTIVITY_STATUS:
      en: "Activity Status"
      zh: "活动状态"

    DASH_LBL_DIMENSION:
      en: "Dimension"
      zh: "维度"

    DASH_LBL_THRESHOLD:
      en: "Threshold"
      zh: "阈值"

    DASH_LBL_TOPIC_NAME:
      en: "Topic Name"
      zh: "主题名"

    DASH_LBL_ENDPOINT_AND_PROTOCOL:
      en: "Endpoint and Protocol"
      zh: "终端和协议"

    DASH_LBL_CONFIRMATION:
      en: "Confirmation"
      zh: "确认"

    DASH_LBL_SUBNETS:
      en: "Subnets"
      zh: "子网"

    DASH_LBL_ASSOCIATION_ID:
      en: "Association ID"
      zh: "关联 ID"

    DASH_LBL_ALLOCATION_ID:
      en: "Allocation ID"
      zh: "分配 ID"

    DASH_LBL_NETWORK_INTERFACE_ID:
      en: "Network Interface ID"
      zh: "网络接口 ID"

    DASH_LBL_PRIVATE_IP_ADDRESS:
      en: "Private Ip Address"
      zh: "内网IP地址"

    DASH_LBL_AUTOSCALING_GROUP_NAME:
      en: "Auto Scaling Group Name"
      zh: "Auto Scaling组名"

    DASH_LBL_AUTOSCALING_GROUP_ARN:
      en: "Auto Scaling Group ARN"
      zh: "Auto Scaling组ARN"

    DASH_LBL_ENABLED_METRICS:
      en: "Enabled Metrics"
      zh: "开启的指标"

    DASH_LBL_LAUNCH_CONFIGURATION_NAME:
      en: "Launch Configuration Name"
      zh: "启动配置名称"

    DASH_LBL_LOADBALANCER_NAMES:
      en: "LoadBalancer Names"
      zh: "负载均衡器名称"

    DASH_LBL_MIN_SIZE:
      en: "MinSize"
      zh: "最小值"

    DASH_LBL_MAX_SIZE:
      en: "MaxSize"
      zh: "最大值"

    DASH_LBL_TERMINATION_POLICIES:
      en: "Termination Policies"
      zh: "结束策略"

    DASH_LBL_VPC_ZONE_IDENTIFIER:
      en: "VPC Zone Identifier"
      zh: "VPC区域标识符"

    DASH_LBL_ACTIONS_ENABLED:
      en: "Actions Enabled"
      zh: "操作启用"

    DASH_LBL_ALARM_ACTIONS:
      en: "Alarm Actions"
      zh: "警报操作"

    DASH_LBL_ALARM_ARN:
      en: "Alarm Arn"
      zh: "警报 ARN"

    DASH_LBL_ALARM_DESCRIPTION:
      en: "Alarm Description"
      zh: "警报描述"

    DASH_LBL_ALARM_NAME:
      en: "Alarm Name"
      zh: "警报名称"

    DASH_LBL_COMPARISON_OPERATOR:
      en: "Comparison Operator"
      zh: "比较操作符"

    DASH_LBL_DIMENSIONS:
      en: "Dimensions"
      zh: "维度"

    DASH_LBL_EVALUATION_PERIODS:
      en: "Evaluation Periods"
      zh: "评估周期"

    DASH_LBL_INSUFFICIENT_DATA_ACTIONS:
      en: "Insufficient Data Actions"
      zh: "数据不足操作"

    DASH_LBL_METRIC_NAME:
      en: "Metric Name"
      zh: "指标名称"

    DASH_LBL_NAMESPACE:
      en: "Namespace"
      zh: "命名空间"

    DASH_LBL_OK_ACTIONS:
      en: "OK Actions"
      zh: "OK操作"

    DASH_LBL_PERIOD:
      en: "Period"
      zh: "周期"

    DASH_LBL_STATISTIC:
      en: "Statistic"
      zh: "统计数据"

    DASH_LBL_STATE_VALUE:
      en: "State Value"
      zh: "状态值"

    DASH_LBL_UNIT:
      en: "Unit"
      zh: "单位"

    DASH_LBL_ENDPOINT:
      en: "Endpoint"
      zh: "终端"

    DASH_LBL_OWNER:
      en: "Owner"
      zh: "拥有者"

    DASH_LBL_PROTOCOL:
      en: "Protocol"
      zh: "协议"

    DASH_LBL_SUBSCRIPTION_ARN:
      en: "Subscription ARN"
      zh: "订阅 ARN"

    DASH_LBL_TOPIC_ARN:
      en: "Topic ARN"
      zh: "主题 ARN"

    DASH_BUB_NAME:
      en: "Name"
      zh: "名称"

    DASH_BUB_DESCRIPTION:
      en: "Description"
      zh: "描述"

    DASH_BUB_ARCHITECTURE:
      en: "Architecture"
      zh: "架构"

    DASH_BUB_IMAGELOCATION:
      en: "Image Location"
      zh: "映像位置"

    DASH_BUB_IMAGEOWNERALIAS:
      en: "Image Owner Alias"
      zh: "映像所有者别名"

    DASH_BUB_IMAGEOWNERID:
      en: "Image Owner ID"
      zh: "映像所有者ID"

    DASH_BUB_ISPUBLIC:
      en: "Public"
      zh: "是否公用"

    DASH_BUB_KERNELID:
      en: "KernelId"
      zh: "内核ID"

    DASH_BUB_ROOTDEVICENAME:
      en: "Root Device Name"
      zh: "根设备名"

    DASH_BUB_ROOTDEVICETYPE:
      en: "Root Device Type"
      zh: "根设备类型"

    DASH_POP_CREATE_STACK_CREATE_THIS_STACK_IN:
      en: "Create this stack in"
      zh: "将模板创建为"

    DASH_POP_CREATE_STACK_CREATE_STACK_ERROR:
      en: "Create stack error"
      zh: "创建模板出错"

    DASH_POP_FALE_LOAD_RESOURCE_PLEASE_RETRY:
      en: "Failed to load region information. Please try agian."
      zh: "加载地区资源失败。请重试。"

    DASH_POP_BTN_RETRY:
      en: "Retry"
      zh: "重试"

    DASH_POP_CREATE_STACK_CLASSIC:
      en: "Classic"
      zh: "传统模式"

    DASH_POP_CREATE_STACK_CLASSIC_INTRO:
      en: "Resources will be created into the Classic platform"
      zh: "资源将被创建在传统的平台中"

    DASH_POP_CREATE_STACK_VPC:
      en: "VPC"
      zh: "VPC模式"

    DASH_POP_CREATE_STACK_VPC_INTRO:
      en: "Resources will be created into a newly created VPC"
      zh: "资源将被创建在新创建的VPC中"

    DASH_POP_CREATE_STACK_DEFAULT_VPC:
      en: "Default VPC"
      zh: "默认VPC"

    DASH_POP_CREATE_STACK_CUSTOM_VPC:
      en: "Custom VPC"
      zh: "定制VPC"

    DASH_POP_CREATE_STACK_DEFAULT_VPC_INTRO:
      en: "Resources will be created into the default VPC"
      zh: "资源将被创建在新默认的VPC中"

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

    RUN_STACK:
      en: "run stack"
      zh: "运行"

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
      en: "Auto scaling group in this app will be deleted when it is stopped."
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
      en: " Terminating it will make your service unavailable."
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

    ##### State Editor

    ## State Editor Tooltip

    STATE_TIP_DELETE_STATE:
      en: "Delete State"
      zh: ""

    STATE_TIP_SELECT_STATE:
      en: "Select State"
      zh: ""

    STATE_TIP_DESCRIPTION:
      en: "Help"
      zh: ""

    STATE_TIP_STATE_LOG:
      en: "State Log"
      zh: ""

    STATE_TIP_REFRESH_STATE_LOG:
      en: "Refresh State Log"
      zh: ""

    STATE_TIP_SYSTEM_LOG:
      en: "System Log"
      zh: ""

    STATE_TIP_SELECT_ALL_STATES:
      en: "Select All States"
      zh: ""

    ## State Editor Special State

    STATE_UNKNOWN_DISTRO_LBL:
      en: "The AMI's distro cannot be recognised. Some state modules may not apply to this AMI."
      zh: ""

    STATE_NO_STATE_LBL:
      en: "No state configured yet."
      zh: ""

    STATE_NO_STATE_ADD_BTN:
      en: "Add a State"
      zh: ""

    ## State Editor Toolbar

    STATE_TOOL_ADD_STATE:
      en: "Add State"
      zh: ""

    STATE_TOOL_COPY_ALL:
      en: "Copy All"
      zh: ""

    STATE_TOOL_COPY_SELECTED:
      en: "Copy "
      zh: ""

    STATE_TOOL_DELETE:
      en: "Delete "
      zh: ""

    STATE_TOOL_PASTE:
      en: "Paste"
      zh: ""

    STATE_TOOL_UNDO:
      en: "Undo"
      zh: ""

    STATE_TOOL_REDO:
      en: "Redo"
      zh: ""

    ## State Editor Log

    STATE_LOG_TIT:
      en: "State Log"
      zh: ""

    STATE_LOG_LOADING_LBL:
      en: "Loading..."
      zh: ""

    STATE_LOG_VIEW_DETAIL:
      en: "View details..."
      zh: ""

    STATE_LOG_ITEM_INSTANCE:
      en: "Instance"
      zh: ""

    STATE_LOG_ITEM_UNKNOWN:
      en: "unknown"
      zh: ""

    STATE_LOG_DETAIL_MOD_TIT:
      en: "State Log Detail"
      zh: ""

    STATE_LOG_DETAIL_MOD_CLOSE_BTN:
      en: "Close"
      zh: ""

    STATE_TEXT_EXPAND_MODAL_SAVE_BTN:
      en: "Save"
      zh: ""

    STATE_TEXT_EXPAND_MODAL_CLOSE_BTN:
      en: "Close"
      zh: ""

    ## State Editor Help

    STATE_HELP_INTRO_LBL:
      en: "<p>Select or input a command to see a related help document here. Read detailed <a href='http://docs.visualops.io/source/reference/mod.html' target='_blank'>documentation</a>.</p>"
      zh: ""

    ##### Request Invite to Experimental Feature

    INVITE_MOD_TIT:
      en: "Request invitation to experimental new feature"
      zh: ""

    INVITE_MOD_INTRO:
      en: "Introduce <b>Instance State</b>,<br>a new way to devOps your infrastructure!"
      zh: ""

    INVITE_MOD_INTRO_MORE:
      en: "<b>Instance State</b> enables you to manage the software layer of your instances. Software packages, configuration files, services, all are there in a very easy, intuitive and functional way."
      zh: ""

    INVITE_MOD_REQUEST_TIT:
      en: "Request an Invite"
      zh: ""

    INVITE_MOD_REQUEST_CONTENT:
      en: "This feature is experimental and still in a beta phase. If you are interested, feel free to request an invite for early peek!"
      zh: ""

    INVITE_MOD_REQUEST_PLACEHOLDER:
      en: "Tell us more about your use case, why you are interested etc. to help us accelerate the approval of request."
      zh: ""

    INVITE_MOD_BTN_REQUEST:
      en: "Request an Invite"
      zh: ""

    INVITE_MOD_BTN_CANCEL:
      en: "Cancel"
      zh: ""

    INVITE_MOD_THANK_LBL:
      en: "Your request has been sent."
      zh: ""

    INVITE_MOD_THANK_MORE:
      en: "Thanks for your interest. We will get back with you soon."
      zh: ""

    INVITE_MOD_BTN_DONE:
      en: "Done"
      zh: ""

    ##### Keyboard Shortcuts Modal
    KEY_MOD_TIT:
      en: "Keyboard Shortcuts (?)"
      zh: ""

    # Stack/App Operation

    KEY_TIT_STACK_APP_OP:
      en: "Canvas"
      zh: ""

    KEY_PROP_KEY:
      en: "P"
      zh: ""

    KEY_PROP_ACTION:
      en: "Open Property Panel"
      zh: ""

    KEY_STAT_KEY:
      en: "S"
      zh: ""

    KEY_STAT_ACTION:
      en: "Open State Panel"
      zh: ""

    KEY_DUPL_KEY_MAC:
      en: "Option + drag"
      zh: ""

    KEY_DUPL_KEY_PC:
      en: "Alt + drag"
      zh: ""

    KEY_DUPL_ACTION:
      en: "Duplicate the selected instance"
      zh: ""

    KEY_DEL_KEY_MAC:
      en: "Delete"
      zh: ""

    KEY_DEL_KEY_PC:
      en: "Delete/Backspace"
      zh: ""

    KEY_DEL_ACTION:
      en: "Delete the selected item"
      zh: ""

    KEY_SAVE_KEY_MAC:
      en: "Command + S"
      zh: ""

    KEY_SAVE_KEY_PC:
      en: "Ctrl + S"
      zh: ""

    KEY_SAVE_ACTION:
      en: "Save the stack"
      zh: ""

    KEY_SCRL_KEY_MAC:
      en: "Command + drag"
      zh: ""

    KEY_SCRL_KEY_PC:
      en: "Ctrl + drag"
      zh: ""

    KEY_SCRL_ACTION:
      en: "Scroll the canvas"
      zh: ""

    # State Panel Operation - General

    KEY_TIT_STATE_GEN:
      en: "State Panel - General"
      zh: ""

    KEY_FOCUS_KEY:
      en: "Up/Down"
      zh: ""

    KEY_FOCUS_ACTION:
      en: "Switch focus in the state list"
      zh: ""

    KEY_SELECT_KEY:
      en: "Space"
      zh: ""

    KEY_SELECT_ACTION:
      en: "Select/unselect the focused state"
      zh: ""

    KEY_EXPAND_KEY:
      en: "ENTER"
      zh: ""

    KEY_EXPAND_ACTION:
      en: "Expand the focused state"
      zh: ""

    KEY_COLLAPSE_KEY:
      en: "ESC"
      zh: ""

    KEY_COLLAPSE_ACTION:
      en: "Fold the focused state"
      zh: ""

    KEY_NEXT_KEY:
      en: "Tab"
      zh: ""

    KEY_NEXT_ACTION:
      en: "Switch to the next input"
      zh: ""

    KEY_PREV_KEY:
      en: "Shift + Tab"
      zh: ""

    KEY_CONTENT_EDITOR_MAC:
      en: "Command + E"
      zh: ""

    KEY_CONTENT_EDITOR_PC:
      en: "Ctrl + E"
      zh: ""

    KEY_CONTENT_EDITOR_ACTION:
      en: "Open content editor"
      zh: ""

    KEY_PREV_ACTION:
      en: "Switch back to the previous input"
      zh: ""

    KEY_INFO_KEY_MAC:
      en: "Command + I"
      zh: ""

    KEY_INFO_KEY_PC:
      en: "Ctrl + I"
      zh: ""

    KEY_INFO_ACTION:
      en: "Open/fold the help"
      zh: ""

    KEY_LOG_KEY_MAC:
      en: "Command + L"
      zh: ""

    KEY_LOG_KEY_PC:
      en: "Ctrl + L"
      zh: ""

    KEY_LOG_ACTION:
      en: "Open/fold the log"
      zh: ""

    # State Panel Operation - Editable Mode

    KEY_TIT_STATE_EDIT:
      en: "State Panel - Edit Mode"
      zh: ""

    KEY_SELECT_ALL_KEY_MAC:
      en: "Command + A"
      zh: ""

    KEY_SELECT_ALL_KEY_PC:
      en: "Ctrl + A"
      zh: ""

    KEY_SELECT_ALL_ACTION:
      en: "Select all states"
      zh: ""

    KEY_DESELECT_KEY_MAC:
      en: "Command + D"
      zh: ""

    KEY_DESELECT_KEY_PC:
      en: "Ctrl + D"
      zh: ""

    KEY_DESELECT_ACTION:
      en: "Deselect all states"
      zh: ""

    KEY_CREATE_KEY_MAC:
      en: "Command + Enter"
      zh: ""

    KEY_CREATE_KEY_PC:
      en: "Ctrl + Enter"
      zh: ""

    KEY_CREATE_ACTION:
      en: "Add a new state"
      zh: ""

    KEY_DEL_STATE_KEY_MAC:
      en: "Command + Delete"
      zh: ""

    KEY_DEL_STATE_KEY_PC:
      en: "Ctrl + Delete"
      zh: ""

    KEY_DEL_STATE_ACTION:
      en: "Delete selected state(s)"
      zh: ""

    KEY_MOVE_FOCUS_STATE_KEY_MAC:
      en: "Command + Up/Down"
      zh: ""

    KEY_MOVE_FOCUS_STATE_KEY_PC:
      en: "Ctrl + Up/Down"
      zh: ""

    KEY_MOVE_FOCUS_STATE_ACTION:
      en: "Move the focused state"
      zh: ""

    KEY_COPY_STATE_KEY_MAC:
      en: "Command + C"
      zh: ""

    KEY_COPY_STATE_KEY_PC:
      en: "Ctrl + C"
      zh: ""

    KEY_COPY_STATE_ACTION:
      en: "Copy the selected state(s)"
      zh: ""

    KEY_PASTE_STATE_KEY_MAC:
      en: "Command + V"
      zh: ""

    KEY_PASTE_STATE_KEY_PC:
      en: "Ctrl + V"
      zh: ""

    KEY_PASTE_STATE_ACTION:
      en: "Paste the copied state(s)"
      zh: ""

    KEY_UNDO_STATE_KEY_MAC:
      en: "Command + Z"
      zh: ""

    KEY_UNDO_STATE_KEY_PC:
      en: "Ctrl + Z"
      zh: ""

    KEY_UNDO_STATE_ACTION:
      en: "Undo"
      zh: ""

    KEY_REDO_STATE_KEY_MAC:
      en: "Command + Y"
      zh: ""

    KEY_REDO_STATE_KEY_PC:
      en: "Ctrl + Y"
      zh: ""

    KEY_REDO_STATE_ACTION:
      en: "Redo"
      zh: ""

    KEY_MODAL_BTN_CLOSE:
      en: "Close"
      zh: ""

    ##### State Editor

    ##### Trust Advisor

    # VPC
    TA_MSG_WARNING_NOT_VPC_CAN_CONNECT_OUTSIDE:
      en: "No instance in VPC has Elastic IP or auto-assigned public IP, which means this VPC can only connect to outside via VPN."
      # en: "No instance in VPC has Elastic IP, which means this VPC can only connect to outside via VPN."
      zh: ""

    # Subnet
    TA_MSG_ERROR_CIDR_ERROR_CONNECT_TO_ELB:
      en: "Subnet <span class='validation-tag tag-subnet'>%s</span> is attached with a Load Balancer. Its mask must be smaller than /27."
      zh: ""

    # Instance
    TA_MSG_NOTICE_INSTANCE_NOT_EBS_OPTIMIZED_FOR_ATTACHED_PROVISIONED_VOLUME:
      en: "Instance <span class='validation-tag tag-instance'>%s</span> has an attached Provisioned IOPS volume but is not EBS-Optimized."
      zh: ""
    TA_MSG_WARNING_INSTANCE_SG_RULE_EXCEED_FIT_NUM:
      en: "Instance <span class='validation-tag tag-instance'>%s</span> has more than %s security group rules, If a Instance has a large number of security group rules, performance can be degraded."
      zh: ""
    TA_MSG_ERROR_INSTANCE_NAT_CHECKED_SOURCE_DEST:
      en: "To allow routing to work properly, instance <span class='validation-tag tag-instance'>%s</span> should disabled Source/Destination Checking in \"Network Interface Details\""
      zh: ""

    TA_MSG_ERROR_INSTANCE_REF_OLD_KEYPAIR:
      en: "%s has associated with an nonexistient key pair <span class='validation-tag'>%s</span>. Make sure to use an existing key pair or creating a new one."
      zh: ""

    TA_MSG_NOTICE_KEYPAIR_LONE_LIVE:
      en: "Make sure you have access to all private key files associated with instances or launch configurations. Without them, you won't be able to log into your instances."
      zh: ""


    # ENI
    TA_MSG_ERROR_ENI_NOT_ATTACH_TO_INSTANCE:
      en: "Network Interface <span class='validation-tag tag-eni'>%s</span> is not attached to any Instance."
      zh: ""

    # ELB
    TA_MSG_ERROR_VPC_HAVE_INTERNET_ELB_AND_NO_HAVE_IGW:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> is internet-facing but VPC no have an Internet Gateway."
      zh: ""

    TA_MSG_ERROR_ELB_NO_ATTACH_INSTANCE_OR_ASG:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> has no instance or auto scaling group added to it."
      zh: ""

    TA_MSG_WARNING_ELB_NO_ATTACH_TO_MULTI_AZ:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> is attached to only 1 availability zone. Attach load balancer to multiple availability zones can improve fault tolerance."
      zh: ""

    TA_MSG_NOTICE_ELB_REDIRECT_PORT_443_TO_443:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> redirects <span class='validation-tag tag-port'>443</span> to <span class='validation-tag tag-port'>443</span>. Suggest to use load balancer to decrypt and redirect to port <span class='validation-tag tag-port'>80</span>."
      zh: ""

    TA_MSG_ERROR_ELB_HAVE_REPEAT_LISTENER_ITEM:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> has duplicate load balancer ports."
      zh: ""

    TA_MSG_ERROR_ELB_HAVE_NO_SSL_CERT:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> is using HTTPS/SSL protocol for Load Balancer Listener. Please add server certificate."
      zh: ""

    TA_MSG_ERROR_ELB_RULE_NOT_INBOUND_TO_ELB_LISTENER:
      en: "Load balancer <span class='validation-tag tag-elb'>%s</span> should allow inbound traffic towards its Load Balancer Protocol: %s."
      zh: ""

    TA_MSG_WARNING_ELB_RULE_NOT_INBOUND_TO_ELB_PING_PORT:
      en: "Load balancer <span class='validation-tag tag-elb'>%s</span>'s security group rule should allow inbound traffic towards its ping port: <span class='validation-tag tag-port'>%s</span>."
      zh: ""

    TA_MSG_ERROR_ELB_RULE_NOT_OUTBOUND_TO_INSTANCE_LISTENER:
      en: "Load balancer <span class='validation-tag tag-elb'>%s</span> should allow outbound traffic towards its backend instance or auto-scaling group through Instance Protocol: %s."
      zh: ""

    TA_MSG_ERROR_ELB_RULE_INSTANCE_NOT_OUTBOUND_FOR_ELB_LISTENER:
      en: "%s <span class='validation-tag tag-elb'>%s</span> should allow inbound traffic towards %s according to %s's Instance Listener Protocol."
      zh: ""

    # SG
    TA_MSG_WARNING_SG_RULE_EXCEED_FIT_NUM:
      en: "Security Group <span class='validation-tag tag-sg'>%s</span> has more than %s rules, If a security group has a large number of rules, performance can be degraded."
      zh: ""
    TA_MSG_NOTICE_STACK_USING_ONLY_ONE_SG:
      en: "This stack is only using 1 security group."
      zh: ""
    TA_MSG_WARNING_SG_USING_ALL_PROTOCOL_RULE:
      en: "Security Group <span class='validation-tag tag-sg'>%s</span> is using 'ALL' protocol traffic."
      zh: ""
    TA_MSG_WARNING_SG_RULE_FULL_ZERO_SOURCE_TARGET_TO_OTHER_PORT:
      en: "Security Group <span class='validation-tag tag-sg'>%s</span> has inbound rule which traffic from <span class='validation-tag tag-ip'>0.0.0.0/0</span> is not targeting port <span class='validation-tag tag-port'>80</span> or <span class='validation-tag tag-port'>443</span>."
      zh: ""
    TA_MSG_NOTICE_SG_RULE_USING_PORT_22:
      en: "Security Group <span class='validation-tag tag-sg'>%s</span> has rule which using port <span class='validation-tag tag-port'>22</span>. To enhance security, suggest to use other port than <span class='validation-tag tag-port'>22</span>."
      zh: ""
    TA_MSG_WARNING_SG_RULE_HAVE_FULL_ZERO_OUTBOUND:
      en: "Security Group <span class='validation-tag tag-sg'>%s</span> has outbound rule towards <span class='validation-tag tag-ip'>0.0.0.0/0</span>. Suggest to change to more specific range."
      zh: ""
    TA_MSG_ERROR_RESOURCE_ASSOCIATED_SG_EXCEED_LIMIT:
      en: "%s <span class='validation-tag tag-%s'>%s</span>'s associated Security Group exceed max %s limit."
      zh: ""

    # ASG
    TA_MSG_ERROR_ASG_HAS_NO_LAUNCH_CONFIG:
      en:"Auto Scaling Group <span class='validation-tag tag-asg'>%s</span> has no launch configuration."
      zh:""

    TA_MSG_WARNING_ELB_HEALTH_NOT_CHECK:
      en: "Auto Scaling Group <span class='validation-tag tag-asg'>%s</span> has connected to Load Balancer but the Load Balancer health check is not enabled."
      zh: ""

    TA_MSG_ERROR_HAS_EIP_NOT_HAS_IGW:
      en: "VPC has instance with Elastic IP must have an Internet Gateway."
      zh: ""

    # RT
    TA_MSG_NOTICE_RT_ROUTE_NAT:
      en: "Instance <span class='validation-tag tag-instance'>%s</span> is a target of Route Table <span class='validation-tag tag-rtb'>%s</span>. To make sure the routing works, <span class='validation-tag tag-instance'>%s</span> should have security group rule to allow traffic from subnets assciated with <span class='validation-tag tag-rtb'>%s</span>."
      zh: ""

    TA_MSG_NOTICE_INSTANCE_HAS_RTB_NO_ELB:
      en: "Route Table <span class='validation-tag tag-rtb'>%s</span> has route to Instance <span class='validation-tag tag-instance'>%s</span>. If <span class='validation-tag tag-instance'>%s</span> is working as NAT instance, it should be assigned with an Elastic IP."
      zh: ""

    TA_MSG_WARNING_NO_RTB_CONNECT_IGW:
      en: "No Route Table is connected to Internet Gateway."
      zh: ""

    TA_MSG_WARNING_NO_RTB_CONNECT_VGW:
      en: "No Route Table is connected to VPN Gateway."
      zh: ""

    TA_MSG_NOTICE_ACL_HAS_NO_ALLOW_RULE:
      en: "Network ACL <span class='validation-tag tag-acl'>%s</span> has no ALLOW rule. The subnet(s) associate(s) with it cannot have traffic in or out."
      zh: ""

    TA_MSG_ERROR_RT_HAVE_CONFLICT_DESTINATION:
      en:"Route Table <span class='validation-tag tag-rtb'>%s</span> has routes with conflicting CIDR blocks."
      zh:""

    # AZ
    TA_MSG_WARNING_SINGLE_AZ:
      en: "Only 1 Availability Zone is used. Multiple Availability Zone can improve fault tolerance."
      zh: ""

    # CGW
    TA_MSG_ERROR_CGW_CHECKING_IP_CONFLICT:
      en:"Checking Customer Gateway IP Address confliction with existing resource..."
      zh:""
    TA_MSG_ERROR_CGW_IP_CONFLICT:
      en:"Customer Gateway <span class='validation-tag tag-cgw'>%s</span>'s IP <span class='validation-tag tag-ip'>%s</span> conflicts with existing <span class='validation-tag tag-cgw'>%s</span>'s IP <span class='validation-tag tag-ip'>%s</span>."
      zh:""
    TA_MSG_WARNING_CGW_IP_RANGE_ERROR:
      en:"Customer Gateway <span class='validation-tag tag-cgw'>%s</span>'s IP(%s) invalid."
      zh:""

    # VPN
    TA_MSG_ERROR_VPN_NO_IP_FOR_STATIC_CGW:
      en:"VPN Connection of <span class='validation-tag tag-cgw'>%s</span> and <span class='validation-tag tag-vgw'>%s</span> is missing IP prefix."
      zh:""
    TA_MSG_ERROR_VPN_NOT_PUBLIC_IP:
      en:"VPN Connection <span class='validation-tag tag-vpn'>%s</span>'s IP prefix <span class='validation-tag tag-ip'>%s</span> is invalid."
      zh:""

    # Stack
    TA_MSG_ERROR_STACK_CHECKING_FORMAT_VALID:
      en:"Checking Stack data format validity..."
      zh:""
    TA_MSG_ERROR_STACK_FORMAT_VALID_FAILED:
      en:"Resource %s has format problem, %s."
      zh:""
    TA_MSG_ERROR_STACK_HAVE_NOT_EXIST_AMI:
      en:"%s <span class='validation-tag tag-%s'>%s</span>'s AMI <span class='validation-tag tag-ami'>%s</span> is not available any more. Please change another AMI."
      zh:""
    TA_MSG_ERROR_STACK_HAVE_NOT_EXIST_SNAPSHOT:
      en:"Snapshot <span class='validation-tag tag-snapshot'>%s</span> attached to %s <span class='validation-tag tag-instance'>%s</span> is not available or not accessible to your account. Please change another one."
      zh:""
    TA_MSG_ERROR_STACK_HAVE_NOT_AUTHED_AMI:
      en:"You are not authorized for %s <span class='validation-tag tag-%s'>%s</span>'s AMI <span class='validation-tag tag-ami'>%s</span>. Go to AWS Marketplace to get authorized or use another AMI by creating new instance."
      zh:""

    # State Editor
    TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_INSTANCE:
      en: "Instance <span class='validation-tag tag-instance'>%s</span> <span class='validation-tag tag-state'>state %s</span> has referenced the inexistent <span class='validation-tag tag-state-ref'>%s</span>."
      zh: ""

    TA_MSG_ERROR_STATE_EDITOR_INEXISTENT_ASG:
      en: "Auto Scaling Group <span class='validation-tag tag-asg'>%s</span> <span class='validation-tag tag-state'>state %s</span> has referenced the inexistent <span class='validation-tag tag-state-ref'>%s</span>."
      zh: ""

    TA_MSG_ERROR_STATE_EDITOR_EMPTY_REQUIED_PARAMETER:
      en: "<span class='validation-tag tag-instance'>%s</span>'s <span class='validation-tag tag-state'>state %s</span> is missing required parameter <span class='validation-tag tag-parameter'>%s</span>."
      zh: ""

    # State
    TA_MSG_ERROR_NOT_CONNECT_OUT:
      en: "Subnet <span class='validation-tag tag-subnet'>%s</span> must be connected to internet directly or via a NAT instance. "
      zh: ""

    TA_MSG_ERROR_NO_EIP_OR_PIP:
      en: "<span class='validation-tag tag-instance'>%s</span> has configured states. To make sure OpsAgent to work, <span class='validation-tag tag-instance'>%s</span> must have an elastic IP or public IP. If not, subnet <span class='validation-tag tag-subnet'>%s</span>'s outward traffic must be routed to a <a href='javascript:void(0)' class='bubble bubble-NAT-instance' data-bubble-template='bubbleNATreq'>NAT instance</a>."
      zh: ""

    TA_MSG_ERROR_NO_CGW:
      en: "You have configured states for instance. To make sure OpsAgent to work, the VPC must have an internet gateway."
      zh: ""
    TA_MSG_ERROR_NO_OUTBOUND_RULES:
      en: "<span class='validation-tag tag-instance'>%s</span> has configured states. To make sure OpsAgent to work, it should have outbound rules on <span class='validation-tag tag-port'>80</span> and <span class='validation-tag tag-port'>443</span> ports to the outside."
      zh: ""
    TA_MSG_WARNING_OUTBOUND_NOT_TO_ALL:
      en: "<span class='validation-tag tag-instance'>%s</span> has configured states. Suggest to set its outbound rule on <span class='validation-tag tag-port'>80</span> and <span class='validation-tag tag-port'>443</span> to <span class='validation-tag tag-ip'>0.0.0.0/0</span>. Otherwise, agent may not be able to work properly, install packages or check out source codes lacking route to VisualOps's monitoring systems or required repositories."
      zh: ""



    ##### Trust Advisor

  service:

    NETWORK_ERROR:
      en: "Service is temporarily unavailable. Please try again later."
      zh: "服务暂时不可用, 请稍后重试"

    "ERROR_CODE_-1_MESSAGE_AWS_RESOURCE":
      en: "Sorry, we are suffering from some technical issues, please click the refresh icon at top right corner of Global tab again."
      zh: "对不起,我们有一些技术问题,请点击'我的资源'页上右上角的刷新图标"

    "ERROR_CODE_-1_MESSAGE":
      en: "Sorry, we are suffering from some technical issues, please try again later."
      zh: "对不起,我们有一些技术问题,请稍后再试"

    ERROR_CODE_0_MESSAGE:
      en: ""
      zh: ""

    ERROR_CODE_1_MESSAGE:
      en: "Sorry, AWS is suffering from some technical issues, please try again later."
      zh: "对不起,AWS有一些技术问题,请稍后再试"

    ERROR_CODE_2_MESSAGE:
      en: "Sorry, we are suffering from some technical issues, please try again later."
      zh: "对不起,我们有一些技术问题,请稍后再试"

    ERROR_CODE_3_MESSAGE:
      en: ""
      zh: ""

    ERROR_CODE_4_MESSAGE:
      en: ""
      zh: ""

    ERROR_CODE_5_MESSAGE:
      en: "Sorry, AWS is suffering from some technical issues, please try again later."
      zh: "对不起,AWS有一些技术问题,请稍后再试"

    ERROR_CODE_6_MESSAGE:
      en: ""
      zh: ""

    ERROR_CODE_7_MESSAGE:
      en: ""
      zh: ""

    ERROR_CODE_8_MESSAGE:
      en: ""
      zh: ""

    ERROR_CODE_9_MESSAGE:
      en: "Sorry, your AWS credentials have not sufficient permissions."
      zh: "对不起,您的AWS凭证没有足够的权限"

    ERROR_CODE_10_MESSAGE:
      en: ""
      zh: ""

    ERROR_CODE_11_MESSAGE:
      en: ""
      zh: ""

    ERROR_CODE_12_MESSAGE:
      en: "Sorry, we are suffering from some technical issues, please try again later."
      zh: "对不起,我们有一些技术问题,请稍后再试"

    ERROR_CODE_13_MESSAGE:
      en: ""
      zh: ""

    ERROR_CODE_14_MESSAGE:
      en: ""
      zh: ""

    ERROR_CODE_15_MESSAGE:
      en: "Sorry, AWS is suffering from some technical issues, please try again later."
      zh: "对不起,AWS有一些技术问题,请稍后再试"

    ERROR_CODE_16_MESSAGE:
      en: "Sorry, AWS is suffering from some technical issues, please try again later."
      zh: "对不起,AWS有一些技术问题,请稍后再试"

    ERROR_CODE_17_MESSAGE:
      en: ""
      zh: ""

    ERROR_CODE_18_MESSAGE:
      en: "Sorry, AWS is suffering from some technical issues, please try again later."
      zh: "对不起,AWS有一些技术问题,请稍后再试"

    ERROR_CODE_19_MESSAGE:
      en: "Sorry, your session has expired, please login again."
      zh: "对不起，你的会话已过期，请重新登录"

    ERROR_CODE_20_MESSAGE:
      en: "Sorry, this invitation has finished."
      zh: "对不起，邀请已经结束"

    ERROR_CODE_21_MESSAGE:
      en: "User has been blocked."
      zh: "对不起，此账号已被锁住"

    RESET_PASSWORD_ERROR_2:
      en: "Sorry, but your url is invalid. Please Check your url and try again."
      zh: "对不起, 您的链接地址不正确, 请检查后重试"

    RESET_PASSWORD_ERROR_12:
      en: "Sorry, password reset URL is invalid or has expired."
      zh: "对不起, 您的链接地址不正确或已经失效"

    RESET_PASSWORD_ERROR_18:
      en: "Sorry, but your params is invalid. Please check your url and try again."
      zh: "对不起, 您的参数不正确, 请检查后重试"
