#*************************************************************************************
#* Filename     : dhcp_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 15:59:21
#* Description  : qunit test module for dhcp_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'dhcp_service'], ( MC, $, test_util, session_service, dhcp_service ) ->

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
    module "Module aws/vpc - dhcp"
    #-----------------------------------------------
    #Test DescribeDhcpOptions()
    #-----------------------------------------------
    test_DescribeDhcpOptions = () ->
        asyncTest "/aws/vpc dhcp.DescribeDhcpOptions()", () ->
            dhcp_ids = null
            filters = null

            dhcp_service.DescribeDhcpOptions username, session_id, region_name, dhcp_ids, filters, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeDhcpOptions succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeDhcpOptions() succeed"
                else
                #DescribeDhcpOptions failed
                    ok false, "DescribeDhcpOptions() failed" + aws_result.error_message
            
                start()
                


    test_DescribeDhcpOptions()

