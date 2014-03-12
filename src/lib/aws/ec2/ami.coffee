define [ 'MC', 'constant' ], ( MC, constant ) ->


	getOSType = ( ami ) ->

		#return osType by ami.name | ami.description | ami.imageLocation
		if !ami
			return 'unknown'

		if ami.osType
			return ami.osType

		osTypeList = ['centos', 'redhat', 'rhel', 'ubuntu', 'debian', 'fedora', 'gentoo', 'opensuse', 'suse','amazon', 'amzn']

		osType = 'linux-other'

		found  = []

		if  ami.platform and ami.platform == 'windows'

			found.push 'windows'

		else

			#check ami.name
			if ami.name
				found = osTypeList.filter (word) -> ~ami.name.toLowerCase().indexOf word

			#check ami.description
			if found.length == 0 and 'description' of ami and ami.description
				found = osTypeList.filter (word) -> ~ami.description.toLowerCase().indexOf word

			#check ami.imageLocation
			if found.length == 0 and 'imageLocation' of ami and ami.imageLocation
				found = osTypeList.filter (word) -> ~ami.imageLocation.toLowerCase().indexOf word

		if found.length > 0
			osType = found[0]

		switch osType
			when 'rhel' then osType = 'redhat'
			when 'amzn' then osType = 'amazon'

		osType

	getInstanceType = ( ami ) ->

		try
			region = MC.canvas_data.region
			instance_type = MC.data.instance_type[region]
			region_instance_type = MC.data.region_instance_type
			current_region_instance_type = null

			if region_instance_type
				current_region_instance_type = region_instance_type[region]

			currentTypeData = instance_type

			if current_region_instance_type and ami.osFamily
				currentTypeData = current_region_instance_type

			if !currentTypeData
				return []

			if current_region_instance_type
				key = ami.osFamily
				if not key
					osType = ami.osType
					key = constant.OS_TYPE_MAPPING[osType]

				currentTypeData = currentTypeData[key]
			else
				if ami.osType == 'windows'
					currentTypeData = currentTypeData.windows
				else
					currentTypeData = currentTypeData.linux

			if ami.rootDeviceType == 'ebs'
				currentTypeData = currentTypeData.ebs
			else
				currentTypeData = currentTypeData['instance store']
			if ami.architecture == 'x86_64'
				currentTypeData = currentTypeData["64"]
			else
				currentTypeData = currentTypeData["32"]

			# According to property/instance/model, if ami.virtualizationType is undefined.
			# It defaults to "paravirtual"
			currentTypeData = currentTypeData[ami.virtualizationType || "paravirtual"]
		catch err
			currentTypeData = []

		if not currentTypeData or currentTypeData.length <= 0
			currentTypeData = MC.data.config[region].region_instance_type

		return currentTypeData

	setLayout = ( canvas_data ) ->

		for uid, comp of canvas_data.component

			if comp.type in ['AWS.EC2.Instance', "AWS.AutoScaling.LaunchConfiguration"]

				if MC.data.dict_ami[comp.resource.ImageId]

					canvas_data.layout.component.node[uid].osType = MC.data.dict_ami[comp.resource.ImageId].osType
					canvas_data.layout.component.node[uid].architecture = MC.data.dict_ami[comp.resource.ImageId].architecture
					canvas_data.layout.component.node[uid].rootDeviceType = MC.data.dict_ami[comp.resource.ImageId].rootDeviceType
					#canvas_data.layout.component.node[uid].virtualizationType = MC.data.dict_ami[comp.resource.ImageId].virtualizationType


	convertBlockDeviceMapping = (ami) ->

	    data = {}
	    if ami and ami.blockDeviceMapping.item
		    for value,idx in ami.blockDeviceMapping.item

		        if value.ebs
		            data[value.deviceName] =
		                snapshotId : value.ebs.snapshotId
		                volumeSize : value.ebs.volumeSize
		                volumeType : value.ebs.volumeType
		                deleteOnTermination : value.ebs.deleteOnTermination
		        else
		            data[value.deviceName] = {}

		    ami.blockDeviceMapping = data
	    null


	getRootDevice = (image_id) ->

		ami = MC.data.dict_ami[image_id]
		rootDevice = null

		if MC.data.dict_ami and MC.data.dict_ami[image_id]
			ami_info    = MC.data.dict_ami[image_id]
			root_device_name = ami_info.rootDeviceName
			root_device_info = ami_info.blockDeviceMapping[root_device_name]
			if root_device_name and root_device_info
				rootDevice = {
					"DeviceName": root_device_name
					"Ebs":
						"VolumeSize": root_device_info.volumeSize
						"SnapshotId": root_device_info.snapshotId
						"VolumeType": root_device_info.volumeType
						"Iops": if root_device_info.iops then root_device_info.iops else ""
					}
			else
				console.warn "root_device(): can not found root device of AMI(" + image_id + ")"

		rootDevice


	setLayout : setLayout
	getOSType : getOSType
	getInstanceType : getInstanceType
	convertBlockDeviceMapping : convertBlockDeviceMapping
	getRootDevice : getRootDevice
