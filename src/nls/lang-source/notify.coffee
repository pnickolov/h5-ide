# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =

  NOTIFY:

    WARN_AUTH_FAILED:
      en : "Authentication failed."
      zh : ""

    INFO_STATE_COPY_TO_CLIPBOARD:
      en : "State(s) copied to clipboard"
      zh : ""

    INFO_STATE_PARSE_COMMAND_FAILED:
      en : "The states are from a different version. Some module may be incompatible."
      zh : ""

    INFO_STATE_PARSE_REFRENCE_FAILED:
      en : "The states contains @references which cannot pass on. Validate to see details."
      zh : ""

    WARN_OPERATE_NOT_SUPPORT_YET:
      en : "This operation is not supported yet."
      zh : ""

    WARN_ASG_CAN_ONLY_CONNECT_TO_ELB_ON_LAUNCH:
      en : "Auto Scaling Group can only register with Load Balancer on launch."
      zh : ""

    WARN_AMI_NOT_EXIST_TRY_USE_OTHER:
      en : "The AMI(%s) is not exist now, try to use another AMI."
      zh : ""

    WARN_ATTACH_VOLUME_REACH_INSTANCE_LIMIT:
      en : "Attached volume has reached instance limit."
      zh : ""

    WARN_KEYPAIR_NAME_ALREADY_EXISTS:
      en : "KeyPair with the same name already exists."
      zh : ""

    WARN_CANNT_AUTO_ASSIGN_CIDR_FOR_SUBNET:
      en : "Cannot auto-assign cidr for subnets, please manually update subnets' cidr before changing vpc's cidr."
      zh : ""

    WARN_VPC_DOES_NOT_EXIST:
      en : "VPC does not exist."
      zh : ""





    INFO_APP_REFRESH_FINISH:
      en: "Refresh resources for app( %s ) complete."
      zh: "完成应用( %s )的资源刷新。"

    INFO_APP_REFRESH_FAILED:
      en: "Refresh resources for app( %s ) falied, please click refresh tool button to retry."
      zh: "刷新应用( %s )的资源失败, 请点击刷新按钮来重试。"

    INFO_APP_REFRESH_START:
      en: "Refresh resources for app( %s ) start ..."
      zh: "开始刷新应用( %s )的资源 ..."

    ERR_CONVERT_CLOUDFORMATION:
      en: "Convert to stack json to CloudFormation format error"
      zh: "转换成CloudFormation出错"

    ERROR_CANT_DUPLICATE:
      en: "Cannot duplicate the stack, please retry."
      zh: ""

    ERROR_FAILED_LOAD_AWS_DATA:
      en: "Error while loading AWS data, please try again later."
      zh: ""

    ERROR_FAILED_START:
      en: "Fail to start your app %s. (ErrorCode: %s)"
      zh: ""

    ERROR_FAILED_STOP:
      en: "Fail to stop your app %s. (ErrorCode: %s)"
      zh: ""

    ERROR_FAILED_TERMINATE:
      en: "Fail to terminate your app %s. (ErrorCode: %s)"
      zh: ""

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
      en: "Save stack %s failed, please check and save it again."
      zh: "保存模块 %s 失败，请您检查并重新保存。"

    ERR_SAVE_SUCCESS:
      en: "Save stack %s successfully."
      zh: "保存 %s 成功。"

    ERR_DEL_STACK_SUCCESS:
      en: "Delete stack %s successfully."
      zh: "删除 %s 成功。"

    ERR_DEL_STACK_FAILED:
      en: "Delete stack %s failed."
      zh: "删除 %s 失败。"


    FAILED_TO_DELETE_DHCP:
      en: "%s DhcpOptions failed to delete because of: %s"
      zh: ""

    DELETE_SUCCESSFULLY:
      en: "Delete Successfully"
      zh: ""

    DHCP_CREATED_SUCCESSFULLY:
      en: "New DHCP Option is created successfully"
      zh: ""

    YOU_MUST_DOWNLOAD_THE_KEYPAIR:
      en: "You must download the keypair."
      zh: ""

    XXX_IS_DELETED:
      en: "%s is deleted."
      zh: ""

    SELECTED_KEYPAIRS_ARE_DELETED:
      en: "Selected %s key pairs are deleted."
      zh: ""

    XXX_IS_IMPORTED:
      en: "%s is imported."
      zh: ""

    PARAMETER_GROUP_UPDATED_FAILED:
      en: "Parameter Group updated failed because of %s"
      zh: ""

    PARAMETER_GROUP_IS_UPDATED:
      en: "Parameter Group is updated."
      zh: ""

    CREATE_FAILED_BECAUSE_OF_XXX:
      en: "Create failed because of: %s"
      zh: ""

    NEW_RDS_PARAMETER_GROUP_IS_CREATED_SUCCESSFULLY:
      en: "New RDS Parameter Group is created successfully!"
      zh: ""

    RDS_PARAMETER_GROUP_IS_RESET_SUCCESSFULLY:
      en: "RDS Parameter Group is reset successfully!"
      zh: ""





    DB_SNAPSHOT_CREATE_FAILED:
      en: "Create failed because of : %s"
      zh: ""

    DUPLICATE_FAILED_BECAUSE_OF_XXX:
      en: "Duplicate failed because of : %s"
      zh: ""

    DB_SNAPSHOT_DUPLICATE_SUCCESS:
      en: "New RDS snapshot is duplicated successfully!"
      zh: ""

    DB_SNAPSHOT_DUPLICATE_SUCCESS_OTHER_REGION:
      en: "New RDS Snapshot is duplicated to another region, you need to switch region to check the snapshot you just created."
      zh: ""

    XXX_SNAPSHOT_FAILED_TO_DELETE:
      en: "%s Snapshot failed to delete, Please try again later."
      zh: " "

    DB_SNAPSHOT_DELETE_SUCCESS:
      en: "RDS Snapshot(s) Delete Successfully!"
      zh: ""

    NEW_SNAPSHOT_IS_CREATED_SUCCESSFULLY:
      en: "New Snapshot is created successfully!"
      zh: ""

    INFO_DUPLICATE_SNAPSHOT_SUCCESS:
      en: "New Snapshot is duplicated successfully"
      zh: ""

    INFO_ANOTHER_REGION_DUPLICATE_SNAPSHOT_SUCCESS:
      en: "New Snapshot is duplicated to another region, you need to switch region to check the snapshot you just created."
      zh: ""

    INFO_DELETE_SNAPSHOT_SUCCESSFULLY:
      en: "Delete Successfully"
      zh: ""

    REMOVE_SUBSCRIPTION_SUCCEED:
      en: "Remove Subscription Succeed."
      zh: ""

    SELECTED_XXX_SNS_TOPIC_ARE_DELETED:
      en: "Selected %s SNS topic are deleted."
      zh: ""

    CREATE_SUBSCRIPTION_SUCCEED:
      en: "Create Subscription Succeed"
      zh: ""

    CERTIFICATE_NAME_XXX_IS_INVALID:
      en: "Certificate name %s is invalid"
      zh: ""

    CERTIFICATE_XXX_IS_UPLOADED:
      en: "Certificate %s is uploaded"
      zh: ""

    CANNOT_LOAD_APPLICATION_DATA:
      en: "Cannot load application data. Please reload your browser."
      zh: ""

    SETTINGS_UPDATE_PWD_SUCCESS:
      en: "Password has been updated."
      zh: "密码修改成功。"

    SETTINGS_UPDATE_EMAIL_SUCCESS:
      en: "Email has been updated."
      zh: "电子邮箱修改成功。"

    FAIL_TO_CREATE_TOKEN:
      en: "Fail to create token, please retry."
      zh: ""

    FAIL_TO_UPDATE_TOKEN:
      en: "Fail to update token, please retry."
      zh: ""

    FAIL_TO_DELETE_TOKEN:
      en: "Fail to delete token, please retry."
      zh: ""

    FAILED_TO_LOAD_DATA:
      en: "Failed to load data, please retry."
      zh: ""

    FAILED_TO_LOAD_AWS_DATA:
      en: "Failed to load aws data, please retry."
      zh: ""

    READ_REPLICA_MUST_BE_DROPPED_IN_THE_SAME_SBG:
      en: "Read replica must be dropped in the same subnet group with source DB instance."
      zh: ""

    CANNOT_CREATE_MORE_READ_REPLICA:
      en: "Cannot create more read replica."
      zh: ""

    CANNOT_CREATE_SBG_DUE_TO_INSUFFICIENT_SUBNETS:
      en: "Cannot create subnet group due to insufficient subnets."
      zh: ""

    ERR_GET_PASSWD_FAILED:
      en: "There was an error decrypting your password. Please ensure that you have entered your private key correctly."
      zh: "解密出错，请确认您是否上传了正确的私钥。"

    ERR_AMI_NOT_FOUND:
      en: "Can not find information for selected AMI( %s ), try to drag another AMI."
      zh: "无法获取选中的( %s )AMI的信息，请拖拽其他的AMI。"

    THE_ADDING_RULE_ALREADY_EXIST:
      en: "The adding rule already exist."
      zh: ""

    UNABLE_TO_LOAD_COMMUNITY_AMIS:
      en: "Unable to load community AMIs"
      zh: "不能加载社区映像"

    FAIL_TO_EXPORT_TO_CLOUDFORMATION:
      en: "Fail to export to AWS CloudFormation Template, Error code: %s"
      zh: ""

    RELOAD_STATE_INVALID_REQUEST:
        en: "Sorry, but the request is not valid."
        zh: ""

    RELOAD_STATE_NETWORKERROR:
      en: "Network error, please try again later."
      zh: ""

    RELOAD_STATE_INTERNAL_SERVER_ERROR:
      en: "Sorry, Internal server error, please try again later."
      zh: ""

    RELOAD_STATE_SUCCESS:
      en: "States reloaded successfully!"
      zh: ""

    RELOAD_STATE_NOT_READY:
      en: "App Agent is not ready yet, Please try again later."
      zh: ""

    FAILA_TO_RUN_STACK_BECAUSE_OF_XXX:
      en: "Failed to run your stack %s because of %s"
      zh: ""

