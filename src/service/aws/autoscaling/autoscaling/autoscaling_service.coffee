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

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/autoscaling/'

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
			console.log "autoscaling." + api_name + " error:" + error.toString()


		true
	# end of send_request

	#///////////////// Parser for DescribeAdjustmentTypes return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeAdjustmentTypesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeAdjustmentTypesResponse

	#private (parser DescribeAdjustmentTypes return)
	parserDescribeAdjustmentTypesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeAdjustmentTypesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeAdjustmentTypesReturn


	#///////////////// Parser for DescribeAutoScalingGroups return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeAutoScalingGroupsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeAutoScalingGroupsResponse.DescribeAutoScalingGroupsResult.AutoScalingGroups

	#private (parser DescribeAutoScalingGroups return)
	parserDescribeAutoScalingGroupsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeAutoScalingGroupsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeAutoScalingGroupsReturn


	#///////////////// Parser for DescribeAutoScalingInstances return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeAutoScalingInstancesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeAutoScalingInstancesResponse.DescribeAutoScalingInstancesResult.AutoScalingInstances

	#private (parser DescribeAutoScalingInstances return)
	parserDescribeAutoScalingInstancesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeAutoScalingInstancesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeAutoScalingInstancesReturn


	#///////////////// Parser for DescribeAutoScalingNotificationTypes return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeAutoScalingNotificationTypesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeAutoScalingNotificationTypesResponse

	#private (parser DescribeAutoScalingNotificationTypes return)
	parserDescribeAutoScalingNotificationTypesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeAutoScalingNotificationTypesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeAutoScalingNotificationTypesReturn


	#///////////////// Parser for DescribeLaunchConfigurations return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeLaunchConfigurationsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeLaunchConfigurationsResponse.DescribeLaunchConfigurationsResult.LaunchConfigurations


	#private (parser DescribeLaunchConfigurations return)
	parserDescribeLaunchConfigurationsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeLaunchConfigurationsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeLaunchConfigurationsReturn


	#///////////////// Parser for DescribeMetricCollectionTypes return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeMetricCollectionTypesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeMetricCollectionTypesResponse

	#private (parser DescribeMetricCollectionTypes return)
	parserDescribeMetricCollectionTypesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeMetricCollectionTypesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeMetricCollectionTypesReturn


	#///////////////// Parser for DescribeNotificationConfigurations return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeNotificationConfigurationsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeNotificationConfigurationsResponse.DescribeNotificationConfigurationsResult.NotificationConfigurations

	#private (parser DescribeNotificationConfigurations return)
	parserDescribeNotificationConfigurationsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeNotificationConfigurationsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeNotificationConfigurationsReturn


	#///////////////// Parser for DescribePolicies return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribePoliciesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribePoliciesResponse.DescribePoliciesResult.ScalingPolicies

	#private (parser DescribePolicies return)
	parserDescribePoliciesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribePoliciesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribePoliciesReturn


	#///////////////// Parser for DescribeScalingActivities return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeScalingActivitiesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeScalingActivitiesResponse.DescribeScalingActivitiesResult.Activities

	#private (parser DescribeScalingActivities return)
	parserDescribeScalingActivitiesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeScalingActivitiesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeScalingActivitiesReturn


	#///////////////// Parser for DescribeScalingProcessTypes return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeScalingProcessTypesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeScalingProcessTypesResponse.DescribeScalingProcessTypesResult

	#private (parser DescribeScalingProcessTypes return)
	parserDescribeScalingProcessTypesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeScalingProcessTypesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeScalingProcessTypesReturn


	#///////////////// Parser for DescribeScheduledActions return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeScheduledActionsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeScheduledActionsResponse.DescribeScheduledActionsResult.ScheduledUpdateGroupActions

	#private (parser DescribeScheduledActions return)
	parserDescribeScheduledActionsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeScheduledActionsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeScheduledActionsReturn


	#///////////////// Parser for DescribeTags return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeTagsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeTagsResponse

	#private (parser DescribeTags return)
	parserDescribeTagsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeTagsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeTagsReturn


	#############################################################

	#def DescribeAdjustmentTypes(self, username, session_id, region_name):
	DescribeAdjustmentTypes = ( src, username, session_id, region_name, callback ) ->
		send_request "DescribeAdjustmentTypes", src, [ username, session_id, region_name ], parserDescribeAdjustmentTypesReturn, callback
		true

	#def DescribeAutoScalingGroups(self, username, session_id, region_name, group_names=None, max_records=None, next_token=None):
	DescribeAutoScalingGroups = ( src, username, session_id, region_name, group_names=null, max_records=null, next_token=null, callback ) ->
		send_request "DescribeAutoScalingGroups", src, [ username, session_id, region_name, group_names, max_records, next_token ], parserDescribeAutoScalingGroupsReturn, callback
		true

	#def DescribeAutoScalingInstances(self, username, session_id, region_name, instance_ids=None, max_records=None, next_token=None):
	DescribeAutoScalingInstances = ( src, username, session_id, region_name, instance_ids=null, max_records=null, next_token=null, callback ) ->
		send_request "DescribeAutoScalingInstances", src, [ username, session_id, region_name, instance_ids, max_records, next_token ], parserDescribeAutoScalingInstancesReturn, callback
		true

	#def DescribeAutoScalingNotificationTypes(self, username, session_id, region_name):
	DescribeAutoScalingNotificationTypes = ( src, username, session_id, region_name, callback ) ->
		send_request "DescribeAutoScalingNotificationTypes", src, [ username, session_id, region_name ], parserDescribeAutoScalingNotificationTypesReturn, callback
		true

	#def DescribeLaunchConfigurations(self, username, session_id, region_name, config_names=None, max_records=None, next_token=None):
	DescribeLaunchConfigurations = ( src, username, session_id, region_name, config_names=null, max_records=null, next_token=null, callback ) ->
		send_request "DescribeLaunchConfigurations", src, [ username, session_id, region_name, config_names, max_records, next_token ], parserDescribeLaunchConfigurationsReturn, callback
		true

	#def DescribeMetricCollectionTypes(self, username, session_id, region_name):
	DescribeMetricCollectionTypes = ( src, username, session_id, region_name, callback ) ->
		send_request "DescribeMetricCollectionTypes", src, [ username, session_id, region_name ], parserDescribeMetricCollectionTypesReturn, callback
		true

	#def DescribeNotificationConfigurations(self, username, session_id, region_name, group_names=None, max_records=None, next_token=None):
	DescribeNotificationConfigurations = ( src, username, session_id, region_name, group_names=null, max_records=null, next_token=null, callback ) ->
		send_request "DescribeNotificationConfigurations", src, [ username, session_id, region_name, group_names, max_records, next_token ], parserDescribeNotificationConfigurationsReturn, callback
		true

	#def DescribePolicies(self, username, session_id, region_name, group_name=None, policy_names=None, max_records=None, next_token=None):
	DescribePolicies = ( src, username, session_id, region_name, group_name=null, policy_names=null, max_records=null, next_token=null, callback ) ->
		send_request "DescribePolicies", src, [ username, session_id, region_name, group_name, policy_names, max_records, next_token ], parserDescribePoliciesReturn, callback
		true

	#def DescribeScalingActivities(self, username, session_id, region_name, group_name=None, activity_ids=None, max_records=None, next_token=None):
	DescribeScalingActivities = ( src, username, session_id, region_name, group_name=null, activity_ids=null, max_records=null, next_token=null, callback ) ->
		send_request "DescribeScalingActivities", src, [ username, session_id, region_name, group_name, activity_ids, max_records, next_token ], parserDescribeScalingActivitiesReturn, callback
		true

	#def DescribeScalingProcessTypes(self, username, session_id, region_name):
	DescribeScalingProcessTypes = ( src, username, session_id, region_name, callback ) ->
		send_request "DescribeScalingProcessTypes", src, [ username, session_id, region_name ], parserDescribeScalingProcessTypesReturn, callback
		true

	#def DescribeScheduledActions(self, username, session_id, region_name, group_name=None, action_names=None, start_time=None, end_time=None, max_records=None, next_token=None):
	DescribeScheduledActions = ( src, username, session_id, region_name, group_name=null, action_names=null, start_time=null, end_time=null, max_records=null, next_token=null, callback ) ->
		send_request "DescribeScheduledActions", src, [ username, session_id, region_name, group_name, action_names, start_time, end_time, max_records, next_token ], parserDescribeScheduledActionsReturn, callback
		true

	#def DescribeTags(self, username, session_id, region_name, filters=None, max_records=None, next_token=None):
	DescribeTags = ( src, username, session_id, region_name, filters=null, max_records=null, next_token=null, callback ) ->
		send_request "DescribeTags", src, [ username, session_id, region_name, filters, max_records, next_token ], parserDescribeTagsReturn, callback
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

	resolveDescribeAutoScalingGroupsResult           : resolveDescribeAutoScalingGroupsResult
	resolveDescribeLaunchConfigurationsResult        : resolveDescribeLaunchConfigurationsResult
	resolveDescribeNotificationConfigurationsResult  : resolveDescribeNotificationConfigurationsResult
	resolveDescribePoliciesResult                    : resolveDescribePoliciesResult
	resolveDescribeScheduledActionsResult            : resolveDescribeScheduledActionsResult
	resolveDescribeScalingActivitiesResult           : resolveDescribeScalingActivitiesResult
	resolveDescribeAutoScalingInstancesResult        : resolveDescribeAutoScalingInstancesResult

