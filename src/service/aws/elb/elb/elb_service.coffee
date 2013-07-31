#*************************************************************************************
#* Filename     : elb_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:19
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

	URL = '/aws/elb/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "elb." + api_name + " callback is null"
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
			console.log "elb." + api_name + " error:" + error.toString()


		true
	# end of send_request

	#///////////////// Parser for DescribeInstanceHealth return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeInstanceHealthResult = ( result ) ->
		#resolve result
		#return vo
		result_set = ($.xml2json ($.parseXML result[1])).DescribeInstanceHealthResponse.DescribeInstanceHealthResult.InstanceStates.member

		if $.type(result_set) == "object"

			tmp = []

			tmp.push result_set

			result_set = tmp

		result_set

	#private (parser DescribeInstanceHealth return)
	parserDescribeInstanceHealthReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeInstanceHealthResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeInstanceHealthReturn


	#///////////////// Parser for DescribeLoadBalancerPolicies return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeLoadBalancerPoliciesResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeLoadBalancerPoliciesResponse.DescribeLoadBalancerPoliciesResult.PolicyDescriptions

	#private (parser DescribeLoadBalancerPolicies return)
	parserDescribeLoadBalancerPoliciesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeLoadBalancerPoliciesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeLoadBalancerPoliciesReturn


	#///////////////// Parser for DescribeLoadBalancerPolicyTypes return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeLoadBalancerPolicyTypesResult = ( result ) ->
		#resolve result

		#return vo
		($.xml2json ($.parseXML result[1])).DescribeLoadBalancerPolicyTypesResponse.DescribeLoadBalancerPolicyTypesResult.PolicyTypeDescriptions

	#private (parser DescribeLoadBalancerPolicyTypes return)
	parserDescribeLoadBalancerPolicyTypesReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeLoadBalancerPolicyTypesResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeLoadBalancerPolicyTypesReturn


	#///////////////// Parser for DescribeLoadBalancers return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveDescribeLoadBalancersResult = ( result ) ->
		#resolve result
		#return vo
		result_set = ($.xml2json ($.parseXML result[1])).DescribeLoadBalancersResponse.DescribeLoadBalancersResult.LoadBalancerDescriptions

		if result_set

			if $.type(result_set.member) == "object"

				tmp = result_set.member

				result_set = []

				result_set.push tmp

			else
				result_set = result_set.member

		result_set

	#private (parser DescribeLoadBalancers return)
	parserDescribeLoadBalancersReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveDescribeLoadBalancersResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserDescribeLoadBalancersReturn


	#############################################################

	#def DescribeInstanceHealth(self, username, session_id, region_name, elb_name, instance_ids=None):
	DescribeInstanceHealth = ( src, username, session_id, region_name, elb_name, instance_ids=null, callback ) ->
		send_request "DescribeInstanceHealth", src, [ username, session_id, region_name, elb_name, instance_ids ], parserDescribeInstanceHealthReturn, callback
		true

	#def DescribeLoadBalancerPolicies(self, username, session_id, region_name, elb_name=None, policy_names=None):
	DescribeLoadBalancerPolicies = ( src, username, session_id, region_name, elb_name=null, policy_names=null, callback ) ->
		send_request "DescribeLoadBalancerPolicies", src, [ username, session_id, region_name, elb_name, policy_names ], parserDescribeLoadBalancerPoliciesReturn, callback
		true

	#def DescribeLoadBalancerPolicyTypes(self, username, session_id, region_name, policy_type_names=None):
	DescribeLoadBalancerPolicyTypes = ( src, username, session_id, region_name, policy_type_names=null, callback ) ->
		send_request "DescribeLoadBalancerPolicyTypes", src, [ username, session_id, region_name, policy_type_names ], parserDescribeLoadBalancerPolicyTypesReturn, callback
		true

	#def DescribeLoadBalancers(self, username, session_id, region_name, elb_names=None, marker=None):
	DescribeLoadBalancers = ( src, username, session_id, region_name, elb_names=null, marker=null, callback ) ->
		send_request "DescribeLoadBalancers", src, [ username, session_id, region_name, elb_names, marker ], parserDescribeLoadBalancersReturn, callback
		true


	#############################################################
	#public
	DescribeInstanceHealth       : DescribeInstanceHealth
	DescribeLoadBalancerPolicies : DescribeLoadBalancerPolicies
	DescribeLoadBalancerPolicyTypes : DescribeLoadBalancerPolicyTypes
	DescribeLoadBalancers        : DescribeLoadBalancers
	#
	resolveDescribeLoadBalancersResult : resolveDescribeLoadBalancersResult

