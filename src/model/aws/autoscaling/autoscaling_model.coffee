#*************************************************************************************
#* Filename     : autoscaling_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:42
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'autoscaling_service', 'base_model' ], ( Backbone, _, autoscaling_service, base_model ) ->

    AutoScalingModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #DescribeAdjustmentTypes api (define function)
        DescribeAdjustmentTypes : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            autoscaling_service.DescribeAdjustmentTypes src, username, session_id, region_name, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAdjustmentTypes succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_ADJT_TYPS_RETURN', aws_result

                else
                #DescribeAdjustmentTypes failed

                    console.log 'autoscaling.DescribeAdjustmentTypes failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeAutoScalingGroups api (define function)
        DescribeAutoScalingGroups : ( src, username, session_id, region_name, group_names=null, max_records=null, next_token=null ) ->

            me = this

            src.model = me

            autoscaling_service.DescribeAutoScalingGroups src, username, session_id, region_name, group_names, max_records, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAutoScalingGroups succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_ASL_GRPS_RETURN', aws_result

                else
                #DescribeAutoScalingGroups failed

                    console.log 'autoscaling.DescribeAutoScalingGroups failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeAutoScalingInstances api (define function)
        DescribeAutoScalingInstances : ( src, username, session_id, region_name, instance_ids=null, max_records=null, next_token=null ) ->

            me = this

            src.model = me

            autoscaling_service.DescribeAutoScalingInstances src, username, session_id, region_name, instance_ids, max_records, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAutoScalingInstances succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_ASL_INSS_RETURN', aws_result

                else
                #DescribeAutoScalingInstances failed

                    console.log 'autoscaling.DescribeAutoScalingInstances failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeAutoScalingNotificationTypes api (define function)
        DescribeAutoScalingNotificationTypes : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            autoscaling_service.DescribeAutoScalingNotificationTypes src, username, session_id, region_name, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeAutoScalingNotificationTypes succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_ASL_NTF_TYPS_RETURN', aws_result

                else
                #DescribeAutoScalingNotificationTypes failed

                    console.log 'autoscaling.DescribeAutoScalingNotificationTypes failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeLaunchConfigurations api (define function)
        DescribeLaunchConfigurations : ( src, username, session_id, region_name, config_names=null, max_records=null, next_token=null ) ->

            me = this

            src.model = me

            autoscaling_service.DescribeLaunchConfigurations src, username, session_id, region_name, config_names, max_records, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeLaunchConfigurations succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_LAUNCH_CONFS_RETURN', aws_result

                else
                #DescribeLaunchConfigurations failed

                    console.log 'autoscaling.DescribeLaunchConfigurations failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeMetricCollectionTypes api (define function)
        DescribeMetricCollectionTypes : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            autoscaling_service.DescribeMetricCollectionTypes src, username, session_id, region_name, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeMetricCollectionTypes succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_METRIC_COLL_TYPS_RETURN', aws_result

                else
                #DescribeMetricCollectionTypes failed

                    console.log 'autoscaling.DescribeMetricCollectionTypes failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeNotificationConfigurations api (define function)
        DescribeNotificationConfigurations : ( src, username, session_id, region_name, group_names=null, max_records=null, next_token=null ) ->

            me = this

            src.model = me

            autoscaling_service.DescribeNotificationConfigurations src, username, session_id, region_name, group_names, max_records, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeNotificationConfigurations succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_NTF_CONFS_RETURN', aws_result

                else
                #DescribeNotificationConfigurations failed

                    console.log 'autoscaling.DescribeNotificationConfigurations failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribePolicies api (define function)
        DescribePolicies : ( src, username, session_id, region_name, group_name=null, policy_names=null, max_records=null, next_token=null ) ->

            me = this

            src.model = me

            autoscaling_service.DescribePolicies src, username, session_id, region_name, group_name, policy_names, max_records, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribePolicies succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_PCYS_RETURN', aws_result

                else
                #DescribePolicies failed

                    console.log 'autoscaling.DescribePolicies failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeScalingActivities api (define function)
        DescribeScalingActivities : ( src, username, session_id, region_name, group_name=null, activity_ids=null, max_records=null, next_token=null ) ->

            me = this

            src.model = me

            autoscaling_service.DescribeScalingActivities src, username, session_id, region_name, group_name, activity_ids, max_records, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeScalingActivities succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_SCALING_ACTIS_RETURN', aws_result

                else
                #DescribeScalingActivities failed

                    console.log 'autoscaling.DescribeScalingActivities failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeScalingProcessTypes api (define function)
        DescribeScalingProcessTypes : ( src, username, session_id, region_name ) ->

            me = this

            src.model = me

            autoscaling_service.DescribeScalingProcessTypes src, username, session_id, region_name, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeScalingProcessTypes succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_SCALING_PRC_TYPS_RETURN', aws_result

                else
                #DescribeScalingProcessTypes failed

                    console.log 'autoscaling.DescribeScalingProcessTypes failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeScheduledActions api (define function)
        DescribeScheduledActions : ( src, username, session_id, region_name, group_name=null, action_names=null, start_time=null, end_time=null, max_records=null, next_token=null ) ->

            me = this

            src.model = me

            autoscaling_service.DescribeScheduledActions src, username, session_id, region_name, group_name, action_names, start_time, end_time, max_records, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeScheduledActions succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_SCHD_ACTS_RETURN', aws_result

                else
                #DescribeScheduledActions failed

                    console.log 'autoscaling.DescribeScheduledActions failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeTags api (define function)
        DescribeTags : ( src, username, session_id, region_name, filters=null, max_records=null, next_token=null ) ->

            me = this

            src.model = me

            autoscaling_service.DescribeTags src, username, session_id, region_name, filters, max_records, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeTags succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'ASL__DESC_TAGS_RETURN', aws_result

                else
                #DescribeTags failed

                    console.log 'autoscaling.DescribeTags failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    autoscaling_model = new AutoScalingModel()

    #public (exposes methods)
    autoscaling_model

