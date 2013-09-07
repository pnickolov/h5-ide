define [ 'MC' ], ( MC) ->


	getOSType = ( ami ) ->

		#return osType by ami.name | ami.description | ami.imageLocation

		osTypeList = ['centos', 'redhat', 'redhat', 'ubuntu', 'debian', 'fedora', 'gentoo', 'opensus', 'suse','amazon', 'amazon']

		osType = 'linux-other'

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


	getOSType : getOSType

