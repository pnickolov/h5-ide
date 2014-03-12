define [ 'MC' ], ( MC) ->

	#get valid deviceName for Volume
	getDeviceName = (uid,volume_id) ->

		comp_data 	= MC.canvas.data.get("component")[uid]
		region 		= MC.canvas.data.get("region")
		image_id 	= (if comp_data then comp_data.resource.ImageId else "")
		ami_info 	= (if (MC.data.config[region].ami and MC.data.config[region].ami[image_id]) then MC.data.config[region].ami[image_id] else MC.data.dict_ami[image_id])
		device_list	= []
		device_name = null #result

		#check deviceName
		if ami_info and ami_info.osType != 'windows'
			#linux
			device_list = 'f g h i j k l m n o p'.split(' ')

		else
			#windows
			device_list = 'f g h i j k l m n o p'.split(' ')


		$.each ami_info.blockDeviceMapping, (key, value) ->
			if $.type(value) is "string"
				#only for external volume
				if key.slice(0, 4) is "/dev/"
					k = key.slice(-1)
					index = device_list.indexOf(k)
					device_list.splice index, 1  if index >= 0
			null


		if comp_data.type == 'AWS.EC2.Instance'

			#for Instance
			$.each comp_data.resource.BlockDeviceMapping, (key, value) ->
				if $.type(value) is "string"
					#only for external volume
					volume_uid = value.slice(1)
					k = MC.canvas_data.component[volume_uid].name.slice(-1)
					index = device_list.indexOf(k)
					device_list.splice index, 1  if index >= 0

		else if comp_data.type == 'AWS.AutoScaling.LaunchConfiguration'

			#for LaunchConfiguration
			$.each comp_data.resource.BlockDeviceMapping, (key, value) ->
			  index = device_list.indexOf(value.DeviceName.substr(-1, 1))
			  device_list.splice index, 1  if index >= 0


		if device_list.length is 0
			#no valid deviceName
			device_name = null

		else

			if ami_info.osType isnt "windows"
			  device_name = "/dev/sd" + device_list[0]
			else
			  device_name = "xvd" + device_list[0]

		device_name

	getVolumeLen = (bdm) ->

		volume_len = 0

		if bdm is null
			return volume_len

		if bdm.length is 0 or ( bdm.length > 0 and ( $.type(bdm[0]) is "string" or bdm[0].DeviceName isnt "/dev/sda1" ) )
			#has no root device
			volume_len = bdm.length

		else
			volume_len = bdm.length - 1

		volume_len

	getRootDevice = (bdm) ->

		rootDevice = null

		if bdm is null or bdm.length is 0
			return null

		if bdm.length is 0 or ( bdm.length > 0 and ( $.type(bdm[0]) is "string" or bdm[0].DeviceName isnt "/dev/sda1" ) )
			#has no root device
			return null

		else
			rootDevice = bdm[0]

		rootDevice

	getDeviceName : getDeviceName
	getVolumeLen : getVolumeLen
	getRootDevice : getRootDevice
