define [ 'MC', 'constant', 'underscore', 'Design' ], ( MC, constant, _, Design ) ->

	getAZAryForDefaultVPC = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]
		elbInstances = elbComp.resource.Instances
		azNameAry = []

		_.each elbInstances, (instanceRefObj) ->
			instanceRef = instanceRefObj.InstanceId
			instanceUID = MC.extractID(instanceRef)
			instanceAZName = MC.canvas_data.component[instanceUID].resource.Placement.AvailabilityZone
			if !(instanceAZName in azNameAry)
				azNameAry.push(instanceAZName)
			null

		return azNameAry


	#private
	getVPCUID = () ->
		vpc = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).theVPC()
		if vpc
			vpc.id
		else
			null

	updateAllSubnetCIDR = (vpcCIDR, oldVPCCIDR) ->

		needUpdateAllSubnetCIDR = false
		subnetCount = 0

		oldSubnetAry = []
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
				subnetCount++
				subnetCIDR = compObj.resource.CidrBlock
				oldSubnetAry.push(subnetCIDR)
			null
		###############

		newSubnetCIDRAry = []
		newSimpleSubnetCIDRAry = MC.aws.subnet.autoAssignSimpleCIDR(vpcCIDR, oldSubnetAry, oldVPCCIDR)
		if newSimpleSubnetCIDRAry.length
			newSubnetCIDRAry = newSimpleSubnetCIDRAry
		else
			newSubnetCIDRAry = MC.aws.subnet.autoAssignAllCIDR(vpcCIDR, subnetCount)

		# if subnet error, return
		haveError = false
		_.each newSubnetCIDRAry, (subnetCIDR) ->
			if !MC.validate 'cidr', subnetCIDR
				haveError = true
			null

		if haveError
			return false

		###############

		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
				subnetCIDR = compObj.resource.CidrBlock
				if !MC.aws.subnet.isInVPCCIDR(vpcCIDR, subnetCIDR)
					needUpdateAllSubnetCIDR = true

			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
				compObj.resource.RouteSet[0].DestinationCidrBlock = vpcCIDR
			null

		if !needUpdateAllSubnetCIDR
			return true

		# assign new CIDR

		subnetNum = 0
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
				newCIDR = newSubnetCIDRAry[subnetNum]
				MC.canvas_data.component[compObj.uid].resource.CidrBlock = newCIDR
				MC.aws.subnet.updateAllENIIPList(compObj.uid, false)
				MC.canvas.update compObj.uid, 'text', 'label', compObj.name + ' (' + newCIDR + ')'
				subnetNum++

		return true

	checkFullDefaultVPC = () ->

		if MC.canvas_data.platform isnt 'default-vpc'
			return false

		currentRegion = MC.canvas_data.region
		accountData = MC.data.account_attribute[currentRegion]

		defaultVPCId = accountData.default_vpc
		defaultSubnetObj = accountData.default_subnet

		if defaultVPCId is 'none'
			return false

		if !defaultSubnetObj or _.keys(defaultSubnetObj).length is 0
			return false

		allSubnetIsDefaultForAZ = true
		_.each defaultSubnetObj, (subnetObj, azName) ->
			if subnetObj.defaultForAz isnt 'true'
				allSubnetIsDefaultForAZ = false
			if subnetObj.vpcId isnt defaultVPCId
				allSubnetIsDefaultForAZ = false
			if subnetObj.state isnt 'available'
				allSubnetIsDefaultForAZ = false
			null

		if allSubnetIsDefaultForAZ
			return true
		else
			return false

	getSubnetForDefaultVPC = (instanceOrEniUID) ->

		instanceComp = MC.canvas_data.component[instanceOrEniUID]

		instanceAZ = ''
		if instanceComp.resource.AvailabilityZone
			instanceAZ = instanceComp.resource.AvailabilityZone
		else
			instanceAZ = instanceComp.resource.Placement.AvailabilityZone

		currentRegion = MC.canvas_data.region
		accountData = MC.data.account_attribute[currentRegion]

		defaultVPCId = accountData.default_vpc
		defaultSubnetObj = accountData.default_subnet

		subnetObj = defaultSubnetObj[instanceAZ]

		return subnetObj

	getAZSubnetForDefaultVPC = (azName) ->
		MC.data.account_attribute[ Design.instance().region() ].default_subnet[ azName ]

	generateComponentForDefaultVPC = () ->

		resType = constant.AWS_RESOURCE_TYPE

		originComps = MC.canvas_data.component
		currentComps = _.extend(originComps, {})

		defaultVPCId = MC.aws.aws.checkDefaultVPC()

		azObjAry = MC.data.config[MC.canvas_data.region].zone.item
		azSubnetIdMap = {}
		_.each azObjAry, (azObj) ->
			azName = azObj.zoneName
			resultObj = {}
			subnetObj = MC.aws.vpc.getAZSubnetForDefaultVPC(azName)
			subnetId = null
			if subnetObj
				subnetId = subnetObj.subnetId
			else
				subnetId = ''
			azSubnetIdMap[azName] = subnetId
			null

		_.each currentComps, (compObj) ->

			compType = compObj.type
			compUID = compObj.uid

			if compType is resType.AWS_EC2_Instance
				instanceAZName = compObj.resource.Placement.AvailabilityZone
				currentComps[compUID].resource.VpcId = defaultVPCId
				currentComps[compUID].resource.SubnetId = azSubnetIdMap[instanceAZName]

			else if compType is resType.AWS_VPC_NetworkInterface
				eniAZName = compObj.resource.AvailabilityZone
				currentComps[compUID].resource.VpcId = defaultVPCId
				currentComps[compUID].resource.SubnetId = azSubnetIdMap[eniAZName]

			else if compType is resType.AWS_ELB
				currentComps[compUID].resource.VpcId = defaultVPCId
				azNameAry = getAZAryForDefaultVPC(compUID)
				subnetIdAry = _.map azNameAry, (azName) ->
					return azSubnetIdMap[azName]
				currentComps[compUID].resource.Subnets = subnetIdAry

			else if compType is resType.AWS_EC2_SecurityGroup
				currentComps[compUID].resource.VpcId = defaultVPCId

			else if compType is resType.AWS_AutoScaling_Group
				asgAZAry = compObj.resource.AvailabilityZones
				asgSubnetIdAry = _.map asgAZAry, (azName) ->
					return azSubnetIdMap[azName]
				asgSubnetIdStr = asgSubnetIdAry.join(' , ')
				currentComps[compUID].resource.VPCZoneIdentifier = asgSubnetIdStr

			null

		return currentComps

	#public
	getVPCUID : getVPCUID
	updateAllSubnetCIDR : updateAllSubnetCIDR
	checkFullDefaultVPC : checkFullDefaultVPC
	getSubnetForDefaultVPC : getSubnetForDefaultVPC
	getAZSubnetForDefaultVPC : getAZSubnetForDefaultVPC
	generateComponentForDefaultVPC : generateComponentForDefaultVPC
