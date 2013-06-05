
define [ 'MC', 'session_model' ,'jquery', 'apiList','log_model', 'public_model', 'request_model', 'app_model', 'favorite_model', 'stack_model', 'aws_model', 'ami_model', 'ebs_model', 'ec2_model', 'eip_model', 'instance_model', 'keypair_model', 'placementgroup_model', 'securitygroup_model', 'elb_model', 'iam_model', 'acl_model', 'customergateway_model', 'dhcp_model', 'eni_model', 'internetgateway_model', 'routetable_model', 'subnet_model', 'vpc_model', 'vpngateway_model', 'vpn_model',],
( MC, session_model, $, apiList, log_model, public_model, request_model, app_model, favorite_model, stack_model, aws_model, ami_model, ebs_model, ec2_model, eip_model, instance_model, keypair_model, placementgroup_model, securitygroup_model, elb_model, iam_model, acl_model, customergateway_model, dhcp_model, eni_model, internetgateway_model, routetable_model, subnet_model, vpc_model, vpngateway_model, vpn_model ) ->
    #session info

    session_id   = ""
    username     = ""
    region_name  = ""

    dict_request = {}
    me           = this


    #private method
    login = ( event ) ->

        event.preventDefault()

        username = $( '#login_user' ).val()
        password = $( '#login_password' ).val()

        #invoke session.login api
        session_model.login {sender: this}, username, password

        #login return handler (dispatch from service/session/session_model)
        session_model.once 'SESSION_LOGIN_RETURN', ( forge_result ) ->

            if !forge_result.is_error
            #login succeed

                session_info = forge_result.resolved_data
                session_id   = session_info.session_id
                username     = session_info.usercode
                region_name  = session_info.region_name

                $( "#label_login_result" ).text "login succeed, session_id : " + session_info.session_id + ", region_name : " + session_info.region_name

                $('#region_list').val session_info.region_name

                true

            else
            #login failed
                alert forge_result.error_message

                false

        true


    #private
    resolveResult = ( request_time, service, resource, api, result ) ->

        data = window.API_DATA_LIST[ service ][ resource ][ api ]
        if !result.is_error
        #DescribeInstances succeed

            $( "#label_request_result" ).text data.method + " succeed!"

            #Object to JSON, pretty print
            $( "#response_data" ).removeClass("prettyprinted").text JSON.stringify(result.resolved_data ,null,4  )
            prettyPrint()

            log_data = {
                request_time   : MC.dateFormat(request_time, "yyyy-MM-dd hh:mm:ss"),
                response_time  : MC.dateFormat(new Date(), "yyyy-MM-dd hh:mm:ss"),
                service_name   : service,
                resource_name  : resource,
                api_name       : api,
                json_ok        : "status-green",
                e_ok           : "status-green"
            }

            window.add_request_log log_data

        else
        #DescribeInstances failed

            $( "#label_request_result" ).text data.method + " failed!"
            $( "#response_data" ).text aws_result.error_message
        

    #private
    request = ( event ) ->

        event.preventDefault()

        current_api      = $( "#api_list" ).val()

        if current_api == null
            alert "Please select an api first!"
            return false

        current_service  = $( "#service_list" ).val()
        current_resource = $( "#resource_list" ).val()

        request_time     = new Date()
        response_time    = null

        key              = current_service + "-" + current_resource + "-" + current_api
        dict_request[key]= event
        

        # #instance
        # instance_model.DescribeInstances {sender: me}, usercode, session_id, region_name, null, null
        # instance_model.once "EC2_INS_DESC_INSTANCES_RETURN", ( aws_result ) ->
        #   resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Log ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "log" && current_api == "put_user_log"
            user_logs = null
            #log.put_user_log
            log_model.put_user_log {sender: me}, username, session_id, user_logs
            log_model.once "LOG_PUT__USER__LOG_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Public ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "public" && current_api == "get_hostname"
            instance_id = null
            #public.get_hostname
            public_model.get_hostname {sender: me}, region_name, instance_id
            public_model.once "PUBLIC_GET__HOSTNAME_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "public" && current_api == "get_dns_ip"

            #public.get_dns_ip
            public_model.get_dns_ip {sender: me}, region_name
            public_model.once "PUBLIC_GET__DNS__IP_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Request ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "request" && current_api == "init"

            #request.init
            request_model.init {sender: me}, username, session_id, region_name
            request_model.once "REQUEST_INIT_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "request" && current_api == "update"
            timestamp = null
            #request.update
            request_model.update {sender: me}, username, session_id, region_name, timestamp
            request_model.once "REQUEST_UPDATE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Session ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "session" && current_api == "login"
            password = null
            #session.login
            session_model.login {sender: me}, username, password
            session_model.once "SESSION_LOGIN_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "session" && current_api == "logout"

            #session.logout
            session_model.logout {sender: me}, username, session_id
            session_model.once "SESSION_LOGOUT_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "session" && current_api == "set_credential"
            access_key = null
            secret_key = null
            account_id = null
            #session.set_credential
            session_model.set_credential {sender: me}, username, session_id, access_key, secret_key, account_id
            session_model.once "SESSION_SET__CREDENTIAL_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "session" && current_api == "guest"
            guest_id = null
            guestname = null
            #session.guest
            session_model.guest {sender: me}, guest_id, guestname
            session_model.once "SESSION_GUEST_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## App ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "create"
            spec = null
            #app.create
            app_model.create {sender: me}, username, session_id, region_name, spec
            app_model.once "APP_CREATE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "update"
            spec = null
            app_id = null
            #app.update
            app_model.update {sender: me}, username, session_id, region_name, spec, app_id
            app_model.once "APP_UPDATE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "rename"
            app_id = null
            new_name = null
            app_name = null
            #app.rename
            app_model.rename {sender: me}, username, session_id, region_name, app_id, new_name, app_name
            app_model.once "APP_RENAME_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "terminate"
            app_id = null
            app_name = null
            #app.terminate
            app_model.terminate {sender: me}, username, session_id, region_name, app_id, app_name
            app_model.once "APP_TERMINATE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "start"
            app_id = null
            app_name = null
            #app.start
            app_model.start {sender: me}, username, session_id, region_name, app_id, app_name
            app_model.once "APP_START_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "stop"
            app_id = null
            app_name = null
            #app.stop
            app_model.stop {sender: me}, username, session_id, region_name, app_id, app_name
            app_model.once "APP_STOP_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "reboot"
            app_id = null
            app_name = null
            #app.reboot
            app_model.reboot {sender: me}, username, session_id, region_name, app_id, app_name
            app_model.once "APP_REBOOT_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "info"
            app_ids = null
            #app.info
            app_model.info {sender: me}, username, session_id, region_name, app_ids
            app_model.once "APP_INFO_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "list"
            app_ids = null
            #app.list
            app_model.list {sender: me}, username, session_id, region_name, app_ids
            app_model.once "APP_LST_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "resource"
            app_id = null
            #app.resource
            app_model.resource {sender: me}, username, session_id, region_name, app_id
            app_model.once "APP_RESOURCE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "summary"

            #app.summary
            app_model.summary {sender: me}, username, session_id, region_name
            app_model.once "APP_SUMMARY_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Favorite ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "favorite" && current_api == "add"
            resource = null
            #favorite.add
            favorite_model.add {sender: me}, username, session_id, region_name, resource
            favorite_model.once "FAVORITE_ADD_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "favorite" && current_api == "remove"
            resource_ids = null
            #favorite.remove
            favorite_model.remove {sender: me}, username, session_id, region_name, resource_ids
            favorite_model.once "FAVORITE_REMOVE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "favorite" && current_api == "info"
            provider = null
            service = null
            resource = null
            #favorite.info
            favorite_model.info {sender: me}, username, session_id, region_name, provider, service, resource
            favorite_model.once "FAVORITE_INFO_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Guest ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "guest" && current_api == "invite"

            #guest.invite
            guest_model.invite {sender: me}, username, session_id, region_name
            guest_model.once "GUEST_INVITE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "guest" && current_api == "cancel"
            guest_id = null
            #guest.cancel
            guest_model.cancel {sender: me}, username, session_id, region_name, guest_id
            guest_model.once "GUEST_CANCEL_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "guest" && current_api == "access"
            guestname = null
            guest_id = null
            #guest.access
            guest_model.access {sender: me}, guestname, session_id, region_name, guest_id
            guest_model.once "GUEST_ACCESS_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "guest" && current_api == "end"
            guestname = null
            guest_id = null
            #guest.end
            guest_model.end {sender: me}, guestname, session_id, region_name, guest_id
            guest_model.once "GUEST_END_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "guest" && current_api == "info"
            guest_id = null
            #guest.info
            guest_model.info {sender: me}, username, session_id, region_name, guest_id
            guest_model.once "GUEST_INFO_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Stack ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "create"
            spec = null
            #stack.create
            stack_model.create {sender: me}, username, session_id, region_name, spec
            stack_model.once "STACK_CREATE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "remove"
            stack_id = null
            stack_name = null
            #stack.remove
            stack_model.remove {sender: me}, username, session_id, region_name, stack_id, stack_name
            stack_model.once "STACK_REMOVE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "save"
            spec = null
            #stack.save
            stack_model.save {sender: me}, username, session_id, region_name, spec
            stack_model.once "STACK_SAVE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "rename"
            stack_id = null
            new_name = null
            stack_name = null
            #stack.rename
            stack_model.rename {sender: me}, username, session_id, region_name, stack_id, new_name, stack_name
            stack_model.once "STACK_RENAME_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "run"
            stack_id = null
            app_name = null
            app_desc = null
            app_component = null
            app_property = null
            app_layout = null
            stack_name = null
            #stack.run
            stack_model.run {sender: me}, username, session_id, region_name, stack_id, app_name, app_desc, app_component, app_property, app_layout, stack_name
            stack_model.once "STACK_RUN_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "save_as"
            stack_id = null
            new_name = null
            stack_name = null
            #stack.save_as
            stack_model.save_as {sender: me}, username, session_id, region_name, stack_id, new_name, stack_name
            stack_model.once "STACK_SAVE__AS_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "info"
            stack_ids = null
            #stack.info
            stack_model.info {sender: me}, username, session_id, region_name, stack_ids
            stack_model.once "STACK_INFO_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "list"
            stack_ids = null
            #stack.list
            stack_model.list {sender: me}, username, session_id, region_name, stack_ids
            stack_model.once "STACK_LST_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## AutoScaling ##########
        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeAdjustmentTypes"

            #autoscaling.DescribeAdjustmentTypes
            autoscaling_model.DescribeAdjustmentTypes {sender: me}, username, session_id, region_name
            autoscaling_model.once "ASL__DESC_ADJT_TYPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeAutoScalingGroups"
            group_names = null
            max_records = null
            next_token = null
            #autoscaling.DescribeAutoScalingGroups
            autoscaling_model.DescribeAutoScalingGroups {sender: me}, username, session_id, region_name, group_names, max_records, next_token
            autoscaling_model.once "ASL__DESC_ASL_GRPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeAutoScalingInstances"
            instance_ids = null
            max_records = null
            next_token = null
            #autoscaling.DescribeAutoScalingInstances
            autoscaling_model.DescribeAutoScalingInstances {sender: me}, username, session_id, region_name, instance_ids, max_records, next_token
            autoscaling_model.once "ASL__DESC_ASL_INSS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeAutoScalingNotificationTypes"

            #autoscaling.DescribeAutoScalingNotificationTypes
            autoscaling_model.DescribeAutoScalingNotificationTypes {sender: me}, username, session_id, region_name
            autoscaling_model.once "ASL__DESC_ASL_NTF_TYPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeLaunchConfigurations"
            config_names = null
            max_records = null
            next_token = null
            #autoscaling.DescribeLaunchConfigurations
            autoscaling_model.DescribeLaunchConfigurations {sender: me}, username, session_id, region_name, config_names, max_records, next_token
            autoscaling_model.once "ASL__DESC_LAUNCH_CONFS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeMetricCollectionTypes"

            #autoscaling.DescribeMetricCollectionTypes
            autoscaling_model.DescribeMetricCollectionTypes {sender: me}, username, session_id, region_name
            autoscaling_model.once "ASL__DESC_METRIC_COLL_TYPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeNotificationConfigurations"
            group_names = null
            max_records = null
            next_token = null
            #autoscaling.DescribeNotificationConfigurations
            autoscaling_model.DescribeNotificationConfigurations {sender: me}, username, session_id, region_name, group_names, max_records, next_token
            autoscaling_model.once "ASL__DESC_NTF_CONFS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribePolicies"
            group_name = null
            policy_names = null
            max_records = null
            next_token = null
            #autoscaling.DescribePolicies
            autoscaling_model.DescribePolicies {sender: me}, username, session_id, region_name, group_name, policy_names, max_records, next_token
            autoscaling_model.once "ASL__DESC_PCYS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeScalingActivities"

            #autoscaling.DescribeScalingActivities
            autoscaling_model.DescribeScalingActivities {sender: me}, username, session_id
            autoscaling_model.once "ASL__DESC_SCALING_ACTIS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeScalingProcessTypes"

            #autoscaling.DescribeScalingProcessTypes
            autoscaling_model.DescribeScalingProcessTypes {sender: me}, username, session_id, region_name
            autoscaling_model.once "ASL__DESC_SCALING_PRC_TYPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeScheduledActions"

            #autoscaling.DescribeScheduledActions
            autoscaling_model.DescribeScheduledActions {sender: me}, username, session_id
            autoscaling_model.once "ASL__DESC_SCHD_ACTS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeTags"
            filters = null
            max_records = null
            next_token = null
            #autoscaling.DescribeTags
            autoscaling_model.DescribeTags {sender: me}, username, session_id, region_name, filters, max_records, next_token
            autoscaling_model.once "ASL__DESC_TAGS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## AWS ##########
        if current_service.toLowerCase() == "awsutil" && current_resource.toLowerCase() == "aws" && current_api == "quickstart"

            #aws.quickstart
            aws_model.quickstart {sender: me}, username, session_id, region_name
            aws_model.once "AWS_QUICKSTART_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "awsutil" && current_resource.toLowerCase() == "aws" && current_api == "Public"

            #aws.Public
            aws_model.Public {sender: me}, username, session_id, region_name
            aws_model.once "AWS__PUBLIC_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "awsutil" && current_resource.toLowerCase() == "aws" && current_api == "info"

            #aws.info
            aws_model.info {sender: me}, username, session_id, region_name
            aws_model.once "AWS_INFO_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "awsutil" && current_resource.toLowerCase() == "aws" && current_api == "resource"
            resources = null
            #aws.resource
            aws_model.resource {sender: me}, username, session_id, region_name, resources
            aws_model.once "AWS_RESOURCE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "awsutil" && current_resource.toLowerCase() == "aws" && current_api == "price"

            #aws.price
            aws_model.price {sender: me}, username, session_id
            aws_model.once "AWS_PRICE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "awsutil" && current_resource.toLowerCase() == "aws" && current_api == "status"

            #aws.status
            aws_model.status {sender: me}, username, session_id
            aws_model.once "AWS_STATUS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## CloudWatch ##########
        if current_service.toLowerCase() == "cloudwatch" && current_resource.toLowerCase() == "cloudwatch" && current_api == "GetMetricStatistics"

            #cloudwatch.GetMetricStatistics
            cloudwatch_model.GetMetricStatistics {sender: me}, username, session_id
            cloudwatch_model.once "CW__GET_METRIC_STATS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "cloudwatch" && current_resource.toLowerCase() == "cloudwatch" && current_api == "ListMetrics"

            #cloudwatch.ListMetrics
            cloudwatch_model.ListMetrics {sender: me}, username, session_id
            cloudwatch_model.once "CW__LST_METRICS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "cloudwatch" && current_resource.toLowerCase() == "cloudwatch" && current_api == "DescribeAlarmHistory"

            #cloudwatch.DescribeAlarmHistory
            cloudwatch_model.DescribeAlarmHistory {sender: me}, username, session_id
            cloudwatch_model.once "CW__DESC_ALM_HIST_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "cloudwatch" && current_resource.toLowerCase() == "cloudwatch" && current_api == "DescribeAlarms"

            #cloudwatch.DescribeAlarms
            cloudwatch_model.DescribeAlarms {sender: me}, username, session_id
            cloudwatch_model.once "CW__DESC_ALMS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "cloudwatch" && current_resource.toLowerCase() == "cloudwatch" && current_api == "DescribeAlarmsForMetric"

            #cloudwatch.DescribeAlarmsForMetric
            cloudwatch_model.DescribeAlarmsForMetric {sender: me}, username, session_id
            cloudwatch_model.once "CW__DESC_ALMS_FOR_METRIC_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## AMI ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ami" && current_api == "CreateImage"
            instance_id = null
            ami_name = null
            ami_desc = null
            no_reboot = null
            bd_mappings = null
            #ami.CreateImage
            ami_model.CreateImage {sender: me}, username, session_id, region_name, instance_id, ami_name, ami_desc, no_reboot, bd_mappings
            ami_model.once "EC2_AMI_CREATE_IMAGE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ami" && current_api == "RegisterImage"
            ami_name = null
            ami_desc = null
            #ami.RegisterImage
            ami_model.RegisterImage {sender: me}, username, session_id, region_name, ami_name, ami_desc
            ami_model.once "EC2_AMI_REGISTER_IMAGE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ami" && current_api == "DeregisterImage"
            ami_id = null
            #ami.DeregisterImage
            ami_model.DeregisterImage {sender: me}, username, session_id, region_name, ami_id
            ami_model.once "EC2_AMI_DEREGISTER_IMAGE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ami" && current_api == "ModifyImageAttribute"

            #ami.ModifyImageAttribute
            ami_model.ModifyImageAttribute {sender: me}, username, session_id
            ami_model.once "EC2_AMI_MODIFY_IMAGE_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ami" && current_api == "ResetImageAttribute"
            ami_id = null
            attribute_name = null
            #ami.ResetImageAttribute
            ami_model.ResetImageAttribute {sender: me}, username, session_id, region_name, ami_id, attribute_name
            ami_model.once "EC2_AMI_RESET_IMAGE_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ami" && current_api == "DescribeImageAttribute"
            ami_id = null
            attribute_name = null
            #ami.DescribeImageAttribute
            ami_model.DescribeImageAttribute {sender: me}, username, session_id, region_name, ami_id, attribute_name
            ami_model.once "EC2_AMI_DESC_IMAGE_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ami" && current_api == "DescribeImages"
            ami_ids = null
            owners = null
            executable_by = null
            filters = null
            #ami.DescribeImages
            ami_model.DescribeImages {sender: me}, username, session_id, region_name, ami_ids, owners, executable_by, filters
            ami_model.once "EC2_AMI_DESC_IMAGES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## EBS ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "CreateVolume"
            zone_name = null
            snapshot_id = null
            volume_size = null
            volume_type = null
            iops = null
            #ebs.CreateVolume
            ebs_model.CreateVolume {sender: me}, username, session_id, region_name, zone_name, snapshot_id, volume_size, volume_type, iops
            ebs_model.once "EC2_EBS_CREATE_VOL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DeleteVolume"
            volume_id = null
            #ebs.DeleteVolume
            ebs_model.DeleteVolume {sender: me}, username, session_id, region_name, volume_id
            ebs_model.once "EC2_EBS_DELETE_VOL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "AttachVolume"
            volume_id = null
            instance_id = null
            device = null
            #ebs.AttachVolume
            ebs_model.AttachVolume {sender: me}, username, session_id, region_name, volume_id, instance_id, device
            ebs_model.once "EC2_EBS_ATTACH_VOL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DetachVolume"
            volume_id = null
            instance_id = null
            device = null
            force = null
            #ebs.DetachVolume
            ebs_model.DetachVolume {sender: me}, username, session_id, region_name, volume_id, instance_id, device, force
            ebs_model.once "EC2_EBS_DETACH_VOL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DescribeVolumes"
            volume_ids = null
            filters = null
            #ebs.DescribeVolumes
            ebs_model.DescribeVolumes {sender: me}, username, session_id, region_name, volume_ids, filters
            ebs_model.once "EC2_EBS_DESC_VOLS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DescribeVolumeAttribute"
            volume_id = null
            attribute_name = null
            #ebs.DescribeVolumeAttribute
            ebs_model.DescribeVolumeAttribute {sender: me}, username, session_id, region_name, volume_id, attribute_name
            ebs_model.once "EC2_EBS_DESC_VOL_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DescribeVolumeStatus"
            volume_ids = null
            filters = null
            max_result = null
            next_token = null
            #ebs.DescribeVolumeStatus
            ebs_model.DescribeVolumeStatus {sender: me}, username, session_id, region_name, volume_ids, filters, max_result, next_token
            ebs_model.once "EC2_EBS_DESC_VOL_STATUS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "ModifyVolumeAttribute"
            volume_id = null
            auto_enable_IO = null
            #ebs.ModifyVolumeAttribute
            ebs_model.ModifyVolumeAttribute {sender: me}, username, session_id, region_name, volume_id, auto_enable_IO
            ebs_model.once "EC2_EBS_MODIFY_VOL_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "EnableVolumeIO"
            volume_id = null
            #ebs.EnableVolumeIO
            ebs_model.EnableVolumeIO {sender: me}, username, session_id, region_name, volume_id
            ebs_model.once "EC2_EBS_ENABLE_VOL_I_O_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "CreateSnapshot"
            volume_id = null
            description = null
            #ebs.CreateSnapshot
            ebs_model.CreateSnapshot {sender: me}, username, session_id, region_name, volume_id, description
            ebs_model.once "EC2_EBS_CREATE_SS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DeleteSnapshot"
            snapshot_id = null
            #ebs.DeleteSnapshot
            ebs_model.DeleteSnapshot {sender: me}, username, session_id, region_name, snapshot_id
            ebs_model.once "EC2_EBS_DELETE_SS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "ModifySnapshotAttribute"
            snapshot_id = null
            user_ids = null
            group_names = null
            #ebs.ModifySnapshotAttribute
            ebs_model.ModifySnapshotAttribute {sender: me}, username, session_id, region_name, snapshot_id, user_ids, group_names
            ebs_model.once "EC2_EBS_MODIFY_SS_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "ResetSnapshotAttribute"
            snapshot_id = null
            attribute_name = null
            #ebs.ResetSnapshotAttribute
            ebs_model.ResetSnapshotAttribute {sender: me}, username, session_id, region_name, snapshot_id, attribute_name
            ebs_model.once "EC2_EBS_RESET_SS_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DescribeSnapshots"
            snapshot_ids = null
            owners = null
            restorable_by = null
            filters = null
            #ebs.DescribeSnapshots
            ebs_model.DescribeSnapshots {sender: me}, username, session_id, region_name, snapshot_ids, owners, restorable_by, filters
            ebs_model.once "EC2_EBS_DESC_SSS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DescribeSnapshotAttribute"
            snapshot_id = null
            attribute_name = null
            #ebs.DescribeSnapshotAttribute
            ebs_model.DescribeSnapshotAttribute {sender: me}, username, session_id, region_name, snapshot_id, attribute_name
            ebs_model.once "EC2_EBS_DESC_SS_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## EC2 ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ec2" && current_api == "CreateTags"
            resource_ids = null
            tags = null
            #ec2.CreateTags
            ec2_model.CreateTags {sender: me}, username, session_id, region_name, resource_ids, tags
            ec2_model.once "EC2_EC2_CREATE_TAGS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ec2" && current_api == "DeleteTags"
            resource_ids = null
            tags = null
            #ec2.DeleteTags
            ec2_model.DeleteTags {sender: me}, username, session_id, region_name, resource_ids, tags
            ec2_model.once "EC2_EC2_DELETE_TAGS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ec2" && current_api == "DescribeTags"
            filters = null
            #ec2.DescribeTags
            ec2_model.DescribeTags {sender: me}, username, session_id, region_name, filters
            ec2_model.once "EC2_EC2_DESC_TAGS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ec2" && current_api == "DescribeRegions"
            region_names = null
            filters = null
            #ec2.DescribeRegions
            ec2_model.DescribeRegions {sender: me}, username, session_id, region_names, filters
            ec2_model.once "EC2_EC2_DESC_REGIONS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ec2" && current_api == "DescribeAvailabilityZones"
            zone_names = null
            filters = null
            #ec2.DescribeAvailabilityZones
            ec2_model.DescribeAvailabilityZones {sender: me}, username, session_id, region_name, zone_names, filters
            ec2_model.once "EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## EIP ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "eip" && current_api == "AllocateAddress"
            domain = null
            #eip.AllocateAddress
            eip_model.AllocateAddress {sender: me}, username, session_id, region_name, domain
            eip_model.once "EC2_EIP_ALLOCATE_ADDR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "eip" && current_api == "ReleaseAddress"
            ip = null
            allocation_id = null
            #eip.ReleaseAddress
            eip_model.ReleaseAddress {sender: me}, username, session_id, region_name, ip, allocation_id
            eip_model.once "EC2_EIP_RELEASE_ADDR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "eip" && current_api == "AssociateAddress"

            #eip.AssociateAddress
            eip_model.AssociateAddress {sender: me}, username
            eip_model.once "EC2_EIP_ASSOCIATE_ADDR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "eip" && current_api == "DisassociateAddress"
            ip = null
            association_id = null
            #eip.DisassociateAddress
            eip_model.DisassociateAddress {sender: me}, username, session_id, region_name, ip, association_id
            eip_model.once "EC2_EIP_DISASSOCIATE_ADDR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "eip" && current_api == "DescribeAddresses"
            ips = null
            allocation_ids = null
            filters = null
            #eip.DescribeAddresses
            eip_model.DescribeAddresses {sender: me}, username, session_id, region_name, ips, allocation_ids, filters
            eip_model.once "EC2_EIP_DESC_ADDRES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Instance ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "RunInstances"

            #instance.RunInstances
            instance_model.RunInstances {sender: me}, username, session_id
            instance_model.once "EC2_INS_RUN_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "StartInstances"
            instance_ids = null
            #instance.StartInstances
            instance_model.StartInstances {sender: me}, username, session_id, region_name, instance_ids
            instance_model.once "EC2_INS_START_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "StopInstances"
            instance_ids = null
            force = null
            #instance.StopInstances
            instance_model.StopInstances {sender: me}, username, session_id, region_name, instance_ids, force
            instance_model.once "EC2_INS_STOP_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "RebootInstances"
            instance_ids = null
            #instance.RebootInstances
            instance_model.RebootInstances {sender: me}, username, session_id, region_name, instance_ids
            instance_model.once "EC2_INS_REBOOT_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "TerminateInstances"
            instance_ids = null
            #instance.TerminateInstances
            instance_model.TerminateInstances {sender: me}, username, session_id, region_name, instance_ids
            instance_model.once "EC2_INS_TERMINATE_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "MonitorInstances"
            instance_ids = null
            #instance.MonitorInstances
            instance_model.MonitorInstances {sender: me}, username, session_id, region_name, instance_ids
            instance_model.once "EC2_INS_MONITOR_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "UnmonitorInstances"
            instance_ids = null
            #instance.UnmonitorInstances
            instance_model.UnmonitorInstances {sender: me}, username, session_id, region_name, instance_ids
            instance_model.once "EC2_INS_UNMONITOR_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "BundleInstance"
            instance_id = null
            s3_bucket = null
            #instance.BundleInstance
            instance_model.BundleInstance {sender: me}, username, session_id, region_name, instance_id, s3_bucket
            instance_model.once "EC2_INS_BUNDLE_INSTANCE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "CancelBundleTask"
            bundle_id = null
            #instance.CancelBundleTask
            instance_model.CancelBundleTask {sender: me}, username, session_id, region_name, bundle_id
            instance_model.once "EC2_INS_CANCEL_BUNDLE_TASK_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "ModifyInstanceAttribute"

            #instance.ModifyInstanceAttribute
            instance_model.ModifyInstanceAttribute {sender: me}, username, session_id
            instance_model.once "EC2_INS_MODIFY_INSTANCE_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "ResetInstanceAttribute"
            instance_id = null
            attribute_name = null
            #instance.ResetInstanceAttribute
            instance_model.ResetInstanceAttribute {sender: me}, username, session_id, region_name, instance_id, attribute_name
            instance_model.once "EC2_INS_RESET_INSTANCE_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "ConfirmProductInstance"
            instance_id = null
            product_code = null
            #instance.ConfirmProductInstance
            instance_model.ConfirmProductInstance {sender: me}, username, session_id, region_name, instance_id, product_code
            instance_model.once "EC2_INS_CONFIRM_PRODUCT_INSTANCE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "DescribeInstances"
            instance_ids = null
            filters = null
            #instance.DescribeInstances
            instance_model.DescribeInstances {sender: me}, username, session_id, region_name, instance_ids, filters
            instance_model.once "EC2_INS_DESC_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "DescribeInstanceStatus"
            instance_ids = null
            include_all_instances = null
            max_results = null
            next_token = null
            #instance.DescribeInstanceStatus
            instance_model.DescribeInstanceStatus {sender: me}, username, session_id, region_name, instance_ids, include_all_instances, max_results, next_token
            instance_model.once "EC2_INS_DESC_INSTANCE_STATUS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "DescribeBundleTasks"
            bundle_ids = null
            filters = null
            #instance.DescribeBundleTasks
            instance_model.DescribeBundleTasks {sender: me}, username, session_id, region_name, bundle_ids, filters
            instance_model.once "EC2_INS_DESC_BUNDLE_TASKS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "DescribeInstanceAttribute"
            instance_id = null
            attribute_name = null
            #instance.DescribeInstanceAttribute
            instance_model.DescribeInstanceAttribute {sender: me}, username, session_id, region_name, instance_id, attribute_name
            instance_model.once "EC2_INS_DESC_INSTANCE_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "GetConsoleOutput"
            instance_id = null
            #instance.GetConsoleOutput
            instance_model.GetConsoleOutput {sender: me}, username, session_id, region_name, instance_id
            instance_model.once "EC2_INS_GET_CONSOLE_OUTPUT_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "GetPasswordData"
            instance_id = null
            key_data = null
            #instance.GetPasswordData
            instance_model.GetPasswordData {sender: me}, username, session_id, region_name, instance_id, key_data
            instance_model.once "EC2_INS_GET_PWD_DATA_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## KeyPair ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "CreateKeyPair"
            key_name = null
            #keypair.CreateKeyPair
            keypair_model.CreateKeyPair {sender: me}, username, session_id, region_name, key_name
            keypair_model.once "EC2_KP_CREATE_KEY_PAIR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "DeleteKeyPair"
            key_name = null
            #keypair.DeleteKeyPair
            keypair_model.DeleteKeyPair {sender: me}, username, session_id, region_name, key_name
            keypair_model.once "EC2_KP_DELETE_KEY_PAIR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "ImportKeyPair"
            key_name = null
            key_data = null
            #keypair.ImportKeyPair
            keypair_model.ImportKeyPair {sender: me}, username, session_id, region_name, key_name, key_data
            keypair_model.once "EC2_KP_IMPORT_KEY_PAIR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "DescribeKeyPairs"
            key_names = null
            filters = null
            #keypair.DescribeKeyPairs
            keypair_model.DescribeKeyPairs {sender: me}, username, session_id, region_name, key_names, filters
            keypair_model.once "EC2_KP_DESC_KEY_PAIRS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "upload"
            key_name = null
            key_data = null
            #keypair.upload
            keypair_model.upload {sender: me}, username, session_id, region_name, key_name, key_data
            keypair_model.once "EC2_KPUPLOAD_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "download"
            key_name = null
            #keypair.download
            keypair_model.download {sender: me}, username, session_id, region_name, key_name
            keypair_model.once "EC2_KPDOWNLOAD_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "remove"
            key_name = null
            #keypair.remove
            keypair_model.remove {sender: me}, username, session_id, region_name, key_name
            keypair_model.once "EC2_KPREMOVE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "list"

            #keypair.list
            keypair_model.list {sender: me}, username, session_id, region_name
            keypair_model.once "EC2_KPLST_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## PlacementGroup ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "placementgroup" && current_api == "CreatePlacementGroup"
            group_name = null
            strategy = null
            #placementgroup.CreatePlacementGroup
            placementgroup_model.CreatePlacementGroup {sender: me}, username, session_id, region_name, group_name, strategy
            placementgroup_model.once "EC2_PG_CREATE_PLA_GRP_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "placementgroup" && current_api == "DeletePlacementGroup"
            group_name = null
            #placementgroup.DeletePlacementGroup
            placementgroup_model.DeletePlacementGroup {sender: me}, username, session_id, region_name, group_name
            placementgroup_model.once "EC2_PG_DELETE_PLA_GRP_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "placementgroup" && current_api == "DescribePlacementGroups"
            group_names = null
            filters = null
            #placementgroup.DescribePlacementGroups
            placementgroup_model.DescribePlacementGroups {sender: me}, username, session_id, region_name, group_names, filters
            placementgroup_model.once "EC2_PG_DESC_PLA_GRPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## SecurityGroup ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "securitygroup" && current_api == "CreateSecurityGroup"
            group_name = null
            group_desc = null
            vpc_id = null
            #securitygroup.CreateSecurityGroup
            securitygroup_model.CreateSecurityGroup {sender: me}, username, session_id, region_name, group_name, group_desc, vpc_id
            securitygroup_model.once "EC2_SG_CREATE_SG_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "securitygroup" && current_api == "DeleteSecurityGroup"
            group_name = null
            group_id = null
            #securitygroup.DeleteSecurityGroup
            securitygroup_model.DeleteSecurityGroup {sender: me}, username, session_id, region_name, group_name, group_id
            securitygroup_model.once "EC2_SG_DELETE_SG_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "securitygroup" && current_api == "AuthorizeSecurityGroupIngress"

            #securitygroup.AuthorizeSecurityGroupIngress
            securitygroup_model.AuthorizeSecurityGroupIngress {sender: me}, username, session_id
            securitygroup_model.once "EC2_SG_AUTH_SG_INGRESS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "securitygroup" && current_api == "RevokeSecurityGroupIngress"

            #securitygroup.RevokeSecurityGroupIngress
            securitygroup_model.RevokeSecurityGroupIngress {sender: me}, username, session_id
            securitygroup_model.once "EC2_SG_REVOKE_SG_INGRESS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "securitygroup" && current_api == "DescribeSecurityGroups"
            group_names = null
            group_ids = null
            filters = null
            #securitygroup.DescribeSecurityGroups
            securitygroup_model.DescribeSecurityGroups {sender: me}, username, session_id, region_name, group_names, group_ids, filters
            securitygroup_model.once "EC2_SG_DESC_SGS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ELB ##########
        if current_service.toLowerCase() == "elb" && current_resource.toLowerCase() == "elb" && current_api == "DescribeInstanceHealth"
            elb_name = null
            instance_ids = null
            #elb.DescribeInstanceHealth
            elb_model.DescribeInstanceHealth {sender: me}, username, session_id, region_name, elb_name, instance_ids
            elb_model.once "ELB__DESC_INS_HLT_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "elb" && current_resource.toLowerCase() == "elb" && current_api == "DescribeLoadBalancerPolicies"
            elb_name = null
            policy_names = null
            #elb.DescribeLoadBalancerPolicies
            elb_model.DescribeLoadBalancerPolicies {sender: me}, username, session_id, region_name, elb_name, policy_names
            elb_model.once "ELB__DESC_LB_PCYS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "elb" && current_resource.toLowerCase() == "elb" && current_api == "DescribeLoadBalancerPolicyTypes"
            policy_type_names = null
            #elb.DescribeLoadBalancerPolicyTypes
            elb_model.DescribeLoadBalancerPolicyTypes {sender: me}, username, session_id, region_name, policy_type_names
            elb_model.once "ELB__DESC_LB_PCY_TYPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "elb" && current_resource.toLowerCase() == "elb" && current_api == "DescribeLoadBalancers"
            elb_names = null
            marker = null
            #elb.DescribeLoadBalancers
            elb_model.DescribeLoadBalancers {sender: me}, username, session_id, region_name, elb_names, marker
            elb_model.once "ELB__DESC_LBS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## IAM ##########
        if current_service.toLowerCase() == "iam" && current_resource.toLowerCase() == "iam" && current_api == "GetServerCertificate"
            servercer_name = null
            #iam.GetServerCertificate
            iam_model.GetServerCertificate {sender: me}, username, session_id, region_name, servercer_name
            iam_model.once "IAM__GET_SERVER_CERTIFICATE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "iam" && current_resource.toLowerCase() == "iam" && current_api == "ListServerCertificates"
            marker = null
            max_items = null
            path_prefix = null
            #iam.ListServerCertificates
            iam_model.ListServerCertificates {sender: me}, username, session_id, region_name, marker, max_items, path_prefix
            iam_model.once "IAM__LST_SERVER_CERTIFICATES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## OpsWorks ##########
        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeApps"
            app_ids = null
            stack_id = null
            #opsworks.DescribeApps
            opsworks_model.DescribeApps {sender: me}, username, session_id, region_name, app_ids, stack_id
            opsworks_model.once "OPSWORKS__DESC_APPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeStacks"
            stack_ids = null
            #opsworks.DescribeStacks
            opsworks_model.DescribeStacks {sender: me}, username, session_id, region_name, stack_ids
            opsworks_model.once "OPSWORKS__DESC_STACKS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeCommands"
            command_ids = null
            deployment_id = null
            instance_id = null
            #opsworks.DescribeCommands
            opsworks_model.DescribeCommands {sender: me}, username, session_id, region_name, command_ids, deployment_id, instance_id
            opsworks_model.once "OPSWORKS__DESC_COMMANDS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeDeployments"
            app_id = null
            deployment_ids = null
            stack_id = null
            #opsworks.DescribeDeployments
            opsworks_model.DescribeDeployments {sender: me}, username, session_id, region_name, app_id, deployment_ids, stack_id
            opsworks_model.once "OPSWORKS__DESC_DEPLOYMENTS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeElasticIps"
            instance_id = null
            ips = null
            #opsworks.DescribeElasticIps
            opsworks_model.DescribeElasticIps {sender: me}, username, session_id, region_name, instance_id, ips
            opsworks_model.once "OPSWORKS__DESC_ELASTIC_IPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeInstances"
            app_id = null
            instance_ids = null
            layer_id = null
            stack_id = null
            #opsworks.DescribeInstances
            opsworks_model.DescribeInstances {sender: me}, username, session_id, region_name, app_id, instance_ids, layer_id, stack_id
            opsworks_model.once "OPSWORKS__DESC_INSS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeLayers"
            stack_id = null
            layer_ids = null
            #opsworks.DescribeLayers
            opsworks_model.DescribeLayers {sender: me}, username, session_id, region_name, stack_id, layer_ids
            opsworks_model.once "OPSWORKS__DESC_LAYERS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeLoadBasedAutoScaling"
            layer_ids = null
            #opsworks.DescribeLoadBasedAutoScaling
            opsworks_model.DescribeLoadBasedAutoScaling {sender: me}, username, session_id, region_name, layer_ids
            opsworks_model.once "OPSWORKS__DESC_LOAD_BASED_ASL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribePermissions"
            iam_user_arn = null
            stack_id = null
            #opsworks.DescribePermissions
            opsworks_model.DescribePermissions {sender: me}, username, session_id, region_name, iam_user_arn, stack_id
            opsworks_model.once "OPSWORKS__DESC_PERMISSIONS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeRaidArrays"
            instance_id = null
            raid_array_ids = null
            #opsworks.DescribeRaidArrays
            opsworks_model.DescribeRaidArrays {sender: me}, username, session_id, region_name, instance_id, raid_array_ids
            opsworks_model.once "OPSWORKS__DESC_RAID_ARRAYS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeServiceErrors"
            instance_id = null
            service_error_ids = null
            stack_id = null
            #opsworks.DescribeServiceErrors
            opsworks_model.DescribeServiceErrors {sender: me}, username, session_id, region_name, instance_id, service_error_ids, stack_id
            opsworks_model.once "OPSWORKS__DESC_SERVICE_ERRORS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeTimeBasedAutoScaling"
            instance_ids = null
            #opsworks.DescribeTimeBasedAutoScaling
            opsworks_model.DescribeTimeBasedAutoScaling {sender: me}, username, session_id, region_name, instance_ids
            opsworks_model.once "OPSWORKS__DESC_TIME_BASED_ASL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeUserProfiles"
            iam_user_arns = null
            #opsworks.DescribeUserProfiles
            opsworks_model.DescribeUserProfiles {sender: me}, username, session_id, region_name, iam_user_arns
            opsworks_model.once "OPSWORKS__DESC_USER_PROFILES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeVolumes"
            instance_id = null
            raid_array_id = null
            volume_ids = null
            #opsworks.DescribeVolumes
            opsworks_model.DescribeVolumes {sender: me}, username, session_id, region_name, instance_id, raid_array_id, volume_ids
            opsworks_model.once "OPSWORKS__DESC_VOLS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Instance ##########
        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "instance" && current_api == "DescribeDBInstances"
            instance_id = null
            marker = null
            max_records = null
            #instance.DescribeDBInstances
            instance_model.DescribeDBInstances {sender: me}, username, session_id, region_name, instance_id, marker, max_records
            instance_model.once "RDS_INS_DESC_DB_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## OptionGroup ##########
        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "optiongroup" && current_api == "DescribeOptionGroupOptions"

            #optiongroup.DescribeOptionGroupOptions
            optiongroup_model.DescribeOptionGroupOptions {sender: me}, username, session_id
            optiongroup_model.once "RDS_OG_DESC_OPT_GRP_OPTIONS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "optiongroup" && current_api == "DescribeOptionGroups"

            #optiongroup.DescribeOptionGroups
            optiongroup_model.DescribeOptionGroups {sender: me}, username, session_id
            optiongroup_model.once "RDS_OG_DESC_OPT_GRPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ParameterGroup ##########
        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "parametergroup" && current_api == "DescribeDBParameterGroups"
            pg_name = null
            marker = null
            max_records = null
            #parametergroup.DescribeDBParameterGroups
            parametergroup_model.DescribeDBParameterGroups {sender: me}, username, session_id, region_name, pg_name, marker, max_records
            parametergroup_model.once "RDS_PG_DESC_DB_PARAM_GRPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "parametergroup" && current_api == "DescribeDBParameters"
            pg_name = null
            source = null
            marker = null
            max_records = null
            #parametergroup.DescribeDBParameters
            parametergroup_model.DescribeDBParameters {sender: me}, username, session_id, region_name, pg_name, source, marker, max_records
            parametergroup_model.once "RDS_PG_DESC_DB_PARAMS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## RDS ##########
        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "rds" && current_api == "DescribeDBEngineVersions"

            #rds.DescribeDBEngineVersions
            rds_model.DescribeDBEngineVersions {sender: me}, username
            rds_model.once "RDS_RDS_DESC_DB_ENG_VERS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "rds" && current_api == "DescribeOrderableDBInstanceOptions"

            #rds.DescribeOrderableDBInstanceOptions
            rds_model.DescribeOrderableDBInstanceOptions {sender: me}, username
            rds_model.once "RDS_RDS_DESC_ORD_DB_INS_OPTS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "rds" && current_api == "DescribeEngineDefaultParameters"
            pg_family = null
            marker = null
            max_records = null
            #rds.DescribeEngineDefaultParameters
            rds_model.DescribeEngineDefaultParameters {sender: me}, username, session_id, region_name, pg_family, marker, max_records
            rds_model.once "RDS_RDS_DESC_ENG_DFT_PARAMS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "rds" && current_api == "DescribeEvents"

            #rds.DescribeEvents
            rds_model.DescribeEvents {sender: me}, username, session_id
            rds_model.once "RDS_RDS_DESC_EVENTS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ReservedInstance ##########
        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "reservedinstance" && current_api == "DescribeReservedDBInstances"

            #reservedinstance.DescribeReservedDBInstances
            reservedinstance_model.DescribeReservedDBInstances {sender: me}, username, session_id
            reservedinstance_model.once "RDS_RSVDINS_DESC_RESERVED_DB_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "reservedinstance" && current_api == "DescribeReservedDBInstancesOfferings"

            #reservedinstance.DescribeReservedDBInstancesOfferings
            reservedinstance_model.DescribeReservedDBInstancesOfferings {sender: me}, username, session_id
            reservedinstance_model.once "RDS_RSVDINS_DESC_RESERVED_DB_INSTANCES_OFFERINGS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## SecurityGroup ##########
        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "securitygroup" && current_api == "DescribeDBSecurityGroups"
            sg_name = null
            marker = null
            max_records = null
            #securitygroup.DescribeDBSecurityGroups
            securitygroup_model.DescribeDBSecurityGroups {sender: me}, username, session_id, region_name, sg_name, marker, max_records
            securitygroup_model.once "RDS_SG_DESC_DB_SGS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Snapshot ##########
        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "snapshot" && current_api == "DescribeDBSnapshots"

            #snapshot.DescribeDBSnapshots
            snapshot_model.DescribeDBSnapshots {sender: me}, username, session_id
            snapshot_model.once "RDS_SS_DESC_DB_SNAPSHOTS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## SubnetGroup ##########
        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "subnetgroup" && current_api == "DescribeDBSubnetGroups"
            sg_name = null
            marker = null
            max_records = null
            #subnetgroup.DescribeDBSubnetGroups
            subnetgroup_model.DescribeDBSubnetGroups {sender: me}, username, session_id, region_name, sg_name, marker, max_records
            subnetgroup_model.once "RDS_SNTG_DESC_DB_SNET_GRPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## SDB ##########
        if current_service.toLowerCase() == "sdb" && current_resource.toLowerCase() == "sdb" && current_api == "DomainMetadata"
            doamin_name = null
            #sdb.DomainMetadata
            sdb_model.DomainMetadata {sender: me}, username, session_id, region_name, doamin_name
            sdb_model.once "SDB__DOMAIN_MDATA_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "sdb" && current_resource.toLowerCase() == "sdb" && current_api == "GetAttributes"
            domain_name = null
            item_name = null
            attribute_name = null
            consistent_read = null
            #sdb.GetAttributes
            sdb_model.GetAttributes {sender: me}, username, session_id, region_name, domain_name, item_name, attribute_name, consistent_read
            sdb_model.once "SDB__GET_ATTRS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "sdb" && current_resource.toLowerCase() == "sdb" && current_api == "ListDomains"
            max_domains = null
            next_token = null
            #sdb.ListDomains
            sdb_model.ListDomains {sender: me}, username, session_id, region_name, max_domains, next_token
            sdb_model.once "SDB__LST_DOMAINS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ACL ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "acl" && current_api == "DescribeNetworkAcls"
            acl_ids = null
            filters = null
            #acl.DescribeNetworkAcls
            acl_model.DescribeNetworkAcls {sender: me}, username, session_id, region_name, acl_ids, filters
            acl_model.once "VPC_ACL_DESC_NET_ACLS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## CustomerGateway ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "customergateway" && current_api == "DescribeCustomerGateways"
            gw_ids = null
            filters = null
            #customergateway.DescribeCustomerGateways
            customergateway_model.DescribeCustomerGateways {sender: me}, username, session_id, region_name, gw_ids, filters
            customergateway_model.once "VPC_CGW_DESC_CUST_GWS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## DHCP ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "dhcp" && current_api == "DescribeDhcpOptions"
            dhcp_ids = null
            filters = null
            #dhcp.DescribeDhcpOptions
            dhcp_model.DescribeDhcpOptions {sender: me}, username, session_id, region_name, dhcp_ids, filters
            dhcp_model.once "VPC_DHCP_DESC_DHCP_OPTS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ENI ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "eni" && current_api == "DescribeNetworkInterfaces"
            eni_ids = null
            filters = null
            #eni.DescribeNetworkInterfaces
            eni_model.DescribeNetworkInterfaces {sender: me}, username, session_id, region_name, eni_ids, filters
            eni_model.once "VPC_ENI_DESC_NET_IFS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "eni" && current_api == "DescribeNetworkInterfaceAttribute"
            eni_id = null
            attribute = null
            #eni.DescribeNetworkInterfaceAttribute
            eni_model.DescribeNetworkInterfaceAttribute {sender: me}, username, session_id, region_name, eni_id, attribute
            eni_model.once "VPC_ENI_DESC_NET_IF_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## InternetGateway ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "internetgateway" && current_api == "DescribeInternetGateways"
            gw_ids = null
            filters = null
            #internetgateway.DescribeInternetGateways
            internetgateway_model.DescribeInternetGateways {sender: me}, username, session_id, region_name, gw_ids, filters
            internetgateway_model.once "VPC_IGW_DESC_INET_GWS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## RouteTable ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "routetable" && current_api == "DescribeRouteTables"
            rt_ids = null
            filters = null
            #routetable.DescribeRouteTables
            routetable_model.DescribeRouteTables {sender: me}, username, session_id, region_name, rt_ids, filters
            routetable_model.once "VPC_RT_DESC_RT_TBLS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Subnet ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "subnet" && current_api == "DescribeSubnets"
            subnet_ids = null
            filters = null
            #subnet.DescribeSubnets
            subnet_model.DescribeSubnets {sender: me}, username, session_id, region_name, subnet_ids, filters
            subnet_model.once "VPC_SNET_DESC_SUBNETS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## VPC ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "vpc" && current_api == "DescribeVpcs"
            vpc_ids = null
            filters = null
            #vpc.DescribeVpcs
            vpc_model.DescribeVpcs {sender: me}, username, session_id, region_name, vpc_ids, filters
            vpc_model.once "VPC_VPC_DESC_VPCS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "vpc" && current_api == "DescribeAccountAttributes"
            attribute_name = null
            #vpc.DescribeAccountAttributes
            vpc_model.DescribeAccountAttributes {sender: me}, username, session_id, region_name, attribute_name
            vpc_model.once "VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "vpc" && current_api == "DescribeVpcAttribute"
            vpc_id = null
            attribute = null
            #vpc.DescribeVpcAttribute
            vpc_model.DescribeVpcAttribute {sender: me}, username, session_id, region_name, vpc_id, attribute
            vpc_model.once "VPC_VPC_DESC_VPC_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## VPNGateway ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "vpngateway" && current_api == "DescribeVpnGateways"
            gw_ids = null
            filters = null
            #vpngateway.DescribeVpnGateways
            vpngateway_model.DescribeVpnGateways {sender: me}, username, session_id, region_name, gw_ids, filters
            vpngateway_model.once "VPC_VGW_DESC_VPN_GWS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## VPN ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "vpn" && current_api == "DescribeVpnConnections"
            vpn_ids = null
            filters = null
            #vpn.DescribeVpnConnections
            vpn_model.DescribeVpnConnections {sender: me}, username, session_id, region_name, vpn_ids, filters
            vpn_model.once "VPC_VPN_DESC_VPN_CONNS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result






        null

    #public object
    ready : () ->
        $( '#login_form' ).submit( login )
        $( '#request_form' ).submit( request )
        window.init()


