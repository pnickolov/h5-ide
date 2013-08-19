define [ 'MC', 'constant', 'underscore', 'jquery' ], ( MC, constant, _, $ ) ->

	#private
	getNewName = (compType) ->

		new_name 	= ""
		name_prefix = ""
		name_list   = []

		switch compType

			when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
				name_prefix = "host"

			when constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair
				name_prefix = "kp"

			when constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
				name_prefix = "custom-sg-"

			when constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
				name_prefix = "eip"

			when constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume
				name_prefix = "vol"

			when constant.AWS_RESOURCE_TYPE.AWS_ELB
				name_prefix = "load-balancer-"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC
				name_prefix = "vpc"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
				name_prefix = "subnet"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
				name_prefix = "RT-"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway
				name_prefix = "customer-gateway-"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
				name_prefix = "eni"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions
				name_prefix = "dhcp"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection
				name_prefix = "vpn"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
				name_prefix = "acl"

			when constant.AWS_RESOURCE_TYPE.AWS_IAM_ServerCertificate
				name_prefix = "iam"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway
				name_prefix = "Internet-gateway"

			when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway
				name_prefix = "VPN-gateway"

			#ASG
			when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
				name_prefix = "asg"

			when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
				name_prefix = "launch-config-"

			when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration
				name_prefix = "asl-nc"

			when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy
				name_prefix = "asl-sp-"

			when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScheduledActions
				name_prefix = "asl-sa-"

			when constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch
				name_prefix = "clw-"

			when constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription
				name_prefix = "sns-sub"

			when constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic
				name_prefix = "sns-topic"


		#get exist name
		_.each MC.canvas_data.component, (compObj) ->

			if compObj.type is compType

				name_list.push compObj.name

			null


		#find name
		idx = 1
		while idx <= name_list.length

			if $.inArray( (name_prefix + idx), name_list ) == -1
				#not in name_list
				break

			idx++

		#return new name
		name_prefix + idx


	cacheResource = (resources, region) ->

		#cache aws resource data to MC.data.reosurce_list

		#vpc
		if resources.DescribeVpcs
			_.map resources.DescribeVpcs, ( res, i ) ->
				MC.data.resource_list[region][res.vpcId] = res
				null

		#instance
		if resources.DescribeInstances
			_.map resources.DescribeInstances, ( res, i ) ->
				MC.data.resource_list[region][res.instanceId] = res
				null

		#volume
		if resources.DescribeVolumes
			_.map resources.DescribeVolumes, ( res, i ) ->
				MC.data.resource_list[region][res.volumeId] = res
				null

		#eip
		if resources.DescribeAddresses
			_.map resources.DescribeAddresses, ( res, i ) ->
				MC.data.resource_list[region][res.publicIp] = res
				null

		#elb
		if resources.DescribeLoadBalancers
			_.map resources.DescribeLoadBalancers, ( res, i ) ->
				MC.data.resource_list[region][res.LoadBalancerName] = res
				null

		#vpn
		if resources.DescribeVpnConnections
			_.map resources.DescribeVpnConnections, ( res, i ) ->
				MC.data.resource_list[region][res.vpnConnectionId] = res
				null

		#kp
		if resources.DescribeKeyPairs
			_.map resources.DescribeKeyPairs, ( res, i ) ->
				MC.data.resource_list[region][res.keyFingerprint] = res
				null

		#sg
		if resources.DescribeSecurityGroups
			_.map resources.DescribeSecurityGroups, ( res, i ) ->
				MC.data.resource_list[region][res.groupId] = res
				null

		#dhcp
		if resources.DescribeDhcpOptions
			_.map resources.DescribeDhcpOptions, ( res, i ) ->
				MC.data.resource_list[region][res.dhcpOptionsId] = res
				null

		#subnet
		if resources.DescribeSubnets
			_.map resources.DescribeSubnets, ( res, i ) ->
				MC.data.resource_list[region][res.subnetId] = res
				null

		#routetable
		if resources.DescribeRouteTables
			_.map resources.DescribeRouteTables, ( res, i ) ->
				MC.data.resource_list[region][res.routeTableId] = res
				null

		#acl
		if resources.DescribeNetworkAcls
			_.map resources.DescribeNetworkAcls, ( res, i ) ->
				MC.data.resource_list[region][res.networkAclId] = res
				null

		#eni
		if resources.DescribeNetworkInterfaces
			_.map resources.DescribeNetworkInterfaces , ( res, i ) ->
				MC.data.resource_list[region][res.networkInterfaceId] = res
				null

		#igw
		if resources.DescribeInternetGateways
			_.map resources.DescribeInternetGateways, ( res, i ) ->
				MC.data.resource_list[region][res.internetGatewayId] = res
				null

		#vgw
		if resources.DescribeVpnGateways
			_.map resources.DescribeVpnGateways, ( res, i ) ->
				MC.data.resource_list[region][res.vpnGatewayId] = res
				null

		#cgw
		if resources.DescribeCustomerGateways
			_.map resources.DescribeCustomerGateways, ( res, i ) ->
				MC.data.resource_list[region][res.customerGatewayId] = res
				null

		#ami
		if resources.DescribeImages
			_.map resources.DescribeImages, ( res, i ) ->
				if !MC.data.dict_ami[res.imageId]
					MC.data.dict_ami[res.imageId] = res
				#MC.data.resource_list[region][res.imageId] = res
				null


		########################

		#asg
		if resources.DescribeAutoScalingGroups
			_.map resources.DescribeAutoScalingGroups, ( res, i ) ->
				MC.data.resource_list[region][res.AutoScalingGroupARN] = res
				null

		#asl lc
		if resources.DescribeLaunchConfigurations
			_.map resources.DescribeLaunchConfigurations, ( res, i ) ->
				MC.data.resource_list[region][res.LaunchConfigurationARN] = res
				null

		#asl nc
		if resources.DescribeNotificationConfigurations

			#init
			if !MC.data.resource_list[region].NotificationConfigurations
				MC.data.resource_list[region].NotificationConfigurations = []

			_.map resources.DescribeNotificationConfigurations, ( res, i ) ->
				MC.data.resource_list[region].NotificationConfigurations.push res
				null

		#asl sp
		if resources.DescribePolicies
			_.map resources.DescribePolicies, ( res, i ) ->
				MC.data.resource_list[region][res.PolicyARN] = res
				null

		#asl sa
		if resources.DescribeScheduledActions
			_.map resources.DescribeScheduledActions, ( res, i ) ->
				MC.data.resource_list[region][res.ScheduledActionARN] = res
				null

		#clw
		if resources.DescribeAlarms
			_.map resources.DescribeAlarms, ( res, i ) ->
				MC.data.resource_list[region][res.AlarmArn] = res
				null

		#sns sub
		if resources.ListSubscriptions

			#init
			if !MC.data.resource_list[region].Subscriptions
				MC.data.resource_list[region].Subscriptions = []

			_.map resources.ListSubscriptions, ( res, i ) ->
				MC.data.resource_list[region].Subscriptions.push res
				null

		#sns topic
		if resources.ListTopics
			_.map resources.ListTopics, ( res, i ) ->
				MC.data.resource_list[region][res.TopicArn] = res
				null


		#asl instance
		if resources.DescribeAutoScalingInstances
			_.map resources.DescribeAutoScalingInstances, ( res, i ) ->
				MC.data.resource_list[region][res.AutoScalingGroupName + ':' + res.InstanceId] = res
				null


		#asl activities
		if resources.DescribeScalingActivities
			_.map resources.DescribeScalingActivities, ( res, i ) ->
				MC.data.resource_list[region][res.ActivityId] = res
				null




		null


	checkIsRepeatName = (compUID, newName) ->

		originCompObj = MC.canvas_data.component[compUID]
		originCompUID = originCompObj.uid
		originCompType = originCompObj.type

		not _.some MC.canvas_data.component, (compObj) ->
			compUID = compObj.uid
			compType = compObj.type
			compName = compObj.name
			if originCompType is compType and originCompUID isnt compUID and newName is compName
				return true


	checkStackName = ( stackId, newName ) ->
		stackArray = _.flatten _.values MC.data.stack_list

		not _.some stackArray, ( stack ) ->
			return stack.id isnt stackId and stack.name is newName

	disabledAllOperabilityArea = (enabled) ->

		if enabled
            $('#resource-panel').append('<div class="disabled-event-layout"></div>')
            $('#canvas').append('<div class="disabled-event-layout"></div>')
            $('#tabbar-wrapper').append('<div class="disabled-event-layout"></div>')
		else
			$('.disabled-event-layout').remove()

	#public
	getNewName : getNewName
	cacheResource : cacheResource
	checkIsRepeatName : checkIsRepeatName
	checkStackName : checkStackName
	disabledAllOperabilityArea : disabledAllOperabilityArea
