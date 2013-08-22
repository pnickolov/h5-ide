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
					return
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

	#public
	getVPCUID : getVPCUID
	updateAllSubnetCIDR : updateAllSubnetCIDR