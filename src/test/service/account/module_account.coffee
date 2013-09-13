#*************************************************************************************
#* Filename     : account_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-09-13 09:00:21
#* Description  : qunit test module for account_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'account_service'], ( MC, $, test_util, session_service, account_service ) ->

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
    #account test
    ################################################
    module "Module account - account"
    #-----------------------------------------------
    #Test register()
    #-----------------------------------------------
    test_register = () ->
        asyncTest "/account account.register()", () ->
            password = null
            email = null

            account_service.register {sender:this}, username, password, email, ( forge_result ) ->
                if !forge_result.is_error
                #register succeed
                    data = forge_result.resolved_data
                    ok true, "register() succeed"
                else
                #register failed
                    ok false, "register() failed" + forge_result.error_message

                start()


    #-----------------------------------------------
    #Test update_account()
    #-----------------------------------------------
    test_update_account = () ->
        asyncTest "/account account.update_account()", () ->
            attributes = null

            account_service.update_account {sender:this}, username, session_id, attributes, ( forge_result ) ->
                if !forge_result.is_error
                #update_account succeed
                    data = forge_result.resolved_data
                    ok true, "update_account() succeed"
                else
                #update_account failed
                    ok false, "update_account() failed" + forge_result.error_message

                start()
                test_register()

    #-----------------------------------------------
    #Test reset_password()
    #-----------------------------------------------
    test_reset_password = () ->
        asyncTest "/account account.reset_password()", () ->


            account_service.reset_password {sender:this}, username, ( forge_result ) ->
                if !forge_result.is_error
                #reset_password succeed
                    data = forge_result.resolved_data
                    ok true, "reset_password() succeed"
                else
                #reset_password failed
                    ok false, "reset_password() failed" + forge_result.error_message

                start()
                test_update_account()

    #-----------------------------------------------
    #Test update_password()
    #-----------------------------------------------
    test_update_password = () ->
        asyncTest "/account account.update_password()", () ->
            id = null
            new_pwd = null

            account_service.update_password {sender:this}, id, new_pwd, ( forge_result ) ->
                if !forge_result.is_error
                #update_password succeed
                    data = forge_result.resolved_data
                    ok true, "update_password() succeed"
                else
                #update_password failed
                    ok false, "update_password() failed" + forge_result.error_message

                start()
                test_reset_password()

    #-----------------------------------------------
    #Test check_repeat()
    #-----------------------------------------------
    test_check_repeat = () ->
        asyncTest "/account account.check_repeat()", () ->
            email = null

            account_service.check_repeat {sender:this}, username, email, ( forge_result ) ->
                if !forge_result.is_error
                #check_repeat succeed
                    data = forge_result.resolved_data
                    ok true, "check_repeat() succeed"
                else
                #check_repeat failed
                    ok false, "check_repeat() failed" + forge_result.error_message

                start()
                test_update_password()

    #-----------------------------------------------
    #Test check_validation()
    #-----------------------------------------------
    test_check_validation = () ->
        asyncTest "/account account.check_validation()", () ->
            key = null
            flag = null

            account_service.check_validation {sender:this}, key, flag, ( forge_result ) ->
                if !forge_result.is_error
                #check_validation succeed
                    data = forge_result.resolved_data
                    ok true, "check_validation() succeed"
                else
                #check_validation failed
                    ok false, "check_validation() failed" + forge_result.error_message

                start()
                test_check_repeat()


    test_check_validation()

