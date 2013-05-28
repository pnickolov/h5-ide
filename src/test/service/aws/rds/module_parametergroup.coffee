#*************************************************************************************
#* Filename     : parametergroup_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 15:59:19
#* Description  : qunit test module for parametergroup_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'parametergroup_service'], ( MC, $, test_util, session_service, parametergroup_service ) ->

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
    module "Module aws/rds - parametergroup"
    #-----------------------------------------------
    #Test DescribeDBParameterGroups()
    #-----------------------------------------------
    test_DescribeDBParameterGroups = () ->
        asyncTest "/aws/rds parametergroup.DescribeDBParameterGroups()", () ->
            pg_name = null
            marker = null
            max_records = null

            parametergroup_service.DescribeDBParameterGroups username, session_id, region_name, pg_name, marker, max_records, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeDBParameterGroups succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeDBParameterGroups() succeed"
                else
                #DescribeDBParameterGroups failed
                    ok false, "DescribeDBParameterGroups() failed" + aws_result.error_message
            
                start()
                

    #-----------------------------------------------
    #Test DescribeDBParameters()
    #-----------------------------------------------
    test_DescribeDBParameters = () ->
        asyncTest "/aws/rds parametergroup.DescribeDBParameters()", () ->
            pg_name = null
            source = null
            marker = null
            max_records = null

            parametergroup_service.DescribeDBParameters username, session_id, region_name, pg_name, source, marker, max_records, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeDBParameters succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeDBParameters() succeed"
                else
                #DescribeDBParameters failed
                    ok false, "DescribeDBParameters() failed" + aws_result.error_message
            
                start()
                test_DescribeDBParameterGroups()


    test_DescribeDBParameters()

