# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =

  IDE:

    COMMA:
      en: ", "
      zh: "，"

    NAV_TIT_DASHBOARD:
      en: "Dashboard"
      zh: "仪表板"

    NAV_TIT_APPS:
      en: "Apps"
      zh: "Apps"

    NAV_TIT_STACKS:
      en: "Stacks"
      zh: "Stacks"

    NAV_LBL_GLOBAL:
      en: "Global"
      zh: "我的资源"

    IDE_MSG_ERR_OPEN_OLD_STACK_APP_TAB:
      en: "Sorry, the stack/app is too old, unable to open"
      zh: "抱歉，Stack/App的格式太旧了，无法打开。"

    IDE_MSG_ERR_OPEN_TAB:
      en: "Unable to open the stack/app, please try again"
      zh: "无法打开 Stack/App, 请重试"

    IDE_MSG_ERR_CONNECTION:
      en: "Unable to load some parts of the IDE, please refresh the browser"
      zh: "无法加载部分IDE内容，请重试"

    IDE_TIP_VISUALIZE_MORE_THAN_100_ENI:
      en: "Currently we do not support to visualize system has more than 300 network interfaces. Contact us by the Feedback button for details."
      zh: "我们目前尚不支持可视化超过300 个网络接口的系统, 如有需要请通过反馈按钮联系我们。"

    RES_TIT_RESOURCES:
      en: "Resources"
      zh: "资源"

    RES_TIP_SHARED_RESOURCES:
      en: "Manage other resources"
      zh: "资源"

    RES_TIP_REFRESH_RESOURCE_LIST:
      en: "Refresh resource list"
      zh: "刷新资源列表"

    RES_TIT_RESOURCES_MENU_KEYPAIR:
      en: "Manage Key Pairs..."
      zh: "管理密钥对"

    RES_TIT_RESOURCES_MENU_SNAPSHOT:
      en: "Manage EBS Snapshots..."
      zh: "管理 EBS 快照"

    RES_TIT_RESOURCES_MENU_SNS:
      en: "Manage SNS Topic & Subscriptions..."
      zh: "管理 SNS 主题和订阅"

    RES_TIT_RESOURCES_MENU_SSLCERT:
      en: "Manage Server Certificates..."
      zh: "管理服务器证书"

    RES_TIT_RESOURCES_MENU_DHCP:
      en: "Manage DHCP Option Sets..."
      zh: "管理 DHCP 选项组"

    RES_TIT_AZ:
      en: "AZ & Subnet"
      zh: "可用区和子网"

    RES_TIT_AMI:
      en: "Images"
      zh: "AMI"

    RES_TIT_VOL:
      en: "Volume & Snapshot"
      zh: "虚拟磁盘和快照"

    RES_TIT_SNAPSHOT_MANAGE:
      en: "Manage EBS Snapshot"
      zh: "管理 EBS 快照"

    RES_MSG_RDS_DISABLED:
      en: "Your AWS account does not have access to this resource. Please make sure you can access to all RDS-related resources. "
      zh: "您的 AWS 账号没有到此资源的权限， 请确定您有完整的 RDS 相关权限。"

    RES_TIT_RDS:
      en: "RDS & Snapshot"
      zh: "RDS和快照"

    RES_LBL_NEW_RDS_INSTANCE:
      en: "New DB Instance"
      zh: "新数据库实例"

    RES_LBL_NEW_RDS_INSTANCE_FROM_SNAPSHOT:
      en: "New DB from Snapshot"
      zh: "新的数据库实例快照"

    RES_TIT_RDS_SNAPSHOT_MANAGE:
      en: "Manage RDS Snapshot"
      zh: "管理 RDS 快照"

    RES_TIT_ELB_ASG:
      en: "Load Balancer and Auto Scaling"
      zh: "负载均衡器和 Auto Scaling 组"

    RES_TIT_REMOVE_FROM_FAVORITE:
      en: "Remove from Favorite"
      zh: "从收藏中移除"

    RES_TIT_ADD_TO_FAVORITE:
      en: "Add to Favorite"
      zh: "添加到收藏"

    RES_TIT_TOGGLE_FAVORITE:
      en: "Toggle favorite"
      zh: "收藏/取消收藏"

    RES_TIT_VPC:
      en: "Network"
      zh: "网络"

    RES_LBL_QUICK_START_AMI:
      en: "Quick Start Images"
      zh: "推荐的AMI"

    RES_LBL_MY_AMI:
      en: "My Images"
      zh: "我的AMI"

    RES_LBL_FAVORITE_AMI:
      en: "Favorite Images"
      zh: "收藏的AMI"

    RES_LBL_NEW_VOL:
      en: "New Volume"
      zh: "新的卷"

    RES_LBL_NEW_BLANK_VOL:
      en: "New Blank Volume"
      zh: "新的空白卷"

    RES_LBL_NEW_VOL_FROM_SNAPSHOT:
      en: "New Volume from Snapshot"
      zh: "从快照创建的新卷"

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
      zh: "子网组"

    RES_LBL_NEW_RTB:
      en: "Route Table"
      zh: "路由表"

    RES_LBL_NEW_IGW:
      en: "Internet Gateway"
      zh: "因特网网关"

    RES_LBL_NEW_VGW:
      en: "Virtual Private Gateway"
      zh: "虚拟专用网关"

    RES_LBL_NEW_CGW:
      en: "Customer Gateway"
      zh: "客户网关"

    RES_LBL_NEW_ENI:
      en: "Network Interface"
      zh: "网络接口"

    RES_BTN_BROWSE_COMMUNITY_AMI:
      en: "Browse Community Images"
      zh: "浏览社区 AMI"

    RES_TIP_TOGGLE_RESOURCE_PANEL:
      en: "Show/Hide Resource Panel"
      zh: "显示/隐藏 资源面板"

    RES_TIP_DRAG_AZ:
      en: "Drag to the canvas to use this availability zone"
      zh: "拖放到画布来使用这个可用区域"

    RES_TIP_DRAG_NEW_VOLUME:
      en: "Drag onto an instance to attach a new volume."
      zh: "拖放到一个实例来附加一个新卷。"

    RES_TIP_DRAG_NEW_ELB:
      en: "Drag to the canvas to create a new load balancer."
      zh: "拖放到画布来创建一个新负载均衡器。"

    RES_TIP_DRAG_NEW_ASG:
      en: "Drag to the canvas to create a new auto scaling group."
      zh: "拖放到画布来创建一个新 Auto Scaling 组。"

    RES_TIP_DRAG_NEW_SUBNET:
      en: "Drag to an availability zone to create a new subnet."
      zh: "拖放到一个可用区域来创建一个新子网。"

    RES_TIP_DRAG_CREATE_SUBNET_GROUP:
      en: "To create subnet group, there must to be subnets from at least %s different subnets cross availability zones on canvas."
      zh: "要创建子网组，画布上要至少有 %s 个跨不同可用区的子网。"

    RES_TIP_DRAG_NEW_SUBNET_GROUP:
      en: "Drag to an availability zone to create a new subnet group."
      zh: "拖拽到一个可用区域来创建一个新的子网组。"

    RES_TIP_DRAG_NEW_RTB:
      en: "Drag to a VPC to create a new route table."
      zh: "拖放到一个VPC来创建一个路由表。"

    RES_TIP_DRAG_NEW_IGW:
      en: "Drag to the canvas to create a new internet gateway."
      zh: "拖放到画布来创建一个新互联网网关。"

    RES_TIP_DRAG_NEW_VGW:
      en: "Drag to the canvas to create a new Virtual Private Gateway."
      zh: "拖放到画布来创建一个新虚拟专用网关。"

    RES_TIP_DRAG_NEW_CGW:
      en: "Drag to the canvas to create a new customer gateway."
      zh: "拖放到画布来创建一个新客户网关。"

    RES_TIP_DRAG_NEW_ENI:
      en: "Drag to a subnet to create a new network interface."
      zh: "拖放到一个子网来创建一个新网络接口。"

    RES_TIP_DRAG_HAS_IGW:
      en: "This VPC already has an internet gateway."
      zh: "这个VPC已经有了一个互联网网关。"

    RES_TIP_DRAG_HAS_VGW:
      en: "This VPC already has a Virtual Private Gateway."
      zh: "这个VPC已经有了一个虚拟专用网关。"

    RES_TIP_DRAG_TO_DUPLICATE:
      en: "Drag to create a read replica."
      zh: "拖动以创建只读副本。"

    RES_TIP_CANT_CREATE_MORE_REPLICA:
      en: "Can't create more read replica."
      zh: "无法创建更多的只读副本。"

    RES_TIP_PLEASE_WAIT_AUTOBACKUP_ENABLE_TO_CREATE_REPLICA:
      en: "Please wait Automatic Backup to be enabled to create read replica."
      zh: "请等待自动备份启用以创建只读副本。"

    RES_TIP_DRAG_TO_RESTORE:
      en: "Drag to restore to point in time"
      zh: "拖动以恢复到时间点"

    RES_MSG_INFO_ADD_AMI_FAVORITE_SUCCESS:
      en: "AMI is added to Favorite AMI"
      zh: "收藏AMI成功"

    RES_MSG_ERR_ADD_FAVORITE_AMI_FAILED:
      en: "Failed to add AMI to Favorite"
      zh: "收藏AMI失败"

    RES_MSG_ERR_REMOVE_FAVORITE_AMI_FAILED:
      en: "Failed to remove AMI from Favorite"
      zh: "AMI 从收藏列表移除失败"

    RDS_MSG_ERR_REMOVE_SUBNET_FAILED_CAUSEDBY_USEDBY_SBG:
      en: "%s is a member of subnet group %s. To delete the subnet, remove the membership first."
      zh: "%s 是子网组 %s 的成员， 要删除子网， 必须先删除成员。"

    RDS_MSG_ERR_REMOVE_AZ_FAILED_CAUSEDBY_CHILD_USEDBY_SBG:
      en: "Cannot delete availability zone because some subnet in it is used by a subnet group."
      zh: "无法删除可用区域， 因为里面有被子网组使用的子网。"

    PROC_STEP_REQUEST:
      en: "Processing"
      zh: "处理中"

    PROC_FAILED_TITLE:
      en: "Oops! Starting app failed."
      zh: "启动App错误"

    REG_MSG_WARN_APP_PENDING:
      en: "Your app is in Processing. Please wait a moment."
      zh: "您的App正在处理中，请稍等一会。"


    CFM_BTN_DELETE:
      en: "Delete"
      zh: "删除"

    CFM_BTN_REMOVE:
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
      zh: "运行、 停止、 终止 App 的结果将显示在这里。"

    HEAD_LABEL_MENUITEM_USER_TOUR:
      en: "User Tour"
      zh: "用户教程"

    HEAD_LABEL_MENUITEM_KEY_SHORT:
      en: "Keyboard Shortcuts"
      zh: "快捷键"

    HEAD_LABEL_MENUITEM_DOC:
      en: "Documentation"
      zh: "使用文档"

    HEAD_LABEL_MENUITEM_SETTING:
      en: "Settings"
      zh: "账号设置"

    HEAD_LABEL_MENUITEM_LOGOUT:
      en: "Log Out"
      zh: "登出"

    HEAD_LABEL_MENUITEM_BILLING:
      en: "Billing"
      zh: "账单"

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

    HEAD_LABEL_ACCOUNT_FULLNAME:
      en: "Full Name"
      zh: "全名"

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
      zh : "您正在使用测试帐号， 设置您的 AWS 证书以运行 Live 资源， 或者导入已有资源。"

    SETTINGS_CRED_DEMO_TEXT:
      en : "Some stack you build in demo mode may report error after setting up credential due to resource inconsistency between different accounts."
      zh : "由于两种账号之间资源的差异， 当您设置了 AWS 证书后， 一些您在测试账号时创建的 Stack 可能会报错。"

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
      zh: "通过点击&nbsp;账号&nbsp;&gt;安全性认证&nbsp;菜单，然后切换到页面中间的&nbsp;访问码&nbsp;页面，您将能找到您的访问码。 例如aBCDefgH/ Ijklmnopq1Rs2tUVWXY3AbcDeFGhijk"

    SETTINGS_LABEL_ACCOUNTID:
      en: "Account Number"
      zh: "账户 ID"

    SETTINGS_LABEL_ACCESSKEY:
      en: "Access Key ID"
      zh: "访问密钥 ID"

    SETTINGS_LABEL_SECRETKEY:
      en: "Secret Key"
      zh: "私有访问密钥"

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
      en: "API Token"
      zh: "API令牌"

    SETTINGS_INFO_TOKEN:
      en: "Use token within API calls to initiate automatic states update. "
      zh: "使用 API 接口的令牌以初始化自动 state 更新。"

    SETTINGS_BTN_TOKEN_CREATE:
      en: "Generate Token"
      zh: "生成令牌"

    SETTINGS_BTN_TOKEN_REMOVE:
      en: "Delete Token"
      zh: "删除令牌"

    SETTINGS_INFO_TOKEN_LINK:
      en: "Read detailed documentation."
      zh: "阅读详细文档"

    SETTINGS_INFO_TOKEN_EMPTY:
      en: "You currently have no token."
      zh: "您当前没有令牌"

    SETTINGS_CONFIRM_TOKEN_RM_TIT:
      en: 'Do you confirm to delete the "%s"?'
      zh: '您确定要删除 "%s" 吗?'

    SETTINGS_LABEL_TOKENTABLE_NAME:
      en: "Token Name"
      zh: "令牌名称"

    SETTINGS_LABEL_TOKENTABLE_TOKEN:
      en: "API Token"
      zh: "API令牌"

    SETTINGS_CONFIRM_TOKEN_RM:
      en: 'Any applications or scripts using this token will no longer be able to access the
