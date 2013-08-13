#*************************************************************************************
#* Filename     : sns_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-08-03 14:02:01
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

    URL = '/aws/sns/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "sns." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
                    aws_result = {}
                    aws_result = parser result, return_code, param_ary

                    callback aws_result

                error : ( result, return_code ) ->

                    aws_result = {}
                    aws_result.return_code      = return_code
                    aws_result.is_error         = true
                    aws_result.error_message    = result.toString()

                    callback aws_result
            }

        catch error
            console.log "sns." + method + " error:" + error.toString()


        true
    # end of send_request


    #///////////////// Parser for GetSubscriptionAttributes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetSubscriptionAttributesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        ($.xml2json ($.parseXML result[1])).GetSubscriptionAttributesResponse

    #private (parser GetSubscriptionAttributes return)
    parserGetSubscriptionAttributesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveGetSubscriptionAttributesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserGetSubscriptionAttributesReturn


    #///////////////// Parser for GetTopicAttributes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetTopicAttributesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        ($.xml2json ($.parseXML result[1])).GetTopicAttributesResponse

    #private (parser GetTopicAttributes return)
    parserGetTopicAttributesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveGetTopicAttributesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserGetTopicAttributesReturn


    #///////////////// Parser for ListSubscriptions return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveListSubscriptionsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        ($.xml2json ($.parseXML result[1])).ListSubscriptionsResponse.ListSubscriptionsResult.Subscriptions

    #private (parser ListSubscriptions return)
    parserListSubscriptionsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveListSubscriptionsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserListSubscriptionsReturn


    #///////////////// Parser for ListSubscriptionsByTopic return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveListSubscriptionsByTopicResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        ($.xml2json ($.parseXML result[1])).ListSubscriptionsByTopicResponse

    #private (parser ListSubscriptionsByTopic return)
    parserListSubscriptionsByTopicReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveListSubscriptionsByTopicResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserListSubscriptionsByTopicReturn


    #///////////////// Parser for ListTopics return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveListTopicsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        ($.xml2json ($.parseXML result[1])).ListTopicsResponse

    #private (parser ListTopics return)
    parserListTopicsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveListTopicsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserListTopicsReturn


    #def GetSubscriptionAttributes(self, username, session_id, region_name, subscription_arn):
    GetSubscriptionAttributes = ( src, username, session_id, region_name, subscription_arn, callback ) ->
        send_request "GetSubscriptionAttributes", src, [ username, session_id, region_name, subscription_arn ], parserGetSubscriptionAttributesReturn, callback
        true

    #def GetTopicAttributes(self, username, session_id, region_name, topic_arn):
    GetTopicAttributes = ( src, username, session_id, region_name, topic_arn, callback ) ->
        send_request "GetTopicAttributes", src, [ username, session_id, region_name, topic_arn ], parserGetTopicAttributesReturn, callback
        true

    #def ListSubscriptions(self, username, session_id, region_name, next_token=None):
    ListSubscriptions = ( src, username, session_id, region_name, next_token=null, callback ) ->
        send_request "ListSubscriptions", src, [ username, session_id, region_name, next_token ], parserListSubscriptionsReturn, callback
        true

    #def ListSubscriptionsByTopic(self, username, session_id, region_name, topic_arn, next_token=None):
    ListSubscriptionsByTopic = ( src, username, session_id, region_name, topic_arn, next_token=null, callback ) ->
        send_request "ListSubscriptionsByTopic", src, [ username, session_id, region_name, topic_arn, next_token ], parserListSubscriptionsByTopicReturn, callback
        true

    #def ListTopics(self, username, session_id, region_name, next_token=None):
    ListTopics = ( src, username, session_id, region_name, next_token=null, callback ) ->
        send_request "ListTopics", src, [ username, session_id, region_name, next_token ], parserListTopicsReturn, callback
        true


    #############################################################
    #public
    GetSubscriptionAttributes    : GetSubscriptionAttributes
    GetTopicAttributes           : GetTopicAttributes
    ListSubscriptions            : ListSubscriptions
    ListSubscriptionsByTopic     : ListSubscriptionsByTopic
    ListTopics                   : ListTopics

    resolveListSubscriptionsResult  : resolveListSubscriptionsResult
    resolveListTopicsResult         : resolveListTopicsResult
