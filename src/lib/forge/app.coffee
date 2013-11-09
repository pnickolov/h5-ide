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


	#public
	existing_app_resource : existing_app_resource
	getNameById : getNameById
