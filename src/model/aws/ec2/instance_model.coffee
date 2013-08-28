#*************************************************************************************
#* Filename     : instance_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-08-26 12:19:48
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'instance_service', 'base_model' ], ( Backbone, _, instance_service, base_model ) ->

    InstanceModel = Backbone.Model.extend {

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #RunInstances api (define function)
        RunInstances : ( src, username, session_id ) ->

            me = this

            src.model = me

            instance_service.RunInstances src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #RunInstances succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_RUN_INSTANCES_RETURN', aws_result

                else
                #RunInstances failed

                    console.log 'instance.RunInstances failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #StartInstances api (define function)
        StartInstances : ( src, username, session_id, region_name, instance_ids=null ) ->

            me = this

            src.model = me

            instance_service.StartInstances src, username, session_id, region_name, instance_ids, ( aws_result ) ->

                if !aws_result.is_error
                #StartInstances succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_START_INSTANCES_RETURN', aws_result

                else
                #StartInstances failed

                    console.log 'instance.StartInstances failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #StopInstances api (define function)
        StopInstances : ( src, username, session_id, region_name, instance_ids=null, force=false ) ->

            me = this

            src.model = me

            instance_service.StopInstances src, username, session_id, region_name, instance_ids, force, ( aws_result ) ->

                if !aws_result.is_error
                #StopInstances succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_STOP_INSTANCES_RETURN', aws_result

                else
                #StopInstances failed

                    console.log 'instance.StopInstances failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #RebootInstances api (define function)
        RebootInstances : ( src, username, session_id, region_name, instance_ids=null ) ->

            me = this

            src.model = me

            instance_service.RebootInstances src, username, session_id, region_name, instance_ids, ( aws_result ) ->

                if !aws_result.is_error
                #RebootInstances succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_REBOOT_INSTANCES_RETURN', aws_result

                else
                #RebootInstances failed

                    console.log 'instance.RebootInstances failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #TerminateInstances api (define function)
        TerminateInstances : ( src, username, session_id, region_name, instance_ids=null ) ->

            me = this

            src.model = me

            instance_service.TerminateInstances src, username, session_id, region_name, instance_ids, ( aws_result ) ->

                if !aws_result.is_error
                #TerminateInstances succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_TERMINATE_INSTANCES_RETURN', aws_result

                else
                #TerminateInstances failed

                    console.log 'instance.TerminateInstances failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #MonitorInstances api (define function)
        MonitorInstances : ( src, username, session_id, region_name, instance_ids ) ->

            me = this

            src.model = me

            instance_service.MonitorInstances src, username, session_id, region_name, instance_ids, ( aws_result ) ->

                if !aws_result.is_error
                #MonitorInstances succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_MONITOR_INSTANCES_RETURN', aws_result

                else
                #MonitorInstances failed

                    console.log 'instance.MonitorInstances failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #UnmonitorInstances api (define function)
        UnmonitorInstances : ( src, username, session_id, region_name, instance_ids ) ->

            me = this

            src.model = me

            instance_service.UnmonitorInstances src, username, session_id, region_name, instance_ids, ( aws_result ) ->

                if !aws_result.is_error
                #UnmonitorInstances succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_UNMONITOR_INSTANCES_RETURN', aws_result

                else
                #UnmonitorInstances failed

                    console.log 'instance.UnmonitorInstances failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #BundleInstance api (define function)
        BundleInstance : ( src, username, session_id, region_name, instance_id, s3_bucket ) ->

            me = this

            src.model = me

            instance_service.BundleInstance src, username, session_id, region_name, instance_id, s3_bucket, ( aws_result ) ->

                if !aws_result.is_error
                #BundleInstance succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_BUNDLE_INSTANCE_RETURN', aws_result

                else
                #BundleInstance failed

                    console.log 'instance.BundleInstance failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #CancelBundleTask api (define function)
        CancelBundleTask : ( src, username, session_id, region_name, bundle_id ) ->

            me = this

            src.model = me

            instance_service.CancelBundleTask src, username, session_id, region_name, bundle_id, ( aws_result ) ->

                if !aws_result.is_error
                #CancelBundleTask succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_CANCEL_BUNDLE_TASK_RETURN', aws_result

                else
                #CancelBundleTask failed

                    console.log 'instance.CancelBundleTask failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #ModifyInstanceAttribute api (define function)
        ModifyInstanceAttribute : ( src, username, session_id ) ->

            me = this

            src.model = me

            instance_service.ModifyInstanceAttribute src, username, session_id, ( aws_result ) ->

                if !aws_result.is_error
                #ModifyInstanceAttribute succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_MODIFY_INSTANCE_ATTR_RETURN', aws_result

                else
                #ModifyInstanceAttribute failed

                    console.log 'instance.ModifyInstanceAttribute failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #ResetInstanceAttribute api (define function)
        ResetInstanceAttribute : ( src, username, session_id, region_name, instance_id, attribute_name ) ->

            me = this

            src.model = me

            instance_service.ResetInstanceAttribute src, username, session_id, region_name, instance_id, attribute_name, ( aws_result ) ->

                if !aws_result.is_error
                #ResetInstanceAttribute succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_RESET_INSTANCE_ATTR_RETURN', aws_result

                else
                #ResetInstanceAttribute failed

                    console.log 'instance.ResetInstanceAttribute failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #ConfirmProductInstance api (define function)
        ConfirmProductInstance : ( src, username, session_id, region_name, instance_id, product_code ) ->

            me = this

            src.model = me

            instance_service.ConfirmProductInstance src, username, session_id, region_name, instance_id, product_code, ( aws_result ) ->

                if !aws_result.is_error
                #ConfirmProductInstance succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_CONFIRM_PRODUCT_INSTANCE_RETURN', aws_result

                else
                #ConfirmProductInstance failed

                    console.log 'instance.ConfirmProductInstance failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeInstances api (define function)
        DescribeInstances : ( src, username, session_id, region_name, instance_ids=null, filters=null ) ->

            me = this

            src.model = me

            instance_service.DescribeInstances src, username, session_id, region_name, instance_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeInstances succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_DESC_INSTANCES_RETURN', aws_result

                else
                #DescribeInstances failed

                    console.log 'instance.DescribeInstances failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeInstanceStatus api (define function)
        DescribeInstanceStatus : ( src, username, session_id, region_name, instance_ids=null, include_all_instances=false, max_results=1000, next_token=null ) ->

            me = this

            src.model = me

            instance_service.DescribeInstanceStatus src, username, session_id, region_name, instance_ids, include_all_instances, max_results, next_token, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeInstanceStatus succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_DESC_INSTANCE_STATUS_RETURN', aws_result

                else
                #DescribeInstanceStatus failed

                    console.log 'instance.DescribeInstanceStatus failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeBundleTasks api (define function)
        DescribeBundleTasks : ( src, username, session_id, region_name, bundle_ids=null, filters=null ) ->

            me = this

            src.model = me

            instance_service.DescribeBundleTasks src, username, session_id, region_name, bundle_ids, filters, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeBundleTasks succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_DESC_BUNDLE_TASKS_RETURN', aws_result

                else
                #DescribeBundleTasks failed

                    console.log 'instance.DescribeBundleTasks failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #DescribeInstanceAttribute api (define function)
        DescribeInstanceAttribute : ( src, username, session_id, region_name, instance_id, attribute_name ) ->

            me = this

            src.model = me

            instance_service.DescribeInstanceAttribute src, username, session_id, region_name, instance_id, attribute_name, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeInstanceAttribute succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_DESC_INSTANCE_ATTR_RETURN', aws_result

                else
                #DescribeInstanceAttribute failed

                    console.log 'instance.DescribeInstanceAttribute failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #GetConsoleOutput api (define function)
        GetConsoleOutput : ( src, username, session_id, region_name, instance_id ) ->

            me = this

            src.model = me

            instance_service.GetConsoleOutput src, username, session_id, region_name, instance_id, ( aws_result ) ->

                if !aws_result.is_error
                #GetConsoleOutput succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_GET_CONSOLE_OUTPUT_RETURN', aws_result

                else
                #GetConsoleOutput failed

                    console.log 'instance.GetConsoleOutput failed, error is ' + aws_result.error_message
                    me.pub aws_result



        #GetPasswordData api (define function)
        GetPasswordData : ( src, username, session_id, region_name, instance_id, key_data=null ) ->

            me = this

            src.model = me

            instance_service.GetPasswordData src, username, session_id, region_name, instance_id, key_data, ( aws_result ) ->

                if !aws_result.is_error
                #GetPasswordData succeed

                    #dispatch event (dispatch event whenever login succeed or failed)
                    if src.sender and src.sender.trigger then src.sender.trigger 'EC2_INS_GET_PWD_DATA_RETURN', aws_result

                else
                #GetPasswordData failed

                    console.log 'instance.GetPasswordData failed, error is ' + aws_result.error_message
                    me.pub aws_result




    }

    #############################################################
    #private (instantiation)
    instance_model = new InstanceModel()

    #public (exposes methods)
    instance_model

