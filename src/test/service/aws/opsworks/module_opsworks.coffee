#*************************************************************************************
#* Filename     : opsworks_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 11:35:50
#* Description  : qunit test module for opsworks_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'opsworks_service'], ( MC, $, test_util, session_service, opsworks_service ) ->

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
    #aws/opsworks test
    ################################################
    module "Module aws/opsworks - opsworks"
    #-----------------------------------------------
    #Test DescribeApps()
    #-----------------------------------------------
    test_DescribeApps = () ->
        asyncTest "/aws/opsworks opsworks.DescribeApps()", () ->
            app_ids = null
            stack_id = null

            opsworks_service.DescribeApps username, session_id, region_name, app_ids, stack_id, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeApps succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeApps() succeed"
                else
                #DescribeApps failed
                    ok false, "DescribeApps() failed" + aws_result.error_message
            
                start()
                

    #-----------------------------------------------
    #Test DescribeStacks()
    #-----------------------------------------------
    test_DescribeStacks = () ->
        asyncTest "/aws/opsworks opsworks.DescribeStacks()", () ->
            stack_ids = null

            opsworks_service.DescribeStacks username, session_id, region_name, stack_ids, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeStacks succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeStacks() succeed"
                else
                #DescribeStacks failed
                    ok false, "DescribeStacks() failed" + aws_result.error_message
            
                start()
                test_DescribeApps()

    #-----------------------------------------------
    #Test DescribeCommands()
    #-----------------------------------------------
    test_DescribeCommands = () ->
        asyncTest "/aws/opsworks opsworks.DescribeCommands()", () ->
            command_ids = null
            deployment_id = null
            instance_id = null

            opsworks_service.DescribeCommands username, session_id, region_name, command_ids, deployment_id, instance_id, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeCommands succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeCommands() succeed"
                else
                #DescribeCommands failed
                    ok false, "DescribeCommands() failed" + aws_result.error_message
            
                start()
                test_DescribeStacks()

    #-----------------------------------------------
    #Test DescribeDeployments()
    #-----------------------------------------------
    test_DescribeDeployments = () ->
        asyncTest "/aws/opsworks opsworks.DescribeDeployments()", () ->
            app_id = null
            deployment_ids = null
            stack_id = null

            opsworks_service.DescribeDeployments username, session_id, region_name, app_id, deployment_ids, stack_id, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeDeployments succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeDeployments() succeed"
                else
                #DescribeDeployments failed
                    ok false, "DescribeDeployments() failed" + aws_result.error_message
            
                start()
                test_DescribeCommands()

    #-----------------------------------------------
    #Test DescribeElasticIps()
    #-----------------------------------------------
    test_DescribeElasticIps = () ->
        asyncTest "/aws/opsworks opsworks.DescribeElasticIps()", () ->
            instance_id = null
            ips = null

            opsworks_service.DescribeElasticIps username, session_id, region_name, instance_id, ips, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeElasticIps succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeElasticIps() succeed"
                else
                #DescribeElasticIps failed
                    ok false, "DescribeElasticIps() failed" + aws_result.error_message
            
                start()
                test_DescribeDeployments()

    #-----------------------------------------------
    #Test DescribeInstances()
    #-----------------------------------------------
    test_DescribeInstances = () ->
        asyncTest "/aws/opsworks opsworks.DescribeInstances()", () ->
            app_id = null
            instance_ids = null
            layer_id = null
            stack_id = null

            opsworks_service.DescribeInstances username, session_id, region_name, app_id, instance_ids, layer_id, stack_id, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeInstances succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeInstances() succeed"
                else
                #DescribeInstances failed
                    ok false, "DescribeInstances() failed" + aws_result.error_message
            
                start()
                test_DescribeElasticIps()

    #-----------------------------------------------
    #Test DescribeLayers()
    #-----------------------------------------------
    test_DescribeLayers = () ->
        asyncTest "/aws/opsworks opsworks.DescribeLayers()", () ->
            stack_id = null
            layer_ids = null

            opsworks_service.DescribeLayers username, session_id, region_name, stack_id, layer_ids, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeLayers succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeLayers() succeed"
                else
                #DescribeLayers failed
                    ok false, "DescribeLayers() failed" + aws_result.error_message
            
                start()
                test_DescribeInstances()

    #-----------------------------------------------
    #Test DescribeLoadBasedAutoScaling()
    #-----------------------------------------------
    test_DescribeLoadBasedAutoScaling = () ->
        asyncTest "/aws/opsworks opsworks.DescribeLoadBasedAutoScaling()", () ->
            layer_ids = null

            opsworks_service.DescribeLoadBasedAutoScaling username, session_id, region_name, layer_ids, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeLoadBasedAutoScaling succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeLoadBasedAutoScaling() succeed"
                else
                #DescribeLoadBasedAutoScaling failed
                    ok false, "DescribeLoadBasedAutoScaling() failed" + aws_result.error_message
            
                start()
                test_DescribeLayers()

    #-----------------------------------------------
    #Test DescribePermissions()
    #-----------------------------------------------
    test_DescribePermissions = () ->
        asyncTest "/aws/opsworks opsworks.DescribePermissions()", () ->
            iam_user_arn = null
            stack_id = null

            opsworks_service.DescribePermissions username, session_id, region_name, iam_user_arn, stack_id, ( aws_result ) ->
                if !aws_result.is_error
                #DescribePermissions succeed
                    data = aws_result.resolved_data
                    ok true, "DescribePermissions() succeed"
                else
                #DescribePermissions failed
                    ok false, "DescribePermissions() failed" + aws_result.error_message
            
                start()
                test_DescribeLoadBasedAutoScaling()

    #-----------------------------------------------
    #Test DescribeRaidArrays()
    #-----------------------------------------------
    test_DescribeRaidArrays = () ->
        asyncTest "/aws/opsworks opsworks.DescribeRaidArrays()", () ->
            instance_id = null
            raid_array_ids = null

            opsworks_service.DescribeRaidArrays username, session_id, region_name, instance_id, raid_array_ids, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeRaidArrays succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeRaidArrays() succeed"
                else
                #DescribeRaidArrays failed
                    ok false, "DescribeRaidArrays() failed" + aws_result.error_message
            
                start()
                test_DescribePermissions()

    #-----------------------------------------------
    #Test DescribeServiceErrors()
    #-----------------------------------------------
    test_DescribeServiceErrors = () ->
        asyncTest "/aws/opsworks opsworks.DescribeServiceErrors()", () ->
            instance_id = null
            service_error_ids = null
            stack_id = null

            opsworks_service.DescribeServiceErrors username, session_id, region_name, instance_id, service_error_ids, stack_id, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeServiceErrors succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeServiceErrors() succeed"
                else
                #DescribeServiceErrors failed
                    ok false, "DescribeServiceErrors() failed" + aws_result.error_message
            
                start()
                test_DescribeRaidArrays()

    #-----------------------------------------------
    #Test DescribeTimeBasedAutoScaling()
    #-----------------------------------------------
    test_DescribeTimeBasedAutoScaling = () ->
        asyncTest "/aws/opsworks opsworks.DescribeTimeBasedAutoScaling()", () ->
            instance_ids = null

            opsworks_service.DescribeTimeBasedAutoScaling username, session_id, region_name, instance_ids, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeTimeBasedAutoScaling succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeTimeBasedAutoScaling() succeed"
                else
                #DescribeTimeBasedAutoScaling failed
                    ok false, "DescribeTimeBasedAutoScaling() failed" + aws_result.error_message
            
                start()
                test_DescribeServiceErrors()

    #-----------------------------------------------
    #Test DescribeUserProfiles()
    #-----------------------------------------------
    test_DescribeUserProfiles = () ->
        asyncTest "/aws/opsworks opsworks.DescribeUserProfiles()", () ->
            iam_user_arns = null

            opsworks_service.DescribeUserProfiles username, session_id, region_name, iam_user_arns, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeUserProfiles succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeUserProfiles() succeed"
                else
                #DescribeUserProfiles failed
                    ok false, "DescribeUserProfiles() failed" + aws_result.error_message
            
                start()
                test_DescribeTimeBasedAutoScaling()

    #-----------------------------------------------
    #Test DescribeVolumes()
    #-----------------------------------------------
    test_DescribeVolumes = () ->
        asyncTest "/aws/opsworks opsworks.DescribeVolumes()", () ->
            instance_id = null
            raid_array_id = null
            volume_ids = null

            opsworks_service.DescribeVolumes username, session_id, region_name, instance_id, raid_array_id, volume_ids, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeVolumes succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeVolumes() succeed"
                else
                #DescribeVolumes failed
                    ok false, "DescribeVolumes() failed" + aws_result.error_message
            
                start()
                test_DescribeUserProfiles()


    test_DescribeVolumes()

