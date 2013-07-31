define [ 'MC' ], ( MC ) ->

	#private
	init = (uid) ->

		allComp = MC.canvas_data.component
		haveVPC = allComp[uid].resource.VpcId
		if !haveVPC
			MC.canvas_data.component[uid].resource.Scheme = ''

		# have igw ?
		igwCompAry = _.filter allComp, (obj) ->
			obj.type is 'AWS.VPC.InternetGateway'
		if igwCompAry.length isnt 0
			MC.canvas_data.component[uid].resource.Scheme = 'internet-facing'

		null

	addInstanceAndAZToELB = (elbUID, instanceUID) ->
		elbComp = MC.canvas_data.component[elbUID]
		instanceComp = MC.canvas_data.component[instanceUID]

		currentInstanceAZ = instanceComp.resource.Placement.AvailabilityZone

		instanceUID = instanceComp.uid
		instanceRef = '@' + instanceUID + '.resource.InstanceId'

		elbInstanceAry = elbComp.resource.Instances
		elbInstanceAryLength = elbInstanceAry.length

		elbAZAry = elbComp.resource.AvailabilityZones
		elbAZAryLength = elbAZAry.length

		addInstanceToElb = true
		_.each elbInstanceAry, (elem, index) ->
			if elem.InstanceId is instanceRef
				addInstanceToElb = false
				null

		if addInstanceToElb
			MC.canvas_data.component[elbUID].resource.Instances.push({
				InstanceId: instanceRef
			})

		addAZToElb = true
		_.each elbAZAry, (elem, index) ->
			if elem is currentInstanceAZ
				addAZToElb = false
				null

		if addAZToElb
			MC.canvas_data.component[elbUID].resource.AvailabilityZones.push(currentInstanceAZ)

		# If current AZ has no subnet connects to the elb. connect the subnet to elb
		extractRegex = /@([^.]+)\./
		subnet_uid = "@" + subnet_uid + ".resource.SubnetId"

		for subnet, i in elbComp.resource.Subnets
			extractID      = extractRegex.exec( subnet )
			linkedSubnetID = if extractID then extractID[1] else subnet
			linkedSubnet   = MC.canvas_data.component[ linkedSubnetID ]

			if linkedSubnet.resource.AvailabilityZone == currentInstanceAZ
				alreadyLinkedSubnet = true
				break

		if !alreadyLinkedSubnet && instanceComp.resource.SubnetId
			extractID = extractRegex.exec instanceComp.resource.SubnetId
			elbComp.resource.Subnets.push instanceComp.resource.SubnetId
			return extractID[1]

		null

	removeInstanceFromELB = (elbUID, instanceUID) ->
		elbComp = MC.canvas_data.component[elbUID]
		instanceComp = MC.canvas_data.component[instanceUID]

		instanceUID = instanceComp.uid
		instanceRef = '@' + instanceUID + '.resource.InstanceId'

		elbInstanceAry = elbComp.resource.Instances
		elbInstanceAryLength = elbInstanceAry.length

		instanceAry = MC.canvas_data.component[elbUID].resource.Instances

		newInstanceAry = _.filter instanceAry, (value) ->
			if value.InstanceId is instanceRef
				false
			else
				true

		MC.canvas_data.component[elbUID].resource.Instances = newInstanceAry

		null

	setAllELBSchemeAsInternal = () ->
		_.each MC.canvas_data.component, (value, key) ->
			if value.type is 'AWS.ELB'
				MC.canvas_data.component[key].resource.Scheme = 'internal'
				MC.canvas.update key, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNAL_CANVAS
			null
		null

	addSubnetToELB = ( elb_uid, subnet_uid ) ->
		elb = MC.canvas_data.component[ elb_uid ]
		extractRegex = /@([^.]+)\./

		az_subnet_map = {}

		newSubnetAZ   = MC.canvas_data.component[ subnet_uid ].resource.AvailabilityZone

		subnet_uid = "@" + subnet_uid + ".resource.SubnetId"

		for subnet, i in elb.resource.Subnets
			extractID      = extractRegex.exec( subnet )
			linkedSubnetID = if extractID then extractID[1] else subnet
			linkedSubnet   = MC.canvas_data.component[ linkedSubnetID ]

			if linkedSubnet.resource.AvailabilityZone == newSubnetAZ
				replacedSubnet = linkedSubnetID
				elb.resource.Subnets[i] = subnet_uid

		if not replacedSubnet
			elb.resource.Subnets.push subnet_uid

		replacedSubnet

	removeSubnetFromELB = ( elb_uid, subnet_uid ) ->
		elb = MC.canvas_data.component[ elb_uid ]

		for subnet, i in elb.resource.Subnets
			if subnet.indexOf( subnet_uid ) != -1
				elb.resource.Subnets.splice i, 1
				break

		null


	#public
	init                      : init
	addInstanceAndAZToELB     : addInstanceAndAZToELB
	removeInstanceFromELB     : removeInstanceFromELB
	setAllELBSchemeAsInternal : setAllELBSchemeAsInternal
	addSubnetToELB            : addSubnetToELB
	removeSubnetFromELB       : removeSubnetFromELB
