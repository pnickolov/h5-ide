define [ 'MC', 'constant' ], ( MC, constant ) ->


	getNameById = ( app_id ) ->

		app_name = ''

		if app_id

			try

				if MC.tab[app_id]
						current_tab = MC.tab[app_id].data
					else
						current_tab = MC.canvas_data

				if current_tab
					app_name = current_tab.name

			catch e

				console.error '[getNameById] error: ' + e
				app_name = ''


		app_name

	existing_app_resource = ( resource_uid ) ->

		result = null

		if MC.canvas_data.component[resource_uid]

			switch MC.canvas_data.component[resource_uid].type

				when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

					result = if MC.canvas_data.component[resource_uid].resource.InstanceId then true else false

				when constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume

					result = if MC.canvas_data.component[resource_uid].resource.VolumeId then true else false

				when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

					result = if MC.canvas_data.component[resource_uid].resource.AutoScalingGroupARN then true else false

				when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

					result = if MC.canvas_data.component[resource_uid].resource.LaunchConfigurationARN then true else false

				when constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

					result = if MC.canvas_data.component[resource_uid].resource.GroupId then true else false

		return result


	#clear data in MC.data.resource_list for app
	clearResourceInCache = ( canvas_data ) ->

		resource_list = MC.data.resource_list[MC.canvas.data.get('region')]
		if resource_list
			$.each canvas_data.component, (uid, comp) ->

				res_key = constant.AWS_RESOURCE_KEY[comp.type]
				
				if res_key and resource_list and resource_list[comp.resource[res_key]]

					delete resource_list[comp.resource[res_key]]

				null
			
		null


	#add delete class to deleted resource
	updateDeletedResourceState = ( canvas_data ) ->

		if canvas_data and canvas_data.component and MC.data.resource_list
			
			resource_list = MC.data.resource_list[MC.canvas.data.get('region')]
			resource_type_list = [ "AWS.ELB", "AWS.VPC.VPC", "AWS.VPC.Subnet", "AWS.VPC.InternetGateway", "AWS.AutoScaling.Group" ]
			resource_type_list = resource_type_list.concat ["AWS.VPC.RouteTable", "AWS.VPC.VPNGateway", "AWS.VPC.CustomerGateway", "AWS.AutoScaling.LaunchConfiguration" ]
			#resource_type_list = resource_type_list.concat [ "AWS.EC2.Instance", "AWS.EC2.EBS.Volume", "AWS.VPC.NetworkInterface" ]
			#resource_type_list = resource_type_list.concat [ "AWS.VPC.DhcpOptions", "AWS.VPC.VPNConnection", "AWS.VPC.NetworkAcl" ]
			#resource_type_list = resource_type_list.concat ["AWS.AutoScaling.ScalingPolicy", "AWS.AutoScaling.ScheduledActions", "AWS.CloudWatch.CloudWatch" ]
			#resource_type_list = resource_type_list.concat ["AWS.SNS.Subscription", "AWS.AutoScaling.NotificationConfiguration", "AWS.IAM.ServerCertificate", "AWS.SNS.Topic" ]
			#resource_type_list = resource_type_list.concat [ "AWS.EC2.KeyPair", "AWS.EC2.SecurityGroup", "AWS.EC2.EIP", "AWS.EC2.AMI" ]

			$.each canvas_data.component, (uid, comp) ->

				isExisted = true
				
				if comp.type in resource_type_list
					isExisted = _isExistedResource resource_list, comp
				else
					return true

				if !isExisted
					Canvon('#' + uid).addClass 'deleted'
				else
					Canvon('#' + uid).removeClass 'deleted'

				null

		null


	#private
	_isExistedResource = ( resource_list, comp ) ->

		res_key = constant.AWS_RESOURCE_KEY[comp.type]
		res_data = if res_key and resource_list and resource_list[comp.resource[res_key]] then resource_list[comp.resource[res_key]] else null
		
		#return
		if res_data then return true else return false


	#public
	existing_app_resource : existing_app_resource
	getNameById : getNameById
	updateDeletedResourceState : updateDeletedResourceState
	clearResourceInCache : clearResourceInCache
