#*************************************************************************************
#* Filename     : vpngateway_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 11:35:56
#* Description  : qunit test module for vpngateway_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'vpngateway_service'], ( MC, $, test_util, session_service, vpngateway_service ) ->

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
    module "Module aws/vpc - vpngateway"
    #-----------------------------------------------
    #Test DescribeVpnGateways()
    #-----------------------------------------------
    test_DescribeVpnGateways = () ->
        asyncTest "/aws/vpc vpngateway.DescribeVpnGateways()", () ->
            gw_ids = null
            filters = null

            vpngateway_service.DescribeVpnGateways username, session_id, region_name, gw_ids, filters, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeVpnGateways succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeVpnGateways() succeed"
                else
                #DescribeVpnGateways failed
                    ok false, "DescribeVpnGateways() failed" + aws_result.error_message
            
                start()
                


    test_DescribeVpnGateways()

