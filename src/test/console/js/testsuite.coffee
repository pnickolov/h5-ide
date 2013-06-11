
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

                window.username    = username
                window.session_id  = session_id
                window.region_name = region_name


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

            #request
            result.param.splice(0,1)
            $("#resquest_data").removeClass("prettyprinted").text JSON.stringify( result.param, null, 4 )

            #Object to JSON, pretty print
            $( "#response_data" ).removeClass("prettyprinted").text JSON.stringify( result.resolved_data, null, 4 )
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

        region_name      = $("#region_list").val()
        current_service  = $( "#service_list" ).val()
        current_resource = $( "#resource_list" ).val()

        $("#region_name").val region_name

        $( "#resquest_data" ).val ""
        $( "#response_data" ).val ""

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
            user_logs = if $("#user_logs").val() != "null" then $("#user_logs").val() else null
            user_logs = if user_logs != null and user_logs.indexOf("[") != -1 then JSON.parse user_logs else user_logs
            #log.put_user_log
            log_model.put_user_log {sender: me}, username, session_id, user_logs
            log_model.once "LOG_PUT__USER__LOG_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Public ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "public" && current_api == "get_hostname"
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
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
            timestamp = if $("#timestamp").val() != "null" then $("#timestamp").val() else null
            timestamp = if timestamp != null and timestamp.indexOf("[") != -1 then JSON.parse timestamp else timestamp
            #request.update
            request_model.update {sender: me}, username, session_id, region_name, timestamp
            request_model.once "REQUEST_UPDATE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Session ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "session" && current_api == "login"
            password = if $("#password").val() != "null" then $("#password").val() else null
            password = if password != null and password.indexOf("[") != -1 then JSON.parse password else password
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
            access_key = if $("#access_key").val() != "null" then $("#access_key").val() else null
            access_key = if access_key != null and access_key.indexOf("[") != -1 then JSON.parse access_key else access_key
            secret_key = if $("#secret_key").val() != "null" then $("#secret_key").val() else null
            secret_key = if secret_key != null and secret_key.indexOf("[") != -1 then JSON.parse secret_key else secret_key
            account_id = if $("#account_id").val() != "null" then $("#account_id").val() else null
            account_id = if account_id != null and account_id.indexOf("[") != -1 then JSON.parse account_id else account_id
            #session.set_credential
            session_model.set_credential {sender: me}, username, session_id, access_key, secret_key, account_id
            session_model.once "SESSION_SET__CREDENTIAL_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "session" && current_api == "guest"
            guest_id = if $("#guest_id").val() != "null" then $("#guest_id").val() else null
            guest_id = if guest_id != null and guest_id.indexOf("[") != -1 then JSON.parse guest_id else guest_id
            guestname = if $("#guestname").val() != "null" then $("#guestname").val() else null
            guestname = if guestname != null and guestname.indexOf("[") != -1 then JSON.parse guestname else guestname
            #session.guest
            session_model.guest {sender: me}, guest_id, guestname
            session_model.once "SESSION_GUEST_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## App ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "create"
            spec = if $("#spec").val() != "null" then $("#spec").val() else null
            spec = if spec != null and spec.indexOf("[") != -1 then JSON.parse spec else spec
            #app.create
            app_model.create {sender: me}, username, session_id, region_name, spec
            app_model.once "APP_CREATE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "update"
            spec = if $("#spec").val() != "null" then $("#spec").val() else null
            spec = if spec != null and spec.indexOf("[") != -1 then JSON.parse spec else spec
            app_id = if $("#app_id").val() != "null" then $("#app_id").val() else null
            app_id = if app_id != null and app_id.indexOf("[") != -1 then JSON.parse app_id else app_id
            #app.update
            app_model.update {sender: me}, username, session_id, region_name, spec, app_id
            app_model.once "APP_UPDATE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "rename"
            app_id = if $("#app_id").val() != "null" then $("#app_id").val() else null
            app_id = if app_id != null and app_id.indexOf("[") != -1 then JSON.parse app_id else app_id
            new_name = if $("#new_name").val() != "null" then $("#new_name").val() else null
            new_name = if new_name != null and new_name.indexOf("[") != -1 then JSON.parse new_name else new_name
            app_name = if $("#app_name").val() != "null" then $("#app_name").val() else null
            app_name = if app_name != null and app_name.indexOf("[") != -1 then JSON.parse app_name else app_name
            #app.rename
            app_model.rename {sender: me}, username, session_id, region_name, app_id, new_name, app_name
            app_model.once "APP_RENAME_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "terminate"
            app_id = if $("#app_id").val() != "null" then $("#app_id").val() else null
            app_id = if app_id != null and app_id.indexOf("[") != -1 then JSON.parse app_id else app_id
            app_name = if $("#app_name").val() != "null" then $("#app_name").val() else null
            app_name = if app_name != null and app_name.indexOf("[") != -1 then JSON.parse app_name else app_name
            #app.terminate
            app_model.terminate {sender: me}, username, session_id, region_name, app_id, app_name
            app_model.once "APP_TERMINATE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "start"
            app_id = if $("#app_id").val() != "null" then $("#app_id").val() else null
            app_id = if app_id != null and app_id.indexOf("[") != -1 then JSON.parse app_id else app_id
            app_name = if $("#app_name").val() != "null" then $("#app_name").val() else null
            app_name = if app_name != null and app_name.indexOf("[") != -1 then JSON.parse app_name else app_name
            #app.start
            app_model.start {sender: me}, username, session_id, region_name, app_id, app_name
            app_model.once "APP_START_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "stop"
            app_id = if $("#app_id").val() != "null" then $("#app_id").val() else null
            app_id = if app_id != null and app_id.indexOf("[") != -1 then JSON.parse app_id else app_id
            app_name = if $("#app_name").val() != "null" then $("#app_name").val() else null
            app_name = if app_name != null and app_name.indexOf("[") != -1 then JSON.parse app_name else app_name
            #app.stop
            app_model.stop {sender: me}, username, session_id, region_name, app_id, app_name
            app_model.once "APP_STOP_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "reboot"
            app_id = if $("#app_id").val() != "null" then $("#app_id").val() else null
            app_id = if app_id != null and app_id.indexOf("[") != -1 then JSON.parse app_id else app_id
            app_name = if $("#app_name").val() != "null" then $("#app_name").val() else null
            app_name = if app_name != null and app_name.indexOf("[") != -1 then JSON.parse app_name else app_name
            #app.reboot
            app_model.reboot {sender: me}, username, session_id, region_name, app_id, app_name
            app_model.once "APP_REBOOT_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "info"
            app_ids = if $("#app_ids").val() != "null" then $("#app_ids").val() else null
            app_ids = if app_ids != null and app_ids.indexOf("[") != -1 then JSON.parse app_ids else app_ids
            #app.info
            app_model.info {sender: me}, username, session_id, region_name, app_ids
            app_model.once "APP_INFO_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "list"
            app_ids = if $("#app_ids").val() != "null" then $("#app_ids").val() else null
            app_ids = if app_ids != null and app_ids.indexOf("[") != -1 then JSON.parse app_ids else app_ids
            #app.list
            app_model.list {sender: me}, username, session_id, region_name, app_ids
            app_model.once "APP_LST_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "app" && current_api == "resource"
            app_id = if $("#app_id").val() != "null" then $("#app_id").val() else null
            app_id = if app_id != null and app_id.indexOf("[") != -1 then JSON.parse app_id else app_id
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
            resource = if $("#resource").val() != "null" then $("#resource").val() else null
            resource = if resource != null and resource.indexOf("[") != -1 then JSON.parse resource else resource
            #favorite.add
            favorite_model.add {sender: me}, username, session_id, region_name, resource
            favorite_model.once "FAVORITE_ADD_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "favorite" && current_api == "remove"
            resource_ids = if $("#resource_ids").val() != "null" then $("#resource_ids").val() else null
            resource_ids = if resource_ids != null and resource_ids.indexOf("[") != -1 then JSON.parse resource_ids else resource_ids
            #favorite.remove
            favorite_model.remove {sender: me}, username, session_id, region_name, resource_ids
            favorite_model.once "FAVORITE_REMOVE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "favorite" && current_api == "info"
            provider = if $("#provider").val() != "null" then $("#provider").val() else null
            provider = if provider != null and provider.indexOf("[") != -1 then JSON.parse provider else provider
            service = if $("#service").val() != "null" then $("#service").val() else null
            service = if service != null and service.indexOf("[") != -1 then JSON.parse service else service
            resource = if $("#resource").val() != "null" then $("#resource").val() else null
            resource = if resource != null and resource.indexOf("[") != -1 then JSON.parse resource else resource
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
            guest_id = if $("#guest_id").val() != "null" then $("#guest_id").val() else null
            guest_id = if guest_id != null and guest_id.indexOf("[") != -1 then JSON.parse guest_id else guest_id
            #guest.cancel
            guest_model.cancel {sender: me}, username, session_id, region_name, guest_id
            guest_model.once "GUEST_CANCEL_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "guest" && current_api == "access"
            guestname = if $("#guestname").val() != "null" then $("#guestname").val() else null
            guestname = if guestname != null and guestname.indexOf("[") != -1 then JSON.parse guestname else guestname
            guest_id = if $("#guest_id").val() != "null" then $("#guest_id").val() else null
            guest_id = if guest_id != null and guest_id.indexOf("[") != -1 then JSON.parse guest_id else guest_id
            #guest.access
            guest_model.access {sender: me}, guestname, session_id, region_name, guest_id
            guest_model.once "GUEST_ACCESS_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "guest" && current_api == "end"
            guestname = if $("#guestname").val() != "null" then $("#guestname").val() else null
            guestname = if guestname != null and guestname.indexOf("[") != -1 then JSON.parse guestname else guestname
            guest_id = if $("#guest_id").val() != "null" then $("#guest_id").val() else null
            guest_id = if guest_id != null and guest_id.indexOf("[") != -1 then JSON.parse guest_id else guest_id
            #guest.end
            guest_model.end {sender: me}, guestname, session_id, region_name, guest_id
            guest_model.once "GUEST_END_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "guest" && current_api == "info"
            guest_id = if $("#guest_id").val() != "null" then $("#guest_id").val() else null
            guest_id = if guest_id != null and guest_id.indexOf("[") != -1 then JSON.parse guest_id else guest_id
            #guest.info
            guest_model.info {sender: me}, username, session_id, region_name, guest_id
            guest_model.once "GUEST_INFO_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        ########## Stack ##########
        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "create"
            spec = if $("#spec").val() != "null" then $("#spec").val() else null
            spec = if spec != null and spec.indexOf("[") != -1 then JSON.parse spec else spec
            #stack.create
            stack_model.create {sender: me}, username, session_id, region_name, spec
            stack_model.once "STACK_CREATE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "remove"
            stack_id = if $("#stack_id").val() != "null" then $("#stack_id").val() else null
            stack_id = if stack_id != null and stack_id.indexOf("[") != -1 then JSON.parse stack_id else stack_id
            stack_name = if $("#stack_name").val() != "null" then $("#stack_name").val() else null
            stack_name = if stack_name != null and stack_name.indexOf("[") != -1 then JSON.parse stack_name else stack_name
            #stack.remove
            stack_model.remove {sender: me}, username, session_id, region_name, stack_id, stack_name
            stack_model.once "STACK_REMOVE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "save"
            spec = if $("#spec").val() != "null" then $("#spec").val() else null
            spec = if spec != null and spec.indexOf("[") != -1 then JSON.parse spec else spec
            #stack.save
            stack_model.save {sender: me}, username, session_id, region_name, spec
            stack_model.once "STACK_SAVE_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "rename"
            stack_id = if $("#stack_id").val() != "null" then $("#stack_id").val() else null
            stack_id = if stack_id != null and stack_id.indexOf("[") != -1 then JSON.parse stack_id else stack_id
            new_name = if $("#new_name").val() != "null" then $("#new_name").val() else null
            new_name = if new_name != null and new_name.indexOf("[") != -1 then JSON.parse new_name else new_name
            stack_name = if $("#stack_name").val() != "null" then $("#stack_name").val() else null
            stack_name = if stack_name != null and stack_name.indexOf("[") != -1 then JSON.parse stack_name else stack_name
            #stack.rename
            stack_model.rename {sender: me}, username, session_id, region_name, stack_id, new_name, stack_name
            stack_model.once "STACK_RENAME_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "run"
            stack_id = if $("#stack_id").val() != "null" then $("#stack_id").val() else null
            stack_id = if stack_id != null and stack_id.indexOf("[") != -1 then JSON.parse stack_id else stack_id
            app_name = if $("#app_name").val() != "null" then $("#app_name").val() else null
            app_name = if app_name != null and app_name.indexOf("[") != -1 then JSON.parse app_name else app_name
            app_desc = if $("#app_desc").val() != "null" then $("#app_desc").val() else null
            app_desc = if app_desc != null and app_desc.indexOf("[") != -1 then JSON.parse app_desc else app_desc
            app_component = if $("#app_component").val() != "null" then $("#app_component").val() else null
            app_component = if app_component != null and app_component.indexOf("[") != -1 then JSON.parse app_component else app_component
            app_property = if $("#app_property").val() != "null" then $("#app_property").val() else null
            app_property = if app_property != null and app_property.indexOf("[") != -1 then JSON.parse app_property else app_property
            app_layout = if $("#app_layout").val() != "null" then $("#app_layout").val() else null
            app_layout = if app_layout != null and app_layout.indexOf("[") != -1 then JSON.parse app_layout else app_layout
            stack_name = if $("#stack_name").val() != "null" then $("#stack_name").val() else null
            stack_name = if stack_name != null and stack_name.indexOf("[") != -1 then JSON.parse stack_name else stack_name
            #stack.run
            stack_model.run {sender: me}, username, session_id, region_name, stack_id, app_name, app_desc, app_component, app_property, app_layout, stack_name
            stack_model.once "STACK_RUN_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "save_as"
            stack_id = if $("#stack_id").val() != "null" then $("#stack_id").val() else null
            stack_id = if stack_id != null and stack_id.indexOf("[") != -1 then JSON.parse stack_id else stack_id
            new_name = if $("#new_name").val() != "null" then $("#new_name").val() else null
            new_name = if new_name != null and new_name.indexOf("[") != -1 then JSON.parse new_name else new_name
            stack_name = if $("#stack_name").val() != "null" then $("#stack_name").val() else null
            stack_name = if stack_name != null and stack_name.indexOf("[") != -1 then JSON.parse stack_name else stack_name
            #stack.save_as
            stack_model.save_as {sender: me}, username, session_id, region_name, stack_id, new_name, stack_name
            stack_model.once "STACK_SAVE__AS_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "info"
            stack_ids = if $("#stack_ids").val() != "null" then $("#stack_ids").val() else null
            stack_ids = if stack_ids != null and stack_ids.indexOf("[") != -1 then JSON.parse stack_ids else stack_ids
            #stack.info
            stack_model.info {sender: me}, username, session_id, region_name, stack_ids
            stack_model.once "STACK_INFO_RETURN", ( forge_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, forge_result

        if current_service.toLowerCase() == "forge" && current_resource.toLowerCase() == "stack" && current_api == "list"
            stack_ids = if $("#stack_ids").val() != "null" then $("#stack_ids").val() else null
            stack_ids = if stack_ids != null and stack_ids.indexOf("[") != -1 then JSON.parse stack_ids else stack_ids
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
            group_names = if $("#group_names").val() != "null" then $("#group_names").val() else null
            group_names = if group_names != null and group_names.indexOf("[") != -1 then JSON.parse group_names else group_names
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
            next_token = if $("#next_token").val() != "null" then $("#next_token").val() else null
            next_token = if next_token != null and next_token.indexOf("[") != -1 then JSON.parse next_token else next_token
            #autoscaling.DescribeAutoScalingGroups
            autoscaling_model.DescribeAutoScalingGroups {sender: me}, username, session_id, region_name, group_names, max_records, next_token
            autoscaling_model.once "ASL__DESC_ASL_GRPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribeAutoScalingInstances"
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
            next_token = if $("#next_token").val() != "null" then $("#next_token").val() else null
            next_token = if next_token != null and next_token.indexOf("[") != -1 then JSON.parse next_token else next_token
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
            config_names = if $("#config_names").val() != "null" then $("#config_names").val() else null
            config_names = if config_names != null and config_names.indexOf("[") != -1 then JSON.parse config_names else config_names
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
            next_token = if $("#next_token").val() != "null" then $("#next_token").val() else null
            next_token = if next_token != null and next_token.indexOf("[") != -1 then JSON.parse next_token else next_token
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
            group_names = if $("#group_names").val() != "null" then $("#group_names").val() else null
            group_names = if group_names != null and group_names.indexOf("[") != -1 then JSON.parse group_names else group_names
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
            next_token = if $("#next_token").val() != "null" then $("#next_token").val() else null
            next_token = if next_token != null and next_token.indexOf("[") != -1 then JSON.parse next_token else next_token
            #autoscaling.DescribeNotificationConfigurations
            autoscaling_model.DescribeNotificationConfigurations {sender: me}, username, session_id, region_name, group_names, max_records, next_token
            autoscaling_model.once "ASL__DESC_NTF_CONFS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "autoscaling" && current_resource.toLowerCase() == "autoscaling" && current_api == "DescribePolicies"
            group_name = if $("#group_name").val() != "null" then $("#group_name").val() else null
            group_name = if group_name != null and group_name.indexOf("[") != -1 then JSON.parse group_name else group_name
            policy_names = if $("#policy_names").val() != "null" then $("#policy_names").val() else null
            policy_names = if policy_names != null and policy_names.indexOf("[") != -1 then JSON.parse policy_names else policy_names
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
            next_token = if $("#next_token").val() != "null" then $("#next_token").val() else null
            next_token = if next_token != null and next_token.indexOf("[") != -1 then JSON.parse next_token else next_token
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
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
            next_token = if $("#next_token").val() != "null" then $("#next_token").val() else null
            next_token = if next_token != null and next_token.indexOf("[") != -1 then JSON.parse next_token else next_token
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
            resources = if $("#resources").val() != "null" then $("#resources").val() else null
            resources = if resources != null and resources.indexOf("[") != -1 then JSON.parse resources else resources
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
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            ami_name = if $("#ami_name").val() != "null" then $("#ami_name").val() else null
            ami_name = if ami_name != null and ami_name.indexOf("[") != -1 then JSON.parse ami_name else ami_name
            ami_desc = if $("#ami_desc").val() != "null" then $("#ami_desc").val() else null
            ami_desc = if ami_desc != null and ami_desc.indexOf("[") != -1 then JSON.parse ami_desc else ami_desc
            no_reboot = if $("#no_reboot").val() != "null" then $("#no_reboot").val() else null
            no_reboot = if no_reboot != null and no_reboot.indexOf("[") != -1 then JSON.parse no_reboot else no_reboot
            bd_mappings = if $("#bd_mappings").val() != "null" then $("#bd_mappings").val() else null
            bd_mappings = if bd_mappings != null and bd_mappings.indexOf("[") != -1 then JSON.parse bd_mappings else bd_mappings
            #ami.CreateImage
            ami_model.CreateImage {sender: me}, username, session_id, region_name, instance_id, ami_name, ami_desc, no_reboot, bd_mappings
            ami_model.once "EC2_AMI_CREATE_IMAGE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ami" && current_api == "RegisterImage"
            ami_name = if $("#ami_name").val() != "null" then $("#ami_name").val() else null
            ami_name = if ami_name != null and ami_name.indexOf("[") != -1 then JSON.parse ami_name else ami_name
            ami_desc = if $("#ami_desc").val() != "null" then $("#ami_desc").val() else null
            ami_desc = if ami_desc != null and ami_desc.indexOf("[") != -1 then JSON.parse ami_desc else ami_desc
            #ami.RegisterImage
            ami_model.RegisterImage {sender: me}, username, session_id, region_name, ami_name, ami_desc
            ami_model.once "EC2_AMI_REGISTER_IMAGE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ami" && current_api == "DeregisterImage"
            ami_id = if $("#ami_id").val() != "null" then $("#ami_id").val() else null
            ami_id = if ami_id != null and ami_id.indexOf("[") != -1 then JSON.parse ami_id else ami_id
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
            ami_id = if $("#ami_id").val() != "null" then $("#ami_id").val() else null
            ami_id = if ami_id != null and ami_id.indexOf("[") != -1 then JSON.parse ami_id else ami_id
            attribute_name = if $("#attribute_name").val() != "null" then $("#attribute_name").val() else null
            attribute_name = if attribute_name != null and attribute_name.indexOf("[") != -1 then JSON.parse attribute_name else attribute_name
            #ami.ResetImageAttribute
            ami_model.ResetImageAttribute {sender: me}, username, session_id, region_name, ami_id, attribute_name
            ami_model.once "EC2_AMI_RESET_IMAGE_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ami" && current_api == "DescribeImageAttribute"
            ami_id = if $("#ami_id").val() != "null" then $("#ami_id").val() else null
            ami_id = if ami_id != null and ami_id.indexOf("[") != -1 then JSON.parse ami_id else ami_id
            attribute_name = if $("#attribute_name").val() != "null" then $("#attribute_name").val() else null
            attribute_name = if attribute_name != null and attribute_name.indexOf("[") != -1 then JSON.parse attribute_name else attribute_name
            #ami.DescribeImageAttribute
            ami_model.DescribeImageAttribute {sender: me}, username, session_id, region_name, ami_id, attribute_name
            ami_model.once "EC2_AMI_DESC_IMAGE_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ami" && current_api == "DescribeImages"
            ami_ids = if $("#ami_ids").val() != "null" then $("#ami_ids").val() else null
            ami_ids = if ami_ids != null and ami_ids.indexOf("[") != -1 then JSON.parse ami_ids else ami_ids
            owners = if $("#owners").val() != "null" then $("#owners").val() else null
            owners = if owners != null and owners.indexOf("[") != -1 then JSON.parse owners else owners
            executable_by = if $("#executable_by").val() != "null" then $("#executable_by").val() else null
            executable_by = if executable_by != null and executable_by.indexOf("[") != -1 then JSON.parse executable_by else executable_by
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #ami.DescribeImages
            ami_model.DescribeImages {sender: me}, username, session_id, region_name, ami_ids, owners, executable_by, filters
            ami_model.once "EC2_AMI_DESC_IMAGES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## EBS ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "CreateVolume"
            zone_name = if $("#zone_name").val() != "null" then $("#zone_name").val() else null
            zone_name = if zone_name != null and zone_name.indexOf("[") != -1 then JSON.parse zone_name else zone_name
            snapshot_id = if $("#snapshot_id").val() != "null" then $("#snapshot_id").val() else null
            snapshot_id = if snapshot_id != null and snapshot_id.indexOf("[") != -1 then JSON.parse snapshot_id else snapshot_id
            volume_size = if $("#volume_size").val() != "null" then $("#volume_size").val() else null
            volume_size = if volume_size != null and volume_size.indexOf("[") != -1 then JSON.parse volume_size else volume_size
            volume_type = if $("#volume_type").val() != "null" then $("#volume_type").val() else null
            volume_type = if volume_type != null and volume_type.indexOf("[") != -1 then JSON.parse volume_type else volume_type
            iops = if $("#iops").val() != "null" then $("#iops").val() else null
            iops = if iops != null and iops.indexOf("[") != -1 then JSON.parse iops else iops
            #ebs.CreateVolume
            ebs_model.CreateVolume {sender: me}, username, session_id, region_name, zone_name, snapshot_id, volume_size, volume_type, iops
            ebs_model.once "EC2_EBS_CREATE_VOL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DeleteVolume"
            volume_id = if $("#volume_id").val() != "null" then $("#volume_id").val() else null
            volume_id = if volume_id != null and volume_id.indexOf("[") != -1 then JSON.parse volume_id else volume_id
            #ebs.DeleteVolume
            ebs_model.DeleteVolume {sender: me}, username, session_id, region_name, volume_id
            ebs_model.once "EC2_EBS_DELETE_VOL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "AttachVolume"
            volume_id = if $("#volume_id").val() != "null" then $("#volume_id").val() else null
            volume_id = if volume_id != null and volume_id.indexOf("[") != -1 then JSON.parse volume_id else volume_id
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            device = if $("#device").val() != "null" then $("#device").val() else null
            device = if device != null and device.indexOf("[") != -1 then JSON.parse device else device
            #ebs.AttachVolume
            ebs_model.AttachVolume {sender: me}, username, session_id, region_name, volume_id, instance_id, device
            ebs_model.once "EC2_EBS_ATTACH_VOL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DetachVolume"
            volume_id = if $("#volume_id").val() != "null" then $("#volume_id").val() else null
            volume_id = if volume_id != null and volume_id.indexOf("[") != -1 then JSON.parse volume_id else volume_id
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            device = if $("#device").val() != "null" then $("#device").val() else null
            device = if device != null and device.indexOf("[") != -1 then JSON.parse device else device
            force = if $("#force").val() != "null" then $("#force").val() else null
            force = if force != null and force.indexOf("[") != -1 then JSON.parse force else force
            #ebs.DetachVolume
            ebs_model.DetachVolume {sender: me}, username, session_id, region_name, volume_id, instance_id, device, force
            ebs_model.once "EC2_EBS_DETACH_VOL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DescribeVolumes"
            volume_ids = if $("#volume_ids").val() != "null" then $("#volume_ids").val() else null
            volume_ids = if volume_ids != null and volume_ids.indexOf("[") != -1 then JSON.parse volume_ids else volume_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #ebs.DescribeVolumes
            ebs_model.DescribeVolumes {sender: me}, username, session_id, region_name, volume_ids, filters
            ebs_model.once "EC2_EBS_DESC_VOLS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DescribeVolumeAttribute"
            volume_id = if $("#volume_id").val() != "null" then $("#volume_id").val() else null
            volume_id = if volume_id != null and volume_id.indexOf("[") != -1 then JSON.parse volume_id else volume_id
            attribute_name = if $("#attribute_name").val() != "null" then $("#attribute_name").val() else null
            attribute_name = if attribute_name != null and attribute_name.indexOf("[") != -1 then JSON.parse attribute_name else attribute_name
            #ebs.DescribeVolumeAttribute
            ebs_model.DescribeVolumeAttribute {sender: me}, username, session_id, region_name, volume_id, attribute_name
            ebs_model.once "EC2_EBS_DESC_VOL_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DescribeVolumeStatus"
            volume_ids = if $("#volume_ids").val() != "null" then $("#volume_ids").val() else null
            volume_ids = if volume_ids != null and volume_ids.indexOf("[") != -1 then JSON.parse volume_ids else volume_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            max_result = if $("#max_result").val() != "null" then $("#max_result").val() else null
            max_result = if max_result != null and max_result.indexOf("[") != -1 then JSON.parse max_result else max_result
            next_token = if $("#next_token").val() != "null" then $("#next_token").val() else null
            next_token = if next_token != null and next_token.indexOf("[") != -1 then JSON.parse next_token else next_token
            #ebs.DescribeVolumeStatus
            ebs_model.DescribeVolumeStatus {sender: me}, username, session_id, region_name, volume_ids, filters, max_result, next_token
            ebs_model.once "EC2_EBS_DESC_VOL_STATUS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "ModifyVolumeAttribute"
            volume_id = if $("#volume_id").val() != "null" then $("#volume_id").val() else null
            volume_id = if volume_id != null and volume_id.indexOf("[") != -1 then JSON.parse volume_id else volume_id
            auto_enable_IO = if $("#auto_enable_IO").val() != "null" then $("#auto_enable_IO").val() else null
            auto_enable_IO = if auto_enable_IO != null and auto_enable_IO.indexOf("[") != -1 then JSON.parse auto_enable_IO else auto_enable_IO
            #ebs.ModifyVolumeAttribute
            ebs_model.ModifyVolumeAttribute {sender: me}, username, session_id, region_name, volume_id, auto_enable_IO
            ebs_model.once "EC2_EBS_MODIFY_VOL_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "EnableVolumeIO"
            volume_id = if $("#volume_id").val() != "null" then $("#volume_id").val() else null
            volume_id = if volume_id != null and volume_id.indexOf("[") != -1 then JSON.parse volume_id else volume_id
            #ebs.EnableVolumeIO
            ebs_model.EnableVolumeIO {sender: me}, username, session_id, region_name, volume_id
            ebs_model.once "EC2_EBS_ENABLE_VOL_I_O_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "CreateSnapshot"
            volume_id = if $("#volume_id").val() != "null" then $("#volume_id").val() else null
            volume_id = if volume_id != null and volume_id.indexOf("[") != -1 then JSON.parse volume_id else volume_id
            description = if $("#description").val() != "null" then $("#description").val() else null
            description = if description != null and description.indexOf("[") != -1 then JSON.parse description else description
            #ebs.CreateSnapshot
            ebs_model.CreateSnapshot {sender: me}, username, session_id, region_name, volume_id, description
            ebs_model.once "EC2_EBS_CREATE_SS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DeleteSnapshot"
            snapshot_id = if $("#snapshot_id").val() != "null" then $("#snapshot_id").val() else null
            snapshot_id = if snapshot_id != null and snapshot_id.indexOf("[") != -1 then JSON.parse snapshot_id else snapshot_id
            #ebs.DeleteSnapshot
            ebs_model.DeleteSnapshot {sender: me}, username, session_id, region_name, snapshot_id
            ebs_model.once "EC2_EBS_DELETE_SS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "ModifySnapshotAttribute"
            snapshot_id = if $("#snapshot_id").val() != "null" then $("#snapshot_id").val() else null
            snapshot_id = if snapshot_id != null and snapshot_id.indexOf("[") != -1 then JSON.parse snapshot_id else snapshot_id
            user_ids = if $("#user_ids").val() != "null" then $("#user_ids").val() else null
            user_ids = if user_ids != null and user_ids.indexOf("[") != -1 then JSON.parse user_ids else user_ids
            group_names = if $("#group_names").val() != "null" then $("#group_names").val() else null
            group_names = if group_names != null and group_names.indexOf("[") != -1 then JSON.parse group_names else group_names
            #ebs.ModifySnapshotAttribute
            ebs_model.ModifySnapshotAttribute {sender: me}, username, session_id, region_name, snapshot_id, user_ids, group_names
            ebs_model.once "EC2_EBS_MODIFY_SS_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "ResetSnapshotAttribute"
            snapshot_id = if $("#snapshot_id").val() != "null" then $("#snapshot_id").val() else null
            snapshot_id = if snapshot_id != null and snapshot_id.indexOf("[") != -1 then JSON.parse snapshot_id else snapshot_id
            attribute_name = if $("#attribute_name").val() != "null" then $("#attribute_name").val() else null
            attribute_name = if attribute_name != null and attribute_name.indexOf("[") != -1 then JSON.parse attribute_name else attribute_name
            #ebs.ResetSnapshotAttribute
            ebs_model.ResetSnapshotAttribute {sender: me}, username, session_id, region_name, snapshot_id, attribute_name
            ebs_model.once "EC2_EBS_RESET_SS_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DescribeSnapshots"
            snapshot_ids = if $("#snapshot_ids").val() != "null" then $("#snapshot_ids").val() else null
            snapshot_ids = if snapshot_ids != null and snapshot_ids.indexOf("[") != -1 then JSON.parse snapshot_ids else snapshot_ids
            owners = if $("#owners").val() != "null" then $("#owners").val() else null
            owners = if owners != null and owners.indexOf("[") != -1 then JSON.parse owners else owners
            restorable_by = if $("#restorable_by").val() != "null" then $("#restorable_by").val() else null
            restorable_by = if restorable_by != null and restorable_by.indexOf("[") != -1 then JSON.parse restorable_by else restorable_by
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #ebs.DescribeSnapshots
            ebs_model.DescribeSnapshots {sender: me}, username, session_id, region_name, snapshot_ids, owners, restorable_by, filters
            ebs_model.once "EC2_EBS_DESC_SSS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ebs" && current_api == "DescribeSnapshotAttribute"
            snapshot_id = if $("#snapshot_id").val() != "null" then $("#snapshot_id").val() else null
            snapshot_id = if snapshot_id != null and snapshot_id.indexOf("[") != -1 then JSON.parse snapshot_id else snapshot_id
            attribute_name = if $("#attribute_name").val() != "null" then $("#attribute_name").val() else null
            attribute_name = if attribute_name != null and attribute_name.indexOf("[") != -1 then JSON.parse attribute_name else attribute_name
            #ebs.DescribeSnapshotAttribute
            ebs_model.DescribeSnapshotAttribute {sender: me}, username, session_id, region_name, snapshot_id, attribute_name
            ebs_model.once "EC2_EBS_DESC_SS_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## EC2 ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ec2" && current_api == "CreateTags"
            resource_ids = if $("#resource_ids").val() != "null" then $("#resource_ids").val() else null
            resource_ids = if resource_ids != null and resource_ids.indexOf("[") != -1 then JSON.parse resource_ids else resource_ids
            tags = if $("#tags").val() != "null" then $("#tags").val() else null
            tags = if tags != null and tags.indexOf("[") != -1 then JSON.parse tags else tags
            #ec2.CreateTags
            ec2_model.CreateTags {sender: me}, username, session_id, region_name, resource_ids, tags
            ec2_model.once "EC2_EC2_CREATE_TAGS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ec2" && current_api == "DeleteTags"
            resource_ids = if $("#resource_ids").val() != "null" then $("#resource_ids").val() else null
            resource_ids = if resource_ids != null and resource_ids.indexOf("[") != -1 then JSON.parse resource_ids else resource_ids
            tags = if $("#tags").val() != "null" then $("#tags").val() else null
            tags = if tags != null and tags.indexOf("[") != -1 then JSON.parse tags else tags
            #ec2.DeleteTags
            ec2_model.DeleteTags {sender: me}, username, session_id, region_name, resource_ids, tags
            ec2_model.once "EC2_EC2_DELETE_TAGS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ec2" && current_api == "DescribeTags"
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #ec2.DescribeTags
            ec2_model.DescribeTags {sender: me}, username, session_id, region_name, filters
            ec2_model.once "EC2_EC2_DESC_TAGS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ec2" && current_api == "DescribeRegions"
            region_names = if $("#region_names").val() != "null" then $("#region_names").val() else null
            region_names = if region_names != null and region_names.indexOf("[") != -1 then JSON.parse region_names else region_names
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #ec2.DescribeRegions
            ec2_model.DescribeRegions {sender: me}, username, session_id, region_names, filters
            ec2_model.once "EC2_EC2_DESC_REGIONS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "ec2" && current_api == "DescribeAvailabilityZones"
            zone_names = if $("#zone_names").val() != "null" then $("#zone_names").val() else null
            zone_names = if zone_names != null and zone_names.indexOf("[") != -1 then JSON.parse zone_names else zone_names
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #ec2.DescribeAvailabilityZones
            ec2_model.DescribeAvailabilityZones {sender: me}, username, session_id, region_name, zone_names, filters
            ec2_model.once "EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## EIP ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "eip" && current_api == "AllocateAddress"
            domain = if $("#domain").val() != "null" then $("#domain").val() else null
            domain = if domain != null and domain.indexOf("[") != -1 then JSON.parse domain else domain
            #eip.AllocateAddress
            eip_model.AllocateAddress {sender: me}, username, session_id, region_name, domain
            eip_model.once "EC2_EIP_ALLOCATE_ADDR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "eip" && current_api == "ReleaseAddress"
            ip = if $("#ip").val() != "null" then $("#ip").val() else null
            ip = if ip != null and ip.indexOf("[") != -1 then JSON.parse ip else ip
            allocation_id = if $("#allocation_id").val() != "null" then $("#allocation_id").val() else null
            allocation_id = if allocation_id != null and allocation_id.indexOf("[") != -1 then JSON.parse allocation_id else allocation_id
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
            ip = if $("#ip").val() != "null" then $("#ip").val() else null
            ip = if ip != null and ip.indexOf("[") != -1 then JSON.parse ip else ip
            association_id = if $("#association_id").val() != "null" then $("#association_id").val() else null
            association_id = if association_id != null and association_id.indexOf("[") != -1 then JSON.parse association_id else association_id
            #eip.DisassociateAddress
            eip_model.DisassociateAddress {sender: me}, username, session_id, region_name, ip, association_id
            eip_model.once "EC2_EIP_DISASSOCIATE_ADDR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "eip" && current_api == "DescribeAddresses"
            ips = if $("#ips").val() != "null" then $("#ips").val() else null
            ips = if ips != null and ips.indexOf("[") != -1 then JSON.parse ips else ips
            allocation_ids = if $("#allocation_ids").val() != "null" then $("#allocation_ids").val() else null
            allocation_ids = if allocation_ids != null and allocation_ids.indexOf("[") != -1 then JSON.parse allocation_ids else allocation_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
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
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            #instance.StartInstances
            instance_model.StartInstances {sender: me}, username, session_id, region_name, instance_ids
            instance_model.once "EC2_INS_START_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "StopInstances"
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            force = if $("#force").val() != "null" then $("#force").val() else null
            force = if force != null and force.indexOf("[") != -1 then JSON.parse force else force
            #instance.StopInstances
            instance_model.StopInstances {sender: me}, username, session_id, region_name, instance_ids, force
            instance_model.once "EC2_INS_STOP_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "RebootInstances"
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            #instance.RebootInstances
            instance_model.RebootInstances {sender: me}, username, session_id, region_name, instance_ids
            instance_model.once "EC2_INS_REBOOT_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "TerminateInstances"
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            #instance.TerminateInstances
            instance_model.TerminateInstances {sender: me}, username, session_id, region_name, instance_ids
            instance_model.once "EC2_INS_TERMINATE_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "MonitorInstances"
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            #instance.MonitorInstances
            instance_model.MonitorInstances {sender: me}, username, session_id, region_name, instance_ids
            instance_model.once "EC2_INS_MONITOR_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "UnmonitorInstances"
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            #instance.UnmonitorInstances
            instance_model.UnmonitorInstances {sender: me}, username, session_id, region_name, instance_ids
            instance_model.once "EC2_INS_UNMONITOR_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "BundleInstance"
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            s3_bucket = if $("#s3_bucket").val() != "null" then $("#s3_bucket").val() else null
            s3_bucket = if s3_bucket != null and s3_bucket.indexOf("[") != -1 then JSON.parse s3_bucket else s3_bucket
            #instance.BundleInstance
            instance_model.BundleInstance {sender: me}, username, session_id, region_name, instance_id, s3_bucket
            instance_model.once "EC2_INS_BUNDLE_INSTANCE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "CancelBundleTask"
            bundle_id = if $("#bundle_id").val() != "null" then $("#bundle_id").val() else null
            bundle_id = if bundle_id != null and bundle_id.indexOf("[") != -1 then JSON.parse bundle_id else bundle_id
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
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            attribute_name = if $("#attribute_name").val() != "null" then $("#attribute_name").val() else null
            attribute_name = if attribute_name != null and attribute_name.indexOf("[") != -1 then JSON.parse attribute_name else attribute_name
            #instance.ResetInstanceAttribute
            instance_model.ResetInstanceAttribute {sender: me}, username, session_id, region_name, instance_id, attribute_name
            instance_model.once "EC2_INS_RESET_INSTANCE_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "ConfirmProductInstance"
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            product_code = if $("#product_code").val() != "null" then $("#product_code").val() else null
            product_code = if product_code != null and product_code.indexOf("[") != -1 then JSON.parse product_code else product_code
            #instance.ConfirmProductInstance
            instance_model.ConfirmProductInstance {sender: me}, username, session_id, region_name, instance_id, product_code
            instance_model.once "EC2_INS_CONFIRM_PRODUCT_INSTANCE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "DescribeInstances"
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #instance.DescribeInstances
            instance_model.DescribeInstances {sender: me}, username, session_id, region_name, instance_ids, filters
            instance_model.once "EC2_INS_DESC_INSTANCES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "DescribeInstanceStatus"
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            include_all_instances = if $("#include_all_instances").val() != "null" then $("#include_all_instances").val() else null
            include_all_instances = if include_all_instances != null and include_all_instances.indexOf("[") != -1 then JSON.parse include_all_instances else include_all_instances
            max_results = if $("#max_results").val() != "null" then $("#max_results").val() else null
            max_results = if max_results != null and max_results.indexOf("[") != -1 then JSON.parse max_results else max_results
            next_token = if $("#next_token").val() != "null" then $("#next_token").val() else null
            next_token = if next_token != null and next_token.indexOf("[") != -1 then JSON.parse next_token else next_token
            #instance.DescribeInstanceStatus
            instance_model.DescribeInstanceStatus {sender: me}, username, session_id, region_name, instance_ids, include_all_instances, max_results, next_token
            instance_model.once "EC2_INS_DESC_INSTANCE_STATUS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "DescribeBundleTasks"
            bundle_ids = if $("#bundle_ids").val() != "null" then $("#bundle_ids").val() else null
            bundle_ids = if bundle_ids != null and bundle_ids.indexOf("[") != -1 then JSON.parse bundle_ids else bundle_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #instance.DescribeBundleTasks
            instance_model.DescribeBundleTasks {sender: me}, username, session_id, region_name, bundle_ids, filters
            instance_model.once "EC2_INS_DESC_BUNDLE_TASKS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "DescribeInstanceAttribute"
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            attribute_name = if $("#attribute_name").val() != "null" then $("#attribute_name").val() else null
            attribute_name = if attribute_name != null and attribute_name.indexOf("[") != -1 then JSON.parse attribute_name else attribute_name
            #instance.DescribeInstanceAttribute
            instance_model.DescribeInstanceAttribute {sender: me}, username, session_id, region_name, instance_id, attribute_name
            instance_model.once "EC2_INS_DESC_INSTANCE_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "GetConsoleOutput"
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            #instance.GetConsoleOutput
            instance_model.GetConsoleOutput {sender: me}, username, session_id, region_name, instance_id
            instance_model.once "EC2_INS_GET_CONSOLE_OUTPUT_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "instance" && current_api == "GetPasswordData"
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            key_data = if $("#key_data").val() != "null" then $("#key_data").val() else null
            key_data = if key_data != null and key_data.indexOf("[") != -1 then JSON.parse key_data else key_data
            #instance.GetPasswordData
            instance_model.GetPasswordData {sender: me}, username, session_id, region_name, instance_id, key_data
            instance_model.once "EC2_INS_GET_PWD_DATA_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## KeyPair ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "CreateKeyPair"
            key_name = if $("#key_name").val() != "null" then $("#key_name").val() else null
            key_name = if key_name != null and key_name.indexOf("[") != -1 then JSON.parse key_name else key_name
            #keypair.CreateKeyPair
            keypair_model.CreateKeyPair {sender: me}, username, session_id, region_name, key_name
            keypair_model.once "EC2_KP_CREATE_KEY_PAIR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "DeleteKeyPair"
            key_name = if $("#key_name").val() != "null" then $("#key_name").val() else null
            key_name = if key_name != null and key_name.indexOf("[") != -1 then JSON.parse key_name else key_name
            #keypair.DeleteKeyPair
            keypair_model.DeleteKeyPair {sender: me}, username, session_id, region_name, key_name
            keypair_model.once "EC2_KP_DELETE_KEY_PAIR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "ImportKeyPair"
            key_name = if $("#key_name").val() != "null" then $("#key_name").val() else null
            key_name = if key_name != null and key_name.indexOf("[") != -1 then JSON.parse key_name else key_name
            key_data = if $("#key_data").val() != "null" then $("#key_data").val() else null
            key_data = if key_data != null and key_data.indexOf("[") != -1 then JSON.parse key_data else key_data
            #keypair.ImportKeyPair
            keypair_model.ImportKeyPair {sender: me}, username, session_id, region_name, key_name, key_data
            keypair_model.once "EC2_KP_IMPORT_KEY_PAIR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "DescribeKeyPairs"
            key_names = if $("#key_names").val() != "null" then $("#key_names").val() else null
            key_names = if key_names != null and key_names.indexOf("[") != -1 then JSON.parse key_names else key_names
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #keypair.DescribeKeyPairs
            keypair_model.DescribeKeyPairs {sender: me}, username, session_id, region_name, key_names, filters
            keypair_model.once "EC2_KP_DESC_KEY_PAIRS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "upload"
            key_name = if $("#key_name").val() != "null" then $("#key_name").val() else null
            key_name = if key_name != null and key_name.indexOf("[") != -1 then JSON.parse key_name else key_name
            key_data = if $("#key_data").val() != "null" then $("#key_data").val() else null
            key_data = if key_data != null and key_data.indexOf("[") != -1 then JSON.parse key_data else key_data
            #keypair.upload
            keypair_model.upload {sender: me}, username, session_id, region_name, key_name, key_data
            keypair_model.once "EC2_KPUPLOAD_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "download"
            key_name = if $("#key_name").val() != "null" then $("#key_name").val() else null
            key_name = if key_name != null and key_name.indexOf("[") != -1 then JSON.parse key_name else key_name
            #keypair.download
            keypair_model.download {sender: me}, username, session_id, region_name, key_name
            keypair_model.once "EC2_KPDOWNLOAD_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "keypair" && current_api == "remove"
            key_name = if $("#key_name").val() != "null" then $("#key_name").val() else null
            key_name = if key_name != null and key_name.indexOf("[") != -1 then JSON.parse key_name else key_name
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
            group_name = if $("#group_name").val() != "null" then $("#group_name").val() else null
            group_name = if group_name != null and group_name.indexOf("[") != -1 then JSON.parse group_name else group_name
            strategy = if $("#strategy").val() != "null" then $("#strategy").val() else null
            strategy = if strategy != null and strategy.indexOf("[") != -1 then JSON.parse strategy else strategy
            #placementgroup.CreatePlacementGroup
            placementgroup_model.CreatePlacementGroup {sender: me}, username, session_id, region_name, group_name, strategy
            placementgroup_model.once "EC2_PG_CREATE_PLA_GRP_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "placementgroup" && current_api == "DeletePlacementGroup"
            group_name = if $("#group_name").val() != "null" then $("#group_name").val() else null
            group_name = if group_name != null and group_name.indexOf("[") != -1 then JSON.parse group_name else group_name
            #placementgroup.DeletePlacementGroup
            placementgroup_model.DeletePlacementGroup {sender: me}, username, session_id, region_name, group_name
            placementgroup_model.once "EC2_PG_DELETE_PLA_GRP_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "placementgroup" && current_api == "DescribePlacementGroups"
            group_names = if $("#group_names").val() != "null" then $("#group_names").val() else null
            group_names = if group_names != null and group_names.indexOf("[") != -1 then JSON.parse group_names else group_names
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #placementgroup.DescribePlacementGroups
            placementgroup_model.DescribePlacementGroups {sender: me}, username, session_id, region_name, group_names, filters
            placementgroup_model.once "EC2_PG_DESC_PLA_GRPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## SecurityGroup ##########
        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "securitygroup" && current_api == "CreateSecurityGroup"
            group_name = if $("#group_name").val() != "null" then $("#group_name").val() else null
            group_name = if group_name != null and group_name.indexOf("[") != -1 then JSON.parse group_name else group_name
            group_desc = if $("#group_desc").val() != "null" then $("#group_desc").val() else null
            group_desc = if group_desc != null and group_desc.indexOf("[") != -1 then JSON.parse group_desc else group_desc
            vpc_id = if $("#vpc_id").val() != "null" then $("#vpc_id").val() else null
            vpc_id = if vpc_id != null and vpc_id.indexOf("[") != -1 then JSON.parse vpc_id else vpc_id
            #securitygroup.CreateSecurityGroup
            securitygroup_model.CreateSecurityGroup {sender: me}, username, session_id, region_name, group_name, group_desc, vpc_id
            securitygroup_model.once "EC2_SG_CREATE_SG_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "ec2" && current_resource.toLowerCase() == "securitygroup" && current_api == "DeleteSecurityGroup"
            group_name = if $("#group_name").val() != "null" then $("#group_name").val() else null
            group_name = if group_name != null and group_name.indexOf("[") != -1 then JSON.parse group_name else group_name
            group_id = if $("#group_id").val() != "null" then $("#group_id").val() else null
            group_id = if group_id != null and group_id.indexOf("[") != -1 then JSON.parse group_id else group_id
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
            group_names = if $("#group_names").val() != "null" then $("#group_names").val() else null
            group_names = if group_names != null and group_names.indexOf("[") != -1 then JSON.parse group_names else group_names
            group_ids = if $("#group_ids").val() != "null" then $("#group_ids").val() else null
            group_ids = if group_ids != null and group_ids.indexOf("[") != -1 then JSON.parse group_ids else group_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #securitygroup.DescribeSecurityGroups
            securitygroup_model.DescribeSecurityGroups {sender: me}, username, session_id, region_name, group_names, group_ids, filters
            securitygroup_model.once "EC2_SG_DESC_SGS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ELB ##########
        if current_service.toLowerCase() == "elb" && current_resource.toLowerCase() == "elb" && current_api == "DescribeInstanceHealth"
            elb_name = if $("#elb_name").val() != "null" then $("#elb_name").val() else null
            elb_name = if elb_name != null and elb_name.indexOf("[") != -1 then JSON.parse elb_name else elb_name
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            #elb.DescribeInstanceHealth
            elb_model.DescribeInstanceHealth {sender: me}, username, session_id, region_name, elb_name, instance_ids
            elb_model.once "ELB__DESC_INS_HLT_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "elb" && current_resource.toLowerCase() == "elb" && current_api == "DescribeLoadBalancerPolicies"
            elb_name = if $("#elb_name").val() != "null" then $("#elb_name").val() else null
            elb_name = if elb_name != null and elb_name.indexOf("[") != -1 then JSON.parse elb_name else elb_name
            policy_names = if $("#policy_names").val() != "null" then $("#policy_names").val() else null
            policy_names = if policy_names != null and policy_names.indexOf("[") != -1 then JSON.parse policy_names else policy_names
            #elb.DescribeLoadBalancerPolicies
            elb_model.DescribeLoadBalancerPolicies {sender: me}, username, session_id, region_name, elb_name, policy_names
            elb_model.once "ELB__DESC_LB_PCYS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "elb" && current_resource.toLowerCase() == "elb" && current_api == "DescribeLoadBalancerPolicyTypes"
            policy_type_names = if $("#policy_type_names").val() != "null" then $("#policy_type_names").val() else null
            policy_type_names = if policy_type_names != null and policy_type_names.indexOf("[") != -1 then JSON.parse policy_type_names else policy_type_names
            #elb.DescribeLoadBalancerPolicyTypes
            elb_model.DescribeLoadBalancerPolicyTypes {sender: me}, username, session_id, region_name, policy_type_names
            elb_model.once "ELB__DESC_LB_PCY_TYPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "elb" && current_resource.toLowerCase() == "elb" && current_api == "DescribeLoadBalancers"
            elb_names = if $("#elb_names").val() != "null" then $("#elb_names").val() else null
            elb_names = if elb_names != null and elb_names.indexOf("[") != -1 then JSON.parse elb_names else elb_names
            marker = if $("#marker").val() != "null" then $("#marker").val() else null
            marker = if marker != null and marker.indexOf("[") != -1 then JSON.parse marker else marker
            #elb.DescribeLoadBalancers
            elb_model.DescribeLoadBalancers {sender: me}, username, session_id, region_name, elb_names, marker
            elb_model.once "ELB__DESC_LBS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## IAM ##########
        if current_service.toLowerCase() == "iam" && current_resource.toLowerCase() == "iam" && current_api == "GetServerCertificate"
            servercer_name = if $("#servercer_name").val() != "null" then $("#servercer_name").val() else null
            servercer_name = if servercer_name != null and servercer_name.indexOf("[") != -1 then JSON.parse servercer_name else servercer_name
            #iam.GetServerCertificate
            iam_model.GetServerCertificate {sender: me}, username, session_id, region_name, servercer_name
            iam_model.once "IAM__GET_SERVER_CERTIFICATE_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "iam" && current_resource.toLowerCase() == "iam" && current_api == "ListServerCertificates"
            marker = if $("#marker").val() != "null" then $("#marker").val() else null
            marker = if marker != null and marker.indexOf("[") != -1 then JSON.parse marker else marker
            max_items = if $("#max_items").val() != "null" then $("#max_items").val() else null
            max_items = if max_items != null and max_items.indexOf("[") != -1 then JSON.parse max_items else max_items
            path_prefix = if $("#path_prefix").val() != "null" then $("#path_prefix").val() else null
            path_prefix = if path_prefix != null and path_prefix.indexOf("[") != -1 then JSON.parse path_prefix else path_prefix
            #iam.ListServerCertificates
            iam_model.ListServerCertificates {sender: me}, username, session_id, region_name, marker, max_items, path_prefix
            iam_model.once "IAM__LST_SERVER_CERTIFICATES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## OpsWorks ##########
        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeApps"
            app_ids = if $("#app_ids").val() != "null" then $("#app_ids").val() else null
            app_ids = if app_ids != null and app_ids.indexOf("[") != -1 then JSON.parse app_ids else app_ids
            stack_id = if $("#stack_id").val() != "null" then $("#stack_id").val() else null
            stack_id = if stack_id != null and stack_id.indexOf("[") != -1 then JSON.parse stack_id else stack_id
            #opsworks.DescribeApps
            opsworks_model.DescribeApps {sender: me}, username, session_id, region_name, app_ids, stack_id
            opsworks_model.once "OPSWORKS__DESC_APPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeStacks"
            stack_ids = if $("#stack_ids").val() != "null" then $("#stack_ids").val() else null
            stack_ids = if stack_ids != null and stack_ids.indexOf("[") != -1 then JSON.parse stack_ids else stack_ids
            #opsworks.DescribeStacks
            opsworks_model.DescribeStacks {sender: me}, username, session_id, region_name, stack_ids
            opsworks_model.once "OPSWORKS__DESC_STACKS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeCommands"
            command_ids = if $("#command_ids").val() != "null" then $("#command_ids").val() else null
            command_ids = if command_ids != null and command_ids.indexOf("[") != -1 then JSON.parse command_ids else command_ids
            deployment_id = if $("#deployment_id").val() != "null" then $("#deployment_id").val() else null
            deployment_id = if deployment_id != null and deployment_id.indexOf("[") != -1 then JSON.parse deployment_id else deployment_id
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            #opsworks.DescribeCommands
            opsworks_model.DescribeCommands {sender: me}, username, session_id, region_name, command_ids, deployment_id, instance_id
            opsworks_model.once "OPSWORKS__DESC_COMMANDS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeDeployments"
            app_id = if $("#app_id").val() != "null" then $("#app_id").val() else null
            app_id = if app_id != null and app_id.indexOf("[") != -1 then JSON.parse app_id else app_id
            deployment_ids = if $("#deployment_ids").val() != "null" then $("#deployment_ids").val() else null
            deployment_ids = if deployment_ids != null and deployment_ids.indexOf("[") != -1 then JSON.parse deployment_ids else deployment_ids
            stack_id = if $("#stack_id").val() != "null" then $("#stack_id").val() else null
            stack_id = if stack_id != null and stack_id.indexOf("[") != -1 then JSON.parse stack_id else stack_id
            #opsworks.DescribeDeployments
            opsworks_model.DescribeDeployments {sender: me}, username, session_id, region_name, app_id, deployment_ids, stack_id
            opsworks_model.once "OPSWORKS__DESC_DEPLOYMENTS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeElasticIps"
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            ips = if $("#ips").val() != "null" then $("#ips").val() else null
            ips = if ips != null and ips.indexOf("[") != -1 then JSON.parse ips else ips
            #opsworks.DescribeElasticIps
            opsworks_model.DescribeElasticIps {sender: me}, username, session_id, region_name, instance_id, ips
            opsworks_model.once "OPSWORKS__DESC_ELASTIC_IPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeInstances"
            app_id = if $("#app_id").val() != "null" then $("#app_id").val() else null
            app_id = if app_id != null and app_id.indexOf("[") != -1 then JSON.parse app_id else app_id
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            layer_id = if $("#layer_id").val() != "null" then $("#layer_id").val() else null
            layer_id = if layer_id != null and layer_id.indexOf("[") != -1 then JSON.parse layer_id else layer_id
            stack_id = if $("#stack_id").val() != "null" then $("#stack_id").val() else null
            stack_id = if stack_id != null and stack_id.indexOf("[") != -1 then JSON.parse stack_id else stack_id
            #opsworks.DescribeInstances
            opsworks_model.DescribeInstances {sender: me}, username, session_id, region_name, app_id, instance_ids, layer_id, stack_id
            opsworks_model.once "OPSWORKS__DESC_INSS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeLayers"
            stack_id = if $("#stack_id").val() != "null" then $("#stack_id").val() else null
            stack_id = if stack_id != null and stack_id.indexOf("[") != -1 then JSON.parse stack_id else stack_id
            layer_ids = if $("#layer_ids").val() != "null" then $("#layer_ids").val() else null
            layer_ids = if layer_ids != null and layer_ids.indexOf("[") != -1 then JSON.parse layer_ids else layer_ids
            #opsworks.DescribeLayers
            opsworks_model.DescribeLayers {sender: me}, username, session_id, region_name, stack_id, layer_ids
            opsworks_model.once "OPSWORKS__DESC_LAYERS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeLoadBasedAutoScaling"
            layer_ids = if $("#layer_ids").val() != "null" then $("#layer_ids").val() else null
            layer_ids = if layer_ids != null and layer_ids.indexOf("[") != -1 then JSON.parse layer_ids else layer_ids
            #opsworks.DescribeLoadBasedAutoScaling
            opsworks_model.DescribeLoadBasedAutoScaling {sender: me}, username, session_id, region_name, layer_ids
            opsworks_model.once "OPSWORKS__DESC_LOAD_BASED_ASL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribePermissions"
            iam_user_arn = if $("#iam_user_arn").val() != "null" then $("#iam_user_arn").val() else null
            iam_user_arn = if iam_user_arn != null and iam_user_arn.indexOf("[") != -1 then JSON.parse iam_user_arn else iam_user_arn
            stack_id = if $("#stack_id").val() != "null" then $("#stack_id").val() else null
            stack_id = if stack_id != null and stack_id.indexOf("[") != -1 then JSON.parse stack_id else stack_id
            #opsworks.DescribePermissions
            opsworks_model.DescribePermissions {sender: me}, username, session_id, region_name, iam_user_arn, stack_id
            opsworks_model.once "OPSWORKS__DESC_PERMISSIONS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeRaidArrays"
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            raid_array_ids = if $("#raid_array_ids").val() != "null" then $("#raid_array_ids").val() else null
            raid_array_ids = if raid_array_ids != null and raid_array_ids.indexOf("[") != -1 then JSON.parse raid_array_ids else raid_array_ids
            #opsworks.DescribeRaidArrays
            opsworks_model.DescribeRaidArrays {sender: me}, username, session_id, region_name, instance_id, raid_array_ids
            opsworks_model.once "OPSWORKS__DESC_RAID_ARRAYS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeServiceErrors"
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            service_error_ids = if $("#service_error_ids").val() != "null" then $("#service_error_ids").val() else null
            service_error_ids = if service_error_ids != null and service_error_ids.indexOf("[") != -1 then JSON.parse service_error_ids else service_error_ids
            stack_id = if $("#stack_id").val() != "null" then $("#stack_id").val() else null
            stack_id = if stack_id != null and stack_id.indexOf("[") != -1 then JSON.parse stack_id else stack_id
            #opsworks.DescribeServiceErrors
            opsworks_model.DescribeServiceErrors {sender: me}, username, session_id, region_name, instance_id, service_error_ids, stack_id
            opsworks_model.once "OPSWORKS__DESC_SERVICE_ERRORS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeTimeBasedAutoScaling"
            instance_ids = if $("#instance_ids").val() != "null" then $("#instance_ids").val() else null
            instance_ids = if instance_ids != null and instance_ids.indexOf("[") != -1 then JSON.parse instance_ids else instance_ids
            #opsworks.DescribeTimeBasedAutoScaling
            opsworks_model.DescribeTimeBasedAutoScaling {sender: me}, username, session_id, region_name, instance_ids
            opsworks_model.once "OPSWORKS__DESC_TIME_BASED_ASL_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeUserProfiles"
            iam_user_arns = if $("#iam_user_arns").val() != "null" then $("#iam_user_arns").val() else null
            iam_user_arns = if iam_user_arns != null and iam_user_arns.indexOf("[") != -1 then JSON.parse iam_user_arns else iam_user_arns
            #opsworks.DescribeUserProfiles
            opsworks_model.DescribeUserProfiles {sender: me}, username, session_id, region_name, iam_user_arns
            opsworks_model.once "OPSWORKS__DESC_USER_PROFILES_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "opsworks" && current_resource.toLowerCase() == "opsworks" && current_api == "DescribeVolumes"
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            raid_array_id = if $("#raid_array_id").val() != "null" then $("#raid_array_id").val() else null
            raid_array_id = if raid_array_id != null and raid_array_id.indexOf("[") != -1 then JSON.parse raid_array_id else raid_array_id
            volume_ids = if $("#volume_ids").val() != "null" then $("#volume_ids").val() else null
            volume_ids = if volume_ids != null and volume_ids.indexOf("[") != -1 then JSON.parse volume_ids else volume_ids
            #opsworks.DescribeVolumes
            opsworks_model.DescribeVolumes {sender: me}, username, session_id, region_name, instance_id, raid_array_id, volume_ids
            opsworks_model.once "OPSWORKS__DESC_VOLS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Instance ##########
        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "instance" && current_api == "DescribeDBInstances"
            instance_id = if $("#instance_id").val() != "null" then $("#instance_id").val() else null
            instance_id = if instance_id != null and instance_id.indexOf("[") != -1 then JSON.parse instance_id else instance_id
            marker = if $("#marker").val() != "null" then $("#marker").val() else null
            marker = if marker != null and marker.indexOf("[") != -1 then JSON.parse marker else marker
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
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
            pg_name = if $("#pg_name").val() != "null" then $("#pg_name").val() else null
            pg_name = if pg_name != null and pg_name.indexOf("[") != -1 then JSON.parse pg_name else pg_name
            marker = if $("#marker").val() != "null" then $("#marker").val() else null
            marker = if marker != null and marker.indexOf("[") != -1 then JSON.parse marker else marker
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
            #parametergroup.DescribeDBParameterGroups
            parametergroup_model.DescribeDBParameterGroups {sender: me}, username, session_id, region_name, pg_name, marker, max_records
            parametergroup_model.once "RDS_PG_DESC_DB_PARAM_GRPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "rds" && current_resource.toLowerCase() == "parametergroup" && current_api == "DescribeDBParameters"
            pg_name = if $("#pg_name").val() != "null" then $("#pg_name").val() else null
            pg_name = if pg_name != null and pg_name.indexOf("[") != -1 then JSON.parse pg_name else pg_name
            source = if $("#source").val() != "null" then $("#source").val() else null
            source = if source != null and source.indexOf("[") != -1 then JSON.parse source else source
            marker = if $("#marker").val() != "null" then $("#marker").val() else null
            marker = if marker != null and marker.indexOf("[") != -1 then JSON.parse marker else marker
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
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
            pg_family = if $("#pg_family").val() != "null" then $("#pg_family").val() else null
            pg_family = if pg_family != null and pg_family.indexOf("[") != -1 then JSON.parse pg_family else pg_family
            marker = if $("#marker").val() != "null" then $("#marker").val() else null
            marker = if marker != null and marker.indexOf("[") != -1 then JSON.parse marker else marker
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
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
            sg_name = if $("#sg_name").val() != "null" then $("#sg_name").val() else null
            sg_name = if sg_name != null and sg_name.indexOf("[") != -1 then JSON.parse sg_name else sg_name
            marker = if $("#marker").val() != "null" then $("#marker").val() else null
            marker = if marker != null and marker.indexOf("[") != -1 then JSON.parse marker else marker
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
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
            sg_name = if $("#sg_name").val() != "null" then $("#sg_name").val() else null
            sg_name = if sg_name != null and sg_name.indexOf("[") != -1 then JSON.parse sg_name else sg_name
            marker = if $("#marker").val() != "null" then $("#marker").val() else null
            marker = if marker != null and marker.indexOf("[") != -1 then JSON.parse marker else marker
            max_records = if $("#max_records").val() != "null" then $("#max_records").val() else null
            max_records = if max_records != null and max_records.indexOf("[") != -1 then JSON.parse max_records else max_records
            #subnetgroup.DescribeDBSubnetGroups
            subnetgroup_model.DescribeDBSubnetGroups {sender: me}, username, session_id, region_name, sg_name, marker, max_records
            subnetgroup_model.once "RDS_SNTG_DESC_DB_SNET_GRPS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## SDB ##########
        if current_service.toLowerCase() == "sdb" && current_resource.toLowerCase() == "sdb" && current_api == "DomainMetadata"
            doamin_name = if $("#doamin_name").val() != "null" then $("#doamin_name").val() else null
            doamin_name = if doamin_name != null and doamin_name.indexOf("[") != -1 then JSON.parse doamin_name else doamin_name
            #sdb.DomainMetadata
            sdb_model.DomainMetadata {sender: me}, username, session_id, region_name, doamin_name
            sdb_model.once "SDB__DOMAIN_MDATA_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "sdb" && current_resource.toLowerCase() == "sdb" && current_api == "GetAttributes"
            domain_name = if $("#domain_name").val() != "null" then $("#domain_name").val() else null
            domain_name = if domain_name != null and domain_name.indexOf("[") != -1 then JSON.parse domain_name else domain_name
            item_name = if $("#item_name").val() != "null" then $("#item_name").val() else null
            item_name = if item_name != null and item_name.indexOf("[") != -1 then JSON.parse item_name else item_name
            attribute_name = if $("#attribute_name").val() != "null" then $("#attribute_name").val() else null
            attribute_name = if attribute_name != null and attribute_name.indexOf("[") != -1 then JSON.parse attribute_name else attribute_name
            consistent_read = if $("#consistent_read").val() != "null" then $("#consistent_read").val() else null
            consistent_read = if consistent_read != null and consistent_read.indexOf("[") != -1 then JSON.parse consistent_read else consistent_read
            #sdb.GetAttributes
            sdb_model.GetAttributes {sender: me}, username, session_id, region_name, domain_name, item_name, attribute_name, consistent_read
            sdb_model.once "SDB__GET_ATTRS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "sdb" && current_resource.toLowerCase() == "sdb" && current_api == "ListDomains"
            max_domains = if $("#max_domains").val() != "null" then $("#max_domains").val() else null
            max_domains = if max_domains != null and max_domains.indexOf("[") != -1 then JSON.parse max_domains else max_domains
            next_token = if $("#next_token").val() != "null" then $("#next_token").val() else null
            next_token = if next_token != null and next_token.indexOf("[") != -1 then JSON.parse next_token else next_token
            #sdb.ListDomains
            sdb_model.ListDomains {sender: me}, username, session_id, region_name, max_domains, next_token
            sdb_model.once "SDB__LST_DOMAINS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ACL ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "acl" && current_api == "DescribeNetworkAcls"
            acl_ids = if $("#acl_ids").val() != "null" then $("#acl_ids").val() else null
            acl_ids = if acl_ids != null and acl_ids.indexOf("[") != -1 then JSON.parse acl_ids else acl_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #acl.DescribeNetworkAcls
            acl_model.DescribeNetworkAcls {sender: me}, username, session_id, region_name, acl_ids, filters
            acl_model.once "VPC_ACL_DESC_NET_ACLS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## CustomerGateway ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "customergateway" && current_api == "DescribeCustomerGateways"
            gw_ids = if $("#gw_ids").val() != "null" then $("#gw_ids").val() else null
            gw_ids = if gw_ids != null and gw_ids.indexOf("[") != -1 then JSON.parse gw_ids else gw_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #customergateway.DescribeCustomerGateways
            customergateway_model.DescribeCustomerGateways {sender: me}, username, session_id, region_name, gw_ids, filters
            customergateway_model.once "VPC_CGW_DESC_CUST_GWS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## DHCP ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "dhcp" && current_api == "DescribeDhcpOptions"
            dhcp_ids = if $("#dhcp_ids").val() != "null" then $("#dhcp_ids").val() else null
            dhcp_ids = if dhcp_ids != null and dhcp_ids.indexOf("[") != -1 then JSON.parse dhcp_ids else dhcp_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #dhcp.DescribeDhcpOptions
            dhcp_model.DescribeDhcpOptions {sender: me}, username, session_id, region_name, dhcp_ids, filters
            dhcp_model.once "VPC_DHCP_DESC_DHCP_OPTS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## ENI ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "eni" && current_api == "DescribeNetworkInterfaces"
            eni_ids = if $("#eni_ids").val() != "null" then $("#eni_ids").val() else null
            eni_ids = if eni_ids != null and eni_ids.indexOf("[") != -1 then JSON.parse eni_ids else eni_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #eni.DescribeNetworkInterfaces
            eni_model.DescribeNetworkInterfaces {sender: me}, username, session_id, region_name, eni_ids, filters
            eni_model.once "VPC_ENI_DESC_NET_IFS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "eni" && current_api == "DescribeNetworkInterfaceAttribute"
            eni_id = if $("#eni_id").val() != "null" then $("#eni_id").val() else null
            eni_id = if eni_id != null and eni_id.indexOf("[") != -1 then JSON.parse eni_id else eni_id
            attribute = if $("#attribute").val() != "null" then $("#attribute").val() else null
            attribute = if attribute != null and attribute.indexOf("[") != -1 then JSON.parse attribute else attribute
            #eni.DescribeNetworkInterfaceAttribute
            eni_model.DescribeNetworkInterfaceAttribute {sender: me}, username, session_id, region_name, eni_id, attribute
            eni_model.once "VPC_ENI_DESC_NET_IF_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## InternetGateway ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "internetgateway" && current_api == "DescribeInternetGateways"
            gw_ids = if $("#gw_ids").val() != "null" then $("#gw_ids").val() else null
            gw_ids = if gw_ids != null and gw_ids.indexOf("[") != -1 then JSON.parse gw_ids else gw_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #internetgateway.DescribeInternetGateways
            internetgateway_model.DescribeInternetGateways {sender: me}, username, session_id, region_name, gw_ids, filters
            internetgateway_model.once "VPC_IGW_DESC_INET_GWS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## RouteTable ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "routetable" && current_api == "DescribeRouteTables"
            rt_ids = if $("#rt_ids").val() != "null" then $("#rt_ids").val() else null
            rt_ids = if rt_ids != null and rt_ids.indexOf("[") != -1 then JSON.parse rt_ids else rt_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #routetable.DescribeRouteTables
            routetable_model.DescribeRouteTables {sender: me}, username, session_id, region_name, rt_ids, filters
            routetable_model.once "VPC_RT_DESC_RT_TBLS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## Subnet ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "subnet" && current_api == "DescribeSubnets"
            subnet_ids = if $("#subnet_ids").val() != "null" then $("#subnet_ids").val() else null
            subnet_ids = if subnet_ids != null and subnet_ids.indexOf("[") != -1 then JSON.parse subnet_ids else subnet_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #subnet.DescribeSubnets
            subnet_model.DescribeSubnets {sender: me}, username, session_id, region_name, subnet_ids, filters
            subnet_model.once "VPC_SNET_DESC_SUBNETS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## VPC ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "vpc" && current_api == "DescribeVpcs"
            vpc_ids = if $("#vpc_ids").val() != "null" then $("#vpc_ids").val() else null
            vpc_ids = if vpc_ids != null and vpc_ids.indexOf("[") != -1 then JSON.parse vpc_ids else vpc_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #vpc.DescribeVpcs
            vpc_model.DescribeVpcs {sender: me}, username, session_id, region_name, vpc_ids, filters
            vpc_model.once "VPC_VPC_DESC_VPCS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "vpc" && current_api == "DescribeAccountAttributes"
            attribute_name = if $("#attribute_name").val() != "null" then $("#attribute_name").val() else null
            attribute_name = if attribute_name != null and attribute_name.indexOf("[") != -1 then JSON.parse attribute_name else attribute_name
            #vpc.DescribeAccountAttributes
            vpc_model.DescribeAccountAttributes {sender: me}, username, session_id, region_name, attribute_name
            vpc_model.once "VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "vpc" && current_api == "DescribeVpcAttribute"
            vpc_id = if $("#vpc_id").val() != "null" then $("#vpc_id").val() else null
            vpc_id = if vpc_id != null and vpc_id.indexOf("[") != -1 then JSON.parse vpc_id else vpc_id
            attribute = if $("#attribute").val() != "null" then $("#attribute").val() else null
            attribute = if attribute != null and attribute.indexOf("[") != -1 then JSON.parse attribute else attribute
            #vpc.DescribeVpcAttribute
            vpc_model.DescribeVpcAttribute {sender: me}, username, session_id, region_name, vpc_id, attribute
            vpc_model.once "VPC_VPC_DESC_VPC_ATTR_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## VPNGateway ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "vpngateway" && current_api == "DescribeVpnGateways"
            gw_ids = if $("#gw_ids").val() != "null" then $("#gw_ids").val() else null
            gw_ids = if gw_ids != null and gw_ids.indexOf("[") != -1 then JSON.parse gw_ids else gw_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
            #vpngateway.DescribeVpnGateways
            vpngateway_model.DescribeVpnGateways {sender: me}, username, session_id, region_name, gw_ids, filters
            vpngateway_model.once "VPC_VGW_DESC_VPN_GWS_RETURN", ( aws_result ) ->
                resolveResult request_time, current_service, current_resource, current_api, aws_result

        ########## VPN ##########
        if current_service.toLowerCase() == "vpc" && current_resource.toLowerCase() == "vpn" && current_api == "DescribeVpnConnections"
            vpn_ids = if $("#vpn_ids").val() != "null" then $("#vpn_ids").val() else null
            vpn_ids = if vpn_ids != null and vpn_ids.indexOf("[") != -1 then JSON.parse vpn_ids else vpn_ids
            filters = if $("#filters").val() != "null" then $("#filters").val() else null
            filters = if filters != null and filters.indexOf("[") != -1 then JSON.parse filters else filters
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


