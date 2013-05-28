#*************************************************************************************
#* Filename     : request_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 15:59:02
#* Description  : qunit test module for request_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'request_service'], ( MC, $, test_util, session_service, request_service ) ->

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
    #request test
    ################################################
    module "Module request - request"
    #-----------------------------------------------
    #Test init()
    #-----------------------------------------------
    test_init = () ->
        asyncTest "/request request.init()", () ->


            request_service.init username, session_id, region_name, ( forge_result ) ->
                if !forge_result.is_error
                #init succeed
                    data = forge_result.resolved_data
                    ok true, "init() succeed"
                else
                #init failed
                    ok false, "init() failed" + forge_result.error_message
            
                start()
                

    #-----------------------------------------------
    #Test update()
    #-----------------------------------------------
    test_update = () ->
        asyncTest "/request request.update()", () ->
            timestamp = null

            request_service.update username, session_id, region_name, timestamp, ( forge_result ) ->
                if !forge_result.is_error
                #update succeed
                    data = forge_result.resolved_data
                    ok true, "update() succeed"
                else
                #update failed
                    ok false, "update() failed" + forge_result.error_message
            
                start()
                test_init()


    test_update()

