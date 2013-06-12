#*************************************************************************************
#* Filename     : autoscaling_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:11
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'autoscaling_parser', 'result_vo' ], ( MC, autoscaling_parser, result_vo ) ->

    URL = '/aws/autoscaling/autoscaling/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "autoscaling." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, src
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
            console.log "autoscaling." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def DescribeAdjustmentTypes(self, username, session_id, region_name):
    DescribeAdjustmentTypes = ( src, username, session_id, region_name, callback ) ->
        send_request "DescribeAdjustmentTypes", src, [ username, session_id, region_name ], autoscaling_parser.parserDescribeAdjustmentTypesReturn, callback
        true

    #def DescribeAutoScalingGroups(self, username, session_id, region_name, group_names=None, max_records=None, next_token=None):
    DescribeAutoScalingGroups = ( src, username, session_id, region_name, group_names=null, max_records=null, next_token=null, callback ) ->
        send_request "DescribeAutoScalingGroups", src, [ username, session_id, region_name, group_names, max_records, next_token ], autoscaling_parser.parserDescribeAutoScalingGroupsReturn, callback
        true

    #def DescribeAutoScalingInstances(self, username, session_id, region_name, instance_ids=None, max_records=None, next_token=None):
    DescribeAutoScalingInstances = ( src, username, session_id, region_name, instance_ids=null, max_records=null, next_token=null, callback ) ->
        send_request "DescribeAutoScalingInstances", src, [ username, session_id, region_name, instance_ids, max_records, next_token ], autoscaling_parser.parserDescribeAutoScalingInstancesReturn, callback
        true

    #def DescribeAutoScalingNotificationTypes(self, username, session_id, region_name):
    DescribeAutoScalingNotificationTypes = ( src, username, session_id, region_name, callback ) ->
        send_request "DescribeAutoScalingNotificationTypes", src, [ username, session_id, region_name ], autoscaling_parser.parserDescribeAutoScalingNotificationTypesReturn, callback
        true

    #def DescribeLaunchConfigurations(self, username, session_id, region_name, config_names=None, max_records=None, next_token=None):
    DescribeLaunchConfigurations = ( src, username, session_id, region_name, config_names=null, max_records=null, next_token=null, callback ) ->
        send_request "DescribeLaunchConfigurations", src, [ username, session_id, region_name, config_names, max_records, next_token ], autoscaling_parser.parserDescribeLaunchConfigurationsReturn, callback
        true

    #def DescribeMetricCollectionTypes(self, username, session_id, region_name):
    DescribeMetricCollectionTypes = ( src, username, session_id, region_name, callback ) ->
        send_request "DescribeMetricCollectionTypes", src, [ username, session_id, region_name ], autoscaling_parser.parserDescribeMetricCollectionTypesReturn, callback
        true

    #def DescribeNotificationConfigurations(self, username, session_id, region_name, group_names=None, max_records=None, next_token=None):
    DescribeNotificationConfigurations = ( src, username, session_id, region_name, group_names=null, max_records=null, next_token=null, callback ) ->
        send_request "DescribeNotificationConfigurations", src, [ username, session_id, region_name, group_names, max_records, next_token ], autoscaling_parser.parserDescribeNotificationConfigurationsReturn, callback
        true

    #def DescribePolicies(self, username, session_id, region_name, group_name=None, policy_names=None, max_records=None, next_token=None):
    DescribePolicies = ( src, username, session_id, region_name, group_name=null, policy_names=null, max_records=null, next_token=null, callback ) ->
        send_request "DescribePolicies", src, [ username, session_id, region_name, group_name, policy_names, max_records, next_token ], autoscaling_parser.parserDescribePoliciesReturn, callback
        true

    #def DescribeScalingActivities(self, username, session_id, region_name,
    DescribeScalingActivities = ( src, username, session_id, callback ) ->
        send_request "DescribeScalingActivities", src, [ username, session_id ], autoscaling_parser.parserDescribeScalingActivitiesReturn, callback
        true

    #def DescribeScalingProcessTypes(self, username, session_id, region_name):
    DescribeScalingProcessTypes = ( src, username, session_id, region_name, callback ) ->
        send_request "DescribeScalingProcessTypes", src, [ username, session_id, region_name ], autoscaling_parser.parserDescribeScalingProcessTypesReturn, callback
        true

    #def DescribeScheduledActions(self, username, session_id, region_name,
    DescribeScheduledActions = ( src, username, session_id, callback ) ->
        send_request "DescribeScheduledActions", src, [ username, session_id ], autoscaling_parser.parserDescribeScheduledActionsReturn, callback
        true

    #def DescribeTags(self, username, session_id, region_name, filters=None, max_records=None, next_token=None):
    DescribeTags = ( src, username, session_id, region_name, filters=null, max_records=null, next_token=null, callback ) ->
        send_request "DescribeTags", src, [ username, session_id, region_name, filters, max_records, next_token ], autoscaling_parser.parserDescribeTagsReturn, callback
        true


    #############################################################
    #public
    DescribeAdjustmentTypes      : DescribeAdjustmentTypes
    DescribeAutoScalingGroups    : DescribeAutoScalingGroups
    DescribeAutoScalingInstances : DescribeAutoScalingInstances
    DescribeAutoScalingNotificationTypes : DescribeAutoScalingNotificationTypes
    DescribeLaunchConfigurations : DescribeLaunchConfigurations
    DescribeMetricCollectionTypes : DescribeMetricCollectionTypes
    DescribeNotificationConfigurations : DescribeNotificationConfigurations
    DescribePolicies             : DescribePolicies
    DescribeScalingActivities    : DescribeScalingActivities
    DescribeScalingProcessTypes  : DescribeScalingProcessTypes
    DescribeScheduledActions     : DescribeScheduledActions
    DescribeTags                 : DescribeTags