VisualOps API. You cannot UNDO this action.'
      zh: '任何使用这个令牌的应用或脚本都将无法访问 VisualOps 的 API， 此操作无法撤销。'

    SETTINGS_CRED_CONNECTED_TIT:
      en: "You have connected with following AWS account:"
      zh: "您已经使用如下AWS账号连接："

    SETTINGS_CRED_REMOVE_TIT:
      en: "Do you confirm to remove AWS Credentials of account %s?"
      zh: "您确定要移除账号%s的AWS证书吗？"

    SETTINGS_CRED_REMOVE_TEXT:
      en: "<p>By removing Credentials, you will be in the demo mode.</p><p>If you want to launch stack into app, you need to provide valid AWS Credentials. </p><p>The stacks you designed in demo mode may not be able to launch with your AWS Credentials due to resource inconsistency.</p><p>If you have existing apps, they will become unmanageable and can only be forced to delete.</p>"
      zh: "<p>移除证书后， 您将处于 Demo 账号模式。</p><p>如果您想运行 App，您需要提供 AWS 证书。 </p><p>您在 Demo 账号模式下设计的 Stack 可能会因为资源获取的问题无法正常运行。 </p><p>如果您有已存在的 App， 将无法管理而强制删除。</p>"

    SETTINGS_CRED_ADDING:
      en : "Adding credential..."
      zh : "正在添加证书..."

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
      en : "Failed to validate the credential. <br> Make sure it is correct and at least has read access to AWS."
      zh : "您的证书验证失败。请保证其正确性，并至少拥有 AWS 的读权限。"

    SETTINGS_ERR_CRED_UPDATE:
      en : "Failed to update credential."
      zh : "更新证书失败。"

    SETTINGS_ERR_CRED_REMOVE:
      en : "Failed to remove credential."
      zh : "移除证书失败。"

    CRED_REMOVE_FAILD_CAUSEDBY_EXIST_APP:
      en: "Cannot remove credential when there exist apps in workspace. Try to forget apps first."
      zh: "当前工作空间存在 App，如想继续请先移除这些 App。"

    SETTINGS_ERR_PROJECT_REMOVE:
      en : "Failed to remove the workspace."
      zh : "删除项目失败。"

    SETTINGS_ERR_PROJECT_RENAME:
      en : "Failed to rename the workspace."
      zh : "项目改名失败。"

    SETTINGS_ERR_PROJECT_LEAVE:
      en : "Failed to leave the workspace."
      zh : "离开项目失败。"

    SETTINGS_CRED_UPDATE_CONFIRM_TIT:
      en : "<span>You have running or stopped app(s).</span> Do you confirm to update the AWS credential?"
      zh : "<span>系统中存在正在运行或已经停止的 App。</span>确定要更新 AWS 证书吗？"

    SETTINGS_CRED_UPDATE_CONFIRM_TEXT:
      en : "If you continue to use the new credential, existing apps might become unmanageable by VisualOps. If the new AWS credential does not have sufficient privileges to manage the existing apps, we strongly recommend to FORGET or TERMINATE existing apps first."
      zh : "如果继续操作，可能将导致已经存在的 App 无法被 VisualOps 管理。如果这个新 AWS 证书没有足够的权限管理现存的 App，我们强烈建议您先移除或终止掉这些存在的 App。"

    SETTINGS_LABEL_UPDATE_CONFIRM:
      en: "Confirm to update"
      zh: "确认更新"

    SETTINGS_ERR_INVALID_PWD:
      en: "New password must contain at least 6 characters."
      zh: "新密码最少6位且不能和您的用户名相同"

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
      zh: "是否重置密码？"

    COMPLETE_YOUR_PROFILE:
      en: "Complete your profile"
      zh: "完善您的资料"

    PROFILE_UPDATED_SUCCESSFULLY:
      en: "Your profile updated successfully"
      zh: "您的资料已经成功更新"

    FIRST_NAME:
      en: "First Name"
      zh: "名"

    LAST_NAME:
      en: "Last Name"
      zh: "姓"

    WELCOME_DIALOG_TIT:
      en: "Welcome to VisualOps"
      zh: "欢迎使用 VisualOps"

    WELCOME_PROVIDE_CRED_TIT:
      en: "Please provide new AWS credentials"
      zh: "请提供新的 AWS 证书"

    WELCOME_PROVIDE_CRED_DESC:
      en: "We cannot validate your AWS credentials, please provide new ones."
      zh: "我们无法验证您的 AWS 证书， 请提供一个新的。"

    WELCOME_TIT:
      en: "Welcome to VisualOps, "
      zh: "欢迎来到 VisualOps， "

    WELCOME_DESC:
      en: "To start designing cloud architecture, please provide your AWS credentials"
      zh: "要开始设计云架构， 请先提供 AWS 证书"

    WELCOME_SKIP_TIT:
      en: "Skip providing AWS Credentials now?"
      zh: "跳过提供 AWS 证书吗？"

    WELCOME_SKIP_SUBTIT:
      en: "You can design stack in the demo mode. Yet, with following drawbacks:"
      zh: "您可以在测试账号下设计 Stack， 但是有以下不足："

    WELCOME_SKIP_MSG:
      en: "<ul><li>The demo mode may not reflect the real condition of resources available for your account.</li> <li>If you want to provide credentials later, design previously created in demo mode may not work due to resource inconsistency.</li>"
      zh: "<ul><li>测试账号可能无法反映资源的实际可用性。</li> <li>如果您稍后提供证书， 因为资源差异的关系， 之前在测试账号设计的 Stack 可能会不可用。</li>"

    WELCOME_SKIP_MSG_EXTRA:
      en: "You can provide AWS Credentials later from Settings in the top-right drop down."
      zh: "您可以通过右上角下拉菜单中的设置来提供 AWS 证书。"

    WELCOME_DONE_TIT:
      en: "Get started with VisualOps"
      zh: "开始使用 VisualOps"

    WELCOME_DONE_HINT:
      en: "You have connected to AWS account: "
      zh: "您已连接到 AWS 账号： "

    WELCOME_DONE_HINT_DEMO:
      en: "You are using a demo AWS account."
      zh: "您正在使用测试账号。"

    WELCOME_DONE_MSG:
      en: "<li>Play with the 5 sample stacks prebuilt in Virginia region.</li>
<li>Read <a href='http://docs.visualops.io/' target='_blank'>Documentation</a>.</li>
<li>Watch short <a href='http://docs.visualops.io/aws/example/video.html' target='_blank'>Tutorial Videos</a>. </li>"
      zh: "<li>试用弗吉尼亚的5个示例 Stack。</li>
