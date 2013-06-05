#*************************************************************************************
#* Filename     : aws_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:07
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'aws_service', 'aws_vo'], ( Backbone, aws_service, aws_vo ) ->

    AWSModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : aws_vo.data
        }

        ###### api ######
        #quickstart api (define function)
        quickstart : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            aws_service.quickstart src, username, session_id, region_name, ( aws_result ) ->

                if !aws_result.is_error
                #quickstart succeed

                    aws_info = aws_result.resolved_data

                    #set vo


                else
                #quickstart failed

                    console.log 'aws.quickstart failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'AWS_QUICKSTART_RETURN', aws_result


        #Public api (define function)
        Public : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            aws_service.Public src, username, session_id, region_name, ( aws_result ) ->

                if !aws_result.is_error
                #Public succeed

                    aws_info = aws_result.resolved_data

                    #set vo


                else
                #Public failed

                    console.log 'aws.Public failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'AWS__PUBLIC_RETURN', aws_result


        #info api (define function)
        info : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            aws_service.info src, username, session_id, region_name, ( aws_result ) ->

                if !aws_result.is_error
                #info succeed

                    aws_info = aws_result.resolved_data

                    #set vo


                else
                #info failed

                    console.log 'aws.info failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'AWS_INFO_RETURN', aws_result


        #resource api (define function)
        resource : ( src, username, session_id, region_name=null, resources=null ) ->

            me = this

            src.model = me

            aws_service.resource src, username, session_id, region_name, resources, ( aws_result ) ->

                if !aws_result.is_error
                #resource succeed

                    aws_info = aws_result.resolved_data

                    #set vo


                else
                #resource failed

                    console.log 'aws.resource failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'AWS_RESOURCE_RETURN', aws_result


        #price api (define function)
        price : ( src, username, session_id ) ->

            me = this

            src.model = me

            aws_service.price src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #price succeed

                    aws_info = aws_result.resolved_data

                    #set vo


                else
                #price failed

                    console.log 'aws.price failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'AWS_PRICE_RETURN', aws_result


        #status api (define function)
        status : ( src, username, session_id ) ->

            me = this

            src.model = me

            aws_service.status src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #status succeed

                    aws_info = aws_result.resolved_data

                    #set vo


                else
                #status failed

                    console.log 'aws.status failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'AWS_STATUS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    aws_model = new AWSModel()

    #public (exposes methods)
    aws_model

