#*************************************************************************************
#* Filename     : app_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 11:35:38
#* Description  : qunit test module for app_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'app_service'], ( MC, $, test_util, session_service, app_service ) ->

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
    #app test
    ################################################
    module "Module app - app"
    #-----------------------------------------------
    #Test create()
    #-----------------------------------------------
    test_create = () ->
        asyncTest "/app app.create()", () ->
            spec = null

            app_service.create username, session_id, region_name, spec, ( forge_result ) ->
                if !forge_result.is_error
                #create succeed
                    data = forge_result.resolved_data
                    ok true, "create() succeed"
                else
                #create failed
                    ok false, "create() failed" + forge_result.error_message
            
                start()
                

    #-----------------------------------------------
    #Test update()
    #-----------------------------------------------
    test_update = () ->
        asyncTest "/app app.update()", () ->
            spec = null
            app_id = null

            app_service.update username, session_id, region_name, spec, app_id, ( forge_result ) ->
                if !forge_result.is_error
                #update succeed
                    data = forge_result.resolved_data
                    ok true, "update() succeed"
                else
                #update failed
                    ok false, "update() failed" + forge_result.error_message
            
                start()
                test_create()

    #-----------------------------------------------
    #Test rename()
    #-----------------------------------------------
    test_rename = () ->
        asyncTest "/app app.rename()", () ->
            app_id = null
            new_name = null
            app_name = null

            app_service.rename username, session_id, region_name, app_id, new_name, app_name, ( forge_result ) ->
                if !forge_result.is_error
                #rename succeed
                    data = forge_result.resolved_data
                    ok true, "rename() succeed"
                else
                #rename failed
                    ok false, "rename() failed" + forge_result.error_message
            
                start()
                test_update()

    #-----------------------------------------------
    #Test terminate()
    #-----------------------------------------------
    test_terminate = () ->
        asyncTest "/app app.terminate()", () ->
            app_id = null
            app_name = null

            app_service.terminate username, session_id, region_name, app_id, app_name, ( forge_result ) ->
                if !forge_result.is_error
                #terminate succeed
                    data = forge_result.resolved_data
                    ok true, "terminate() succeed"
                else
                #terminate failed
                    ok false, "terminate() failed" + forge_result.error_message
            
                start()
                test_rename()

    #-----------------------------------------------
    #Test start()
    #-----------------------------------------------
    test_start = () ->
        asyncTest "/app app.start()", () ->
            app_id = null
            app_name = null

            app_service.start username, session_id, region_name, app_id, app_name, ( forge_result ) ->
                if !forge_result.is_error
                #start succeed
                    data = forge_result.resolved_data
                    ok true, "start() succeed"
                else
                #start failed
                    ok false, "start() failed" + forge_result.error_message
            
                start()
                test_terminate()

    #-----------------------------------------------
    #Test stop()
    #-----------------------------------------------
    test_stop = () ->
        asyncTest "/app app.stop()", () ->
            app_id = null
            app_name = null

            app_service.stop username, session_id, region_name, app_id, app_name, ( forge_result ) ->
                if !forge_result.is_error
                #stop succeed
                    data = forge_result.resolved_data
                    ok true, "stop() succeed"
                else
                #stop failed
                    ok false, "stop() failed" + forge_result.error_message
            
                start()
                test_start()

    #-----------------------------------------------
    #Test reboot()
    #-----------------------------------------------
    test_reboot = () ->
        asyncTest "/app app.reboot()", () ->
            app_id = null
            app_name = null

            app_service.reboot username, session_id, region_name, app_id, app_name, ( forge_result ) ->
                if !forge_result.is_error
                #reboot succeed
                    data = forge_result.resolved_data
                    ok true, "reboot() succeed"
                else
                #reboot failed
                    ok false, "reboot() failed" + forge_result.error_message
            
                start()
                test_stop()

    #-----------------------------------------------
    #Test info()
    #-----------------------------------------------
    test_info = () ->
        asyncTest "/app app.info()", () ->
            app_ids = null

            app_service.info username, session_id, region_name, app_ids, ( forge_result ) ->
                if !forge_result.is_error
                #info succeed
                    data = forge_result.resolved_data
                    ok true, "info() succeed"
                else
                #info failed
                    ok false, "info() failed" + forge_result.error_message
            
                start()
                test_reboot()

    #-----------------------------------------------
    #Test resource()
    #-----------------------------------------------
    test_resource = () ->
        asyncTest "/app app.resource()", () ->
            app_id = null

            app_service.resource username, session_id, region_name, app_id, ( forge_result ) ->
                if !forge_result.is_error
                #resource succeed
                    data = forge_result.resolved_data
                    ok true, "resource() succeed"
                else
                #resource failed
                    ok false, "resource() failed" + forge_result.error_message
            
                start()
                test_info()

    #-----------------------------------------------
    #Test summary()
    #-----------------------------------------------
    test_summary = () ->
        asyncTest "/app app.summary()", () ->


            app_service.summary username, session_id, region_name, ( forge_result ) ->
                if !forge_result.is_error
                #summary succeed
                    data = forge_result.resolved_data
                    ok true, "summary() succeed"
                else
                #summary failed
                    ok false, "summary() failed" + forge_result.error_message
            
                start()
                test_resource()


    test_summary()

