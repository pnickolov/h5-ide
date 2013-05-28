#*************************************************************************************
#* Filename     : instance_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 11:35:52
#* Description  : qunit test module for instance_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'instance_service'], ( MC, $, test_util, session_service, instance_service ) ->

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
    #aws/rds test
    ################################################
    module "Module aws/rds - instance"
    #-----------------------------------------------
    #Test DescribeDBInstances()
    #-----------------------------------------------
    test_DescribeDBInstances = () ->
        asyncTest "/aws/rds instance.DescribeDBInstances()", () ->
            instance_id = null
            marker = null
            max_records = null

            instance_service.DescribeDBInstances username, session_id, region_name, instance_id, marker, max_records, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeDBInstances succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeDBInstances() succeed"
                else
                #DescribeDBInstances failed
                    ok false, "DescribeDBInstances() failed" + aws_result.error_message
            
                start()
                


    test_DescribeDBInstances()

