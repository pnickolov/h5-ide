#*************************************************************************************
#* Filename     : session_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-29 13:27:31
#* Description  : qunit test module for session_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service'], ( MC, $, test_util, session_service ) ->

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
    #session test
    ################################################
    module "Module session - session"
    #-----------------------------------------------
    #Test logout()
    #-----------------------------------------------
    test_logout = () ->
        asyncTest "/session session.logout()", () ->


            session_service.logout username, session_id, ( forge_result ) ->
                if !forge_result.is_error
                #logout succeed
                    data = forge_result.resolved_data
                    ok true, "logout() succeed"
                else
                #logout failed
                    ok false, "logout() failed" + forge_result.error_message
            
                start()
                test_login()

    #-----------------------------------------------
    #Test set_credential()
    #-----------------------------------------------
    test_set_credential = () ->
        asyncTest "/session session.set_credential()", () ->
            access_key = null
            secret_key = null
            account_id = null

            session_service.set_credential username, session_id, access_key, secret_key, account_id, ( forge_result ) ->
                if !forge_result.is_error
                #set_credential succeed
                    data = forge_result.resolved_data
                    ok true, "set_credential() succeed"
                else
                #set_credential failed
                    ok false, "set_credential() failed" + forge_result.error_message
            
                start()
                test_logout()

    #-----------------------------------------------
    #Test guest()
    #-----------------------------------------------
    test_guest = () ->
        asyncTest "/session session.guest()", () ->
            guest_id = null
            guestname = null

            session_service.guest guest_id, guestname, ( forge_result ) ->
                if !forge_result.is_error
                #guest succeed
                    data = forge_result.resolved_data
                    ok true, "guest() succeed"
                else
                #guest failed
                    ok false, "guest() failed" + forge_result.error_message
            
                start()
                test_set_credential()


    test_guest()

