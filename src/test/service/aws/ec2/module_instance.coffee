#*************************************************************************************
#* Filename     : instance_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 17:15:07
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
    #aws/ec2 test
    ################################################
    module "Module aws/ec2 - instance"
    #-----------------------------------------------
    #Test DescribeInstances()
    #-----------------------------------------------
    test_DescribeInstances = () ->
        asyncTest "/aws/ec2 instance.DescribeInstances()", () ->
            instance_ids = null
            filters = null

            instance_service.DescribeInstances {sender:this}, username, session_id, region_name, instance_ids, filters, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeInstances succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeInstances() succeed"
                else
                #DescribeInstances failed
                    ok false, "DescribeInstances() failed" + aws_result.error_message
            
                start()
                test_ConfirmProductInstance()

    #-----------------------------------------------
    #Test DescribeInstanceStatus()
    #-----------------------------------------------
    test_DescribeInstanceStatus = () ->
        asyncTest "/aws/ec2 instance.DescribeInstanceStatus()", () ->
            instance_ids = null
            include_all_instances = null
            max_results = null
            next_token = null

            instance_service.DescribeInstanceStatus {sender:this}, username, session_id, region_name, instance_ids, include_all_instances, max_results, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeInstanceStatus succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeInstanceStatus() succeed"
                else
                #DescribeInstanceStatus failed
                    ok false, "DescribeInstanceStatus() failed" + aws_result.error_message
            
                start()
                test_DescribeInstances()

    #-----------------------------------------------
    #Test DescribeBundleTasks()
    #-----------------------------------------------
    test_DescribeBundleTasks = () ->
        asyncTest "/aws/ec2 instance.DescribeBundleTasks()", () ->
            bundle_ids = null
            filters = null

            instance_service.DescribeBundleTasks {sender:this}, username, session_id, region_name, bundle_ids, filters, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeBundleTasks succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeBundleTasks() succeed"
                else
                #DescribeBundleTasks failed
                    ok false, "DescribeBundleTasks() failed" + aws_result.error_message
            
                start()
                test_DescribeInstanceStatus()

    #-----------------------------------------------
    #Test DescribeInstanceAttribute()
    #-----------------------------------------------
    test_DescribeInstanceAttribute = () ->
        asyncTest "/aws/ec2 instance.DescribeInstanceAttribute()", () ->
            instance_id = null
            attribute_name = null

            instance_service.DescribeInstanceAttribute {sender:this}, username, session_id, region_name, instance_id, attribute_name, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeInstanceAttribute succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeInstanceAttribute() succeed"
                else
                #DescribeInstanceAttribute failed
                    ok false, "DescribeInstanceAttribute() failed" + aws_result.error_message
            
                start()
                test_DescribeBundleTasks()

    #-----------------------------------------------
    #Test GetConsoleOutput()
    #-----------------------------------------------
    test_GetConsoleOutput = () ->
        asyncTest "/aws/ec2 instance.GetConsoleOutput()", () ->
            instance_id = null

            instance_service.GetConsoleOutput {sender:this}, username, session_id, region_name, instance_id, ( aws_result ) ->
                if !aws_result.is_error
                #GetConsoleOutput succeed
                    data = aws_result.resolved_data
                    ok true, "GetConsoleOutput() succeed"
                else
                #GetConsoleOutput failed
                    ok false, "GetConsoleOutput() failed" + aws_result.error_message
            
                start()
                test_DescribeInstanceAttribute()

    #-----------------------------------------------
    #Test GetPasswordData()
    #-----------------------------------------------
    test_GetPasswordData = () ->
        asyncTest "/aws/ec2 instance.GetPasswordData()", () ->
            instance_id = null
            key_data = null

            instance_service.GetPasswordData {sender:this}, username, session_id, region_name, instance_id, key_data, ( aws_result ) ->
                if !aws_result.is_error
                #GetPasswordData succeed
                    data = aws_result.resolved_data
                    ok true, "GetPasswordData() succeed"
                else
                #GetPasswordData failed
                    ok false, "GetPasswordData() failed" + aws_result.error_message
            
                start()
                test_GetConsoleOutput()


    test_GetPasswordData()

