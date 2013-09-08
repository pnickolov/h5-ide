#*************************************************************************************
#* Filename     : opsworks_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:20
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/opsworks/opsworks/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "opsworks." + api_name + " callback is null"
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
			console.log "opsworks." + api_name + " error:" + error.toString()


		true
	# end of send_request

	#///////////////// Parser for DescribeApps return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeAppsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeApps return)
	parserDescribeAppsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeAppsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeAppsReturn


	#///////////////// Parser for DescribeStacks return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeStacksResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeStacks return)
	parserDescribeStacksReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeStacksResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeStacksReturn


	#///////////////// Parser for DescribeCommands return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeCommandsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeCommands return)
	parserDescribeCommandsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeCommandsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeCommandsReturn


	#///////////////// Parser for DescribeDeployments return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeDeploymentsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeDeployments return)
	parserDescribeDeploymentsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeDeploymentsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeDeploymentsReturn


	#///////////////// Parser for DescribeElasticIps return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeElasticIpsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeElasticIps return)
	parserDescribeElasticIpsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeElasticIpsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeElasticIpsReturn


	#///////////////// Parser for DescribeInstances return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeInstancesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeInstances return)
	parserDescribeInstancesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeInstancesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeInstancesReturn


	#///////////////// Parser for DescribeLayers return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeLayersResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeLayers return)
	parserDescribeLayersReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeLayersResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeLayersReturn


	#///////////////// Parser for DescribeLoadBasedAutoScaling return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeLoadBasedAutoScalingResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeLoadBasedAutoScaling return)
	parserDescribeLoadBasedAutoScalingReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeLoadBasedAutoScalingResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeLoadBasedAutoScalingReturn


	#///////////////// Parser for DescribePermissions return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribePermissionsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribePermissions return)
	parserDescribePermissionsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribePermissionsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribePermissionsReturn


	#///////////////// Parser for DescribeRaidArrays return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeRaidArraysResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeRaidArrays return)
	parserDescribeRaidArraysReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeRaidArraysResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeRaidArraysReturn


	#///////////////// Parser for DescribeServiceErrors return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeServiceErrorsResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeServiceErrors return)
	parserDescribeServiceErrorsReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeServiceErrorsResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeServiceErrorsReturn


	#///////////////// Parser for DescribeTimeBasedAutoScaling return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeTimeBasedAutoScalingResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeTimeBasedAutoScaling return)
	parserDescribeTimeBasedAutoScalingReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeTimeBasedAutoScalingResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeTimeBasedAutoScalingReturn


	#///////////////// Parser for DescribeUserProfiles return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeUserProfilesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeUserProfiles return)
	parserDescribeUserProfilesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeUserProfilesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeUserProfilesReturn


	#///////////////// Parser for DescribeVolumes return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeVolumesResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser DescribeVolumes return)
	parserDescribeVolumesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeVolumesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeVolumesReturn


	#############################################################

	#def DescribeApps(self, username, session_id, region_name, app_ids=None, stack_id=None):
	DescribeApps = ( src, username, session_id, region_name, app_ids=null, stack_id=null, callback ) ->
		send_request "DescribeApps", src, [ username, session_id, region_name, app_ids, stack_id ], parserDescribeAppsReturn, callback
		true

	#def DescribeStacks(self, username, session_id, region_name, stack_ids=None):
	DescribeStacks = ( src, username, session_id, region_name, stack_ids=null, callback ) ->
		send_request "DescribeStacks", src, [ username, session_id, region_name, stack_ids ], parserDescribeStacksReturn, callback
		true

	#def DescribeCommands(self, username, session_id, region_name, command_ids=None, deployment_id=None, instance_id=None):
	DescribeCommands = ( src, username, session_id, region_name, command_ids=null, deployment_id=null, instance_id=null, callback ) ->
		send_request "DescribeCommands", src, [ username, session_id, region_name, command_ids, deployment_id, instance_id ], parserDescribeCommandsReturn, callback
		true

	#def DescribeDeployments(self, username, session_id, region_name, app_id=None, deployment_ids=None, stack_id=None):
	DescribeDeployments = ( src, username, session_id, region_name, app_id=null, deployment_ids=null, stack_id=null, callback ) ->
		send_request "DescribeDeployments", src, [ username, session_id, region_name, app_id, deployment_ids, stack_id ], parserDescribeDeploymentsReturn, callback
		true

	#def DescribeElasticIps(self, username, session_id, region_name, instance_id=None, ips=None):
	DescribeElasticIps = ( src, username, session_id, region_name, instance_id=null, ips=null, callback ) ->
		send_request "DescribeElasticIps", src, [ username, session_id, region_name, instance_id, ips ], parserDescribeElasticIpsReturn, callback
		true

	#def DescribeInstances(self, username, session_id, region_name, app_id=None, instance_ids=None, layer_id=None, stack_id=None):
	DescribeInstances = ( src, username, session_id, region_name, app_id=null, instance_ids=null, layer_id=null, stack_id=null, callback ) ->
		send_request "DescribeInstances", src, [ username, session_id, region_name, app_id, instance_ids, layer_id, stack_id ], parserDescribeInstancesReturn, callback
		true

	#def DescribeLayers(self, username, session_id, region_name, stack_id, layer_ids=None):
	DescribeLayers = ( src, username, session_id, region_name, stack_id, layer_ids=null, callback ) ->
		send_request "DescribeLayers", src, [ username, session_id, region_name, stack_id, layer_ids ], parserDescribeLayersReturn, callback
		true

	#def DescribeLoadBasedAutoScaling(self, username, session_id, region_name, layer_ids):
	DescribeLoadBasedAutoScaling = ( src, username, session_id, region_name, layer_ids, callback ) ->
		send_request "DescribeLoadBasedAutoScaling", src, [ username, session_id, region_name, layer_ids ], parserDescribeLoadBasedAutoScalingReturn, callback
		true

	#def DescribePermissions(self, username, session_id, region_name, iam_user_arn, stack_id):
	DescribePermissions = ( src, username, session_id, region_name, iam_user_arn, stack_id, callback ) ->
		send_request "DescribePermissions", src, [ username, session_id, region_name, iam_user_arn, stack_id ], parserDescribePermissionsReturn, callback
		true

	#def DescribeRaidArrays(self, username, session_id, region_name, instance_id=None, raid_array_ids=None):
	DescribeRaidArrays = ( src, username, session_id, region_name, instance_id=null, raid_array_ids=null, callback ) ->
		send_request "DescribeRaidArrays", src, [ username, session_id, region_name, instance_id, raid_array_ids ], parserDescribeRaidArraysReturn, callback
		true

	#def DescribeServiceErrors(self, username, session_id, region_name, instance_id=None, service_error_ids=None, stack_id=None):
	DescribeServiceErrors = ( src, username, session_id, region_name, instance_id=null, service_error_ids=null, stack_id=null, callback ) ->
		send_request "DescribeServiceErrors", src, [ username, session_id, region_name, instance_id, service_error_ids, stack_id ], parserDescribeServiceErrorsReturn, callback
		true

	#def DescribeTimeBasedAutoScaling(self, username, session_id, region_name, instance_ids):
	DescribeTimeBasedAutoScaling = ( src, username, session_id, region_name, instance_ids, callback ) ->
		send_request "DescribeTimeBasedAutoScaling", src, [ username, session_id, region_name, instance_ids ], parserDescribeTimeBasedAutoScalingReturn, callback
		true

	#def DescribeUserProfiles(self, username, session_id, region_name, iam_user_arns):
	DescribeUserProfiles = ( src, username, session_id, region_name, iam_user_arns, callback ) ->
		send_request "DescribeUserProfiles", src, [ username, session_id, region_name, iam_user_arns ], parserDescribeUserProfilesReturn, callback
		true

	#def DescribeVolumes(self, username, session_id, region_name, instance_id=None, raid_array_id=None, volume_ids=None):
	DescribeVolumes = ( src, username, session_id, region_name, instance_id=null, raid_array_id=null, volume_ids=null, callback ) ->
		send_request "DescribeVolumes", src, [ username, session_id, region_name, instance_id, raid_array_id, volume_ids ], parserDescribeVolumesReturn, callback
		true


	#############################################################
	#public
	DescribeApps                 : DescribeApps
	DescribeStacks               : DescribeStacks
	DescribeCommands             : DescribeCommands
	DescribeDeployments          : DescribeDeployments
	DescribeElasticIps           : DescribeElasticIps
	DescribeInstances            : DescribeInstances
	DescribeLayers               : DescribeLayers
	DescribeLoadBasedAutoScaling : DescribeLoadBasedAutoScaling
	DescribePermissions          : DescribePermissions
	DescribeRaidArrays           : DescribeRaidArrays
	DescribeServiceErrors        : DescribeServiceErrors
	DescribeTimeBasedAutoScaling : DescribeTimeBasedAutoScaling
	DescribeUserProfiles         : DescribeUserProfiles
	DescribeVolumes              : DescribeVolumes

