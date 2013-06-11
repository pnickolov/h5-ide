#*************************************************************************************
#* Filename     : rds_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 17:15:14
#* Description  : qunit test module for rds_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'rds_service'], ( MC, $, test_util, session_service, rds_service ) ->

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
    #aws/rds test
    ################################################
    module "Module aws/rds - rds"
    #-----------------------------------------------
    #Test DescribeDBEngineVersions()
    #-----------------------------------------------
    test_DescribeDBEngineVersions = () ->
        asyncTest "/aws/rds rds.DescribeDBEngineVersions()", () ->


            rds_service.DescribeDBEngineVersions {sender:this}, username, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeDBEngineVersions succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeDBEngineVersions() succeed"
                else
                #DescribeDBEngineVersions failed
                    ok false, "DescribeDBEngineVersions() failed" + aws_result.error_message
            
                start()
                

    #-----------------------------------------------
    #Test DescribeOrderableDBInstanceOptions()
    #-----------------------------------------------
    test_DescribeOrderableDBInstanceOptions = () ->
        asyncTest "/aws/rds rds.DescribeOrderableDBInstanceOptions()", () ->


            rds_service.DescribeOrderableDBInstanceOptions {sender:this}, username, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeOrderableDBInstanceOptions succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeOrderableDBInstanceOptions() succeed"
                else
                #DescribeOrderableDBInstanceOptions failed
                    ok false, "DescribeOrderableDBInstanceOptions() failed" + aws_result.error_message
            
                start()
                test_DescribeDBEngineVersions()

    #-----------------------------------------------
    #Test DescribeEngineDefaultParameters()
    #-----------------------------------------------
    test_DescribeEngineDefaultParameters = () ->
        asyncTest "/aws/rds rds.DescribeEngineDefaultParameters()", () ->
            pg_family = null
            marker = null
            max_records = null

            rds_service.DescribeEngineDefaultParameters {sender:this}, username, session_id, region_name, pg_family, marker, max_records, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeEngineDefaultParameters succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeEngineDefaultParameters() succeed"
                else
                #DescribeEngineDefaultParameters failed
                    ok false, "DescribeEngineDefaultParameters() failed" + aws_result.error_message
            
                start()
                test_DescribeOrderableDBInstanceOptions()

    #-----------------------------------------------
    #Test DescribeEvents()
    #-----------------------------------------------
    test_DescribeEvents = () ->
        asyncTest "/aws/rds rds.DescribeEvents()", () ->


            rds_service.DescribeEvents {sender:this}, username, session_id, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeEvents succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeEvents() succeed"
                else
                #DescribeEvents failed
                    ok false, "DescribeEvents() failed" + aws_result.error_message
            
                start()
                test_DescribeEngineDefaultParameters()


    test_DescribeEvents()

