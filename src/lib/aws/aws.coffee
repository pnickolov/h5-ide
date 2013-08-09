define [ 'MC', 'constant' ], ( MC, constant ) ->

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
				name_prefix = "sg"

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

	#public
	getNewName : getNewName
