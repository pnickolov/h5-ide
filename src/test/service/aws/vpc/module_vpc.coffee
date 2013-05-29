#*************************************************************************************
#* Filename     : vpc_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-29 13:27:49
#* Description  : qunit test module for vpc_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'vpc_service'], ( MC, $, test_util, session_service, vpc_service ) ->

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
    #aws/vpc test
    ################################################
    module "Module aws/vpc - vpc"
    #-----------------------------------------------
    #Test DescribeVpcs()
    #-----------------------------------------------
    test_DescribeVpcs = () ->
        asyncTest "/aws/vpc vpc.DescribeVpcs()", () ->
            vpc_ids = null
            filters = null

            vpc_service.DescribeVpcs username, session_id, region_name, vpc_ids, filters, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeVpcs succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeVpcs() succeed"
                else
                #DescribeVpcs failed
                    ok false, "DescribeVpcs() failed" + aws_result.error_message
            
                start()
                

    #-----------------------------------------------
    #Test DescribeAccountAttributes()
    #-----------------------------------------------
    test_DescribeAccountAttributes = () ->
        asyncTest "/aws/vpc vpc.DescribeAccountAttributes()", () ->
            attribute_name = null

            vpc_service.DescribeAccountAttributes username, session_id, region_name, attribute_name, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeAccountAttributes succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeAccountAttributes() succeed"
                else
                #DescribeAccountAttributes failed
                    ok false, "DescribeAccountAttributes() failed" + aws_result.error_message
            
                start()
                test_DescribeVpcs()

    #-----------------------------------------------
    #Test DescribeVpcAttribute()
    #-----------------------------------------------
    test_DescribeVpcAttribute = () ->
        asyncTest "/aws/vpc vpc.DescribeVpcAttribute()", () ->
            vpc_id = null
            attribute = null

            vpc_service.DescribeVpcAttribute username, session_id, region_name, vpc_id, attribute, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeVpcAttribute succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeVpcAttribute() succeed"
                else
                #DescribeVpcAttribute failed
                    ok false, "DescribeVpcAttribute() failed" + aws_result.error_message
            
                start()
                test_DescribeAccountAttributes()


    test_DescribeVpcAttribute()

