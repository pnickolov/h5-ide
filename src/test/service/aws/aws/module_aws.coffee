#*************************************************************************************
#* Filename     : aws_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-29 13:27:36
#* Description  : qunit test module for aws_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'aws_service'], ( MC, $, test_util, session_service, aws_service ) ->

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
    #aws test
    ################################################
    module "Module aws - aws"
    #-----------------------------------------------
    #Test quickstart()
    #-----------------------------------------------
    test_quickstart = () ->
        asyncTest "/aws aws.quickstart()", () ->


            aws_service.quickstart username, session_id, region_name, ( aws_result ) ->
                if !aws_result.is_error
                #quickstart succeed
                    data = aws_result.resolved_data
                    ok true, "quickstart() succeed"
                else
                #quickstart failed
                    ok false, "quickstart() failed" + aws_result.error_message
            
                start()
                

    #-----------------------------------------------
    #Test Public()
    #-----------------------------------------------
    test_Public = () ->
        asyncTest "/aws aws.Public()", () ->


            aws_service.Public username, session_id, region_name, ( aws_result ) ->
                if !aws_result.is_error
                #Public succeed
                    data = aws_result.resolved_data
                    ok true, "Public() succeed"
                else
                #Public failed
                    ok false, "Public() failed" + aws_result.error_message
            
                start()
                test_quickstart()

    #-----------------------------------------------
    #Test info()
    #-----------------------------------------------
    test_info = () ->
        asyncTest "/aws aws.info()", () ->


            aws_service.info username, session_id, region_name, ( aws_result ) ->
                if !aws_result.is_error
                #info succeed
                    data = aws_result.resolved_data
                    ok true, "info() succeed"
                else
                #info failed
                    ok false, "info() failed" + aws_result.error_message
            
                start()
                test_Public()

    #-----------------------------------------------
    #Test resource()
    #-----------------------------------------------
    test_resource = () ->
        asyncTest "/aws aws.resource()", () ->
            resources = null

            aws_service.resource username, session_id, region_name, resources, ( aws_result ) ->
                if !aws_result.is_error
                #resource succeed
                    data = aws_result.resolved_data
                    ok true, "resource() succeed"
                else
                #resource failed
                    ok false, "resource() failed" + aws_result.error_message
            
                start()
                test_info()

    #-----------------------------------------------
    #Test price()
    #-----------------------------------------------
    test_price = () ->
        asyncTest "/aws aws.price()", () ->


            aws_service.price username, session_id, ( aws_result ) ->
                if !aws_result.is_error
                #price succeed
                    data = aws_result.resolved_data
                    ok true, "price() succeed"
                else
                #price failed
                    ok false, "price() failed" + aws_result.error_message
            
                start()
                test_resource()

    #-----------------------------------------------
    #Test status()
    #-----------------------------------------------
    test_status = () ->
        asyncTest "/aws aws.status()", () ->


            aws_service.status username, session_id, ( aws_result ) ->
                if !aws_result.is_error
                #status succeed
                    data = aws_result.resolved_data
                    ok true, "status() succeed"
                else
                #status failed
                    ok false, "status() failed" + aws_result.error_message
            
                start()
                test_price()


    test_status()

