define [ 'MC' ], ( MC) ->


	getOSType = ( ami ) ->

		#return osType by ami.name | ami.description | ami.imageLocation

		osTypeList = ['centos', 'redhat', 'redhat', 'ubuntu', 'debian', 'fedora', 'gentoo', 'opensus', 'suse','amazon', 'amazon']

		osType = 'linux-other'

		found  = []

		if  ami.platform and ami.platform == 'windows'

			found.push 'win'

		else

			#check ami.name
			found = osTypeList.filter (word) -> ~ami.name.toLowerCase().indexOf word

			#check ami.description
			if found.length == 0
				found = osTypeList.filter (word) -> ~ami.description.toLowerCase().indexOf word

			#check ami.imageLocation
			if found.length == 0
				found = osTypeList.filter (word) -> ~ami.imageLocation.toLowerCase().indexOf word

		if found.length == 0
			osType = 'unknown'
		else
			osType = found[0]

		osType

	getInstanceType = ( ami ) ->

		region = MC.canvas_data.region
		instance_type = MC.data.config[region].ami_instance_type

		if !instance_type
			return []

		if ami.virtualizationType == 'hvm'
			instance_type = instance_type.windows
		else
			instance_type = instance_type.linux
		if ami.rootDeviceType == 'ebs'
			instance_type = instance_type.ebs
		else
			instance_type = instance_type['instance store']
		if ami.architecture == 'x86_64'
			instance_type = instance_type["64"]
		else
			instance_type = instance_type["32"]

		# According to property/instance/model, if ami.virtualizationType is undefined.
		# It defaults to "paravirtual"
		instance_type = instance_type[ami.virtualizationType || "paravirtual"]

		return instance_type

	getOSType : getOSType
	getInstanceType : getInstanceType
