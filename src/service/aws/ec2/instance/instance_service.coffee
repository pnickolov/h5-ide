#*************************************************************************************
#* Filename     : instance_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:16
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/ec2/instance/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "instance." + api_name + " callback is null"
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
			console.log "instance." + api_name + " error:" + error.toString()


		true
	# end of send_request

	#///////////////// Parser for RunInstances return  /////////////////
	#private (parser RunInstances return)
	parserRunInstancesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserRunInstancesReturn


	#///////////////// Parser for StartInstances return  /////////////////
	#private (parser StartInstances return)
	parserStartInstancesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserStartInstancesReturn


	#///////////////// Parser for StopInstances return  /////////////////
	#private (parser StopInstances return)
	parserStopInstancesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserStopInstancesReturn


	#///////////////// Parser for RebootInstances return  /////////////////
	#private (parser RebootInstances return)
	parserRebootInstancesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserRebootInstancesReturn


	#///////////////// Parser for TerminateInstances return  /////////////////
	#private (parser TerminateInstances return)
	parserTerminateInstancesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserTerminateInstancesReturn


	#///////////////// Parser for MonitorInstances return  /////////////////
	#private (parser MonitorInstances return)
	parserMonitorInstancesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserMonitorInstancesReturn


	#///////////////// Parser for UnmonitorInstances return  /////////////////
	#private (parser UnmonitorInstances return)
	parserUnmonitorInstancesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserUnmonitorInstancesReturn


	#///////////////// Parser for BundleInstance return  /////////////////
	#private (parser BundleInstance return)
	parserBundleInstanceReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserBundleInstanceReturn


	#///////////////// Parser for CancelBundleTask return  /////////////////
	#private (parser CancelBundleTask return)
	parserCancelBundleTaskReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserCancelBundleTaskReturn


	#///////////////// Parser for ModifyInstanceAttribute return  /////////////////
	#private (parser ModifyInstanceAttribute return)
	parserModifyInstanceAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserModifyInstanceAttributeReturn


	#///////////////// Parser for ResetInstanceAttribute return  /////////////////
	#private (parser ResetInstanceAttribute return)
	parserResetInstanceAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserResetInstanceAttributeReturn


	#///////////////// Parser for ConfirmProductInstance return  /////////////////
	#private (parser ConfirmProductInstance return)
	parserConfirmProductInstanceReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.return vo
		aws_result

	# end of parserConfirmProductInstanceReturn


	#///////////////// Parser for DescribeInstances return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeInstancesResult = ( result ) ->
		#resolve instance
		xml = $.parseXML result[1]

		instance_list  = []

		reservationSet = ($.xml2json xml).DescribeInstancesResponse.reservationSet

		if not $.isEmptyObject reservationSet

			if $.type(reservationSet.item) == "array"

				for item in reservationSet.item

					if $.type(item.instancesSet.item) == "array"

						for i in item.instancesSet.item

							instance_list.push i

					else

						instance_list.push item.instancesSet.item
			else

				if reservationSet.$.type(item.instancesSet.item) == "array"

					instance_list = reservationSet.item.instancesSet.item

				else

					instance_list.push reservationSet.item.instancesSet.item

		instance_list

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


	#///////////////// Parser for DescribeInstanceStatus return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeInstanceStatusResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeInstanceStatusResponse.instanceStatusSet

	#private (parser DescribeInstanceStatus return)
	parserDescribeInstanceStatusReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeInstanceStatusResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeInstanceStatusReturn


	#///////////////// Parser for DescribeBundleTasks return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeBundleTasksResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeBundleTasksResponse.bundleInstanceTasksSet

	#private (parser DescribeBundleTasks return)
	parserDescribeBundleTasksReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeBundleTasksResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeBundleTasksReturn


	#///////////////// Parser for DescribeInstanceAttribute return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeInstanceAttributeResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeInstanceAttributeResponse

	#private (parser DescribeInstanceAttribute return)
	parserDescribeInstanceAttributeReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeInstanceAttributeResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeInstanceAttributeReturn


	#///////////////// Parser for GetConsoleOutput return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveGetConsoleOutputResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).GetConsoleOutputResponse

	#private (parser GetConsoleOutput return)
	parserGetConsoleOutputReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveGetConsoleOutputResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserGetConsoleOutputReturn


	#///////////////// Parser for GetPasswordData return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveGetPasswordDataResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).GetPasswordDataResponse

	#private (parser GetPasswordData return)
	parserGetPasswordDataReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveGetPasswordDataResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserGetPasswordDataReturn


	#############################################################


	#def RunInstances(self, username, session_id, region_name,
	RunInstances = ( src, username, session_id, callback ) ->
		send_request "RunInstances", src, [ username, session_id ], parserRunInstancesReturn, callback
		true

	#def StartInstances(self, username, session_id, region_name, instance_ids=None):
	StartInstances = ( src, username, session_id, region_name, instance_ids=null, callback ) ->
		send_request "StartInstances", src, [ username, session_id, region_name, instance_ids ], parserStartInstancesReturn, callback
		true

	#def StopInstances(self, username, session_id, region_name, instance_ids=None, force=False):
	StopInstances = ( src, username, session_id, region_name, instance_ids=null, force=false, callback ) ->
		send_request "StopInstances", src, [ username, session_id, region_name, instance_ids, force ], parserStopInstancesReturn, callback
		true

	#def RebootInstances(self, username, session_id, region_name, instance_ids=None):
	RebootInstances = ( src, username, session_id, region_name, instance_ids=null, callback ) ->
		send_request "RebootInstances", src, [ username, session_id, region_name, instance_ids ], parserRebootInstancesReturn, callback
		true

	#def TerminateInstances(self, username, session_id, region_name, instance_ids=None):
	TerminateInstances = ( src, username, session_id, region_name, instance_ids=null, callback ) ->
		send_request "TerminateInstances", src, [ username, session_id, region_name, instance_ids ], parserTerminateInstancesReturn, callback
		true

	#def MonitorInstances(self, username, session_id, region_name, instance_ids):
	MonitorInstances = ( src, username, session_id, region_name, instance_ids, callback ) ->
		send_request "MonitorInstances", src, [ username, session_id, region_name, instance_ids ], parserMonitorInstancesReturn, callback
		true

	#def UnmonitorInstances(self, username, session_id, region_name, instance_ids):
	UnmonitorInstances = ( src, username, session_id, region_name, instance_ids, callback ) ->
		send_request "UnmonitorInstances", src, [ username, session_id, region_name, instance_ids ], parserUnmonitorInstancesReturn, callback
		true

	#def BundleInstance(self, username, session_id, region_name, instance_id, s3_bucket, s3_prefix, s3_access_key,
	BundleInstance = ( src, username, session_id, region_name, instance_id, s3_bucket, callback ) ->
		send_request "BundleInstance", src, [ username, session_id, region_name, instance_id, s3_bucket ], parserBundleInstanceReturn, callback
		true

	#def CancelBundleTask(self, username, session_id, region_name, bundle_id):
	CancelBundleTask = ( src, username, session_id, region_name, bundle_id, callback ) ->
		send_request "CancelBundleTask", src, [ username, session_id, region_name, bundle_id ], parserCancelBundleTaskReturn, callback
		true

	#def ModifyInstanceAttribute(self, username, session_id, region_name,
	ModifyInstanceAttribute = ( src, username, session_id, callback ) ->
		send_request "ModifyInstanceAttribute", src, [ username, session_id ], parserModifyInstanceAttributeReturn, callback
		true

	#def ResetInstanceAttribute(self, username, session_id, region_name, instance_id, attribute_name):
	ResetInstanceAttribute = ( src, username, session_id, region_name, instance_id, attribute_name, callback ) ->
		send_request "ResetInstanceAttribute", src, [ username, session_id, region_name, instance_id, attribute_name ], parserResetInstanceAttributeReturn, callback
		true

	#def ConfirmProductInstance(self, username, session_id, region_name, instance_id, product_code):
	ConfirmProductInstance = ( src, username, session_id, region_name, instance_id, product_code, callback ) ->
		send_request "ConfirmProductInstance", src, [ username, session_id, region_name, instance_id, product_code ], parserConfirmProductInstanceReturn, callback
		true

	#def DescribeInstances(self, username, session_id, region_name, instance_ids=None, filters=None):
	DescribeInstances = ( src, username, session_id, region_name, instance_ids=null, filters=null, callback ) ->
		send_request "DescribeInstances", src, [ username, session_id, region_name, instance_ids, filters ], parserDescribeInstancesReturn, callback
		true

	#def DescribeInstanceStatus(self, username, session_id, region_name, instance_ids=None, include_all_instances=False, max_results=1000, next_token=None):
	DescribeInstanceStatus = ( src, username, session_id, region_name, instance_ids=null, include_all_instances=false, max_results=1000, next_token=null, callback ) ->
		send_request "DescribeInstanceStatus", src, [ username, session_id, region_name, instance_ids, include_all_instances, max_results, next_token ], parserDescribeInstanceStatusReturn, callback
		true

	#def DescribeBundleTasks(self, username, session_id, region_name, bundle_ids=None, filters=None):
	DescribeBundleTasks = ( src, username, session_id, region_name, bundle_ids=null, filters=null, callback ) ->
		send_request "DescribeBundleTasks", src, [ username, session_id, region_name, bundle_ids, filters ], parserDescribeBundleTasksReturn, callback
		true

	#def DescribeInstanceAttribute(self, username, session_id, region_name, instance_id, attribute_name):
	DescribeInstanceAttribute = ( src, username, session_id, region_name, instance_id, attribute_name, callback ) ->
		send_request "DescribeInstanceAttribute", src, [ username, session_id, region_name, instance_id, attribute_name ], parserDescribeInstanceAttributeReturn, callback
		true

	#def GetConsoleOutput(self, username, session_id, region_name, instance_id):
	GetConsoleOutput = ( src, username, session_id, region_name, instance_id, callback ) ->
		send_request "GetConsoleOutput", src, [ username, session_id, region_name, instance_id ], parserGetConsoleOutputReturn, callback
		true

	#def GetPasswordData(self, username, session_id, region_name, instance_id, key_data=None):
	GetPasswordData = ( src, username, session_id, region_name, instance_id, key_data=null, callback ) ->
		send_request "GetPasswordData", src, [ username, session_id, region_name, instance_id, key_data ], parserGetPasswordDataReturn, callback
		true


	#############################################################
	#public
	RunInstances                 : RunInstances
	StartInstances               : StartInstances
	StopInstances                : StopInstances
	RebootInstances              : RebootInstances
	TerminateInstances           : TerminateInstances
	MonitorInstances             : MonitorInstances
	UnmonitorInstances           : UnmonitorInstances
	BundleInstance               : BundleInstance
	CancelBundleTask             : CancelBundleTask
	ModifyInstanceAttribute      : ModifyInstanceAttribute
	ResetInstanceAttribute       : ResetInstanceAttribute
	ConfirmProductInstance       : ConfirmProductInstance
	DescribeInstances            : DescribeInstances
	DescribeInstanceStatus       : DescribeInstanceStatus
	DescribeBundleTasks          : DescribeBundleTasks
	DescribeInstanceAttribute    : DescribeInstanceAttribute
	GetConsoleOutput             : GetConsoleOutput
	GetPasswordData              : GetPasswordData
	#
	resolveDescribeInstancesResult : resolveDescribeInstancesResult