<li>阅读我们的 <a href='http://docs.visualops.io/' target='_blank'>文档</a>。</li>
<li>观看 <a href='http://docs.visualops.io/aws/example/video.html' target='_blank'>视频教程</a>。 </li>"

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
      zh: "通过工具栏可以运行Stack、自定义可视化数据以及导出数据和资源。"

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
      zh: "社区 AMI"

    AMI_LBL_ALL_SEARCH_AMI_BY_NAME_OR_ID:
      en: "Search AMI by name or ID"
      zh: "根据名称或ID搜索AMI"

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
      zh: "AMI ID"

    AMI_LBL_AMI_NAME:
      en: "AMI Name"
      zh: "AMI 名称"

    AMI_LBL_ARCH:
      en: "Arch"
      zh: "架构"

    AMI_LBL_PAGEINFO:
      en: "Showing %s-%s items of %s results"
      zh: "当前显示 %s-%s 条，共有 %s 条"

    AMI_TYPE_PUBLIC:
      en: "public"
      zh: "公共"

    AMI_TYPE_PRIVATE:
      en: "private"
      zh: "私有"

    IDE_COM_CREATE_NEW_STACK:
      en: "Create new stack"
      zh: "创建Stack"

    "IDE_LBL_REGION_NAME_cn-north-1":
      en: "CN North"
      zh: "中国"

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

    "IDE_LBL_REGION_NAME_eu-central-1":
      en: "EU Central"
      zh: "欧洲中部"

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

    "IDE_LBL_REGION_NAME_SHORT_cn-north-1":
      en: "Beijing"
      zh: "北京"

    "IDE_LBL_REGION_NAME_guangzhou":
      en: "Guangzhou"
      zh: "广州"

    "IDE_LBL_REGION_NAME_beijing":
      en: "BeiJing"
      zh: "北京"

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

    "IDE_LBL_REGION_NAME_SHORT_eu-central-1":
      en: "Frankfurt"
      zh: "法兰克福"

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

    "IDE_LBL_REGION_NAME_SHORT_guangzhou":
      en: "Guangzhou"
      zh: "广州"

    "IDE_LBL_REGION_NAME_SHORT_beijing":
      en: "BeiJing"
      zh: "北京"

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
      zh: "PEM 加密"

    RUN_STACK_MODAL_TITLE:
      en: "Run Stack"
      zh: "运行"

    RUN_STACK_MODAL_NEED_CREDENTIAL:
      en: "Set Up Credential First"
      zh: "请先设置 AWS 证书"

    RUN_STACK_MODAL_KP_WARNNING:
      en: "Specify a key pair as $DefaultKeyPair for this app."
      zh: "为此 $DefaultKeyPair 指定一个密钥对。"

    RUN_STACK_MODAL_CONFIRM_BTN:
      en: "Run Stack"
      zh: "运行"

    UPDATE_APP_MODAL_TITLE:
      en: "Update App"
      zh: "更新 App"

    CANT_UPDATE_APP:
      en: "Cannot Update App Now"
      zh: "现在无法更新 App"

    UPDATE_APP_CONFIRM_BTN:
      en: "Update App"
      zh: "更新 App"
    RUN_STACK:
      en: "run stack"
      zh: "运行"

    UPDATE_APP_MODAL_NEED_CREDENTIAL:
      en: "Please set Up Credential First"
      zh: "请先设置 AWS 证书"

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
      zh: '连接到子网来添加关联。'

    PORT_TIP_B:
      en: 'Connect to Internet Gateway, Virtual Private Gateway, instance or network interface to create route.'
      zh: '连接到 Internet 网关、 虚拟专用网关、 实例或者网络接口来创建路由。'

    PORT_TIP_C:
      en: 'Connect to route table to create route'
      zh: '连接到路由表来创建路由。'

    PORT_TIP_D:
      en: 'Connect to instance, auto scaling group, network interface or load balancer to create security group rule.'
      zh: '连接到实例、 Auto Scaling 组、 网络接口或者负载均衡器来创建安全组规则。'

    PORT_TIP_E:
      en: 'Connect to network interface to attach.'
      zh: '连接到网络接口。'

    PORT_TIP_F:
      en: 'Connect to instance, auto scaling group or network interface to create security group rule.'
      zh: '连接到实例， Auto Scaling 组或者网络接口来创建安全组规则。'

    PORT_TIP_G:
      en: 'Connect to instance to attach'
      zh: '连接到实例。'

    PORT_TIP_H:
      en: 'Connect to Customer Gateway to create VPN'
      zh: '连接到自定义网关来创建 VPN'

    PORT_TIP_I:
      en: 'Connect to Virtual Private Gateway to create VPN'
      zh: '连接到虚拟私有网关创建 VPN'

    PORT_TIP_J:
      en: 'Connect to instance or launch configuration to register it behind load balancer'
      zh: '连接到实例或者启动配置来注册到负载均衡。'

    PORT_TIP_K:
      en: 'Connect to subnet to associate'
      zh: '连接并关联到子网'

    PORT_TIP_L:
      en: 'Connect to load balancer to associate'
      zh: '连接到负载均衡'

    PORT_TIP_M:
      en: 'Connect to route table to associate'
      zh: '连接到路由表'

    PORT_TIP_N:
      en: "Connect to Port"
      zh: "连接到端口"

    PORT_TIP_O:
      en: "Connect to Load Balancer to register as member"
      zh: "连接到负载均衡以注册为成员"

    PORT_TIP_P:
      en: "Connect to Pool"
      zh: "连接到池"

    PORT_TIP_Q:
      en: "Connect to Listener"
      zh: "连接到 Listener"

    PORT_TIP_R:
      en: "Connect to Server"
      zh: "连接到 Server"

    PORT_TIP_S:
      en: "Connect to Subnet"
      zh: "连接到子网"

    PORT_TIP_T:
      en: "Connect to Router"
      zh: "连接到路由"

    PORT_TIP_U:
      en: "Connect to another app or group this item depends on"
      zh: ""

    PORT_TIP_V:
      en: "Connect to another app or group depends on this item"
      zh: ""



  ##### Modal Confirm Stop/Terminate App

    POP_CONFIRM_STOP_ASG:
      en: "Any auto scaling group will be deleted when application is stopped."
      zh: "App 停止的时候所有的Auto Scaling 组都将被删除。"

    POP_CONFIRM_PROD_APP_WARNING_MSG:
      en: " is for PRODUCTION."
      zh: " 处于生产环境。"

    POP_CONFIRM_STOP_PROD_APP_MSG:
      en: " Stopping it will make your service unavailable."
      zh: " 停止此 App 将导致服务不可用。"

    POP_CONFIRM_STOP_PROD_APP_INPUT_LBL:
      en: "Please type in the name of this app to confirm stopping it."
      zh: "请输入此 App 的名字来确认停止。"

    POP_CONFIRM_TERMINATE_PROD_APP_MSG:
      en: " Terminating it will make your service unavailable. Any auto scaling group will be deleted when application is stopped."
      zh: " 终止此 App 将导致服务不可用， 所有的Auto Scaling 组都将被删除。"

    POP_CONFIRM_FORGET_PROD_APP_INPUT_LBL:
      en: "Please type in the name of this app to confirm forgetting it."
      zh: "请输入此 APP 的名字来确认释放。"

    POP_CONFIRM_TERMINATE_PROD_APP_INPUT_LBL:
      en: "Please type in the name of this app to confirm terminating it."
      zh: "请输入此 APP 的名字来确认终止。"



    ##### Modal Import JSON

    POP_IMPORT_JSON_TIT:
      en: "Import Stack from JSON file"
      zh: "从 JSON 文件导入 Stack"

    POP_IMPORT_CF_TIT:
      en: "Import CloudFormation"
      zh: "导入CloudFormation"

    POP_IMPORT_DROP_LBL:
      en: "Drop a JSON file here or "
      zh: "拖拽 JSON 文件到这里。"

    POP_IMPORT_DROP_CF_LBL:
      en: "Drop a CloudFormation template here or"
      zh: "拖拽 CloudFormation 模板到这里。"

    POP_IMPORT_SELECT_LBL:
      en: " select a file."
      zh: " 或者选择一个文件。"

    POP_IMPORT_ERROR:
      en: "An error occurred when reading the file. Please try again."
      zh: "读取文件出错，请重试。"

    POP_IMPORT_FORMAT_ERROR:
      en: "The JSON file is malformed."
      zh: "此 JSON 格式不正确。"

    POP_IMPORT_MODIFIED_ERROR:
      en: "User modified JSON is not supported."
      zh: "我们不支持用户修改过的文件。"

    POP_IMPORT_CFM_ERROR:
      en: "Failed to import the CloudFormation. Please try another file."
      zh: "无法导入此CloudFormation文件。请尝试导入其他的文件。"

    ##### Modal Confirm Update

    POP_CONFIRM_UPDATE_TIT:
      en: "Confirm to Update App"
      zh: "确认更新 App"

    POP_CONFIRM_UPDATE_MAJOR_TEXT_RUNNING:
      en: "Do you confirm to apply the changes?"
      zh: "您确定要应用修改么？"

    POP_CONFIRM_UPDATE_MAJOR_TEXT_STOPPED:
      en: "Do you confirm to apply the changes and start the app?"
      zh: "您确定要应用修改并启动 App 吗？"

    POP_CONFIRM_UPDATE_MINOR_TEXT_STOPPED:
      en: "The app is currently stopped. To apply updates, the app will be started automatically."
      zh: "这个 App 已经停止， 要应用更改， 此 App 将自动启动。"

    POP_CONFIRM_UPDATE_TABLE_TYPE:
      en: "Type"
      zh: "类型"

    POP_CONFIRM_UPDATE_TABLE_NAME:
      en: "Name"
      zh: "名称"

    POP_CONFIRM_UPDATE_TABLE_CHANGE:
      en: "Change"
      zh: "修改"

    POP_CONFIRM_UPDATE_VALIDATION:
      en: "Validation"
      zh: "验证"

    POP_CONFIRM_UPDATE_VALIDATING:
      en: "Validating your app..."
      zh: "正在验证您的 App"

    POP_CONFIRM_UPDATE_CONFIRM_BTN:
      en: "Continue to Update"
      zh: "继续完成修改"

    POP_CONFIRM_UPDATE_CANCEL_BTN:
      en: "Cancel"
      zh: "取消"

    POP_SELECT_SUBNET_FOR_SUBNET_GROUP_TITLE:
      en: "Select Subnet for Subnet Group"
      zh: "为子网组选择子网"

    POP_SELECT_SUBNET_FOR_SUBNET_GROUP_CONTENT:
      en: "Add subnets from at least %s different availability zones to this subnet group. "
      zh: "至少从%s个不同的可用区域里添加子网到这个子网组里。"

    POP_LBL_DONE:
      en: "Done"
      zh: "完成"

    POP_LBL_CANCEL:
      en: "Cancel"
      zh: "取消"

    ##### Pop


    POP_CONFIRM_TO_REMOVE:
      en: "Confirm to Remove"
      zh: "确认移除"

    ##### RDS

    RDS_EDIT_OPTION_GROUP:
      en: "Edit Option Group"
      zh: "编辑选项组"

    RDS_SOME_ERROR_OCCURED:
      en: "Some error occurred"
      zh: "出错了"

    RDS_PORT_CHANGE_REQUIRES_APPLIED_IMMEDIATELY:
      en: "Edits with port change requires changes to be applied immediately."
      zh: "此端口的额修改需要被立即应用。"

    RDS_DELETE_DB_PG_FAILED:
      en: "%s DB Parameter Group(s) failed to delete, please try again later."
      zh: "%s 个数据库参数组删除失败，请稍后重试。"


    ##### RDS



    TIP_KEYPAIR_USED_DEFAULT_KP:
      en: "One or more instance/launch configuration has used $DefaultKeyPair. You need to specify which key pair (or no key pair) should be used for $DefaultKeyPair."
      zh: "一个或多个实例/启动配置使用了 $DefaultKeyPair。你需要给 $DefaultKeyPair 指定一个密钥对。"


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

    POP_INSTANCE_KEYPAIR_INFO_TIP:
      en: "If any instance or launch configuration uses $DefaultKeyPair, you will need to specify which key pair (or no key pair) should be used for $DefaultKeyPair when launching the instance or creating the launch configuration."
      zh: "如果您在任何实例或者启动配置里使用了 $DefaultKeyPair，启动实例或者开始启动配置的时候，您将需要为 $DefaultKeyPair 指定一个存在的密钥对。"

    POP_ACLRULE_TITLE_ADD:
      en: "Add Network ACL Rule"
      zh: "添加网络 ACL规则"

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
      zh: "端口范围，如80或49152-65535"

    POP_ACLRULE_LBL_PORT_RANGE_ALL:
      en: "Port Range:0-65535"
      zh: "端口范围：0-65535"

    NAV_DESMOD_NOT_FINISH_LOAD:
      en: "Sorry, the designer module is loading now. Please try again after several seconds."
      zh: "抱歉，设计模块正在加载，请稍后重试。"

    PROC_TITLE:
      en: "Launching your app..."
      zh: "正在启动您的App..."

    PROC_RLT_DONE_TITLE:
      en: "Everything went smoothly!"
      zh: "一切顺利！"

    PROC_RLT_DONE_SUB_TITLE:
      en: "Your app will automatically open soon."
      zh: "您的App将被自动打开。"

    PROC_STEP_PREPARE:
      en: "Preparing to start app..."
      zh: "准备启动App..."

    PROC_RLT_FAILED_TITLE:
      en: "Error Starting App."
      zh: "启动 App 失败。"

    PROC_RLT_FAILED_SUB_TITLE:
      en: "Please fix the following issues and try again:"
      zh: "请先解决以下问题，然后重试。"

    PROC_ERR_INFO:
      en: "Error Details"
      zh: "错误详情"

    PROC_CLOSE_TAB:
      en: "Close"
      zh: "关闭"

    COMBO_DROPDOWN_DEMO_AWS_ACCOUNT:
      en: "You are using a demo AWS account"
      zh: "您正在使用测试账号。"

    COMBO_DROPDOWN_PRIVIDE_AWS_CREDENTIAL:
      en: "Provide AWS Credential <br/> to manage resources."
      zh: "提供 AWS 证书来管理资源。"

    COMBO_DROPDOWN_PRIVIDE_AWS_CREDENTIAL_WITH_TYPE:
      en: "Provide AWS Credential <br/> to manage %s"
      zh: "提供 AWS 证书来管理%s。"

    PAYMENT_PAYMENT_NEEDED:
      en: "Upgrade your account"
      zh: "升级账户"

    PAYMENT_INVALID_BILLING:
      en: "Your Billing Information is Invalid"
      zh: "您的账单信息无效"

    PAYMENT_LOADING:
      en: "Loading..."
      zh: "加载中..."

    PAYMENT_LOADING_BILLING:
      en: "Getting Billing Information ..."
      zh: "获取账单信息中..."

    PROFILE_UPDATED_FAILED:
      en: "Your Profile failed to update."
      zh: "你的信息更新失败。"

    PAYMENT_USAGE_TAB:
      en: "Usage"
      zh: "用量"

    PAYMENT_BILLING_TAB:
      en: "Billing"
      zh: "账单"

    PAYMENT_SETTING_TITLE:
      en: "Billing & Usage"
      zh: "账单与用量"

    PAYMENT_HEADER_TOOLTIP:
      en: "<div class=\"payment-header-tooltip\"><strong>%s</strong> free points remaining. <span> Free points will renew in %s days.</span></div>"
      zh: "<div class=\"payment-header-tooltip\">剩余 <strong>%s</strong> 个免费点。 <span> 免费点将在 %s 天后恢复。</span></div>"

    PAYMENT_PROVIDE_UPDATE_CREDITCARD:
      en: "Your account is limited status now. Import VPC, app operation, monitoring and state ensuring are disabled. <a class='update-payment' href='%s' target='_blank'> %s Billing Information</a> as soon as possible."
      zh: "您的账户已经受限。导入 VPC， App 操作，资源监控和 state 已被禁用。请尽快 <a class='update-payment' href='%s' target='_blank'> %s 账单信息</a>"

    PAYMENT_UNPAID_BUT_IN_FREE_QUOTA:
      en: "You have unpaid bill. You can still use the free quota before getting into limited status. <a class='update-payment' href='%s' target='_blank'>Update Billing Information</a> as soon as possible."
      zh: "您有未支付账单，在您的账号受限之前您仍然可用使用您的免费额度。请尽快 <a class='update-payment' href='%s' target='_blank'>更新账单信息</a>"

    DHCP_DELETE_CONFIRM_MULTY:
      en: "Confirm to delete selected %s  DHCP Options set?"
      zh: "您确定要删除选择的%s个 DHCP 选项设定吗？"

    DHCP_DELETE_CONFIRM_ONE:
      en: "Confirm to delete %s ?"
      zh: "您确定要删除 %s 吗？"

    OPTION_GROUP_USED_FOR:
      en: "This Option Group is used for "
      zh: "此选项组适用于 "

    READ_AWS_DOCUMENT:
      en: "Read AWS Document."
      zh: "阅读 AWS 文档。"

    CONFIRM_DELETE_PARAMETER_GROUP:
      en: "Confirm to delete  RDS Parameter Groups %s?"
      zh: "您确认要删除 RDS 参数组 %s 吗？"

    CONFIRM_DELETE_PARAMETER_GROUP_MULTY:
      en: "Confirm to delete selected %s RDS Parameter Groups?"
      zh: "您确认要删除选中的 %s 个 RDS Parameter Group 吗？"

    DELETE_SNS_TOPIC_CONFIRM:
      en: "Confirm to delete SNS Topics %s and all associated subscriptions?"
      zh: "您确定要删除 SNS 主题 %s 及其相关订阅吗？"

    DELETE_SNS_TOPIC_CONFIRM_M:
      en: "Confirm to delete selected %s SNS Topics and all associated subscriptions?"
      zh: "您确定要删除选中的 %s 个 SNS 主题及其相关订阅吗？"

    DELETE_SSL_CERT_CONFIRM:
      en: "Confirm to delete SSL Certificate %s ?"
      zh: "您确定要删除 SSL 证书 %s 吗？"

    DELETE_SSL_CERT_CONFIRM_M:
      en: "Confirm to delete selected %s SSL Certificates?"
      zh: "您确定要删除已选择的 %s 个SSL 证书吗？"

    STATE_TEXT_VIEW:
      en: "View"
      zh: "查看"

    STATE_TEXT_EDIT:
      en: "Edit"
      zh: "编辑"

    STATE_LOG_UPDATE_AFTER_CHANGE:
      en: "State log will update after change is applied."
      zh: "State 日志将在应用更改后更新。"

    XXX_S_STATE:
      en: "'s state"
      zh: "的 State"

    IS_UPDATED:
      en: "is updated."
      zh: "已经更新。"

    HAS_FAILED:
      en: "has failed."
      zh: "运行失败。"

    CREDIT_CARD_INFORMATION:
      en: "Credit Card Information"
      zh: "信用卡信息"

    NO_CARD:
      en: "No Card"
      zh: "无信用卡"

    UPDATE_BILLING_INFORMATION:
      en: "Update Billing Information"
      zh: "更新账单信息"

    BILLING_HISTORY:
      en: "Billing History"
      zh: "账单历史"

    NEXT_BILLING_ON:
      en: "Next Billing on "
      zh: "下次账单日期："

    DATE:
      en: "Date"
      zh: "日期"

    AMOUNT:
      en: "Amount"
      zh: "数量"

    STATUS:
      en: "Status"
      zh: "状态"

    ACTION:
      en: "Action"
      zh: "操作"

    PAYMENT_PAID:
      en: "Paid"
      zh: "已支付"

    PAYMENT_FAILED:
      en: "Failed"
      zh: "支付失败"

    PAYMENT_VIEW_RECEIPT:
      en: "View Receipt"
      zh: "查看收据"

    PAYMENT_INSTANT_HOUR:
      en: "Instance Hour"
      zh: "实例*小时"

    PAYMENT_RENEW_FREE_INFO:
      en: "%s free instance hour will be renewed in %s days."
      zh: "%s 个免费实例*小时将在 %s 天后刷新。"

    PAYMENT_ACCOUNT_IN_LIMITED_STATUS:
      en: "Your account is in limited status now. Import VPC, app operation, monitoring and state ensuring are disabled."
      zh: "您的账户处于受限状态。导入VPC，app 操作，监控和 state ensuring 功能已被禁用。"

    PAYMENT_USAGE:
      en: "Usage"
      zh: "用量"

    PAYMENT_BILLING_EMAIL:
      en: "Billing Email"
      zh: "账单邮箱"

    BILLING_OWNER:
      en: "Billing Owner"
      zh: "账单所属人"

    LBL_SAVING:
      en: "Saving..."
      zh: "保存中..."

    NO_USAGE_REPORT:
      en: "No available usage report"
      zh: "无可用的用量报告"

    NO_BILLING_EVENT:
      en: "No billing event yet."
      zh: "无付费事件。"

    PAYMENT_CURRENT_USAGE:
      en: "Current Usage"
      zh: "当前用量"

    BUBBLE_DNSNAME:
      en: "DNS Name"
      zh: "DNS 名称"

    BUBBLE_ARCHITECTURE:
      en: "Architecture"
      zh: "架构"

    BUBBLE_EBSOPTIMIZED:
      en: "EBS Optimized"
      zh: "EBS 优化"

    BUBBLE_GROUPSET:
      en: "GroupSet"
      zh: "群组"

    BUBBLE_HYPERVISOR:
      en: "Hypervisor"
      zh: "虚拟监视器"

    BUBBLE_IMAGEID:
      en: "Image ID"
      zh: "映像 ID"

    BUBBLE_INSTANCESTATE:
      en: "Instance State"
      zh: "Instance State"

    BUBBLE_INSTANCETYPE:
      en: "Instance Type"
      zh: "实例类型"

    BUBBLE_IPADDRESS:
      en: "Ip Address"
      zh: "IP 地址"

    BUBBLE_KERNELID:
      en: "Kernel ID"
      zh: "核心 ID"

    BUBBLE_KEYNAME:
      en: "Keyname"
      zh: "键值"

    BUBBLE_LAUNCHTIME:
      en: "Launch Time"
      zh: "启动时间"

    BUBBLE_MONITORING:
      en: "Monitoring"
      zh: "监测"

    BUBBLE_NETWORKINTERFACESET:
      en: "Network Interface Set"
      zh: "网络接口组"

    BUBBLE_AVAILABILITYZONE:
      en: "Availability Zone"
      zh: "可用区域"

    BUBBLE_PRIVATEDNSNAME:
      en: "Private DNS Name"
      zh: "私有 DNS 名称"

    BUBBLE_ROOTDEVICENAME:
      en: "Root Device Name"
      zh: "根设备名称"

    BUBBLE_ROOTDEVICETYPE:
      en: "Root Device Type"
      zh: "根设备类型"

    BUBBLE_START_TIME:
      en: "Start Time:"
      zh: "开始时间："

    BUBBLE_STOP_TIME:
      en: "Stop Time:"
      zh: "停止时间："

    BUBBLE_ESTIMATED_COST:
      en: "Estimated Cost:"
      zh: "估计费用："

    BUBBLE_SIZE:
      en: "Size"
      zh: "大小"

    BUBBLE_ENCRYPTED:
      en: "Encrypted"
      zh: "加密的"

    BUBBLE_SNAPSHOTID:
      en: "Snapshot ID"
      zh: "快照 ID"

    BUBBLE_IMAGE_SIZE:
      en: "Image Size"
      zh: "映像大小"

    BUBBLE_IMAGELOCATION:
      en: "Image Location"
      zh: "镜像地址"

    BUBBLE_IMAGESTATE:
      en: "Image State"
      zh: "镜像状态"

    BUBBLE_IMAGEOWNERID:
      en: "Image Owner ID"
      zh: "镜像所有者 ID"

    BUBBLE_ISPUBLIC:
      en: "Is Public"
      zh: "是否公开"

    BUBBLE_IMAGETYPE:
      en: "Image Type"
      zh: "镜像类型"

    BUBBLE_SRIOVNETSUPPORT:
      en: "SR-IOV Net Support"
      zh: "SR-IOV 网络支持"

    BUBBLE_NAME:
      en: "Name"
      zh: "名称"

    BUBBLE_VALUE:
      en: "Value"
      zh: "值"

    BUBBLE_DESCRIPTION:
      en: "Description"
      zh: "描述"

    BUBBLE_VIRTUALIZATIONTYPE:
      en: "Virtualization Type"
      zh: "虚拟类型"

    BUBBLE_ID:
      en: "ID"
      zh: "ID"

    BUBBLE_MACADDRESS:
      en: "MAC Address"
      zh: "MAC 地址"

    BUBBLE_NETWORKINTERFACEID:
      en: "Network Interface ID"
      zh: "网络接口 ID"

    BUBBLE_OWNERID:
      en: "Owner ID"
      zh: "所有者 ID"

    BUBBLE_PRIVATEIPADDRESS:
      en: "Private IP Address"
      zh: "私有 IP 地址"

    BUBBLE_SOURCEDESTCHECK:
      en: "Source/Destination Check"
      zh: "源/目标检查"

    BUBBLE_STATUS:
      en: "Status"
      zh: "状态"

    BUBBLE_SUBNETID:
      en: "Subnet ID"
      zh: "子网 ID"

    BUBBLE_VPCID:
      en: "VPC ID"
      zh: "VPC ID"

    BUBBLE_ATTACHTIME:
      en: "Attach Time"
      zh: "连接时间"

    BUBBLE_DELETEONTERMINATION:
      en: "Delete On Termination"
      zh: "终止后删除"

    BUBBLE_DEVICENAME:
      en: "Device Name"
      zh: "设备名称"

    BUBBLE_VOLUMEID:
      en: "Volume ID"
      zh: "卷 ID"

    BUBBLE_DHCPOPTIONSID:
      en: "DHCP Options ID"
      zh: "DHCP 选项 ID"

    BUBBLE_DOMAIN_NAME:
      en: "Domain Name"
      zh: "域名"

    BUBBLE_DOMAIN_NAME_SERVERS:
      en: "Domain Name Server"
      zh: "域名服务器"

    BUBBLE_NTP_SERVERS:
      en: "NTP Server"
      zh: "NTP 服务器"

    BUBBLE_NETBIOS_NAME_SERVERS:
      en: "Netbios Name Server"
      zh: "Netbios 服务器"

    BUBBLE_NETBIOS_NODE_TYPE:
      en: "Netbios Node Type"
      zh: "Netbios 节点类型"

    BUBBLE_INTERVAL:
      en: "Interval"
      zh: "周期"

    BUBBLE_TARGET:
      en: "Target"
      zh: "目标"

    BUBBLE_HEALTHYTHRESHOLD:
      en: "Healthy Threshold"
      zh: "健康度阈值"

    BUBBLE_TIMEOUT:
      en: "Timeout"
      zh: "超时"

    BUBBLE_UNHEALTHYTHRESHOLD:
      en: "Unhealthy Threshold"
      zh: "不健康阈值"

    BUBBLE_IMAGESIZE:
      en: "Image Size"
      zh: "镜像大小"

    BUBBLE_OSTYPE:
      en: "OS Type"
      zh: "操作系统类型"

    BUBBLE_OSFAMILY:
      en: "OS Family"
      zh: "操作系统组"

    BUBBLE_PLATFORM:
      en: "Platform"
      zh: "平台"

    BUBBLE_IMAGEOWNERALIAS:
      en: "Image Owner Alias"
      zh: "镜像所有者简称"

    BUBBLE_REGION:
      en: "Region"
      zh: "地区"

    ESTIMATED_AWS_COST:
      en: "Estimated AWS Cost"
      zh: "估计 AWS 费用"

    PAYMENT_WARNNING_IN_MODAL:
      en: "There was an issue to process payment in your account. Please update your <a class=\"route\" href=\"%s\">payment information</a>"
      zh: "您的账户付费遇到问题，请更新您的 <a class=\"route\" href=\"%s\">付费信息</a>。"

    PER_MONTH:
      en: "/ month"
      zh: "/ 月"

    SG_RULE_WILL_BE_DELETED:
      en: "Following rule(s) will be deleted from its(their) security group:"
      zh: "以下规则将从安全组中被删除："

    INSTANCE_ASSO_WITH_KEYPAIR:
      en: "This instance was associated with key pair:"
      zh: "这个实例已被关联到密钥对："

    TO_ACCESS_THIS_INSTANCE_REMOTELY:
      en: "To access this instance remotely(e.g. Remote Desktop Connection), you will need your windows administration password. A default password was created when the instance was launched and is available encrypted in the system log."
      zh: "要远程连接(比如远程桌面连接)这个实例，你需要 Windows 管理员密码，实例启动时创建了一个默认密码，你可以在系统日志里面得到加密过的。"

    DECRYPT_PASSWORD:
      en: "Decrypt Password"
      zh: "加密密码"

    DECRYPTED_PASSWORD_WILL_APPEAR_HERE:
      en: "Decrypted password will appear here"
      zh: "加密后的密码将显示在这里"

    GET_WINDOWS_PASSWORD:
      en: "Get Windows Password"
      zh: "获取 Windows 密码"

    RECOMMEND_CHANGE_PASSWORD:
      en: "We recommend that you change your password to one that you will remember and know privately. Please note that passwords can persist through bundling phases and will not be retrievable through this tool. It is therefore important that you change your password to one that you will remember if you intend to bundle a new AMI from this instance."
      zh: "建议您更改您的默认密码。注意：如果已更改默认密码，则无法通过此工具检索密码。请务必将您的密码更改为易记的密码。"

    CHANGE_PASSWORD_RECOMMENDATION_FROM_AWS:
      en: "Change password Recommendation form AWS"
      zh: "来自 AWS 的修改密码建议"

    YOUR_PASSWORD_IS_NOT_READY:
      en: "Your password is not ready. Password generation can sometimes take more than 30 minutes. Please wait at least 15 minutes after launching an instance before trying to retrieve the generated password."
      zh: "您的密码还没有准备好，有时生成密码会花费 30 分钟以上的时间，请在启动实例之后等待至少15分钟，然后重试取回密码。"

    PASSWORD_OF_OWN_AMI:
      en: "If you launched this instance from your own AMI, the password is the same as for the instance from which you created the AMI, unless this setting was modified in the EC2Config service settings."
      zh: "如果你从私有的 AMI 启动的实例，密码将会与您创建 AMI 的实例的密码相同，除非此设置在 EC2Config 服务里被修改了。"

    KEY_PAIR_DATA_IS_READY:
      en: "Key Pair data is ready"
      zh: "密钥对数据已经准备好"

    INSTANCE_ASSO_WITH_KP:
      en: "This instance was associated with key pair:"
      zh: "此实例关联到的密钥对："

    LBL_REMOTE_ACCESS:
      en: "Remote Access"
      zh: "远程访问"

    WINDOWS_LOGIN_PASSWORD:
      en: "Windows Login Password"
      zh: "Windows 登录密码"

    SHOW_PASSWORD:
      en: "Show Password"
      zh: "显示密码"

    MISSING_PROPERTY_PANEL:
      en: "This resource is not available. It may have been deleted from other source or terminated in previous app editing."
      zh: "此资源不可用，可能已经在其他地方被删除或在上次修改的时候被终止了。"

    ASG_DELETED_IN_STOPPED_APP:
      en: "is deleted in stopped app. The auto scaling group will be created when the app is started."
      zh: "在 App 停止的时候被删除了，Auto Scaling 组会在 App 启动的时候自动创建。"

    SET_UP_CIDR_BLOCK:
      en: "Set Up CIDR Block"
      zh: "设置 CIDR 区块"

    HOST_HAS_BEEN_ASSIGNED_PUBLIC_IP:
      en: " has been automatically assigned Public IP. "
      zh: " 已经自动分配公共 IP。"

    PUBLIC_IP_MUST_BE_REMOVED:
      en: "If you want to attach the external network interface to %s, the Public IP must be removed."
      zh: "如果你想将外部网络接口连接到 %s 上，公共 IP 必须要被移除。"

    CONFIRM_REMOVE_PUBLIC_IP:
      en: "Do you still want to attach %s to %s and remove the Public IP?"
      zh: "您仍然想要将 %s 连接到 %s 上，并且移除公共 IP 吗？"

    STACK_NAME_ALREADY_IN_USE:
      en: "Stack Name Already in Use"
      zh: "Stack 名称已被占用"

    PLEASE_CHOOSE_ANOTHER_STACK_NAME:
      en: "Stack name <span class=\"resource-name-label\">%s</span> is already used by another stack. Please use a different name."
      zh: "Stack 名称 %s 已经被另外一个 Stack 使用了，请选择一个其他名称。"

    LABEL_STACK_NAME:
      en: "Stack Name"
      zh: "Stack 名称"

    REFRESHING_RESOURCES:
      en: "Refreshing Resources....."
      zh: "刷新资源中..."

    LAST_SAVED:
      en: "Last saved:"
      zh: "上次保存于："

    LBL_VALIDATE:
      en: "Validate"
      zh: "校验"

    VALIDATING_3DOT:
      en: "Validating..."
      zh: "校验中..."

    CONFIRM_TO_DELETE_XXX:
      en: "Are you sure you want to delete %s?"
      zh: "您确定要删除 %s 吗？"

    ONCE_DELETE_STATE_CONF_LOST:
      en: "Once deleted, the states of %s's configuration will be lost."
      zh: "一旦删除， %s 的 state 配置将会丢失时。"

    THE_SG_WILL_BE_DELETED:
      en: "The security group %s will also be deleted. Other load banancer using this security group will be affected."
      zh: "安全组 %s 也将会被删除，其他使用这个安全组的负载均衡也将受到影响。"

    CONFIRM_TO_ENABLE_VISUALOPS:
      en: "Confirm to Enable VisualOps"
      zh: "确认开启 VisualOps"

    ENABLE_VISUALOPS:
      en: "Enable VisualOps"
      zh: "开启 VisualOps"

    ENABLE_VISUALOPS_OVERRIDE_USER_DATA:
      en: "Enable VisualOps will override your custom User Data. Are you sure to continue?"
      zh: "启用 VisualOps 将会覆盖用户自定义数据， 您确定要继续吗？"


    NAT_INSTANCE_MEET_REQ:
      en: "A NAT instance must meet following requirements:"
      zh: "一个 NAT 实例必须满足以下条件："

    NAT_INSTANCE_REQS:
      en: "		<li>Should have a route targeting the instance itself with destination to 0.0.0.0/0.</li>
              <li>Should belong to a subnet which routes traffic with destination 0.0.0.0/0 to Internet Gateway.</li>
              <li>Should disable Source/Destination Checking in \"Network Interface Details\".</li>
              <li>Should have public IP or Elastic IP.</li>
              <li>Should have outbound rule to the outside.</li>
              <li>Should have inbound rule from within the VPC.</li>"
      zh: "<li>应当有一个路由将目标实例的目的地设为 0.0.0.0/0。</li>
           <li>应当属于路由流量目标设为 0.0.0.0/0 连接到互联网关的子网内。</li>
           <li>应当在网络接口详细里面禁止来源/目标检查。</li>
           <li>应当有公共 IP 或者弹性 IP。</li>
           <li>应当有通往外部的外流规则。</li>
           <li>应当有来自 VPC 的内流规则。</li>"


    NEED_TO_RESTART_INSTANCE:
      en: "Need to Restart Instance"
      zh: "实例需要重新启动"

    TO_UPDATE_THE_PROPERTIES_YOU_CHANGED:
      en: "To update the properties you have changed, following instances need to restart:"
      zh: "要更您更改的属性， 以下实例将会重启："

    CONTINUE_TO_UPDATE:
      en: "Continue to Update"
      zh: "继续更新"

    TAKE_FINAL_SNAPSHOT_FOR_DB_INSTANCES:
      en: "Take final snapshot for DB instances."
      zh: "为数据库实例创建最终快照。"

    DB_INSTANCE:
      en: "DB Instance"
      zh: "数据库实例"

    CANNOT_TAKE_FINAL_SNAPSHOT:
      en: "cannot take final snapshot."
      zh: "无法创建最终快照。"

    MONEY_SYMBOL:
      en: "$"
      zh: "￥"

    CANNOT_BE_MODIFIED_NOW:
      en: "cannot be modified now."
      zh: "现在无法更改。"

    WAIT_FOR_DB_THEN_UPDATE:
      en: "Wait for the DB instance(s) to be available. Then try to apply updates again."
      zh: "请等待数据库实例可用，然后再应用更改。"

    EDIT_STATE:
      en: "Edit State"
      zh: "编辑 State"

    SYSTEM_LOG:
      en: "System Log:"
      zh: "系统日志："

    SYSTEM_LOG_NOT_READY:
      en: "System log is not ready yet. Please try in a short while."
      zh: "系统日志还没有准备好， 请稍后重试。"

    USER_DATA_FETCH_FAILED:
      en: "Failed to get user data, please try again later."
      zh: "获取用户数据失败， 请稍后重试。"

    PROVIDE_BILLING_INFORMATION:
      en: "Provide Billing Information"
      zh: "提供账单信息"

    YOUR_FREE_POINTS_USED_UP:
      en: "Your free points are used up. This project is in limited status now. Import VPC, app operation, monitoring and state ensuring are disabled. To make sure your enjoy the full feature of VisualOps, please join the paid plan as soon as possible."
      zh: "您的免费点数已经用尽，此项目已处于受限状态。导入 VPC，App 操作，监控和 state ensuring 功能已被禁用。为确保您能享受 VisualOps 的完整功能，请尽快加入付费计划。"

    YOUR_ACCOUNT_IN_LIMITED_STATUS:
      en: "Your account is in limited status now. <br>Import VPC, app operation, monitoring and state ensuring are disabled."
      zh: "您的账户已经处于受限状态。 导入 App，App 操作，管理和资源监控已被禁用。"

    INSTANCE_HOURS_PER_MONTH:
      en: "%s instance hours per month"
      zh: "每月 %s 个实例*小时"

    LALEL_FREE:
      en: "Free"
      zh: "免费"

    INSTANCE_HOURS_CONSUMED_OVER_XXX:
      en: "Instance hours consumed over %s"
      zh: "超过 %s 的实例*小时"

    PRICING_IN_DETAIL:
      en: "Pricing in detail"
      zh: "详细价格"

    FAILED_TO_CHARGE_YOUR_CREDIT_CARD:
      en: "We were unable to charge the project's credit card. This project is in limited status now. Import VPC, app operation, monitoring and state ensuring are disabled. Update payment information as soon as possible to continue managing apps with VisualOps. "
      zh: "我们无法从此项目绑定的信用卡中扣费。此项目现已处于受限状态。导入 VPC，App 操作，监控和 state ensuring 功能已被禁用。请尽快更新您的付款信息以继续用 VisualOps 管理资源。"

    FAILED_TO_CHARGE_YOUR_CREDIT_CARD_MEMBER:
      en: "We were unable to charge the project's credit card. This project is in limited status now. Import VPC, app operation, monitoring and state ensuring are disabled. "
      zh: "我们无法从此项目绑定的信用卡中扣费。此项目现已处于受限状态。导入 VPC，App 操作，监控和 state ensuring 功能已被禁用。"

    WAIT_FOR_ADMIN_UPDATE_PAYMENT_MODAL:
      en: "Please wait admin of this project to update payment information before you can continue managing apps with VisualOps. "
      zh: "请等待此项目管理员更新付费信息以能继续用 VisualOps 管理资源。"

    WILL_OPEN_CHARGIFY:
      en: "This will open a new window with Chargify.<br/>Meanwhile please keep this page open."
      zh: "将在新窗口打开 Chargify。<br/> 同时，请保持此页面打开。"

    GOOD_JOB_NO_ERROR_HERE:
      en: 'Good job! No error here.'
      zh: "真棒！没有错误。"

    GOOD_JOB_NO_WARNING_HERE:
      en: "Good job! No warning here."
      zh: "真棒！没有警告。"

    GOOD_JOB_NO_NOTICE_HERE:
      en: "Good job! No notice here."
      zh: "真棒！没有提示。"

    GREAT_JOB_NO_ERROR_WARNING_NOTICE_HERE:
      en: "Great job! No error, warning or notice here."
      zh: "真棒！没有错误，警告和提示。"

    NO_ERROR_WARNING_OR_NOTICE:
      en: "No error, warning or notice."
      zh: "没有错误、警告和提示。"

    LENGTH_ERROR:
      en: "%s error(s)"
      zh: "%s 个错误"

    LENGTH_WARNING:
      en: "%s warning(s)"
      zh: "%s 个警告"

    LENGTH_NOTICE:
      en: "%s notice(s)"
      zh: "%s 个提示"

    SOME_ERROR_VALIDATION_ONLY_HAPPENS_AT_THE_TIME_TO_RUN_STACK:
      en: "Some error validation only happens at the time to run stack."
      zh: "一些错误只在运行时产生。"

    MANAGE_KP_IN_AREA:
      en: "Manage Key Pairs in %s"
      zh: "管理%s区的密钥对"

    MANAGE_EIP_IN_AREA:
      en: "Manage Elastic IPs in %s"
      zh: "管理%s区的弹性 IP"

    MANAGE_SNAPSHOT_IN_AREA:
      en: "Manage Snapshots in %s"
      zh: "管理%s区的快照"

    MANAGE_SNS_IN_AREA:
      en: "Manage SNS in %s"
      zh: "管理%s区的 SNS"

    MANAGE_DB_SNAPSHOT_IN_AREA:
      en: "Manage DB Snapshot in %s"
      zh: "管理%s区的数据库快照"

    MANAGE_DHCP_IN_AREA:
      en: "Manage DHCP Options in %s"
      zh: "管理%s区的 DHCP 选项"

    MANAGE_SSL_CERT_IN_AREA:
      en: "Manage SSL Certificate in %s"
      zh: "管理%s区的 SSL 证书"

    TITLE_CONFIRM_TO_FORGET:
      en: "Confirm to Forget App"
      zh: "确认释放 App"

    TITLE_APP_CHANGES:
      en: "App Changes"
      zh: "App 变化"

    TITLE_KEYPAIR_CONTENT:
      en: "Keypair Content"
      zh: "密钥对内容"

    TITLE_CONFIRM_TO_REMOVE_APP:
      en: "Confirm to remove the app %s ?"
      zh: "确定要移除 App %s 吗？"

    TITLE_CONFIRM_TO_CLOSE:
      en: "Confirm to close %s ?"
      zh: "确认要关闭 %s ?"

    TITLE_LOG_AND_EVENT:
      en: "Log & Event: %s"
      zh: "日志和事件： %s"

    TITLE_CONFIRM_PROMOTE_READ_REPLICA:
      en: "Confirm to promote Read Replica"
      zh: "确认要提升只读副本吗？"

    TITLE_RESTORE_TO_POINT_IN_TIME_CONFIG:
      en: "Restore to point in time config"
      zh: "恢复到时间点设置"

    TITLE_DELETE_KEYPAIR:
      en: "Delete Key Pair"
      zh: "删除密钥对"

    TITLE_SUBNET_RT_ASSO:
      en: "Subnet-RT Association"
      zh: "Subnet-RT 关联"

    TITLE_DELETE_NETWORK_ACL:
      en: "Delete Network ACL"
      zh: "删除网络 ACL"

    TITLE_EXPORT_PNG:
      en: "Export PNG"
      zh: "导出 PNG"

    TITLE_CONFIRM_TO_ENABLE_VISUALOPS:
      en: "Confirm to Enable VisualOps"
      zh: "确认开启 VisualOps 功能"

    TITLE_CHANGE_NOT_APPLIED:
      en: "Changes not applied"
      zh: "修改尚未应用"

    SMS_DISPLAY_NAME_IS_REQUIRED:
      en: "Display Name is required if subscription uses SMS protocol."
      zh: "如果订阅使用 SMS 接口，显示名称是必须的。"

    TOPIC_NAME_IS_ALREADY_TAKEN:
      en: "Topic name is already taken"
      zh: "主题名称已经被占用"

    DRAG_AND_DROP_IN_NETOWRK_TO_CREATE_SUBNET:
      en: "Drag and drop in Network to create subnet"
      zh: "拖拽到网络里创建子网"

    DRAG_AND_DROP_OUTSIDE_NETOWRK_TO_CREATE_ROUTER:
      en: "Drag and drop outside Network to create router"
      zh: "拖拽到网络外以创建路由"

    DRAG_AND_DROP_IN_SUBNET_TO_CREATE_PORT:
      en: "Drag and drop in subnet to create port"
      zh: "拖拽到子网里以创建端口"

    DRAG_AND_DROP_IN_SUBNET_TO_CREATE_LOAD_BALANCE:
      en: "Drag and drop in subnet to create Load Balance"
      zh: "拖拽到子网里以创建负载均衡"

    DRAG_AND_DROP_IN_SUBNET_TO_CREATE_LISTENER:
      en: "Drag and drop in subnet to create listener"
      zh: "拖拽到子网里以创建"

    DRAG_AND_DROP_IN_SUBNET_TO_CREATE_POOL:
      en: "Drag and drop in subnet to create pool"
      zh: "拖拽到子网以创建连接池"

    DRAG_AND_DROP_ON_SERVER_TO_ATTACH_VOLUME:
      en: "Drag and drop on server to attach volume"
      zh: "拖拽到服务器上以添加卷"

    LBL_OSSUBNET:
      en: "Subnet"
      zh: "子网"

    LBL_OSRT:
      en: "Router"
      zh: "路由"

    LBL_OSPORT:
      en: "Port"
      zh: "端口"

    LBL_OSELB:
      en: "Load Balancer"
      zh: "负载均衡"

    LBL_OSLISTENER:
      en: "Listener"
      zh: "监听器"

    LBL_OSPOOL:
      en: "Pool"
      zh: "连接池"

    LBL_OSVOL:
      en: "Volume"
      zh: "卷"

    LBL_SUBMIT:
      en: "Submit"
      zh: "提交"

    STARTING_YOUR_APP:
      en: "Starting your app..."
      zh: "正在启动 App ..."

    TERMINATING_YOUR_APP:
      en: "Terminating your app..."
      zh: "正在终止 App ..."

    STOPPING_YOUR_APP :
      en: "Stopping your app..."
      zh: "正在停止 App ..."

    APPLYING_CHANGES_TO_YOUR_APP :
      en: "Applying changes to your app"
      zh: "正在应用 App 的修改"

    REMOVING_YOUR_APP :
      en: "Removing your app from our server..."
      zh: "正在从数据库中删除你的 App..."

    PROCESSING_YOUR_REQUEST:
      en: "Processing your request..."
      zh: "正在处理请求 ..."

    YOU_CAN_LATER_UPDATE_PROFILE:
      en: "You can later update this information in <em>Settings &gt; Account</em>"
      zh: "您可稍后在 <em> 设置 &gt; 账号</em> 里修改此信息。"

    LBL_LOG:
      en: "Log"
      zh: "日志"

    LBL_EVENT:
      en: "Event"
      zh: "事件"

    LBL_LAST_WRITTEN:
      en: "Last Written"
      zh: "上次写入"

    LBL_SIZE_B:
      en: "Size(B)"
      zh: "大小(B)"

    LBL_TIME:
      en: "Time"
      zh: "时间"

    LBL_SYSTEM_NOTES:
      en: "System Notes"
      zh: "系统通知"

    DATE_FORMAT_MONTHS:
      en: "\x04, January, February, March, April, May, June, July, August, September, October, November, December"
      zh: "\x04, 一月, 二月, 三月, 四月, 五月, 六月, 七月, 八月, 九月, 十月, 十一月, 十二月"

    DATE_FORMAT_MON:
      en: "\x01, Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec"
      zh: "\x01, 一月, 二月, 三月, 四月, 五月, 六月, 七月, 八月, 九月, 十月, 十一月, 十二月"

    DATE_FORMAT_WEEK:
      en: "\x02, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday"
      zh: "\x02, 周日, 周一, 周二, 周三, 周四, 周五, 周六"

    DATE_FORMAT_WEK:
      en: "\x03, Sun, Mon, Tue, Wed, Thu, Fri, Sat"
      zh: "\x03, 周日, 周一, 周二, 周三, 周四, 周五, 周六"

    DATE_FORMAT_MONTH:
      en: ""
      zh: "月"

    DATE_FORMAT_DAY:
      en: ""
      zh: "日"

    DATE_FORMAT_YEAR:
      en: ""
      zh: "年"

    DATE_FORMAT_AM:
      en: "AM"
      zh: "上午"

    DATE_FORMAT_PM:
      en: "PM"
      zh: "下午"

    LBL_PUBLIC_KEY:
      en: "Public Key"
      zh: "公钥"

    LBL_DROP:
      en: "Drop %s,"
      zh: "拖拽%s到此，"

    SAVE_STACK:
      en: "Save & Close"
      zh: "保存并关闭"

    SAVING_STACK:
      en: "Saving stack..."
      zh: "正在保存 Stack..."

    ACCESS_TOKEN_EDIT_TIP:
      en: "Edit"
      zh: "编辑"

    ACCESS_TOKEN_DELETE_TIP:
      en: "Delete"
      zh: "删除"

    WORKSPACE:
      en: "Workspace"
      zh: "工作空间"

    WORKSPACE_NAME:
      en: "Workspace Name"
      zh: "工作空间名称"

    MANAGE_WORKSPACE:
      en: "Manage Workspace"
      zh: "工作空间"

    CHANGE_PHOTO:
      en: "Change Photo"
      zh: "更改头像"

    BASIC_SETTINGS:
      en: "Basic Settings"
      zh: "基本设置"

    TEAM:
      en: "Team"
      zh: "团队成员"

    USAGE_REPORT:
      en: "Usage Report"
      zh: "用量报告"

    PROVIDER_CREDENTIAL:
      en: "Cloud Access Credential"
      zh: "证书"

    LEAVE:
      en: "Leave"
      zh: "离开"

    DELETE_WORKSPACE_WILL_FORGOT_APPS:
      en: "Once the workspace is deleted, all stacks will be removed and all apps will be forgotten (Resources will be left as they are)."
      zh: "工作空间一旦被删除，所有该工作空间下的 Stack 和 App 将被删除和释放（资源不会受到影响）。"

    IMPORT_JSON_BEFORE_DELETE_WORKSPACE:
      en: "You can export stacks to JSON before deleting the workspace."
      zh: "您可以在删除工作空间之前将 Stack 导出 JSON 文件。"

    LEAVING_WORKSPACE_WILL_NOT_ACCESS:
      en: "By leaving this workspace, you won't have access to workspace assets any more. This workspace will be managed by other admin."
      zh: "离开工作空间后，将不再有访问工作空间资源的权限，该工作空间将被其他管理员管理。"

    LEAVING_WORKSPACE_WILL_ONLY_ONE_ADMIN:
      en: "Oops, as the only admin of this workspace, you cannot leave it behind."
      zh: "出错了，你是该工作空间中唯一的管理员，不可离开。"

    THIS_ACTION_CANNOT_BE_REVERTED:
      en: "This action CANNOT be reverted."
      zh: "此操作不可逆。"

    TYPE_THE_WORKSPACE_NAME_TO_CONFIRM:
      en: "Type the workspace name below to confirm deleting the workspace."
      zh: "在下面输入工作空间的名称以确认删除该工作空间。"

    ARE_YOU_SURE_YOU_WANT_TO_LEAVE_THIS_WORKSPACE:
      en: "Are you sure you want to leave this workspace?"
      zh: "您确定要离开此工作空间吗？"

    FREE_WORKSPACE_CAN_NOT_DELETE:
      en: "This is your default workspace which cannot be deleted."
      zh: "默认工作空间不能删除。"

    DELETE_WORKSPACE:
      en: "Delete Workspace"
      zh: "删除工作空间"

    LEAVE_WORKSPACE:
      en: "Leave Workspace"
      zh: "离开工作空间"

    CONFIRM_TO_DELETE:
      en: "Confirm to Delete"
      zh: "确认删除"

    CONFIRM_TO_LEAVE:
      en: "Confirm to Leave"
      zh: "确认离开"

    # Settings - Member
    SETTINGS_MEMBER_COLUMN_MEMBER:
      en: "Member"
      zh: "成员"

    SETTINGS_MEMBER_COLUMN_ROLE:
      en: "Role"
      zh: "角色"

    SETTINGS_MEMBER_COLUMN_STATUS:
      en: "Status"
      zh: "状态"

    SETTINGS_MEMBER_COLUMN_EDIT:
      en: "Edit"
      zh: "编辑"

    SETTINGS_MEMBER_LABEL_MEMBER:
      en: "Team"
      zh: "团队成员"

    SETTINGS_MEMBER_LABEL_INVITE_TIP:
      en: "Invite by email address or username..."
      zh: "通过电子邮箱或用户名邀请..."

    SETTINGS_MEMBER_LABEL_INVITE_CONFIRM:
      en: "Invite"
      zh: "邀请"

    SETTINGS_MEMBER_LABEL_LIMIT:
      en: "Your workspace has reached the limit of %s. If you'd like invite more members to collaborate, contact us at"
      zh: "该工作空间已经达到 %s 个成员的标准上限，如果你想要邀请更多协作成员，请联系："

    SETTINGS_MEMBER_LABEL_ONLY_ONE_ADMIN:
      en: "You are the only admin in this workspace. The role can not be changed."
      zh: "你是该工作空间唯一的管理员，角色不可更改。"

    SETTING_MEMBER_LABEL_NO_USER:
      en: "There is no user \"%s\""
      zh: "未找到用户 “%s”"

    SETTING_MEMBER_USER_INVITED:
      en: "Invitation Email has been sent to \"%s\""
      zh: "邀请邮件已经发送给 \"%s\""

    WORKSPACE_DEMO_TIP:
      en: "This workspace is currently in Demo mode. Set up your own cloud credential to run stack
