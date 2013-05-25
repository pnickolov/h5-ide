#*************************************************************************************
#* Filename     : guest_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:01
#* Description  : qunit test module for guest_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'guest_service'], ( MC, $, test_util, session_service, guest_service ) ->

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
    #guest test
    ################################################
    module "Module guest - guest"
    #-----------------------------------------------
    #Test invite()
    #-----------------------------------------------
    asyncTest "/guest guest.invite()", () ->
        

        guest_service.invite username, session_id, region_name, ( forge_result ) ->
            if !forge_result.is_error
            #invite succeed
                data = forge_result.resolved_data
                ok true, "invite() succeed"
                start()
            else
            #invite failed
                ok false, "invite() failed" + forge_result.error_message
                start()

    #-----------------------------------------------
    #Test cancel()
    #-----------------------------------------------
    asyncTest "/guest guest.cancel()", () ->
        
        guest_id = null

        guest_service.cancel username, session_id, region_name, guest_id, ( forge_result ) ->
            if !forge_result.is_error
            #cancel succeed
                data = forge_result.resolved_data
                ok true, "cancel() succeed"
                start()
            else
            #cancel failed
                ok false, "cancel() failed" + forge_result.error_message
                start()

    #-----------------------------------------------
    #Test access()
    #-----------------------------------------------
    asyncTest "/guest guest.access()", () ->
                guestname = null
        guest_id = null

        guest_service.access guestname, session_id, region_name, guest_id, ( forge_result ) ->
            if !forge_result.is_error
            #access succeed
                data = forge_result.resolved_data
                ok true, "access() succeed"
                start()
            else
            #access failed
                ok false, "access() failed" + forge_result.error_message
                start()

    #-----------------------------------------------
    #Test end()
    #-----------------------------------------------
    asyncTest "/guest guest.end()", () ->
                guestname = null
        guest_id = null

        guest_service.end guestname, session_id, region_name, guest_id, ( forge_result ) ->
            if !forge_result.is_error
            #end succeed
                data = forge_result.resolved_data
                ok true, "end() succeed"
                start()
            else
            #end failed
                ok false, "end() failed" + forge_result.error_message
                start()

    #-----------------------------------------------
    #Test info()
    #-----------------------------------------------
    asyncTest "/guest guest.info()", () ->
        
        guest_id = null

        guest_service.info username, session_id, region_name, guest_id, ( forge_result ) ->
            if !forge_result.is_error
            #info succeed
                data = forge_result.resolved_data
                ok true, "info() succeed"
                start()
            else
            #info failed
                ok false, "info() failed" + forge_result.error_message
                start()

