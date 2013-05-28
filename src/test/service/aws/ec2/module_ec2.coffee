#*************************************************************************************
#* Filename     : ec2_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 15:59:11
#* Description  : qunit test module for ec2_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'ec2_service'], ( MC, $, test_util, session_service, ec2_service ) ->

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
    module "Module aws/ec2 - ec2"
    #-----------------------------------------------
    #Test DescribeTags()
    #-----------------------------------------------
    test_DescribeTags = () ->
        asyncTest "/aws/ec2 ec2.DescribeTags()", () ->
            filters = null

            ec2_service.DescribeTags username, session_id, region_name, filters, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeTags succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeTags() succeed"
                else
                #DescribeTags failed
                    ok false, "DescribeTags() failed" + aws_result.error_message
            
                start()
                test_DeleteTags()

    #-----------------------------------------------
    #Test DescribeRegions()
    #-----------------------------------------------
    test_DescribeRegions = () ->
        asyncTest "/aws/ec2 ec2.DescribeRegions()", () ->
            region_names = null
            filters = null

            ec2_service.DescribeRegions username, session_id, region_names, filters, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeRegions succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeRegions() succeed"
                else
                #DescribeRegions failed
                    ok false, "DescribeRegions() failed" + aws_result.error_message
            
                start()
                test_DescribeTags()

    #-----------------------------------------------
    #Test DescribeAvailabilityZones()
    #-----------------------------------------------
    test_DescribeAvailabilityZones = () ->
        asyncTest "/aws/ec2 ec2.DescribeAvailabilityZones()", () ->
            zone_names = null
            filters = null

            ec2_service.DescribeAvailabilityZones username, session_id, region_name, zone_names, filters, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeAvailabilityZones succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeAvailabilityZones() succeed"
                else
                #DescribeAvailabilityZones failed
                    ok false, "DescribeAvailabilityZones() failed" + aws_result.error_message
            
                start()
                test_DescribeRegions()


    test_DescribeAvailabilityZones()