into live resources, or import existing infrastructures."
      zh: "当前工作空间处于测试模式，您需要设置证书才能运行 Stack 和导入已有资源。"

    CREDENTIAL_LINKED_TO_THIS_WORKSPACE:
      en: "Following Cloud Access Credential is linked to this workspace:"
      zh: "连接到此工作空间的证书："

    PARENTHESES_DEMO:
      en: "(Demo)"
      zh: "测试模式"

    DEMO_CREDENTIAL_TIP:
      en: "This is a demo credential for designing stack only."
      zh: "这只是个测试证书，只能用于设计 Stack。"

    DEMO_CREDENTIAL_ERROR_NOTE:
      en: "Note: Some stack you build in demo mode may report error due to resource inconsistency between different cloud accounts."
      zh: "注意：由于两种账号之间资源的差异， 当您设置了 AWS 证书后， 一些您在测试账号时创建的 Stack 可能会报错。"

    SET_UP_PROVIDER_CREDENTIAL:
      en: "Set up Cloud Access Credential"
      zh: "设置证书"

    CREDENTIAL_ALIAS:
      en: "Credential Alias"
      zh: "别名"

    CREDENTIAL_AUTHORIZE_NOTE:
      en: "Note: This credential must be linked to an account at least read access to AWS EC2 resources, otherwise there will be issues using VisualOps."
      zh: "注意：此证书最少必须有读取 AWS EC2 资源的权限，否则 VisualOps 会产生错误。"

    ARE_YOU_SURE_YOU_WANT_TO_REMOVE_XXX:
      en: "Are you sure you want to remove %s?"
      zh: "确定要移除 %s 吗？"

    REMOVE_CREDENTIAL_CONFIRM_TIPS:
      en: "Apps managed under this credential will be forgotten. You will not be able to run stack or import VPC. If you provide a credential later with access to different AWS resources, previous stacks may not work properly."
      zh: "与此证书关联的 App 将被释放，且您将无法运行 Stack 和 导入 VPC 。如果您以后添加一个不同的证书，先前的 Stack 可能无法工作。"

    REMOVE_CREDENTIAL_CONFIRM_BTN:
      en: "Remove Credential"
      zh: "移除证书"

    REMOVE_CREDENTIAL_CONFIRM_TITLE:
      en: 'Remove Cloud Credential'
      zh: "移除云证书"

    SETTINGS_MEMBER_LABEL_REMOVE:
      en: "Remove"
      zh: "移除"

    SETTINGS_MEMBER_LABEL_YOU:
      en: "YOU"
      zh: "你"

    SETTINGS_MEMBER_LABEL_ADMIN:
      en: "ADMIN"
      zh: "管理员"

    SETTINGS_MEMBER_LABEL_COLLABORATOR:
      en: "MEMBER"
      zh: "成员"

    SETTINGS_MEMBER_LABEL_OBSERVER:
      en: "OBSERVER"
      zh: "查看者"

    # SETTINGS_MEMBER_LABEL_ADMIN_DESC:
    #   en: ""
    #   zh: ""
    #
    # SETTINGS_MEMBER_LABEL_COLLABORATOR_DESC:
    #   en: ""
    #   zh: ""
    #
    # SETTINGS_MEMBER_LABEL_OBSERVER_DESC:
    #   en: ""
    #   zh: ""

    SETTINGS_MEMBER_LABEL_ACTIVE:
      en: "Active"
      zh: "已激活"

    SETTINGS_MEMBER_LABEL_PENDING:
      en: "Pending"
      zh: "等待中"

    SETTINGS_MEMBER_LABEL_CANCEL_INVITE:
      en: "Cancel Invitation"
      zh: "取消邀请"

    SETTINGS_MEMBER_LABEL_DONE:
      en: "Done"
      zh: "完成"

    SETTINGS_MEMBER_LABEL_NO_USER:
      en: "There is no user"
      zh: "未找到用户"

    SETTINGS_MEMBER_LABEL_DEFAULT_WORKSPACE_TIP1:
      en: "You are the only member in your default workspace"
      zh: "你是默认工作空间中的唯一成员"

    SETTINGS_MEMBER_LABEL_DEFAULT_WORKSPACE_TIP2:
      en: "To invite member and collaborate with other user"
      zh: "要邀请成员并与其他用户协作"

    SETTINGS_MEMBER_LABEL_CREATE_WORKSPACE:
      en: "create a new workspace"
      zh: "请创建新的工作空间"

    SETTINGS_MEMBER_LABEL_REMOVE_CONFIRM:
      en: "Do you confirm to remove selected %s user(s)?"
      zh: "确定要移除选中的 %s 个用户?"

    ADD_CLOUD_CREDENTIAL:
      en: "Add Cloud Credential"
      zh: "添加证书"

    UPDATE_CLOUD_CREDENTIAL:
      en: "Update Cloud Credential"
      zh: "更新证书"

    # Create Project Modal
    SETTINGS_CREATE_PROJECT_NAME:
      en: "Workspace Name"
      zh: "工作空间名称"

    SETTINGS_CREATE_PROJECT_BILLING:
      en: "WORKSPACE BILLING"
      zh: "工作空间付费"

    SETTINGS_CREATE_PROJECT_BILLING_TIP:
      en: "Provide billing information to create a collaborative workspace. <br/>You will only be charged when instance hour is comsumed in this workspace."
      zh: "提供支付信息以创建一个可协作的工作空间.<br/>在此工作空间你将只需要为超出额度时间的实例付费"

    SETTINGS_CREATE_PROJECT_BILLING_OWNER:
      en: "BILLING OWNER"
      zh: "账单拥有者"

    SETTINGS_CREATE_PROJECT_BILLING_EMAIL:
      en: "BILLING EMAIL"
      zh: "账单邮箱"

    SETTINGS_CREATE_PROJECT_FIRST_NAME:
      en: "First Name"
      zh: "名"

    SETTINGS_CREATE_PROJECT_LAST_NAME:
      en: "Last Name"
      zh: "姓"

    SETTINGS_CREATE_PROJECT_PL_EMAIL:
      en: "example@email.com"
      zh: "example@email.com"

    SETTINGS_CREATE_PROJECT_CARD_NAME:
      en: "CARD NUMBER"
      zh: "卡号"

    SETTINGS_CREATE_PROJECT_PL_CARD_NAME:
      en: "XXXX XXXX XXXX XXXX"
      zh: "XXXX XXXX XXXX XXXX"

    SETTINGS_CREATE_PROJECT_CARD_CVV:
      en: "CVV"
      zh: "CVV"

    SETTINGS_CREATE_PROJECT_EXPRIATION:
      en: "EXPIRATION DATE"
      zh: "过期日期"

    SETTINGS_CREATE_PROJECT_CHARGIFY_SUPPORT:
      en: "Secure Payment"
      zh: "安全支付"

    SETTINGS_CREATE_PROJECT_CHARGIFY_SUPPORT_TIT:
      en: "Powered by Chargify"
      zh: "由Chargify驱动"

    SETTINGS_CREATE_PROJECT_TITLE:
      en: "Create new workspace"
      zh: "创建新工作空间"

    SWITCH_WORKSPACE_UNSAVED_CHANGES:
      en: "Unsaved Changes"
      zh: "未保存的修改"

    SETTINGS_CREATE_PROJECT_EXPIRE_FORMAT:
      en: "Require format MM/YYYY"
      zh: "要求格式 MM/YYYY"

    PAGE_NOT_FOUND_WORKSPACE_TAB_NOT_EXIST:
      en: "Page not Found."
      zh: "页面未找到。"

    WAIT_FOR_ADMIN_FINISH_CREDENTIAL:
      en: "Only workspace admin has the permission to set up credential. You may wait until your admin has made everything ready."
      zh: "只有工作空间的管理员有权限设置证书, 你可以等您的管理员设置好以后再继续。"

    PROVIDE_CRED_TO_VISUALIZE:
      en: "Provide cloud credential to import existing VPC as app."
      zh: "提供云证书以将已有 VPC 导入为 App"

    PAYMENT_INSTANCE_ID:
      en: "Instance ID"
      zh: "实例 ID"

    CANT_DELETE_WORKSPACE:
      en: "We were unable to charge the workspace's credit card. This workspace is in limited status now. Please update your billing information. Once the workspace is back in normal, you may delete it."
      zh: "我们没能在您的工作空间绑定的信用卡上成功扣款。此工作空间现处于受限模式。请更新您的账单信息。一旦工作空间恢复正常模式, 您就可以删除此工作空间。"

    SETTING_INVALID_EMAIL:
      en: "This email is invalid. Please enter a valid email."
      zh: "此电子邮件无效, 请输入有效的电子邮件。"

    TITLE_OPS_CONFLICT:
      en: "Conflict Detected"
      zh: "版本冲突"

    CONTENT_OPS_CONFLICT:
      en: "Cannot save stack since another user has applied changes to this stack. <br/><br/> You can save your changes by duplicate this stack."
      zh: "其他组员在这你之前修改了这个模板，因此无法保存。<br/><br/>你可以通过复制模板来保存当前的改动。"

    WARNNING_APP_CHANGE_BY_OTHER_USER:
      en: "App has been changed by another user. Close the tab and reopen."
      zh: "App 已经被其他用户更改，请关闭该标签并重新打开。"

    # Dashboard logs

    DASHBOARD_PANEL_LOGS_ACTIVITY:
      en: "Activity"
      zh: "活动"

    DASHBOARD_PANEL_LOGS_AUDIT:
      en: "Audit Log"
      zh: "审计"

    DASHBOARD_PANEL_LOGS_NO_ACTIVITY:
      en: "No activity yet."
      zh: "尚无日志"

    DASHBOARD_PANEL_LOGS_NO_ACTIVITY_SUB:
      en: "Operation of team members will appear here."
      zh: "团队成员操作将会显示在这里。"

    # Stack
    DASHBOARD_LOGS_STACK_CREATE:
      en: "%s created stack %s"
      zh: "%s 创建 Stack %s"

    DASHBOARD_LOGS_STACK_REMOVE:
      en: "%s deleted stack %s"
      zh: "%s 删除 Stack %s"

    DASHBOARD_LOGS_STACK_RENAME:
      en: "%s renamed stack %s"
      zh: "%s 重命名 Stack %s"

    DASHBOARD_LOGS_STACK_SAVE:
      en: "%s saved stack %s"
      zh: "%s 保存 Stack %s"

    DASHBOARD_LOGS_STACK_SAVEAS:
      en: "%s duplicated stack %s"
      zh: "%s 复制 Stack %s"

    DASHBOARD_LOGS_STACK_RUN:
    #   en: "%s ran stack %s into app %s"
      en: "%s ran stack %s"
      zh: "%s 运行 Stack %s"

    # App
    DASHBOARD_LOGS_APP_START:
      en: "%s started app %s"
      zh: "%s 恢复 App %s"

    DASHBOARD_LOGS_APP_STOP:
      en: "%s stopped app %s"
      zh: "%s 暂停 App %s"

    DASHBOARD_LOGS_APP_TERMINATE:
      en: "%s terminated app %s"
      zh: "%s 终止 App %s"

    DASHBOARD_LOGS_APP_SAVEIMPORT:
      en: "%s imported VPC as app %s"
      zh: "%s 导入 VPC 为 App %s"

    DASHBOARD_LOGS_APP_SAVE:
      en: "%s saved external change to app %s"
      zh: "%s 保存外部改变到 App %s"

    DASHBOARD_LOGS_APP_UPDATE:
      en: "%s updated app %s"
      zh: "%s 更新 App %s"

    DASHBOARD_LOGS_APP_FORGET:
      en: "%s made app %s forgotten"
      zh: "%s 释放 App %s"

    # Project
    DASHBOARD_LOGS_PROJECT_CREATE:
      en: "%s created workspace %s"
      zh: "%s 创建工作空间 %s"

    DASHBOARD_LOGS_PROJECT_RENAME:
      en: "%s renamed workspace %s"
      zh: "%s 重命名工作空间 %s"

    # Member
    DASHBOARD_LOGS_MEMBER_CREATE:
      en: "%s created member %s"
      zh: "%s 创建成员 %s"

    DASHBOARD_LOGS_MEMBER_UPDATE:
      en: "%s updated member %s"
      zh: "%s 更新成员 %s"

    DASHBOARD_LOGS_MEMBER_REMOVE:
      en: "%s removed member %s"
      zh: "%s 删除成员 %s"

    # Payment
    DASHBOARD_LOGS_PAYMENT_ADD:
      en: "%s added billing information"
      zh: "%s 添加账单信息"

    DASHBOARD_LOGS_PAYMENT_UPDATE:
      en: "%s updated billing information"
      zh: "%s 更新账单信息"

    # CREDENTIAL
    DASHBOARD_LOGS_CREDENTIAL_ADD:
      en: "%s added cloud access credential"
      zh: "%s 添加证书"

    DASHBOARD_LOGS_CREDENTIAL_REMOVE:
      en: "%s removed cloud access credential"
      zh: "%s 删除证书"

    DASHBOARD_LOGS_CREDENTIAL_UPDATE:
      en: "%s updated cloud access credential"
      zh: "%s 更新证书"

    # TOKEN
    DASHBOARD_LOGS_TOKEN_ADD:
      en: "%s added API token %s"
      zh: "%s 添加API令牌 %s"

    DASHBOARD_LOGS_TOKEN_REMOVE:
      en: "%s removed API token %s"
      zh: "%s 删除API令牌 %s"

    DASHBOARD_LOGS_TOKEN_RENAME:
      en: "%s renamed API token %s"
      zh: "%s 重命名API令牌 %s"

    AMI_IS_ADDED_TO_FAVOURITE_AMI:
      en: "AMI %s is added to Favourite AMI."
      zh: "AMI %s 已被添加到 AMI 收藏夹。"

    AMI_IS_REMOVED_FROM_FAVOURITE_AMI:
      en: "AMI %s is removed from Favourite AMI."
      zh: "AMI %s 已从 AMI 收藏夹中移除。"

    CREATE_STACK_TITLE:
      en: "Create Stack"
      zh: "创建 Stack"

    CREATE_STACK_CONFIRM:
      en: "Create Stack"
      zh: "创建 Stack"

    CANT_ATTACH_ENI_TO_MESOS_INSTANCE:
      en: "ENI cannot be attached to a mesos master or slave instance."
      zh: "Eni 不能附加到 Mesos Master 或 Mesos Slave 实例上。"
