#*************************************************************************************
#* Filename     : coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:12
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'result_vo', 'constant', 'ebs_service', 'eip_service', 'instance_service'
         'keypair_service', 'securitygroup_service', 'elb_service', 'iam_service', 'acl_service'
         'customergateway_service', 'dhcp_service', 'eni_service', 'internetgateway_service', 'routetable_service'
         'autoscaling_service', 'cloudwatch_service', 'sns_service',
         'subnet_service', 'vpc_service', 'vpn_service', 'vpngateway_service', 'ec2_service', 'ami_service' ], (MC, result_vo, constant, ebs_service, eip_service, instance_service
         keypair_service, securitygroup_service, elb_service, iam_service, acl_service
         customergateway_service, dhcp_service, eni_service, internetgateway_service, routetable_service,
         autoscaling_service, cloudwatch_service, sns_service,
         subnet_service, vpc_service, vpn_service, vpngateway_service, ec2_service, ami_service) ->

	URL = '/aws/'

	#private
	send_request =  ( api_name, src, param_ary, parser, callback ) ->

		#check callback
		if callback is null
			console.log "aws." + api_name + " callback is null"
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
			console.log "aws." + api_name + " error:" + error.toString()


		true
	# end of send_request


	#///////////////// Parser for quickstart return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveQuickstartResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		result

	#private (parser quickstart return)
	parserQuickstartReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveQuickstartResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserQuickstartReturn


	#///////////////// Parser for Public return (need resolve) /////////////////
	#private (resolve result to vo )
	resolvePublicResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		result

	#private (parser Public return)
	parserPublicReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolvePublicResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserPublicReturn


	#///////////////// Parser for info return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveInfoResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		result

	#private (parser info return)
	parserInfoReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveInfoResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserInfoReturn


	#///////////////// Parser for resource return (need resolve) /////////////////
	resourceMap = ( result ) ->
		responses = {
			"DescribeImagesResponse"               :   ami_service.resolveDescribeImagesResult
			"DescribeAvailabilityZonesResponse"    :   ec2_service.resolveDescribeAvailabilityZonesResult
			"DescribeVolumesResponse"              :   ebs_service.resolveDescribeVolumesResult
			"DescribeSnapshotsResponse"            :   ebs_service.resolveDescribeSnapshotsResult
			"DescribeAddressesResponse"            :   eip_service.resolveDescribeAddressesResult
			"DescribeInstancesResponse"            :   instance_service.resolveDescribeInstancesResult
			"DescribeKeyPairsResponse"             :   keypair_service.resolveDescribeKeyPairsResult
			"DescribeSecurityGroupsResponse"       :   securitygroup_service.resolveDescribeSecurityGroupsResult
			"DescribeLoadBalancersResponse"        :   elb_service.resolveDescribeLoadBalancersResult
			"DescribeNetworkAclsResponse"          :   acl_service.resolveDescribeNetworkAclsResult
			"DescribeCustomerGatewaysResponse"     :   customergateway_service.resolveDescribeCustomerGatewaysResult
			"DescribeDhcpOptionsResponse"          :   dhcp_service.resolveDescribeDhcpOptionsResult
			"DescribeNetworkInterfacesResponse"    :   eni_service.resolveDescribeNetworkInterfacesResult
			"DescribeInternetGatewaysResponse"     :   internetgateway_service.resolveDescribeInternetGatewaysResult
			"DescribeRouteTablesResponse"          :   routetable_service.resolveDescribeRouteTablesResult
			"DescribeSubnetsResponse"              :   subnet_service.resolveDescribeSubnetsResult
			"DescribeVpcsResponse"                 :   vpc_service.resolveDescribeVpcsResult
			"DescribeVpnConnectionsResponse"       :   vpn_service.resolveDescribeVpnConnectionsResult
			"DescribeVpnGatewaysResponse"          :   vpngateway_service.resolveDescribeVpnGatewaysResult
			#
			"DescribeAutoScalingGroupsResponse"            :   autoscaling_service.resolveDescribeAutoScalingGroupsResult
			"DescribeLaunchConfigurationsResponse"         :   autoscaling_service.resolveDescribeLaunchConfigurationsResult
			"DescribeNotificationConfigurationsResponse"   :   autoscaling_service.resolveDescribeNotificationConfigurationsResult
			"DescribePoliciesResponse"                     :   autoscaling_service.resolveDescribePoliciesResult
			"DescribeScheduledActionsResponse"             :   autoscaling_service.resolveDescribeScheduledActionsResult
			"DescribeScalingActivitiesResponse"            :   autoscaling_service.resolveDescribeScalingActivitiesResult
			"DescribeAlarmsResponse"                       :   cloudwatch_service.resolveDescribeAlarmsResult
			"ListSubscriptionsResponse"                    :   sns_service.resolveListSubscriptionsResult
			"ListTopicsResponse"                           :   sns_service.resolveListTopicsResult

		}

		dict = {}

		for node in result

			action_name = ($.parseXML node).documentElement.localName

			dict_name = action_name.replace /Response/i, ""

			dict[dict_name] = [] if dict[dict_name]?

			dict[dict_name] = responses[action_name] [null, node]

		dict


	#private (resolve result to vo )
	resolveResourceResult = ( result ) ->
		#resolve result
		#return vo
		res = {}
		res[region] = resourceMap nodes for region, nodes of result


		res

	#private (parser resource return)
	parserResourceReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveResourceResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserResourceReturn


	#///////////////// Parser for price return (need resolve) /////////////////
	#private (resolve result to vo )
	resolvePriceResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		result

	#private (parser price return)
	parserPriceReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolvePriceResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserPriceReturn


	#///////////////// Parser for status return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveStatusResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		$.parseJSON result[2]

	#private (parser status return)
	parserStatusReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolveStatusResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserStatusReturn


	#############################################################

	#def quickstart(self, username, session_id, region_name):
	quickstart = ( src, username, session_id, region_name, callback ) ->
		send_request "quickstart", src, [ username, session_id, region_name ], parserQuickstartReturn, callback
		true

	#def public(self, username, session_id, region_name):
	Public = ( src, username, session_id, region_name, filters, callback ) ->
		send_request "public", src, [ username, session_id, region_name, filters ], parserPublicReturn, callback
		true

	#def info(self, username, session_id, region_name):
	info = ( src, username, session_id, region_name, callback ) ->
		send_request "info", src, [ username, session_id, region_name ], parserInfoReturn, callback
		true

	#def resource(self, username, session_id, region_name=None, resources=None):
	resource = ( src, username, session_id, region_name=null, resources=null, callback ) ->
		send_request "resource", src, [ username, session_id, region_name, resources ], parserResourceReturn, callback
		true

	#def price(self, username, session_id):
	price = ( src, username, session_id, callback ) ->
		send_request "price", src, [ username, session_id ], parserPriceReturn, callback
		true

	#def status(self, username, session_id):
	status = ( src, username, session_id, callback ) ->
		send_request "status", src, [ username, session_id ], parserStatusReturn, callback
		true


	#############################################################
	#public
	quickstart                   : quickstart
	Public                       : Public
	info                         : info
	resource                     : resource
	price                        : price
	status                       : status

