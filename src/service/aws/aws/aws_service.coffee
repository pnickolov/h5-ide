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

					param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
					aws_result.param = param_ary

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
			"DescribeInstanceHealthResponse"       :   elb_service.resolveDescribeInstanceHealthResult
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
			#
			"DescribeVpcAttributeResponse"        :  vpc_service.resolveDescribeVpcAttributeResult
		}

		dict = {}

		for node in result

			if node

				if $.type(node) is "string"

					action_name = ($.parseXML node).documentElement.localName
					dict_name = action_name.replace /Response/i, ""

					if not responses[action_name]
						console.warn "[resourceMap] can not find action_name [" + action_name + "]"
						continue

					if action_name is "DescribeVpcAttributeResponse"
						if not dict[dict_name]
							dict[dict_name] = {}
						vpcAttr = responses[action_name] [null, node]
						if vpcAttr.enableDnsSupport
							dict[dict_name]['enableDnsSupport'] = vpcAttr.enableDnsSupport.value
						else if vpcAttr.enableDnsHostnames
							dict[dict_name]['enableDnsHostnames'] = vpcAttr.enableDnsHostnames.value
					else
						dict[dict_name] = [] if dict[dict_name]?
						dict[dict_name] = responses[action_name] [null, node]

				else if $.type(node) is "object"

					elbHealthData = node["DescribeInstanceHealth"]
					if elbHealthData
						_.each elbHealthData, ( node, elb_name ) ->
							action_name = ($.parseXML(node)).documentElement.localName
							dict_name = action_name.replace /Response/i, ""
							if not dict[dict_name]
								dict[dict_name] = []
							elb_data = responses[action_name] [null, node]
							if elb_data
								elb_data.LoadBalancerName = elb_name
								dict[dict_name].push elb_data

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

		addition = param[5]
		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = result
			try
				if addition is 'statistic'

					resolved_data = result

				else if addition is 'vpc'

					resolved_data = resolveVpcResourceResult result

				else

					resolved_data = resolveResourceResult result

				aws_result.resolved_data = resolved_data

			catch error
				console.log 'aws service error', error
				console.log result, return_code, param

				if addition is 'vpc'
					aws_result.is_error = true

					aws_result.error_message = "Failed to visualize VPC. Try to refresh resources or contact VisualOps."

					aws_result.return_code = 15

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


	vpc_resource_map = {
		#"DescribeImagesResponse"               :  if MC.common then MC.common.convert.resolveDescribeImagesResult else {}
		"DescribeAvailabilityZones"    :   if MC.common then MC.common.convert.convertAZ else {}
		"DescribeVolumes"              :   if MC.common then MC.common.convert.convertVolume else {}
		#"DescribeSnapshots"            :  if MC.common then  ebs_service.resolveDescribeSnapshotsResult else {}
		"DescribeAddresses"            :   if MC.common then MC.common.convert.convertEIP else {}
		"DescribeInstances"            :   if MC.common then MC.common.convert.convertInstance else {}
		"DescribeKeyPairs"             :   if MC.common then MC.common.convert.convertKP else {}
		"DescribeSecurityGroups"       :   if MC.common then MC.common.convert.convertSGGroup else {}
		"DescribeLoadBalancers"        :   if MC.common then MC.common.convert.convertELB else {}
		"DescribeNetworkAcls"          :   if MC.common then MC.common.convert.convertACL else {}
		"DescribeCustomerGateways"     :   if MC.common then MC.common.convert.convertCGW else {}
		"DescribeDhcpOptions"          :   if MC.common then MC.common.convert.convertDHCP else {}
		"DescribeNetworkInterfaces"    :   if MC.common then MC.common.convert.convertEni else {}
		"DescribeInternetGateways"     :   if MC.common then MC.common.convert.convertIGW else {}
		"DescribeRouteTables"          :   if MC.common then MC.common.convert.convertRTB else {}
		"DescribeSubnets"              :   if MC.common then MC.common.convert.convertSubnet else {}
		"DescribeVpcs"                 :   if MC.common then MC.common.convert.convertVPC else {}
		"DescribeVpnConnections"       :   if MC.common then MC.common.convert.convertVPN else {}
		"DescribeVpnGateways"          :   if MC.common then MC.common.convert.convertVGW else {}
		#
		"DescribeAutoScalingGroups"            :   if MC.common then MC.common.convert.convertASG else {}
		"DescribeLaunchConfigurations"         :   if MC.common then MC.common.convert.convertLC else {}
		"DescribeNotificationConfigurations"   :   if MC.common then MC.common.convert.convertNC else {}
		"DescribePolicies"                     :   if MC.common then MC.common.convert.convertScalingPolicy else {}
		#"DescribeScheduledActionsResponse"             :   if MC.common then autoscaling_service.resolveDescribeScheduledActionsResult else {}
		#"DescribeScalingActivitiesResponse"            :   if MC.common then autoscaling_service.resolveDescribeScalingActivitiesResult else {}
		#"DescribeAlarmsResponse"                       :   if MC.common then cloudwatch_service.resolveDescribeAlarmsResult else {}
		#"ListSubscriptionsResponse"                    :   if MC.common then sns_service.resolveListSubscriptionsResult else {}
		#"ListTopicsResponse"                           :   if MC.common then sns_service.resolveListTopicsResult else {}
		'resolveEC2Tag'                        :   if MC.common then MC.common.convert.resolveEC2Tag else {}
		'removeAppId'                          :   if MC.common then MC.common.convert.removeAppId else {}
		'resourceId2CompUid'                   :   if MC.common then MC.common.convert.resourceId2CompUid else {}
	}

	#///////////////// Parser for vpc_resource return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveVpcResourceResult = ( result ) ->
		#resolve result
		#return vo

		vpc_resource_layout_map = {
			'AWS.EC2.AvailabilityZone'      : MC.canvas.AZ_JSON,
			'AWS.EC2.Instance'              : MC.canvas.INSTANCE_JSON,
			'AWS.ELB'                       : MC.canvas.ELB_JSON,
			'AWS.VPC.VPC'                   : MC.canvas.VPC_JSON,
			'AWS.VPC.Subnet'                : MC.canvas.SUBNET_JSON,
			'AWS.VPC.InternetGateway'       : MC.canvas.IGW_JSON,
			'AWS.VPC.RouteTable'            : MC.canvas.ROUTETABLE_JSON,
			'AWS.VPC.VPNGateway'            : MC.canvas.VGW_JSON,
			'AWS.VPC.CustomerGateway'       : MC.canvas.CGW_JSON,
			'AWS.VPC.NetworkInterface'      : MC.canvas.ENI_JSON,
			'AWS.AutoScaling.Group'         : MC.canvas.ASG_JSON,
			'AWS.AutoScaling.LaunchConfiguration' : MC.canvas.ASL_LC_JSON
		}

		res = {}

		res[region] = resourceMap nodes for region, nodes of result

		#generate app json from Stack template
		app_json = $.extend true, {}, MC.canvas.STACK_JSON

		vpc_id = ""

		ignore_instances = []

		for region, nodes of res

			MC.aws.aws.cacheResource nodes, region, false

			app_json.region = region
			app_json.username = $.cookie( 'usercode' )
			app_json.owner    = $.cookie( 'usercode' )
			app_json.state    = "Running"
			app_json.stack_id = ""
			app_json.description = "This app is created by visualops"
			app_json.history  = {
					event: {}
					time :
						created  : Math.round(new Date().getTime()/1000)
						last     : Math.round(new Date().getTime()/1000)
						run      : 0
						terminate: ""
				}

			# default sg cache
			default_sg   = {}
			default_kp   = null
			vpc_tag      = {}
			resource2uid = {}
			vpc_attr_data= null

			#describe vpc first
			for resource_type, resource_comp of nodes
				if resource_type not in [ "DescribeVpcs", "DescribeVpcAttribute" ]
					continue
				if resource_comp and resource_type is "DescribeVpcs"
					vpc_id = resource_comp[0].vpcId
					vpc_tag= vpc_resource_map["resolveEC2Tag"] resource_comp[0].tagSet
				else if resource_comp and resource_type is "DescribeVpcAttribute"
					vpc_attr_data = resource_comp

			#check app by vpc_id
			if vpc_id and MC.data.app_info and MC.data.app_info[vpc_id]
				resource2uid = vpc_resource_map["resourceId2CompUid"] MC.data.app_info[vpc_id].component

				#generate app json from original app
				app_json = $.extend true, {}, MC.data.app_info[vpc_id]
				app_json.id = ""
				app_json.component = {}
				app_json.layout =
					component :
						group  : {}
						node   : {}
				#find DefaultKP
				for _uid,_comp of MC.data.app_info[vpc_id].component
					if _comp.type is 'AWS.EC2.KeyPair' and _comp.name is 'DefaultKP'
						default_kp = _comp

			for resource_type, resource_comp of nodes

				if resource_type is 'DescribeInstanceHealth'
					continue

				if resource_comp

					if resource_type is 'DescribeAvailabilityZones'

						for comp in resource_comp.item

							c = vpc_resource_map[resource_type] comp

							resKey = constant.AWS_RESOURCE_KEY[c.type]
							resId = c.resource[ resKey ]
							if resKey and resId and resource2uid[resId]
								c.uid = resource2uid[resId]
							app_json.component[c.uid] = c

							# layout = vpc_resource_layout_map[c.type].layout

							# layout.name = c.name

							# todo: add vpc groud uid
							#layout.groupUId =

							# app_json.layout.component.group[c.uid] = layout

					else

						if resource_type is 'DescribeLaunchConfigurations'

							for comp in resource_comp

								remove_index = []

								if comp.BlockDeviceMappings

									for idx, device of comp.BlockDeviceMappings.member

										if not device.Ebs

											remove_index.push idx

								remove_index = remove_index.sort().reverse()

								for i in remove_index

									comp.BlockDeviceMappings.member.splice(i, 1)
						#collect ignore asg instance
						if resource_type is 'DescribeAutoScalingGroups'
							for asg in resource_comp

								if asg.Instances

									for ins in asg.Instances.member

										ignore_instances.push ins.InstanceId

						for comp in resource_comp

							if not vpc_resource_map[resource_type]
								console.warn "[resolveVpcResourceResult] not found resource_type " + resource_type + " in vpc_resource_map"
								continue

							if resource_type is "DescribeVpcs"
								c = vpc_resource_map[resource_type]( comp, vpc_attr_data )
							else if resource_type is "DescribeVolumes"
								c = vpc_resource_map[resource_type]( comp, region )
							else if resource_type is "DescribeInstances"
								c= vpc_resource_map[resource_type]( comp, default_kp )
							else
								c = vpc_resource_map[resource_type]( comp )

							if c
								resKey = constant.AWS_RESOURCE_KEY[c.type]
								resId = c.resource[ resKey ]
								if resKey and resId and resource2uid[resId]
									c.uid = resource2uid[resId]
								app_json.component[c.uid] = c

								#set back state info to instance
								if resource_type is "DescribeInstances"
									if vpc_tag.isApp and MC.data.app_info and MC.data.app_info[vpc_id] and MC.data.app_info[vpc_id].component[c.uid]
										c.state = MC.data.app_info[vpc_id].component[c.uid].state

								#remember default SG
								if resource_type is 'DescribeSecurityGroups'
									if vpc_tag.isApp
										#set sg name by tagSet
										prefix = "VPC-" + vpc_tag.app + "-"
										c.name = c.resource.GroupName.substr(0,c.resource.GroupName.lastIndexOf("-app-")).substr(prefix.length)
									if c.resource.GroupName.indexOf("DefaultSG") isnt -1
										#default sg is "DefaultSG"
										default_sg["DefaultSG"] = c.uid
									else if c.resource.GroupName is "default"
										#default sg is "default"
										default_sg["default"] = c.uid


			# find default SG
			if default_sg["DefaultSG"]
				#old app
				app_json.component[ default_sg["DefaultSG"] ].resource.Default = true
				app_json.component[ default_sg["DefaultSG"] ].name = "DefaultSG"
				if default_sg["default"]
					#delete "default" SG component
					delete app_json.component[ default_sg["default"] ]
			else if default_sg["default"]
				#new app
				app_json.component[ default_sg["default"] ].resource.Default   = true
				app_json.component[ default_sg["default"] ].resource.GroupName = "DefaultSG" #do not use 'default' as GroupName
				app_json.component[ default_sg["default"] ].name = "DefaultSG"

			#add DefaultKP
			if not default_kp
				# add new DefaultKP
				key_obj = {}
				key_obj.keyName = ''
				key_obj.keyFingerprint = ''
				c = vpc_resource_map["DescribeKeyPairs"] key_obj
			else
				# use orial DefaultKP
				c = default_kp
			if c
				c.name = "DefaultKP"
				app_json.component[c.uid] = c


		app_json.name = app_json.id = vpc_id
		#remove_asg_instance
		remove_uid = []

		used_az = []

		for uid, c of app_json.component

			if c.type is 'AWS.EC2.Instance' and c.resource.InstanceId in ignore_instances

				remove_uid.push c.uid

			if c.type is 'AWS.VPC.Subnet'

				if c.resource.AvailabilityZone not in used_az

					used_az.push c.resource.AvailabilityZone

		# remove related resource
		for uid, c of app_json.component

			if c.type is 'AWS.VPC.NetworkInterface' and c.resource.Attachment.InstanceId and c.resource.Attachment.InstanceId in ignore_instances

				remove_uid.push c.uid

			if c.type is 'AWS.EC2.EBS.Volume' and c.resource.AttachmentSet.InstanceId and c.resource.AttachmentSet.InstanceId in ignore_instances

				remove_uid.push c.uid

			if c.type is 'AWS.EC2.AvailabilityZone' and c.resource.ZoneName not in used_az

				remove_uid.push c.uid

		for uid in remove_uid

			delete app_json.component[uid]

		ref_res = MC.aws.aws.collectReference app_json.component

		app_json.component = ref_res[0]

		ref_key = ref_res[1]

		vpc_uid = MC.extractID(ref_key[vpc_id])

		for uid, c of app_json.component


			if vpc_resource_layout_map[c.type]

				# if c.type not in ['AWS.VPC.NetworkInterface', 'AWS.AutoScaling.Group', 'AWS.AutoScaling.LaunchConfiguration']

				#   if c.type in ['AWS.VPC.Subnet', 'AWS.VPC.VPC']
				#       app_json.layout.component.group[c.uid] = vpc_resource_layout_map[c.type].layout
				#   else
				#       app_json.layout.component.node[c.uid] = vpc_resource_layout_map[c.type].layout
				layout = $.extend true, {}, vpc_resource_layout_map[c.type].layout

				layout.uid = c.uid

				switch c.type

					when 'AWS.VPC.NetworkInterface'

						layout.groupUId = MC.extractID(c.resource.SubnetId)

						if c.resource.Attachment and c.resource.Attachment.DeviceIndex not in ['0', 0]

							app_json.layout.component.node[c.uid] = layout

						else if not c.resource.Attachment

							app_json.layout.component.node[c.uid] = layout

					when "AWS.AutoScaling.Group"

						subnets = []

						if c.resource.VPCZoneIdentifier

							subs = c.resource.VPCZoneIdentifier.split(',')

							for subnet in subs

								if subnet[0] isnt "@"

									subnets.push MC.extractID(ref_key[subnet])

								else
									subnets.push MC.extractID(subnet)

							c.resource.VPCZoneIdentifier = subnets.join(',')

						originalId = ''

						for uid_tmp, comp_tmp of app_json.component

							if comp_tmp.type is 'AWS.AutoScaling.LaunchConfiguration' and uid_tmp is MC.extractID(c.resource.LaunchConfigurationName)

								if app_json.layout.component.node[uid_tmp].groupUId

									new_comp = $.extend true, {}, comp_tmp

									new_uid = MC.guid()

									new_comp.uid = new_uid

									new_layout = $.extend true, {}, app_json.layout.component.node[uid_tmp]

									new_layout.originalId = new_uid

									new_layout.groupUId = c.uid

									new_layout.uid = new_uid

									c.resource.LaunchConfigurationName = "#{new_uid}.resource.LaunchConfigurationName"

									app_json.component[new_uid] = new_comp

									app_json.layout.component.node[new_uid] = new_layout

								else
									app_json.layout.component.node[uid_tmp].groupUId = c.uid



						for idx, zone of c.resource.AvailabilityZones

							extend_asg = $.extend true, {}, layout

							if idx in [0,"0"]

								if subnets.length != 0

									originalId = subnets[idx]

								else

									originalId = MC.extractID(zone)

								extend_asg_uid = c.uid
							else

								extend_asg_uid = MC.guid()

								extend_asg.originalId = c.uid

							if subnets.length != 0

								extend_asg.groupUId = subnets[idx]

							else

								extend_asg.groupUId = MC.extractID(zone)

							app_json.layout.component.group[extend_asg_uid] = extend_asg

						#app_json.layout.component.group[c.uid] = vpc_resource_layout_map[c.type].layout


					when 'AWS.EC2.Instance'

						if c.resource.SubnetId

							layout.groupUId = MC.extractID(c.resource.SubnetId)

						else

							layout.groupUId = MC.extractID(c.resource.Placement.AvailabilityZone)


						# collect volume

						for uid_tmp, comp_tmp of app_json.component

							if comp_tmp.type is "AWS.EC2.EBS.Volume" and comp_tmp.resource.AttachmentSet and comp_tmp.resource.AttachmentSet.InstanceId and MC.extractID(comp_tmp.resource.AttachmentSet.InstanceId) is c.uid

								layout.volumeList[uid_tmp] = [uid_tmp]

								app_json.component[c.uid].resource.BlockDeviceMapping.push "##{uid_tmp}"

						app_json.layout.component.node[c.uid] = layout

					when 'AWS.AutoScaling.LaunchConfiguration'

						layout.originalId = c.uid

						app_json.layout.component.node[c.uid] = layout

					when "AWS.EC2.AvailabilityZone"

						layout.name = c.name

						layout.groupUId = vpc_uid

						app_json.layout.component.group[c.uid] = layout

					when "AWS.VPC.Subnet"

						layout.groupUId = MC.extractID(c.resource.AvailabilityZone)

						app_json.layout.component.group[c.uid] = layout

					when "AWS.VPC.VPC"

						app_json.layout.component.group[c.uid] = layout

					else

						layout.groupUId = vpc_uid

						app_json.layout.component.node[c.uid] = layout

		console.log app_json


		#app_json.component = MC.aws.aws.collectReference app_json.component

		[app_json]

		#res

	#private (parser vpc_resource return)
	parserVpcResourceReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			try
				resolved_data = resolveVpcResourceResult result

				aws_result.resolved_data = resolved_data

			catch error

				console.log error

				aws_result.is_error = true

				aws_result.error_message = "We can not reverse your app, please contact VisualOps"

				aws_result.return_code = 15


		#3.return vo
		aws_result

	# end of parserVpcResourceReturn


	#///////////////// Parser for stat_resource return (need resolve) /////////////////
	#private (resolve result to vo )
	resolveStatResourceResult = ( result ) ->
		#resolve result
		#TO-DO

		#return vo
		#TO-DO

	#private (parser stat_resource return)
	parserStatResourceReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserStatResourceReturn




	#///////////////// Parser for property return (need resolve) /////////////////
	#private (resolve result to vo )
	resolvePropertyResult = ( result ) ->

		return result

	#private (parser property return)
	parserPropertyReturn = ( result, return_code, param ) ->

		#1.resolve return_code
		aws_result = result_vo.processAWSReturnHandler result, return_code, param

		#2.resolve return_data when return_code is E_OK
		if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

			resolved_data = resolvePropertyResult result

			aws_result.resolved_data = resolved_data


		#3.return vo
		aws_result

	# end of parserPropertyReturn


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
	resource = ( src, username, session_id, region_name=null, resources=null, addition='all', retry_times=1, callback ) ->
		send_request "resource", src, [ username, session_id, region_name, resources, addition, retry_times ], parserResourceReturn, callback
		true

	#def price(self, username, session_id):
	price = ( src, username, session_id, callback ) ->
		send_request "price", src, [ username, session_id ], parserPriceReturn, callback
		true

	#def status(self, username, session_id):
	status = ( src, username, session_id, callback ) ->
		send_request "status", src, [ username, session_id ], parserStatusReturn, callback
		true

	#def vpc_resource(self, username, session_id, region_name, vpc_id):
	vpc_resource = ( src, username, session_id, region_name=null, resources=null, addition='vpc', retry_times=1, callback ) ->
		send_request "resource", src, [ username, session_id, region_name, resources, addition, retry_times ], parserVpcResourceReturn, callback
		true

	#def stat_resource(self, username, session_id, region_name=None, resources=None):
	stat_resource = ( src, username, session_id, region_name=null, resources=null, callback ) ->
		send_request "stat_resource", src, [ username, session_id, region_name, resources ], parserStatResourceReturn, callback
		true

	#def property(self, username, session_id):
	property = ( src, username, session_id, callback ) ->
		send_request "property", src, [ username, session_id ], parserPropertyReturn, callback
		true


	#############################################################
	#public
	quickstart                   : quickstart
	Public                       : Public
	info                         : info
	resource                     : resource
	price                        : price
	status                       : status
	vpc_resource                 : vpc_resource
	stat_resource                : stat_resource
	property                     : property

