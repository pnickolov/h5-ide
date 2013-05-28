#*************************************************************************************
#* Filename     : cloudwatch_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 15:59:08
#* Description  : qunit test module for cloudwatch_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'cloudwatch_service'], ( MC, $, test_util, session_service, cloudwatch_service ) ->

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
    #aws/cloudwatch test
    ################################################
    module "Module aws/cloudwatch - cloudwatch"
    #-----------------------------------------------
    #Test GetMetricStatistics()
    #-----------------------------------------------
    test_GetMetricStatistics = () ->
        asyncTest "/aws/cloudwatch cloudwatch.GetMetricStatistics()", () ->


            cloudwatch_service.GetMetricStatistics username, session_id, ( aws_result ) ->
                if !aws_result.is_error
                #GetMetricStatistics succeed
                    data = aws_result.resolved_data
                    ok true, "GetMetricStatistics() succeed"
                else
                #GetMetricStatistics failed
                    ok false, "GetMetricStatistics() failed" + aws_result.error_message
            
                start()
                

    #-----------------------------------------------
    #Test ListMetrics()
    #-----------------------------------------------
    test_ListMetrics = () ->
        asyncTest "/aws/cloudwatch cloudwatch.ListMetrics()", () ->


            cloudwatch_service.ListMetrics username, session_id, ( aws_result ) ->
                if !aws_result.is_error
                #ListMetrics succeed
                    data = aws_result.resolved_data
                    ok true, "ListMetrics() succeed"
                else
                #ListMetrics failed
                    ok false, "ListMetrics() failed" + aws_result.error_message
            
                start()
                test_GetMetricStatistics()

    #-----------------------------------------------
    #Test DescribeAlarmHistory()
    #-----------------------------------------------
    test_DescribeAlarmHistory = () ->
        asyncTest "/aws/cloudwatch cloudwatch.DescribeAlarmHistory()", () ->


            cloudwatch_service.DescribeAlarmHistory username, session_id, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeAlarmHistory succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeAlarmHistory() succeed"
                else
                #DescribeAlarmHistory failed
                    ok false, "DescribeAlarmHistory() failed" + aws_result.error_message
            
                start()
                test_ListMetrics()

    #-----------------------------------------------
    #Test DescribeAlarms()
    #-----------------------------------------------
    test_DescribeAlarms = () ->
        asyncTest "/aws/cloudwatch cloudwatch.DescribeAlarms()", () ->


            cloudwatch_service.DescribeAlarms username, session_id, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeAlarms succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeAlarms() succeed"
                else
                #DescribeAlarms failed
                    ok false, "DescribeAlarms() failed" + aws_result.error_message
            
                start()
                test_DescribeAlarmHistory()

    #-----------------------------------------------
    #Test DescribeAlarmsForMetric()
    #-----------------------------------------------
    test_DescribeAlarmsForMetric = () ->
        asyncTest "/aws/cloudwatch cloudwatch.DescribeAlarmsForMetric()", () ->


            cloudwatch_service.DescribeAlarmsForMetric username, session_id, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeAlarmsForMetric succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeAlarmsForMetric() succeed"
                else
                #DescribeAlarmsForMetric failed
                    ok false, "DescribeAlarmsForMetric() failed" + aws_result.error_message
            
                start()
                test_DescribeAlarms()


    test_DescribeAlarmsForMetric()

