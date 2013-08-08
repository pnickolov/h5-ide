#*************************************************************************************
#* Filename     : autoscaling_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 17:15:01
#* Description  : qunit test module for autoscaling_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'autoscaling_service'], ( MC, $, test_util, session_service, autoscaling_service ) ->

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
    #aws/autoscaling test
    ################################################
    module "Module aws/autoscaling - autoscaling"
    #-----------------------------------------------
    #Test DescribeAdjustmentTypes()
    #-----------------------------------------------
    test_DescribeAdjustmentTypes = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribeAdjustmentTypes()", () ->


            autoscaling_service.DescribeAdjustmentTypes {sender:this}, username, session_id, region_name, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeAdjustmentTypes succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeAdjustmentTypes() succeed"
                else
                #DescribeAdjustmentTypes failed
                    ok false, "DescribeAdjustmentTypes() failed" + aws_result.error_message

                start()


    #-----------------------------------------------
    #Test DescribeAutoScalingGroups()
    #-----------------------------------------------
    test_DescribeAutoScalingGroups = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribeAutoScalingGroups()", () ->
            group_names = null
            max_records = null
            next_token = null

            autoscaling_service.DescribeAutoScalingGroups {sender:this}, username, session_id, region_name, group_names, max_records, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeAutoScalingGroups succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeAutoScalingGroups() succeed"
                else
                #DescribeAutoScalingGroups failed
                    ok false, "DescribeAutoScalingGroups() failed" + aws_result.error_message

                start()
                test_DescribeAdjustmentTypes()

    #-----------------------------------------------
    #Test DescribeAutoScalingInstances()
    #-----------------------------------------------
    test_DescribeAutoScalingInstances = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribeAutoScalingInstances()", () ->
            instance_ids = null
            max_records = null
            next_token = null

            autoscaling_service.DescribeAutoScalingInstances {sender:this}, username, session_id, region_name, instance_ids, max_records, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeAutoScalingInstances succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeAutoScalingInstances() succeed"
                else
                #DescribeAutoScalingInstances failed
                    ok false, "DescribeAutoScalingInstances() failed" + aws_result.error_message

                start()
                test_DescribeAutoScalingGroups()

    #-----------------------------------------------
    #Test DescribeAutoScalingNotificationTypes()
    #-----------------------------------------------
    test_DescribeAutoScalingNotificationTypes = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribeAutoScalingNotificationTypes()", () ->


            autoscaling_service.DescribeAutoScalingNotificationTypes {sender:this}, username, session_id, region_name, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeAutoScalingNotificationTypes succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeAutoScalingNotificationTypes() succeed"
                else
                #DescribeAutoScalingNotificationTypes failed
                    ok false, "DescribeAutoScalingNotificationTypes() failed" + aws_result.error_message

                start()
                test_DescribeAutoScalingInstances()

    #-----------------------------------------------
    #Test DescribeLaunchConfigurations()
    #-----------------------------------------------
    test_DescribeLaunchConfigurations = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribeLaunchConfigurations()", () ->
            config_names = null
            max_records = null
            next_token = null

            autoscaling_service.DescribeLaunchConfigurations {sender:this}, username, session_id, region_name, config_names, max_records, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeLaunchConfigurations succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeLaunchConfigurations() succeed"
                else
                #DescribeLaunchConfigurations failed
                    ok false, "DescribeLaunchConfigurations() failed" + aws_result.error_message

                start()
                test_DescribeAutoScalingNotificationTypes()

    #-----------------------------------------------
    #Test DescribeMetricCollectionTypes()
    #-----------------------------------------------
    test_DescribeMetricCollectionTypes = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribeMetricCollectionTypes()", () ->


            autoscaling_service.DescribeMetricCollectionTypes {sender:this}, username, session_id, region_name, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeMetricCollectionTypes succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeMetricCollectionTypes() succeed"
                else
                #DescribeMetricCollectionTypes failed
                    ok false, "DescribeMetricCollectionTypes() failed" + aws_result.error_message

                start()
                test_DescribeLaunchConfigurations()

    #-----------------------------------------------
    #Test DescribeNotificationConfigurations()
    #-----------------------------------------------
    test_DescribeNotificationConfigurations = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribeNotificationConfigurations()", () ->
            group_names = null
            max_records = null
            next_token = null

            autoscaling_service.DescribeNotificationConfigurations {sender:this}, username, session_id, region_name, group_names, max_records, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeNotificationConfigurations succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeNotificationConfigurations() succeed"
                else
                #DescribeNotificationConfigurations failed
                    ok false, "DescribeNotificationConfigurations() failed" + aws_result.error_message

                start()
                test_DescribeMetricCollectionTypes()

    #-----------------------------------------------
    #Test DescribePolicies()
    #-----------------------------------------------
    test_DescribePolicies = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribePolicies()", () ->
            group_name = null
            policy_names = null
            max_records = null
            next_token = null

            autoscaling_service.DescribePolicies {sender:this}, username, session_id, region_name, group_name, policy_names, max_records, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #DescribePolicies succeed
                    data = aws_result.resolved_data
                    ok true, "DescribePolicies() succeed"
                else
                #DescribePolicies failed
                    ok false, "DescribePolicies() failed" + aws_result.error_message

                start()
                test_DescribeNotificationConfigurations()

    #-----------------------------------------------
    #Test DescribeScalingActivities()
    #-----------------------------------------------
    test_DescribeScalingActivities = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribeScalingActivities()", () ->
            group_name = null
            activity_ids = null
            max_records = null
            next_token = null

            autoscaling_service.DescribeScalingActivities {sender:this}, username, session_id, region_name, group_name, activity_ids, max_records, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeScalingActivities succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeScalingActivities() succeed"
                else
                #DescribeScalingActivities failed
                    ok false, "DescribeScalingActivities() failed" + aws_result.error_message

                start()
                test_DescribePolicies()

    #-----------------------------------------------
    #Test DescribeScalingProcessTypes()
    #-----------------------------------------------
    test_DescribeScalingProcessTypes = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribeScalingProcessTypes()", () ->


            autoscaling_service.DescribeScalingProcessTypes {sender:this}, username, session_id, region_name, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeScalingProcessTypes succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeScalingProcessTypes() succeed"
                else
                #DescribeScalingProcessTypes failed
                    ok false, "DescribeScalingProcessTypes() failed" + aws_result.error_message

                start()
                test_DescribeScalingActivities()

    #-----------------------------------------------
    #Test DescribeScheduledActions()
    #-----------------------------------------------
    test_DescribeScheduledActions = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribeScheduledActions()", () ->
            group_name = null
            action_names = null
            start_time = null
            end_time = null
            max_records = null
            next_token = null

            autoscaling_service.DescribeScheduledActions {sender:this}, username, session_id, region_name, group_name, action_names, start_time, end_time, max_records, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeScheduledActions succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeScheduledActions() succeed"
                else
                #DescribeScheduledActions failed
                    ok false, "DescribeScheduledActions() failed" + aws_result.error_message

                start()
                test_DescribeScalingProcessTypes()

    #-----------------------------------------------
    #Test DescribeTags()
    #-----------------------------------------------
    test_DescribeTags = () ->
        asyncTest "/aws/autoscaling autoscaling.DescribeTags()", () ->
            filters = null
            max_records = null
            next_token = null

            autoscaling_service.DescribeTags {sender:this}, username, session_id, region_name, filters, max_records, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeTags succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeTags() succeed"
                else
                #DescribeTags failed
                    ok false, "DescribeTags() failed" + aws_result.error_message

                start()
                test_DescribeScheduledActions()


    test_DescribeTags()
