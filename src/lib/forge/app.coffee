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


	#add delete class to deleted resource
	updateDeletedResourceState = ( canvas_data ) ->

		if canvas_data and canvas_data.component and MC.data.resource_list
			
			resource_list = MC.data.resource_list[MC.canvas.data.get('region')]
			$.each canvas_data.component, (uid, comp) ->

				isExisted = true
				switch
					when comp.type is "AWS.ELB" then isExisted = _isExistedELB comp, resource_list

					else
						return true

				if !isExisted
					Canvon('#' + uid).addClass 'deleted'
				else
					Canvon('#' + uid).removeClass 'deleted'

				null

		null


	#private
	_isExistedELB = ( comp, resource_list ) ->

		elb_key = comp.resource.LoadBalancerName
		elb_data = resource_list[elb_key]
		
		#return
		if elb_data then return true else return false


	#public
	existing_app_resource : existing_app_resource
	getNameById : getNameById
	updateDeletedResourceState : updateDeletedResourceState
