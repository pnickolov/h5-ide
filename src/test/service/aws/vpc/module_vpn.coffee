#*************************************************************************************
#* Filename     : vpn_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 17:15:17
#* Description  : qunit test module for vpn_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'vpn_service'], ( MC, $, test_util, session_service, vpn_service ) ->

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
    #aws/vpc test
    ################################################
    module "Module aws/vpc - vpn"
    #-----------------------------------------------
    #Test DescribeVpnConnections()
    #-----------------------------------------------
    test_DescribeVpnConnections = () ->
        asyncTest "/aws/vpc vpn.DescribeVpnConnections()", () ->
            vpn_ids = null
            filters = null

            vpn_service.DescribeVpnConnections {sender:this}, username, session_id, region_name, vpn_ids, filters, ( aws_result ) ->
                if !aws_result.is_error
                #DescribeVpnConnections succeed
                    data = aws_result.resolved_data
                    ok true, "DescribeVpnConnections() succeed"
                else
                #DescribeVpnConnections failed
                    ok false, "DescribeVpnConnections() failed" + aws_result.error_message
            
                start()
                


    test_DescribeVpnConnections()

