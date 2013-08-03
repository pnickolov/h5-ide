#*************************************************************************************
#* Filename     : sns_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-03 14:22:14
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'sns_service'], ( Backbone, sns_service ) ->

    SNSModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #GetSubscriptionAttributes api (define function)
        GetSubscriptionAttributes : ( src, username, session_id, region_name, subscription_arn ) ->

            me = this

            src.model = me

            sns_service.GetSubscriptionAttributes src, username, session_id, region_name, subscription_arn, ( aws_result ) ->

                if !aws_result.is_error
                #GetSubscriptionAttributes succeed

                    sns_info = aws_result.resolved_data

                    #set vo


                else
                #GetSubscriptionAttributes failed

                    console.log 'sns.GetSubscriptionAttributes failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SNS__GET_SUBSCR_ATTRS_RETURN', aws_result


        #GetTopicAttributes api (define function)
        GetTopicAttributes : ( src, username, session_id, region_name, topic_arn ) ->

            me = this

            src.model = me

            sns_service.GetTopicAttributes src, username, session_id, region_name, topic_arn, ( aws_result ) ->

                if !aws_result.is_error
                #GetTopicAttributes succeed

                    sns_info = aws_result.resolved_data

                    #set vo


                else
                #GetTopicAttributes failed

                    console.log 'sns.GetTopicAttributes failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SNS__GET_TOPIC_ATTRS_RETURN', aws_result


        #ListSubscriptions api (define function)
        ListSubscriptions : ( src, username, session_id, region_name, next_token=null ) ->

            me = this

            src.model = me

            sns_service.ListSubscriptions src, username, session_id, region_name, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #ListSubscriptions succeed

                    sns_info = aws_result.resolved_data

                    #set vo


                else
                #ListSubscriptions failed

                    console.log 'sns.ListSubscriptions failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SNS__LST_SUBSCRS_RETURN', aws_result


        #ListSubscriptionsByTopic api (define function)
        ListSubscriptionsByTopic : ( src, username, session_id, region_name, topic_arn, next_token=null ) ->

            me = this

            src.model = me

            sns_service.ListSubscriptionsByTopic src, username, session_id, region_name, topic_arn, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #ListSubscriptionsByTopic succeed

                    sns_info = aws_result.resolved_data

                    #set vo


                else
                #ListSubscriptionsByTopic failed

                    console.log 'sns.ListSubscriptionsByTopic failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SNS__LST_SUBSCRS_BY_TOPIC_RETURN', aws_result


        #ListTopics api (define function)
        ListTopics : ( src, username, session_id, region_name, next_token=null ) ->

            me = this

            src.model = me

            sns_service.ListTopics src, username, session_id, region_name, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #ListTopics succeed

                    sns_info = aws_result.resolved_data

                    #set vo


                else
                #ListTopics failed

                    console.log 'sns.ListTopics failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SNS__LST_TOPICS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    sns_model = new SNSModel()

    #public (exposes methods)
    sns_model
