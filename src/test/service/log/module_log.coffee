#*************************************************************************************
#* Filename     : log_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 11:35:36
#* Description  : qunit test module for log_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'log_service'], ( MC, $, test_util, session_service, log_service ) ->

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
    #log test
    ################################################
    module "Module log - log"
    #-----------------------------------------------
    #Test put_user_log()
    #-----------------------------------------------
    test_put_user_log = () ->
        asyncTest "/log log.put_user_log()", () ->
            user_logs = null

            log_service.put_user_log username, session_id, user_logs, ( forge_result ) ->
                if !forge_result.is_error
                #put_user_log succeed
                    data = forge_result.resolved_data
                    ok true, "put_user_log() succeed"
                else
                #put_user_log failed
                    ok false, "put_user_log() failed" + forge_result.error_message
            
                start()
                


    test_put_user_log()

