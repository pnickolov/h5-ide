# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =
  TOOLBAR:

    LOADING_DATA:
      en: "Loading data..."
      zh: "加载数据中..."

    ROLLING_BACK:
      en: "Rolling back..."
      zh: "回滚中..."

    RELOADING_DATA:
      en: "Reloading data..."
      zh: "刷新数据中..."

    APP_UPDATE_SUCCESSFULLY_TITLE:
      en: "App has updated successfully."
      zh: "App 已成功更新."

    APP_UPDATE_FAILED_TITLE:
      en: "The app failed to update."
      zh: "App 更新失败."

    APP_ROllBACK_DESC:
      en: "The state of your app has been rolled back, except for the already deleted resources."
      zh: "您的 App 状态已回滚, 除了已经删除的资源."

    LBL_DONE:
      en: "Done"
      zh: "完成"

    CONFIRM_ENABLE_STATE:
      en: "Enable VisualOps will override your custom User Data. Are you sure to continue?"
      zh: "开启 VisualOps 将覆盖您的 User Data, 确定继续么?"

    EXPORT_CLOUDFORMATION_WARNNING:
      en: "DB Instance using custom Option Group is not supported in CloudFormation Template. Default Option Group will be used instead."
      zh: "数据库实例的自定义选项组在 CloudFormation 里不支持, 将使用默认的选项组."

    STACK_VALIDATION:
      en: "Stack Validation"
      zh: "Stack"

    VALIDATING_STACK:
      en: "Validating your stack..."
      zh: "校验Stack"

    ESTIMATED_COST:
      en: "Estimated Cost"
      zh: "估计花费"

    PER_MONTH:
      en: " / month"
      zh: " / 月"

    LBL_DOWNLOAD:
      en: "Download"
      zh: "下载"

    LBL_CANCEL:
      en: "Cancel"
      zh: "取消"

    HAS_UNSAVED_CHANGES:
      en: "has unsaved changes."
      zh: "有未保存变更."

    CLOSE_CONFIRM:
      en: "Do you confirm to close it?"
      zh: "您确认要关闭吗?"

    CANCEL_UPDATE_CONFIRM:
      en: "This app has been changed."
      zh: "此 App 已经改变."

    DISCARD_UPDATE_CHANGE:
      en: "Do you confirm to discard the changes?"
      zh: "您确认要丢弃修改吗?"

    IMPORT_SUCCESSFULLY_WELL_DONE:
      en: "Well done! Your VPC %s has been successfully imported as VisualOps app."
      zh: "很好! 您的 VPC 已经成功导入为 VisualOps App."

    NAME_IMPORTED_APP:
      en: "Give this app an appropriate name."
      zh: "给这个 App 起个合适的名字."

    APP_NAME:
      en: "App Name"
      zh: "App 名称"

    APP_USAGE:
      en: "App Usage"
      zh: "App 用途"

    IMPORT_SUCCESSFULLY_MANAGE_EASILY:
      en: "Now you can easily manage the resources and lifecycle of the app within VisualOps."
      zh: "现在你可以用 VisualOps 轻松地管理 App 的资源和生命周期了."

    VPC_REMOVED_OUTSIDE_VISUALOPS:
      en: "VPC of this app has been deleted outside VisualOps."
      zh: "此 App 的 VPC 在 VisualOps 外部被删除."

    CONFIRM_REMOVE_APP:
      en: "Do you want to remove the app?"
      zh: "您确认要移除此 App 吗?"

    CLOUD_RESOURCE_KEY_PAIR:
      en: "Key Pair"
      zh: "密钥组"

    CLOUD_RESOURCE_EBS_SNAPSHOT:
      en: "EBS Snapshot"
      zh: "EBS 快照"

    CLOUD_RESOURCE_SNS_SUBSCRIPTION:
      en: "SNS Topic & Subscription"
      zh: "SNS 主题和订阅"

    CLOUD_RESOURCE_SERVER_CERTIFICATE:
      en: "Server Certificate"
      zh: "服务器证书"

    CLOUD_RESOURCE_DHCP_OPTION_SETS:
      en: "DHCP Option Sets"
      zh: "DHCP 选项设定"

    CLOUD_RESOURCE_DB_PARAMETER_GROUPS:
      en: "DB Parameter Groups"
      zh: "数据库参数组"

    CLOUD_RESOURCE_DB_SNAPSHOT:
      en: "DB Snapshot"
      zh: "数据库快照"

    CLOUD_RESOURCE_SORT_BY_DATE:
      en: "By Date"
      zh: "按日期"

    CLOUD_RESOURCE_SORT_BY_STORAGE:
      en: "By Storage"
      zh: "按存储"

    CLOUD_RESOURCE_SORT_BY_ENGINE:
      en: "By Engine"
      zh: "按引擎"

    CLOUD_RESOURCE_NO_EBS_SNAPSHOT:
      en: "No EBS Snapshot in %s."
      zh: "%s 没有 EBS 快照"

    CLOUD_RESOURCE_NO_DB_SNAPSHOT:
      en: "No DB Snapshot in %s."
      zh: "%s 没有数据库快照"

    CLOUD_RESOURCE_BROWSE_COMMUNITY_AMI:
      en: "Use \"Browse Community AMI\" to add Favourite AMI."
      zh: "用 \"浏览共享 AMI\" 收藏 AMI"

    CLOUD_RESOURCE_AUTO_SCALING_GROUP:
      en: "Auto Scaling Group "
      zh: "自动收缩组"

    BTN_RUN_STACK:
      en: "Run Stack"
      zh: "运行"

    TIP_BTN_RUN_STACK:
      en: "Run this stack into an app"
      zh: "运行当前Stack为App"

    POP_TIT_RUN_STACK:
      en: "Run Stack"
      zh: "运行"

    TIP_SAVE_STACK:
      en: "Save Stack"
      zh: "保存Stack"

    TIP_DELETE_STACK:
      en: "Delete Stack"
      zh: "删除Stack"

    TIP_DELETE_NEW_STACK:
      en: "This stack is not saved yet."
      zh: "当前Stack未保存"

    POP_TIT_DELETE_STACK:
      en: "Delete Stack"
      zh: "删除Stack"

    POP_BODY_DELETE_STACK:
      en: "Do you confirm to delete stack '%s'?"
      zh: "确认删除Stack '%s' 吗?"

    POP_BTN_DELETE_STACK:
      en: "Delete"
      zh: "删除"

    POP_BTN_CANCEL:
      en: "Cancel"
      zh: "取消"

    POP_EXPORT_CF:
      en: "Export to AWS CloudFormation Template"
      zh: "导出为 AWS CloudFormation 模板"

    POP_EXPORT_CF_INFO:
      en: "Download the template file when it's ready, then you can upload it in AWS console to create CloudFormation Stack."
      zh: "请在数据转换后下载这个云编排模板文件，并把它上传到亚马逊管理控制台来创建 CloudFormation 模块。"

    POP_BTN_EXPORT_CF:
      en: "Download Template File"
      zh: "下载模板文件"

    TIP_DUPLICATE_STACK:
      en: "Duplicate Stack"
      zh: "复制Stack"

    TIT_CLOSE_TAB:
      en: "Close Tab"
      zh: "关闭标签"

    POP_TIT_DUPLICATE_STACK:
      en: "Duplicate Stack"
      zh: "复制Stack"

    POP_BODY_DUPLICATE_STACK:
      en: "New Stack Name:"
      zh: "Stack名称:"

    POP_BODY_APP_To_STACK:
      en: "New Stack Name:"
      zh: "Stack名称:"

    POP_BTN_DUPLICATE_STACK:
      en: "Duplicate"
      zh: "复制"

    POP_BTN_SAVE_TO_STACK:
      en: "Save"
      zh: "保存"

    TIP_CREATE_STACK:
      en: "Create New Stack"
      zh: "创建新Stack"

    TIP_ZOOM_IN:
      en: "Zoom In"
      zh: "放大"

    TIP_SAVE_APP_TO_STACK:
      en: "Save App as Stack"
      zh: "App 保存为 Stack"

    TIP_ZOOM_OUT:
      en: "Zoom Out"
      zh: "缩小"

    EXPORT:
      en: "Export..."
      zh: "导出..."

    EXPORT_AS_JSON:
      en: "Export to JSON"
      zh: "导出JSON文件"

    POP_TIT_EXPORT_AS_JSON:
      en: "Export"
      zh: "导出"

    POP_TIT_APP_TO_STACK:
      en: "Save App as Stack"
      zh: "将 App 保存为 Stack"

    POP_INTRO_1:
      en: "Saving app as stack helps you to revert changes made during app editing back to stack."
      zh: "将 App 保存为Stack可以将编辑 App 时所作修改保存为Stack."

    POP_INTRO_2:
      en: "Canvas design, resource properties and instance states will be saved."
      zh: "画布设计, 资源属性和 instance states 都将被保存."

    POP_REPLACE_STACK:
      en: "Replace the original stack"
      zh: "替换原始Stack"

    POP_REPLACE_STACK_INTRO:
      en: "This app is launched from stack"
      zh: "此 App 是从 stack"

    POP_REPLACE_STACK_INTRO_END:
      en: ". Entirely replace the stack with current app design."
      zh: "启动的, 用当前配置完全替换该Stack."

    POP_SAVE_NEW_STACK:
      en: "Save as new stack"
      zh: "另存为新Stack"

    POP_SAVE_STACK_INSTRUCTION:
      en: "Specify a name for new stack:"
      zh: "指定新Stack的名字"

    POP_STACK_NAME_ERROR:
      en: "The stack name is already in use. Please use another one."
      zh: "此Stack名字已被占用."

    POP_BODY_EXPORT_AS_JSON:
      en: "The stack is ready to export. Please click the Download button to save the file."
      zh: "此Stack已经可以导出, 请点击下载按钮保存文件."

    POP_BTN_DOWNLOAD:
      en: "Download"
      zh: "保存"

    EXPORT_AS_PNG:
      en: "Export to PNG"
      zh: "导出图片"

    SAVE_AS_APP:
      en: "Save as App"
      zh: "保存为App"

    EXPORT_AS_CF:
      en: "Convert to CloudFormation Format"
      zh: "导出 CloudFormation 文件"

    TIP_STOP_APP:
      en: "Stop This App's Resources."
      zh: "暂停App"

    TIP_CONTAINS_INSTANCE_STORED:
      en: "This app cannot be stopped since it contains instance-stored AMI."
      zh: "不能暂停这个App，因为它包含实例存储 AMI"

    POP_TIT_STOP_APP:
      en: "Confirm to Stop App"
      zh: "确认暂停"

    POP_BODY_STOP_APP_LEFT:
      en: "Do you confirm to stop app"
      zh: "本操作将暂停App中的相关资源，您确认暂停当前App"

    POP_BODY_STOP_APP_RIGHT:
      en: "?"
      zh: " 吗?"

    POP_TIT_STOP_PRD_APP:
      en: "Confirm to Stop App for Production"
      zh: "确认暂停生产环境App"

    POP_BTN_STOP_APP:
      en: "Stop"
      zh: "暂停"

    TIP_START_APP:
      en: "Start App"
      zh: "恢复App"

    POP_TIT_START_APP:
      en: "Confirm to Start App"
      zh: "确认恢复"

    POP_BODY_START_APP:
      en: "Do you confirm that you would like to start the app?"
      zh: "本操作将恢复App中的相关资源，您确认恢复当前App吗?"

    POP_START_CONFIRM_LIST_1:
      en: "EC2 instances will be started."
      zh: "EC2 实例将启动."

    POP_START_CONFIRM_LIST_2:
      en: "DB instances will be restored from final snapshot."
      zh: "数据库实例将从最终快照恢复."

    POP_START_CONFIRM_LIST_3:
      en: "Auto Scaling Group will be recreated."
      zh: "自动伸缩组将重新创建."

    POP_STOP_CONFIRM_LIST_1:
      en: "EC2 instances will be stopped."
      zh: "EC2 实例将停止."

    POP_STOP_CONFIRM_LIST_1_SPAN:
      en: "Instance-stored instances will be deleted."
      zh: "实例存储的实例将被删除."

    POP_STOP_CONFIRM_LIST_2:
      en: "DB instances will be deleted final snapshot will be taken."
      zh: "将删除的数据库实例将创建快照."

    POP_STOP_CONFIRM_LIST_2_SPAN:
      en: "Snapshots will be restored when the app is started."
      zh: "快照将会在 App 启动的时候恢复."

    POP_STOP_CONFIRM_LIST_3:
      en: "Auto Scaling Group will be deleted."
      zh: "自动伸缩组将被删除."

    POP_STOP_CONFIRM_LIST_3_SPAN:
      en: "Auto Scaling Group will be recreated when the app is started."
      zh: "自动伸缩组将会在 App 启动的时候重新创建."

    POP_START_WARNNING:
      en: "Warning"
      zh: "警告"

    POP_START_MISSING_SNAPSHOT_1:
      en: "DB Instance"
      zh: "数据库实例"

    POP_START_MISSING_SNAPSHOT_2:
      en: "'s final snapshot is missing. This DB instance cannot be restored."
      zh: "的最终 snapshot 不存在， 此 DBInstace 将无法恢复。"

    POP_ESTIMATED_COST_WHEN_STOP:
      en: "Estimated Cost When Stopped"
      zh: "停止后的估计费用"

    POP_SAVING_COMPARED_TO_RUNNING:
      en: "Saving Compared to Running App"
      zh: "相比运行时节省"

    POP_PER_MONTH:
      en: "/ month"
      zh: "/ 月"

    POP_CANT_STOP_1:
      en: "cannot take final snapshot."
      zh: "无法创建快照"

    POP_CANT_STOP_2:
      en: "Wait for the DB instance(s) to be available. Then try to stop the app again."
      zh: "请等到数据库实例状态可用时, 再重试停止 App"

    POP_TAKE_DB_SNAPSHOT:
      en: "Take final snapshot for DB Instances."
      zh: "为数据库实例创建最终快照"

    POP_CANT_TAKE_SNAPSHOT_1:
      en: "DB Instance"
      zh: "数据库实例"

    POP_CANT_TAKE_SNAPSHOT_2:
      en: "cannot take final snapshot."
      zh: "无法创建最终快照"

    POP_FORCE_TERMINATE:
      en: "Force to delete app"
      zh: "强制删除 App"

    POP_FORCE_TERMINATE_CONTENT:
      en: "The app %s failed to terminate. Do you want to force deleting it? After force deleting it, you need to manually manage the resource in aws console."
      zh: "App %s 种植失败, 您要强制删除它吗? 强制删除后, 您需要在 AWS 控制台里手动管理资源."

    POP_BTN_START_APP:
      en: "Start"
      zh: "恢复"

    TIP_UPDATE_APP:
      en: "Edit App"
      zh: "编辑App"

    TIP_SAVE_UPDATE_APP:
      en: "Apply Updates"
      zh: "保存应用更新"

    TIP_CANCEL_UPDATE_APP:
      en: "Discard Updates"
      zh: "取消应用更新"

    TIP_TERMINATE_APP:
      en: "Permanently Terminate This App's Resources"
      zh: "销毁App"

    POP_TIT_TERMINATE_APP:
      en: "Confirm to Terminate App"
      zh: "确认销毁"

    POP_BODY_TERMINATE_APP_LEFT:
      en: "Warning: all resources in the app will be permanantly deleted. <br/>Do you confirm to terminate app"
      zh: "本操作将销毁App中的相关资源，您确认销毁当前App"

    POP_BODY_TERMINATE_APP_RIGHT:
      en: "?"
      zh: " 吗"

    POP_BTN_TERMINATE_APP:
      en: "Terminate"
      zh: "销毁"

    POP_TIT_TERMINATE_PRD_APP:
      en: "Confirm to Terminate App for Production"
      zh: "确认销毁生产环境App"

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
      zh: "恢复App"

    TOOLBAR_HANDLE_STOP_APP:
      en: "Stop app"
      zh: "暂停App"

    TOOLBAR_HANDLE_TERMINATE_APP:
      en: "Terminate app"
      zh: "销毁App"

    TOOLBAR_HANDLE_EXPORT_CLOUDFORMATION:
      en: "Convert to CloudFormation template"
      zh: "导出 CloudFormation 模板"

    POP_BODY_APP_UPDATE_EC2:
      en: "The public and private addresses will be reassigned after the restart.",
      zh: "重启后，公有/私有的IP地址将会被重新分配。"

    POP_BODY_APP_UPDATE_VPC:
      en: "If any of the instance(s) has been automatically assigned public IP, the IP will change after restart.",
      zh: "重启后，已分配公有IP地址的实例将会被重新分配。"

    TIP_REFRESH_REOURCES:
      en: "Refresh Reources"
      zh: "刷新资源"

    TIP_JSON_DIFF:
      en: "JSON Diff"
      zh: "JSON Diff"

    TIP_JSON_VIEW:
      en: "JSON View"
      zh: "JSON 视图"

    TIP_CUSTOM_USER_DATA:
      en: "Custom User Data will be overridden and disabled to allow installing OpsAgent. (Currently only support Linux platform)"
      zh: "自定义 User Data 将被覆盖并禁止以安装 OpsAgent.(目前只支持 Linux 平台)"

    TIP_NO_CLASSIC_DATA_STACK:
      en: "We will drop support for EC2 Classic and Default VPC soon. We have disabled create new stack, run app or edit app in those platforms. You can export existing stacks as CloudFormation template or as a PNG file. Click to read detailed announcement."
      zh: "我们即将放弃对 EC2 Classic 和 Default VPC 的支持. 我们已经禁止了在这些平台上的创建Stack, 运行 App, 和修改 App 操作. 你可以将已存在的Stack导出为 CloudFormation 模板或者是 PNG 文件. 点击此处阅读详细说明."

    TIP_NO_CLASSIC_DATA_APP:
      en: "We will drop support for EC2 Classic and Default VPC soon. We have disabled create new stack, run app or edit app in those platforms. You can still manage the lifecycle of existing apps.  Click to read detailed announcement."
      zh: "我们即将放弃对 EC2 Classic 和 Default VPC 的支持. 我们已经禁止了在这些平台上的创建Stack, 运行 App, 和修改 App 操作. 您仍然可以管理已存在的 App. 点击此处阅读详细说明."

    TIP_LINESTYLE:
      en: "Line Style"
      zh: "连线类型"

    LBL_LINESTYLE_STRAIGHT:
      en: "Straight"
      zh: "直线"

    LBL_LINESTYLE_ELBOW:
      en: "Elbow"
      zh: "折线"

    LBL_LINESTYLE_CURVE:
      en: "Curve"
      zh: "曲线"

    LBL_LINESTYLE_SMOOTH_QUADRATIC_BELZIER:
      en: "Smooth quadratic Belzier curve"
      zh: "光滑的二次贝塞尔曲线"

    LBL_LINESTYLE_HIDE_SG:
      en: "Hide SecurityGroup line"
      zh: "隐藏SecurityGroup线"

    LBL_LINESTYLE_SHOW_SG:
      en: "Show SecurityGroup line"
      zh: "显示SecurityGroup线"

    EXPERIMENT:
      en: "Experimental Feature!"
      zh: "实验性功能"

    TOGGLE_VISUALOPS_ON:
      en: "instance state on"
      zh: "instance state 开"

    TOGGLE_VISUALOPS_OFF:
      en: "instance state off"
      zh: "instance state 关"

    LBL_NO_CLASSIC:
      en: "Where are the missing buttons?"
      zh: "有些按钮不见了?"

    EDIT_APP:
      en: "Edit App"
      zh: "修改 App"

    APPLY_EDIT:
      en: "Apply"
      zh: "应用"

    START_APP:
      en: "Start App"
      zh: "启动 App"

    CONNECTION_LOST_TO_RECONNECT:
      en: "Connection lost. Attempting to reconnect..."
      zh: "连接丢失. 正在尝试重连..."

    CHANGES_MAY_NOT_BE_SAVED:
      en: "Changes made now may not be saved."
      zh: "所作的修改将不会被保存."

    RELOAD_STATES:
      en: "Reload States"
      zh: "刷新 States"

    SHOW_UNUSED_REGIONS:
      en: "Show unused regions"
      zh: "显示未使用的地区"
