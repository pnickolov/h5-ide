#*************************************************************************************
#* Filename     : securitygroup_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:20
#* Description  : qunit test module for securitygroup_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'securitygroup_service'], ( MC, $, test_util, session_service, securitygroup_service ) ->

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
    module "Module aws/rds - securitygroup"
    #-----------------------------------------------
    #Test DescribeDBSecurityGroups()
    #-----------------------------------------------
    asyncTest "/aws/rds securitygroup.DescribeDBSecurityGroups()", () ->
        
        sg_name = null
        marker = null
        max_records = null

        securitygroup_service.DescribeDBSecurityGroups username, session_id, region_name, sg_name, marker, max_records, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeDBSecurityGroups succeed
                data = aws_result.resolved_data
                ok true, "DescribeDBSecurityGroups() succeed"
                start()
            else
            #DescribeDBSecurityGroups failed
                ok false, "DescribeDBSecurityGroups() failed" + aws_result.error_message
                start()

