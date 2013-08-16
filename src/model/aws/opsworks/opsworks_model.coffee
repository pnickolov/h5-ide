#*************************************************************************************
#* Filename     : opsworks_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:14
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'opsworks_service'], ( Backbone, opsworks_service) ->

    OpsWorksModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        ###### api ######
        #DescribeApps api (define function)
        DescribeApps : ( src, username, session_id, region_name, app_ids=null, stack_id=null ) ->

            me = this

            src.model = me

            opsworks_service.DescribeApps src, username, session_id, region_name, app_ids, stack_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeApps succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeApps failed

                    console.log 'opsworks.DescribeApps failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_APPS_RETURN', aws_result


        #DescribeStacks api (define function)
        DescribeStacks : ( src, username, session_id, region_name, stack_ids=null ) ->

            me = this

            src.model = me

            opsworks_service.DescribeStacks src, username, session_id, region_name, stack_ids, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeStacks succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeStacks failed

                    console.log 'opsworks.DescribeStacks failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_STACKS_RETURN', aws_result


        #DescribeCommands api (define function)
        DescribeCommands : ( src, username, session_id, region_name, command_ids=null, deployment_id=null, instance_id=null ) ->

            me = this

            src.model = me

            opsworks_service.DescribeCommands src, username, session_id, region_name, command_ids, deployment_id, instance_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeCommands succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeCommands failed

                    console.log 'opsworks.DescribeCommands failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_COMMANDS_RETURN', aws_result


        #DescribeDeployments api (define function)
        DescribeDeployments : ( src, username, session_id, region_name, app_id=null, deployment_ids=null, stack_id=null ) ->

            me = this

            src.model = me

            opsworks_service.DescribeDeployments src, username, session_id, region_name, app_id, deployment_ids, stack_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeDeployments succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeDeployments failed

                    console.log 'opsworks.DescribeDeployments failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_DEPLOYMENTS_RETURN', aws_result


        #DescribeElasticIps api (define function)
        DescribeElasticIps : ( src, username, session_id, region_name, instance_id=null, ips=null ) ->

            me = this

            src.model = me

            opsworks_service.DescribeElasticIps src, username, session_id, region_name, instance_id, ips, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeElasticIps succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeElasticIps failed

                    console.log 'opsworks.DescribeElasticIps failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_ELASTIC_IPS_RETURN', aws_result


        #DescribeInstances api (define function)
        DescribeInstances : ( src, username, session_id, region_name, app_id=null, instance_ids=null, layer_id=null, stack_id=null ) ->

            me = this

            src.model = me

            opsworks_service.DescribeInstances src, username, session_id, region_name, app_id, instance_ids, layer_id, stack_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeInstances succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeInstances failed

                    console.log 'opsworks.DescribeInstances failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_INSS_RETURN', aws_result


        #DescribeLayers api (define function)
        DescribeLayers : ( src, username, session_id, region_name, stack_id, layer_ids=null ) ->

            me = this

            src.model = me

            opsworks_service.DescribeLayers src, username, session_id, region_name, stack_id, layer_ids, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeLayers succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeLayers failed

                    console.log 'opsworks.DescribeLayers failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_LAYERS_RETURN', aws_result


        #DescribeLoadBasedAutoScaling api (define function)
        DescribeLoadBasedAutoScaling : ( src, username, session_id, region_name, layer_ids ) ->

            me = this

            src.model = me

            opsworks_service.DescribeLoadBasedAutoScaling src, username, session_id, region_name, layer_ids, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeLoadBasedAutoScaling succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeLoadBasedAutoScaling failed

                    console.log 'opsworks.DescribeLoadBasedAutoScaling failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_LOAD_BASED_ASL_RETURN', aws_result


        #DescribePermissions api (define function)
        DescribePermissions : ( src, username, session_id, region_name, iam_user_arn, stack_id ) ->

            me = this

            src.model = me

            opsworks_service.DescribePermissions src, username, session_id, region_name, iam_user_arn, stack_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribePermissions succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribePermissions failed

                    console.log 'opsworks.DescribePermissions failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_PERMISSIONS_RETURN', aws_result


        #DescribeRaidArrays api (define function)
        DescribeRaidArrays : ( src, username, session_id, region_name, instance_id=null, raid_array_ids=null ) ->

            me = this

            src.model = me

            opsworks_service.DescribeRaidArrays src, username, session_id, region_name, instance_id, raid_array_ids, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeRaidArrays succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeRaidArrays failed

                    console.log 'opsworks.DescribeRaidArrays failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_RAID_ARRAYS_RETURN', aws_result


        #DescribeServiceErrors api (define function)
        DescribeServiceErrors : ( src, username, session_id, region_name, instance_id=null, service_error_ids=null, stack_id=null ) ->

            me = this

            src.model = me

            opsworks_service.DescribeServiceErrors src, username, session_id, region_name, instance_id, service_error_ids, stack_id, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeServiceErrors succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeServiceErrors failed

                    console.log 'opsworks.DescribeServiceErrors failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_SERVICE_ERRORS_RETURN', aws_result


        #DescribeTimeBasedAutoScaling api (define function)
        DescribeTimeBasedAutoScaling : ( src, username, session_id, region_name, instance_ids ) ->

            me = this

            src.model = me

            opsworks_service.DescribeTimeBasedAutoScaling src, username, session_id, region_name, instance_ids, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeTimeBasedAutoScaling succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeTimeBasedAutoScaling failed

                    console.log 'opsworks.DescribeTimeBasedAutoScaling failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_TIME_BASED_ASL_RETURN', aws_result


        #DescribeUserProfiles api (define function)
        DescribeUserProfiles : ( src, username, session_id, region_name, iam_user_arns ) ->

            me = this

            src.model = me

            opsworks_service.DescribeUserProfiles src, username, session_id, region_name, iam_user_arns, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeUserProfiles succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeUserProfiles failed

                    console.log 'opsworks.DescribeUserProfiles failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_USER_PROFILES_RETURN', aws_result


        #DescribeVolumes api (define function)
        DescribeVolumes : ( src, username, session_id, region_name, instance_id=null, raid_array_id=null, volume_ids=null ) ->

            me = this

            src.model = me

            opsworks_service.DescribeVolumes src, username, session_id, region_name, instance_id, raid_array_id, volume_ids, ( aws_result ) ->

                if !aws_result.is_error
                #DescribeVolumes succeed

                    opsworks_info = aws_result.resolved_data

                    #set vo


                else
                #DescribeVolumes failed

                    console.log 'opsworks.DescribeVolumes failed, error is ' + aws_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'OPSWORKS__DESC_VOLS_RETURN', aws_result



    }

    #############################################################
    #private (instantiation)
    opsworks_model = new OpsWorksModel()

    #public (exposes methods)
    opsworks_model

