#*************************************************************************************
#* Filename     : iam_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-29 13:27:44
#* Description  : qunit test module for iam_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'iam_service'], ( MC, $, test_util, session_service, iam_service ) ->

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
    #aws/iam test
    ################################################
    module "Module aws/iam - iam"
    #-----------------------------------------------
    #Test GetServerCertificate()
    #-----------------------------------------------
    test_GetServerCertificate = () ->
        asyncTest "/aws/iam iam.GetServerCertificate()", () ->
            servercer_name = null

            iam_service.GetServerCertificate username, session_id, region_name, servercer_name, ( aws_result ) ->
                if !aws_result.is_error
                #GetServerCertificate succeed
                    data = aws_result.resolved_data
                    ok true, "GetServerCertificate() succeed"
                else
                #GetServerCertificate failed
                    ok false, "GetServerCertificate() failed" + aws_result.error_message
            
                start()
                

    #-----------------------------------------------
    #Test ListServerCertificates()
    #-----------------------------------------------
    test_ListServerCertificates = () ->
        asyncTest "/aws/iam iam.ListServerCertificates()", () ->
            marker = null
            max_items = null
            path_prefix = null

            iam_service.ListServerCertificates username, session_id, region_name, marker, max_items, path_prefix, ( aws_result ) ->
                if !aws_result.is_error
                #ListServerCertificates succeed
                    data = aws_result.resolved_data
                    ok true, "ListServerCertificates() succeed"
                else
                #ListServerCertificates failed
                    ok false, "ListServerCertificates() failed" + aws_result.error_message
            
                start()
                test_GetServerCertificate()


    test_ListServerCertificates()

