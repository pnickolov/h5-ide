#*************************************************************************************
#* Filename     : ami_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-29 13:27:37
#* Description  : qunit test module for ami_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'ami_service'], ( MC, $, test_util, session_service, ami_service ) ->

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
    #aws/ec2 test
    ################################################
    module "Module aws/ec2 - ami"
    #-----------------------------------------------
    #Test DescribeImageAttribute()
    #-----------------------------------------------
    test_DescribeImageAttribute = () ->
        asyncTest "/aws/ec2 ami.DescribeImageAttribute()", () ->
            ami_id = null
            attribute_name = null

            ami_service.DescribeImageAttribute username, session_id, region_name, ami_id, attribute_name, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeImageAttribute succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeImageAttribute() succeed"
                else
                #DescribeImageAttribute failed
                    ok false, "DescribeImageAttribute() failed" + aws_result.error_message
            
                start()
                test_ResetImageAttribute()

    #-----------------------------------------------
    #Test DescribeImages()
    #-----------------------------------------------
    test_DescribeImages = () ->
        asyncTest "/aws/ec2 ami.DescribeImages()", () ->
            ami_ids = null
            owners = null
            executable_by = null
            filters = null

            ami_service.DescribeImages username, session_id, region_name, ami_ids, owners, executable_by, filters, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeImages succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeImages() succeed"
                else
                #DescribeImages failed
                    ok false, "DescribeImages() failed" + aws_result.error_message
            
                start()
                test_DescribeImageAttribute()


    test_DescribeImages()

