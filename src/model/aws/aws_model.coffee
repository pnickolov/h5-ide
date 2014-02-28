#*************************************************************************************
#* Filename     : aws_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:44
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'aws_service', 'base_model' ], ( Backbone, _, aws_service, base_model ) ->

    AWSModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #quickstart api (define function)
        quickstart : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            aws_service.quickstart src, username, session_id, region_name, ( aws_result ) ->

                if !aws_result.is_error
                #quickstart succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'AWS_QUICKSTART_RETURN', aws_result

                else
                #quickstart failed

                    console.log 'aws.quickstart failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #Public api (define function)
        Public : ( src, username, session_id, region_name, filters=null ) ->

            me = this

            src.model = me

            aws_service.Public src, username, session_id, region_name, filters, ( aws_result ) ->

                if !aws_result.is_error
                #Public succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'AWS__PUBLIC_RETURN', aws_result

                else
                #Public failed

                    console.log 'aws.Public failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #info api (define function)
        info : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            aws_service.info src, username, session_id, region_name, ( aws_result ) ->

                if !aws_result.is_error
                #info succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'AWS_INFO_RETURN', aws_result

                else
                #info failed

                    console.log 'aws.info failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #resource api (define function)
        resource : ( src, username, session_id, region_name=null, resources=null, addition='all', retry_times=1 ) ->

            me = this

            src.model = me

            ### env:dev ###
            key = "aws_resource_#{region_name}"
            aws_result = MC.storage.get key
            if aws_result
                if addition is 'vpc'
                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'AWS_RESOURCE_RETURN', aws_result

                else if !aws_result.is_error
                #resource succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'AWS_RESOURCE_RETURN', aws_result

                else
                #resource failed

                    console.log 'aws.resource failed, error is ' + aws_result.error_message
                    me.pub aws_result

                return

            ### env:dev:end ###

            aws_service.resource src, username, session_id, region_name, resources, addition, retry_times, ( aws_result ) ->
                ### env:dev ###
                MC.storage.set key, aws_result
                ### env:dev:end ###

                if addition is 'vpc'
                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'AWS_RESOURCE_RETURN', aws_result

                else if !aws_result.is_error
                #resource succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'AWS_RESOURCE_RETURN', aws_result

                else
                #resource failed

                    console.log 'aws.resource failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #price api (define function)
        price : ( src, username, session_id ) ->

            me = this

            src.model = me

            aws_service.price src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #price succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'AWS_PRICE_RETURN', aws_result

                else
                #price failed

                    console.log 'aws.price failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #status api (define function)
        status : ( src, username, session_id ) ->

            me = this

            src.model = me

            aws_service.status src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #status succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'AWS_STATUS_RETURN', aws_result

                else
                #status failed

                    console.log 'aws.status failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #vpc_resource api (define function)
        vpc_resource : ( src, username, session_id, region_name=null, resources=null, addition='all', retry_times=1 ) ->

            me = this

            src.model = me

            aws_service.vpc_resource src, username, session_id, region_name, resources, addition, retry_times, ( aws_result ) ->

                #if !aws_result.is_error
                #vpc_resource succeed
                #
                #else
                #vpc_resource failed
                #
                #    console.log 'aws.vpc_resource failed, error is ' + aws_result.error_message
                #    me.pub aws_result

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'AWS_VPC__RESOURCE_RETURN', aws_result

        #stat_resource api (define function)
        stat_resource : ( src, username, session_id, region_name=null, resources=null ) ->

            me = this

            src.model = me

            aws_service.stat_resource src, username, session_id, region_name, resources, ( aws_result ) ->

                if !aws_result.is_error
                #stat_resource succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'AWS_STAT__RESOURCE_RETURN', aws_result

                else
                #stat_resource failed

                    console.log 'aws.stat_resource failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #property api (define function)
        property : ( src, username, session_id ) ->

            me = this

            src.model = me

            aws_service.property src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #property succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'AWS_PROPERTY_RETURN', aws_result

                else
                #property failed

                    console.log 'aws.property failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    aws_model = new AWSModel()

    #public (exposes methods)
    aws_model

