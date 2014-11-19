# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =

  NOTIFY:

    WARN_AUTH_FAILED:
      en : "Authentication failed."
      zh : "认证失败"

    INFO_STATE_COPY_TO_CLIPBOARD:
      en : "State(s) copied to clipboard"
      zh : "State(s) 已复制到剪贴板"

    INFO_STATE_PARSE_COMMAND_FAILED:
      en : "The states are from a different version. Some module may be incompatible."
      zh : "发现不同版本的 states，可能导致一些模块不兼容。"

    INFO_STATE_PARSE_REFRENCE_FAILED:
      en : "The states contains @references which cannot pass on. Validate to see details."
      zh : "States 包含无效引用，点击验证查看详情。"

    WARN_OPERATE_NOT_SUPPORT_YET:
      en : "This operation is not supported yet."
      zh : "目前不支持此操作。"

    WARN_ASG_CAN_ONLY_CONNECT_TO_ELB_ON_LAUNCH:
      en : "Auto Scaling Group can only register with Load Balancer on launch."
      zh : "Auto Scaling 组只能在初次运行时连接负载均衡器"

    WARN_AMI_NOT_EXIST_TRY_USE_OTHER:
      en : "AMI %s is not available. Try to use another AMI."
      zh : "AMI %s 不存在，请尝试使用其他 AMI。"

    WARN_ATTACH_VOLUME_REACH_INSTANCE_LIMIT:
      en : "Attached volume has reached instance limit."
      zh : "此实例连接卷已达上限。"

    WARN_KEYPAIR_NAME_ALREADY_EXISTS:
      en : "Key pair with the same name already exists."
      zh : "密钥对名称已存在。"

    FAILED_TO_DELETE_KP:
      en: "Failed to delete key pair. Please try again later."
      zh: "删除密钥对失败，请稍后重试。"

    WARN_CANNT_AUTO_ASSIGN_CIDR_FOR_SUBNET:
      en : "Cannot auto assign CIDR block for subnets. Please manually update subnets' CIDR block before changing VPC's CIDR block."
      zh : "不能为子网自动分配 CIDR，在更改 VPC 的 CIDR 之前先请手动功能新子网的 CIDR "

    WARN_VPC_DOES_NOT_EXIST:
      en : "VPC does not exist."
      zh : "VPC 不存在。"



    INFO_APP_REFRESH_FINISH:
      en: "Resources for app( %s ) are refreshed."
      zh: "完成App( %s )的资源刷新。"

    INFO_APP_REFRESH_FAILED:
      en: "Refreshing resources for app( %s ) falied. Please try again."
      zh: "刷新App( %s )的资源失败, 请点击刷新按钮来重试。"

    INFO_APP_REFRESH_START:
      en: "Refreshing resources for app( %s )..."
      zh: "开始刷新App( %s )的资源 ..."

    ERR_CONVERT_CLOUDFORMATION:
      en: "Fail to convert to CloudFormation format"
      zh: "转换成 CloudFormation 出错"

    ERROR_CANT_DUPLICATE:
      en: "Fail to duplicate stack. Please try again."
      zh: "复制 Stack 失败，请重试。"

    ERROR_FAILED_LOAD_AWS_DATA:
      en: "Fail to load AWS data. Please try again later."
      zh: "加载 AWS 数据失败，请稍后重试。"

    ERROR_FAILED_START:
      en: "Fail to start your app %s. (ErrorCode: %s)"
      zh: "App %s 启动失败。（错误码：%s）"

    ERROR_FAILED_STOP:
      en: "Fail to stop your app %s. (ErrorCode: %s)"
      zh: "App %s 停止失败。（错误码：%s）"

    ERROR_FAILED_TERMINATE:
      en: "Fail to terminate your app %s. (ErrorCode: %s)"
      zh: "App %s 终止失败。（错误码：%s）"

    INFO_REQ_SUCCESS:
      en: "Sending request to %s %s..."
      zh: "正在发送 %s %s 请求..."

    ERR_REQ_FAILED:
      en: "Sending request to %s %s failed."
      zh: "发送 %s %s 请求失败。"

    INFO_HDL_SUCCESS:
      en: "%s %s successfully."
      zh: "%s %s 成功。"

    ERR_HDL_FAILED:
      en: "%s %s failed."
      zh: "%s %s 失败。"

    ERR_SAVE_FAILED:
      en: "Fail to save stack %s. Please try again."
      zh: "保存模块 %s 失败，请您检查并重新保存。"

    ERR_SAVE_FAILED_NAME:
      en: "The stack name has already been used. Please change to a new one."
      zh: "已存在相同名字的模块，请输入一个新的名字后重新保存。"

    ERR_SAVE_SUCCESS:
      en: "Save stack %s successfully."
      zh: "保存 %s 成功。"

    ERR_DEL_STACK_SUCCESS:
      en: "Delete stack %s successfully."
      zh: "删除 %s 成功。"

    ERR_DEL_STACK_FAILED:
      en: "Fail to delete stack %s."
      zh: "删除 %s 失败。"


    FAILED_TO_DELETE_DHCP:
      en: "%s DHCP Options failed to delete because of: %s"
      zh: "DHCP 选项 %s 删除失败，失败原因：%s"

    DELETE_SUCCESSFULLY:
      en: "Delete Successfully"
      zh: "删除成功"

    DHCP_CREATED_SUCCESSFULLY:
      en: "New DHCP Option is created successfully"
      zh: "DHCP 选项创建成功"

    YOU_MUST_DOWNLOAD_THE_KEYPAIR:
      en: "Make sure you have downloaded the key pair."
      zh: "您必须下载密钥对。"

    XXX_IS_DELETED:
      en: "%s is deleted successfully."
      zh: "%s 删除成功。"

    SELECTED_KEYPAIRS_ARE_DELETED:
      en: "Selected %s key pairs are deleted."
      zh: "选中的密钥对 %s 删除成功。"

    XXX_IS_IMPORTED:
      en: "%s is imported."
      zh: "%s 导入成功。"

    PARAMETER_GROUP_UPDATED_FAILED:
      en: "Parameter Group updated failed because of %s"
      zh: ""

    PARAMETER_GROUP_IS_UPDATED:
      en: "Parameter Group is updated."
      zh: "参数组已更新。"

    CREATE_FAILED_BECAUSE_OF_XXX:
      en: "Create failed because of: %s"
      zh: "创建失败，失败原因：%s"

    NEW_RDS_PARAMETER_GROUP_IS_CREATED_SUCCESSFULLY:
      en: "New RDS Parameter Group is created successfully!"
      zh: "RDS 参数组创建成功！"

    RDS_PARAMETER_GROUP_IS_RESET_SUCCESSFULLY:
      en: "RDS Parameter Group is reset successfully!"
      zh: "RDS 参数组重置成功！"



    DB_SNAPSHOT_CREATE_FAILED:
      en: "Create failed because of : %s"
      zh: "创建失败，失败原因：%s"

    DUPLICATE_FAILED_BECAUSE_OF_XXX:
      en: "Duplicate failed because of : %s"
      zh: "复制失败，失败原因：%s"

    DB_SNAPSHOT_DUPLICATE_SUCCESS:
      en: "New RDS snapshot is duplicated successfully!"
      zh: "RDS 快照复制成功！"

    DB_SNAPSHOT_DUPLICATE_SUCCESS_OTHER_REGION:
      en: "New RDS Snapshot is duplicated to another region, you need to switch region to check the snapshot you just created."
      zh: "RDS 快照已复制到其他地区，请切换到对应地区去检查刚创建好的快照。"

    XXX_SNAPSHOT_FAILED_TO_DELETE:
      en: "%s Snapshot failed to delete, Please try again later."
      zh: "快照 %s 删除失败，请稍后重试。"

    DB_SNAPSHOT_DELETE_SUCCESS:
      en: "RDS Snapshot(s) Delete Successfully!"
      zh: "RDS 快照删除成功！"

    NEW_SNAPSHOT_IS_CREATED_SUCCESSFULLY:
      en: "New Snapshot is created successfully!"
      zh: "快照创建成功！"

    INFO_DUPLICATE_SNAPSHOT_SUCCESS:
      en: "New Snapshot is duplicated successfully"
      zh: "快照复制成功"

    INFO_ANOTHER_REGION_DUPLICATE_SNAPSHOT_SUCCESS:
      en: "New Snapshot is duplicated to another region, you need to switch region to check the snapshot you just created."
      zh: "快照已复制到其他区域，请切换到对应区域去检查刚创建好的快照。"

    INFO_DELETE_SNAPSHOT_SUCCESSFULLY:
      en: "Delete Successfully"
      zh: "删除成功"

    REMOVE_SUBSCRIPTION_SUCCEED:
      en: "Remove Subscription Succeed."
      zh: "删除订阅成功。"

    SELECTED_XXX_SNS_TOPIC_ARE_DELETED:
      en: "Selected %s SNS topic are deleted."
      zh: "选定的 SNS 主题 %s 删除成功。"

    CREATE_SUBSCRIPTION_SUCCEED:
      en: "Create Subscription Succeed"
      zh: "创建订阅成功"

    CERTIFICATE_NAME_XXX_IS_INVALID:
      en: "Certificate name %s is invalid"
      zh: "证书名 %s 无效"

    CERTIFICATE_XXX_IS_UPLOADED:
      en: "Certificate %s is uploaded"
      zh: "证书 %s 已更新"

    CANNOT_LOAD_APPLICATION_DATA:
      en: "Cannot load application data. Please reload your browser."
      zh: "加载应用数据失败。请刷新浏览器。"

    SETTINGS_UPDATE_PWD_SUCCESS:
      en: "Password has been updated."
      zh: "密码修改成功。"

    SETTINGS_UPDATE_EMAIL_SUCCESS:
      en: "Email has been updated."
      zh: "电子邮箱修改成功。"

    FAIL_TO_CREATE_TOKEN:
      en: "Fail to create token, please retry."
      zh: "令牌创建失败，请重试。"

    FAIL_TO_UPDATE_TOKEN:
      en: "Fail to update token, please retry."
      zh: "更新令牌失败，请重试。"

    FAIL_TO_DELETE_TOKEN:
      en: "Fail to delete token, please retry."
      zh: "删除令牌失败，请重试。"

    FAILED_TO_LOAD_DATA:
      en: "Failed to load data, please retry."
      zh: "加载数据失败，请重试。"

    FAILED_TO_LOAD_AWS_DATA:
      en: "Failed to load aws data, please retry."
      zh: "加载 AWS 数据失败，请重试"

    READ_REPLICA_MUST_BE_DROPPED_IN_THE_SAME_SBG:
      en: "Read replica must be dropped in the same subnet group with source DB instance."
      zh: "只读副本必须与数据库实例放置在同一个子网组里。"

    CANNOT_CREATE_MORE_READ_REPLICA:
      en: "Cannot create more read replica."
      zh: "只读副本达到上限。"

    CANNOT_CREATE_SBG_DUE_TO_INSUFFICIENT_SUBNETS:
      en: "Cannot create subnet group due to insufficient subnets."
      zh: "子网数量不足，无法创建子网组。"

    ERR_GET_PASSWD_FAILED:
      en: "There was an error decrypting your password. Please ensure that you have entered your private key correctly."
      zh: "解密出错，请确认您是否上传了正确的私钥。"

    ERR_AMI_NOT_FOUND:
      en: "Can not find information for selected AMI( %s ), try to drag another AMI."
      zh: "无法获取选中的( %s ) AMI的信息，请拖拽其他的AMI。"

    THE_ADDING_RULE_ALREADY_EXIST:
      en: "The same rule already exists."
      zh: "该规则已存在。"

    UNABLE_TO_LOAD_COMMUNITY_AMIS:
      en: "Unable to load community AMIs"
      zh: "不能加载社区AMI"

    FAIL_TO_EXPORT_TO_CLOUDFORMATION:
      en: "Fail to export to AWS CloudFormation Template, Error code: %s"
      zh: "导出 AWS CloudFormation 模板失败，（错误码：%s）"

    RELOAD_STATE_INVALID_REQUEST:
        en: "Sorry, but the request is invalid."
        zh: "非法请求。"

    RELOAD_STATE_NETWORKERROR:
      en: "Network error. Please try again later."
      zh: "网络错误，请稍后重试。"

    RELOAD_STATE_INTERNAL_SERVER_ERROR:
      en: "Sorry, internal server error. Please try again later."
      zh: "内部服务器错误，请稍后重试。"

    RELOAD_STATE_SUCCESS:
      en: "States reloaded successfully."
      zh: "States 重新加载成功。"

    RELOAD_STATE_NOT_READY:
      en: "OpsAgent is not ready yet. Please try again later."
      zh: "OpsAgent 还没准备好，请稍后重试。"

    FAILA_TO_RUN_STACK_BECAUSE_OF_XXX:
      en: "Fail to run your stack %s because of %s"
      zh: "Stack %s 运行失败，失败原因：%s"

    UPDATED_FULLNAME_SUCCESS:
      en: "Full name Updated successfully"
      zh: "全名更新成功"

    UPDATED_FULLNAME_FAIL:
      en: "Fail to update full name. Please try again later."
      zh: "全名更新失败，请稍后重试。"
