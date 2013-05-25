#*************************************************************************************
#* Filename     : elb_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:15
#* Description  : qunit test module for elb_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'elb_service'], ( MC, $, test_util, session_service, elb_service ) ->

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
    #aws/elb test
    ################################################
    module "Module aws/elb - elb"
    #-----------------------------------------------
    #Test DescribeInstanceHealth()
    #-----------------------------------------------
    asyncTest "/aws/elb elb.DescribeInstanceHealth()", () ->
        
        elb_name = null
        instance_ids = null

        elb_service.DescribeInstanceHealth username, session_id, region_name, elb_name, instance_ids, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeInstanceHealth succeed
                data = aws_result.resolved_data
                ok true, "DescribeInstanceHealth() succeed"
                start()
            else
            #DescribeInstanceHealth failed
                ok false, "DescribeInstanceHealth() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeLoadBalancerPolicies()
    #-----------------------------------------------
    asyncTest "/aws/elb elb.DescribeLoadBalancerPolicies()", () ->
        
        elb_name = null
        policy_names = null

        elb_service.DescribeLoadBalancerPolicies username, session_id, region_name, elb_name, policy_names, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeLoadBalancerPolicies succeed
                data = aws_result.resolved_data
                ok true, "DescribeLoadBalancerPolicies() succeed"
                start()
            else
            #DescribeLoadBalancerPolicies failed
                ok false, "DescribeLoadBalancerPolicies() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeLoadBalancerPolicyTypes()
    #-----------------------------------------------
    asyncTest "/aws/elb elb.DescribeLoadBalancerPolicyTypes()", () ->
        
        policy_type_names = null

        elb_service.DescribeLoadBalancerPolicyTypes username, session_id, region_name, policy_type_names, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeLoadBalancerPolicyTypes succeed
                data = aws_result.resolved_data
                ok true, "DescribeLoadBalancerPolicyTypes() succeed"
                start()
            else
            #DescribeLoadBalancerPolicyTypes failed
                ok false, "DescribeLoadBalancerPolicyTypes() failed" + aws_result.error_message
                start()

    #-----------------------------------------------
    #Test DescribeLoadBalancers()
    #-----------------------------------------------
    asyncTest "/aws/elb elb.DescribeLoadBalancers()", () ->
        
        elb_names = null
        marker = null

        elb_service.DescribeLoadBalancers username, session_id, region_name, elb_names, marker, ( aws_result ) ->
            if !aws_result.is_error
            #DescribeLoadBalancers succeed
                data = aws_result.resolved_data
                ok true, "DescribeLoadBalancers() succeed"
                start()
            else
            #DescribeLoadBalancers failed
                ok false, "DescribeLoadBalancers() failed" + aws_result.error_message
                start()

