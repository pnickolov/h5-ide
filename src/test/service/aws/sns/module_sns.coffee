#*************************************************************************************
#* Filename     : sns_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-08-03 14:02:01
#* Description  : qunit test module for sns_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require [ 'MC', 'jquery', 'test_util', 'session_service', 'sns_service'], ( MC, $, test_util, session_service, sns_service ) ->

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
    #aws/sns test
    ################################################
    module "Module aws/sns - sns"
    #-----------------------------------------------
    #Test GetSubscriptionAttributes()
    #-----------------------------------------------
    test_GetSubscriptionAttributes = () ->
        asyncTest "/aws/sns sns.GetSubscriptionAttributes()", () ->
            subscription_arn = null

            sns_service.GetSubscriptionAttributes {sender:this}, username, session_id, region_name, subscription_arn, ( aws_result ) ->
                if !aws_result.is_error
                #GetSubscriptionAttributes succeed
                    data = aws_result.resolved_data
                    ok true, "GetSubscriptionAttributes() succeed"
                else
                #GetSubscriptionAttributes failed
                    ok false, "GetSubscriptionAttributes() failed" + aws_result.error_message
            
                start()
                

    #-----------------------------------------------
    #Test GetTopicAttributes()
    #-----------------------------------------------
    test_GetTopicAttributes = () ->
        asyncTest "/aws/sns sns.GetTopicAttributes()", () ->
            topic_arn = null

            sns_service.GetTopicAttributes {sender:this}, username, session_id, region_name, topic_arn, ( aws_result ) ->
                if !aws_result.is_error
                #GetTopicAttributes succeed
                    data = aws_result.resolved_data
                    ok true, "GetTopicAttributes() succeed"
                else
                #GetTopicAttributes failed
                    ok false, "GetTopicAttributes() failed" + aws_result.error_message
            
                start()
                test_GetSubscriptionAttributes()

    #-----------------------------------------------
    #Test ListSubscriptions()
    #-----------------------------------------------
    test_ListSubscriptions = () ->
        asyncTest "/aws/sns sns.ListSubscriptions()", () ->
            next_token = null

            sns_service.ListSubscriptions {sender:this}, username, session_id, region_name, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #ListSubscriptions succeed
                    data = aws_result.resolved_data
                    ok true, "ListSubscriptions() succeed"
                else
                #ListSubscriptions failed
                    ok false, "ListSubscriptions() failed" + aws_result.error_message
            
                start()
                test_GetTopicAttributes()

    #-----------------------------------------------
    #Test ListSubscriptionsByTopic()
    #-----------------------------------------------
    test_ListSubscriptionsByTopic = () ->
        asyncTest "/aws/sns sns.ListSubscriptionsByTopic()", () ->
            topic_arn = null
            next_token = null

            sns_service.ListSubscriptionsByTopic {sender:this}, username, session_id, region_name, topic_arn, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #ListSubscriptionsByTopic succeed
                    data = aws_result.resolved_data
                    ok true, "ListSubscriptionsByTopic() succeed"
                else
                #ListSubscriptionsByTopic failed
                    ok false, "ListSubscriptionsByTopic() failed" + aws_result.error_message
            
                start()
                test_ListSubscriptions()

    #-----------------------------------------------
    #Test ListTopics()
    #-----------------------------------------------
    test_ListTopics = () ->
        asyncTest "/aws/sns sns.ListTopics()", () ->
            next_token = null

            sns_service.ListTopics {sender:this}, username, session_id, region_name, next_token, ( aws_result ) ->
                if !aws_result.is_error
                #ListTopics succeed
                    data = aws_result.resolved_data
                    ok true, "ListTopics() succeed"
                else
                #ListTopics failed
                    ok false, "ListTopics() failed" + aws_result.error_message
            
                start()
                test_ListSubscriptionsByTopic()


    test_ListTopics()

