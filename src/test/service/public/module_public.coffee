#*************************************************************************************
#* Filename     : public_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:58
#* Description  : qunit test module for public_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'public_service'], ( MC, $, test_util, session_service, public_service ) ->

    #test user
    username    = test_util.username
    password    = test_util.password

    #session info
    session_id  = ""
    usercode    = ""
    region_name = ""

    can_test    = false

    test "Check test user", () ->
        if username == "" or password == ""
            ok false, "please set the username and password first(/test/service/test_util), then try again"
        else
            ok true, "passwd"
            can_test = true

    if !can_test
        return false


    ################################################
    #session login
    ################################################
    module "Module Session"

    asyncTest "session.login", () ->
        session_service.login username, password, ( forge_result ) ->
            if !forge_result.is_error
            #login succeed
                session_info = forge_result.resolved_data
                session_id   = session_info.session_id
                usercode     = session_info.usercode
                region_name  = session_info.region_name
                ok true, "login succeed" + "( usercode : " + usercode + " , region_name : " + region_name + " , session_id : " + session_id + ")"
                username = usercode
                start()
            else
            #login failed
                ok false, "login failed, error is " + forge_result.error_message + ", cancel the follow-up test!"
                start()



    ################################################
    #public test
    ################################################
    module "Module public - public"
    #-----------------------------------------------
    #Test get_hostname()
    #-----------------------------------------------
    asyncTest "/public public.get_hostname()", () ->
        
        instance_id = null

        public_service.get_hostname region_name, instance_id, ( forge_result ) ->
            if !forge_result.is_error
            #get_hostname succeed
                data = forge_result.resolved_data
                ok true, "get_hostname() succeed"
                start()
            else
            #get_hostname failed
                ok false, "get_hostname() failed" + forge_result.error_message
                start()

    #-----------------------------------------------
    #Test get_dns_ip()
    #-----------------------------------------------
    asyncTest "/public public.get_dns_ip()", () ->
        

        public_service.get_dns_ip region_name, ( forge_result ) ->
            if !forge_result.is_error
            #get_dns_ip succeed
                data = forge_result.resolved_data
                ok true, "get_dns_ip() succeed"
                start()
            else
            #get_dns_ip failed
                ok false, "get_dns_ip() failed" + forge_result.error_message
                start()

