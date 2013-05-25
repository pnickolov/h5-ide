#*************************************************************************************
#* Filename     : stack_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:02
#* Description  : qunit test module for stack_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'stack_service'], ( MC, $, test_util, session_service, stack_service ) ->

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
    #stack test
    ################################################
    module "Module stack - stack"
    #-----------------------------------------------
    #Test create()
    #-----------------------------------------------
    asyncTest "/stack stack.create()", () ->
        
        spec = null

        stack_service.create username, session_id, region_name, spec, ( forge_result ) ->
            if !forge_result.is_error
            #create succeed
                data = forge_result.resolved_data
                ok true, "create() succeed"
                start()
            else
            #create failed
                ok false, "create() failed" + forge_result.error_message
                start()

    #-----------------------------------------------
    #Test remove()
    #-----------------------------------------------
    asyncTest "/stack stack.remove()", () ->
        
        stack_id = null
        stack_name = null

        stack_service.remove username, session_id, region_name, stack_id, stack_name, ( forge_result ) ->
            if !forge_result.is_error
            #remove succeed
                data = forge_result.resolved_data
                ok true, "remove() succeed"
                start()
            else
            #remove failed
                ok false, "remove() failed" + forge_result.error_message
                start()

    #-----------------------------------------------
    #Test save()
    #-----------------------------------------------
    asyncTest "/stack stack.save()", () ->
        
        spec = null

        stack_service.save username, session_id, region_name, spec, ( forge_result ) ->
            if !forge_result.is_error
            #save succeed
                data = forge_result.resolved_data
                ok true, "save() succeed"
                start()
            else
            #save failed
                ok false, "save() failed" + forge_result.error_message
                start()

    #-----------------------------------------------
    #Test rename()
    #-----------------------------------------------
    asyncTest "/stack stack.rename()", () ->
        
        stack_id = null
        new_name = null
        stack_name = null

        stack_service.rename username, session_id, region_name, stack_id, new_name, stack_name, ( forge_result ) ->
            if !forge_result.is_error
            #rename succeed
                data = forge_result.resolved_data
                ok true, "rename() succeed"
                start()
            else
            #rename failed
                ok false, "rename() failed" + forge_result.error_message
                start()

    #-----------------------------------------------
    #Test run()
    #-----------------------------------------------
    asyncTest "/stack stack.run()", () ->
        
        stack_id = null
        app_name = null
        app_desc = null
        app_component = null
        app_property = null
        app_layout = null
        stack_name = null

        stack_service.run username, session_id, region_name, stack_id, app_name, app_desc, app_component, app_property, app_layout, stack_name, ( forge_result ) ->
            if !forge_result.is_error
            #run succeed
                data = forge_result.resolved_data
                ok true, "run() succeed"
                start()
            else
            #run failed
                ok false, "run() failed" + forge_result.error_message
                start()

    #-----------------------------------------------
    #Test save_as()
    #-----------------------------------------------
    asyncTest "/stack stack.save_as()", () ->
        
        stack_id = null
        new_name = null
        stack_name = null

        stack_service.save_as username, session_id, region_name, stack_id, new_name, stack_name, ( forge_result ) ->
            if !forge_result.is_error
            #save_as succeed
                data = forge_result.resolved_data
                ok true, "save_as() succeed"
                start()
            else
            #save_as failed
                ok false, "save_as() failed" + forge_result.error_message
                start()

    #-----------------------------------------------
    #Test info()
    #-----------------------------------------------
    asyncTest "/stack stack.info()", () ->
        
        stack_ids = null

        stack_service.info username, session_id, region_name, stack_ids, ( forge_result ) ->
            if !forge_result.is_error
            #info succeed
                data = forge_result.resolved_data
                ok true, "info() succeed"
                start()
            else
            #info failed
                ok false, "info() failed" + forge_result.error_message
                start()

