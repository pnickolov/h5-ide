#*************************************************************************************
#* Filename     : sdb_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 15:59:20
#* Description  : qunit test module for sdb_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'sdb_service'], ( MC, $, test_util, session_service, sdb_service ) ->

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
    #aws/sdb test
    ################################################
    module "Module aws/sdb - sdb"
    #-----------------------------------------------
    #Test GetAttributes()
    #-----------------------------------------------
    test_GetAttributes = () ->
        asyncTest "/aws/sdb sdb.GetAttributes()", () ->
            domain_name = null
            item_name = null
            attribute_name = null
            consistent_read = null

            sdb_service.GetAttributes username, session_id, region_name, domain_name, item_name, attribute_name, consistent_read, ( aws_result ) ->
                if !aws_result.is_error
                #GetAttributes succeed
                    data = aws_result.resolved_data
                    ok true, "GetAttributes() succeed"
                else
                #GetAttributes failed
                    ok false, "GetAttributes() failed" + aws_result.error_message
            
                start()
                test_DomainMetadata()

    #-----------------------------------------------
    #Test ListDomains()
    #-----------------------------------------------
    test_ListDomains = () ->
        asyncTest "/aws/sdb sdb.ListDomains()", () ->
            max_domains = null
            next_token = null

            sdb_service.ListDomains username, session_id, region_name, max_domains, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #ListDomains succeed
                    data = aws_result.resolved_data
                    ok true, "ListDomains() succeed"
                else
                #ListDomains failed
                    ok false, "ListDomains() failed" + aws_result.error_message
            
                start()
                test_GetAttributes()


    test_ListDomains()

