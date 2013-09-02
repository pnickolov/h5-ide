define [ 'MC', 'constant' ], ( MC, constant ) ->

	#private
	getVPCUID = () ->
		vpcUID = ''
		_.each MC.canvas_data.layout.component.group, (groupObj, groupUID) ->
			if groupObj.type is 'AWS.VPC.VPC'
				vpcUID = groupUID
				return false
		return vpcUID

	updateAllSubnetCIDR = (vpcCIDR, oldVPCCIDR) ->

		needUpdateAllSubnetCIDR = false
		subnetCount = 0

		oldSubnetAry = []
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
				subnetCount++
				subnetCIDR = compObj.resource.CidrBlock
				oldSubnetAry.push(subnetCIDR)
				if !MC.aws.subnet.isInVPCCIDR(vpcCIDR, subnetCIDR)
					needUpdateAllSubnetCIDR = true

			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
				compObj.resource.RouteSet[0].DestinationCidrBlock = vpcCIDR
			null

		if !needUpdateAllSubnetCIDR then return

		newSubnetCIDRAry = []
		newSimpleSubnetCIDRAry = MC.aws.subnet.autoAssignSimpleCIDR(vpcCIDR, oldSubnetAry, oldVPCCIDR)
		if newSimpleSubnetCIDRAry.length
			newSubnetCIDRAry = newSimpleSubnetCIDRAry
		else
			newSubnetCIDRAry = MC.aws.subnet.autoAssignAllCIDR(vpcCIDR, subnetCount)

		subnetNum = 0
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
				newCIDR = newSubnetCIDRAry[subnetNum]
				MC.canvas_data.component[compObj.uid].resource.CidrBlock = newCIDR
				MC.aws.subnet.updateAllENIIPList(compObj.uid)
				MC.canvas.update compObj.uid, 'text', 'name', compObj.name + ' (' + newCIDR + ')'
				subnetNum++

		null

	checkFullDefaultVPC = () ->

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

		currentRegion = MC.canvas_data.region
		accountData = MC.data.account_attribute[currentRegion]

		defaultSubnetObj = accountData.default_subnet

		subnetObj = defaultSubnetObj[azName]

		return subnetObj

	#public
	getVPCUID : getVPCUID
	updateAllSubnetCIDR : updateAllSubnetCIDR
	checkFullDefaultVPC : checkFullDefaultVPC
	getSubnetForDefaultVPC : getSubnetForDefaultVPC
	getAZSubnetForDefaultVPC : getAZSubnetForDefaultVPC