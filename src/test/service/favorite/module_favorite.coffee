#*************************************************************************************
#* Filename     : favorite_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 17:14:59
#* Description  : qunit test module for favorite_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'favorite_service'], ( MC, $, test_util, session_service, favorite_service ) ->

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
        session_service.login {sender:this}, username, password, ( forge_result ) ->
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
    #favorite test
    ################################################
    module "Module favorite - favorite"
    #-----------------------------------------------
    #Test add()
    #-----------------------------------------------
    test_add = () ->
        asyncTest "/favorite favorite.add()", () ->
            resource = null

            favorite_service.add {sender:this}, username, session_id, region_name, resource, ( forge_result ) ->
                if !forge_result.is_error
                #add succeed
                    data = forge_result.resolved_data
                    ok true, "add() succeed"
                else
                #add failed
                    ok false, "add() failed" + forge_result.error_message
            
                start()
                

    #-----------------------------------------------
    #Test remove()
    #-----------------------------------------------
    test_remove = () ->
        asyncTest "/favorite favorite.remove()", () ->
            resource_ids = null

            favorite_service.remove {sender:this}, username, session_id, region_name, resource_ids, ( forge_result ) ->
                if !forge_result.is_error
                #remove succeed
                    data = forge_result.resolved_data
                    ok true, "remove() succeed"
                else
                #remove failed
                    ok false, "remove() failed" + forge_result.error_message
            
                start()
                test_add()

    #-----------------------------------------------
    #Test info()
    #-----------------------------------------------
    test_info = () ->
        asyncTest "/favorite favorite.info()", () ->
            provider = null
            service = null
            resource = null

            favorite_service.info {sender:this}, username, session_id, region_name, provider, service, resource, ( forge_result ) ->
                if !forge_result.is_error
                #info succeed
                    data = forge_result.resolved_data
                    ok true, "info() succeed"
                else
                #info failed
                    ok false, "info() failed" + forge_result.error_message
            
                start()
                test_remove()


    test_info()

