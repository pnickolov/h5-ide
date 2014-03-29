define [ 'MC', 'constant', 'i18n!nls/lang.js' ], ( MC, constant, lang ) ->

	_addZeroToLeftStr = (str, n) ->
		count = n - str.length + 1
		strAry = _.map [1...count], () ->
			return '0'
		str = strAry.join('') + str

	_addZeroToRightStr = (str, n) ->
		count = n - str.length + 1
		strAry = _.map [1...count], () ->
			return '0'
		str =  str + strAry.join('')

	_getCidrBinStr = (ipCidr) ->

		cutAry = ipCidr.split('/')
		ipAddr = cutAry[0]
		suffix = Number cutAry[1]
		prefix = 32 - suffix

		ipAddrAry = ipAddr.split '.'
		ipAddrBinAry = _.map ipAddrAry, (value) ->
			return _addZeroToLeftStr(parseInt(value).toString(2), 8)

		return ipAddrBinAry.join('')

	#private
	genCIDRPrefixSuffix = (subnetCIDR) ->

		cutAry = subnetCIDR.split('/')
		ipAddr = cutAry[0]
		suffix = Number(cutAry[1])

		ipAddrAry = ipAddr.split('.')

		resultPrefix = ''
		resultSuffix = ''

		if suffix > 23
			resultPrefix = ipAddrAry[0] + '.' + ipAddrAry[1] + '.' + ipAddrAry[2] + '.'
			resultSuffix = 'x'
		else
			resultPrefix = ipAddrAry[0] + '.' + ipAddrAry[1] + '.'
			resultSuffix = 'x.x'

		return [resultPrefix, resultSuffix]

	genCIDRDivAry = (vpcCIDR, subnetCIDR) ->

		vpcSuffix = Number(vpcCIDR.split('/')[1])

		subnetIPAry = subnetCIDR.split('/')
		subnetSuffix = Number(subnetIPAry[1])

		subnetAddrAry = subnetIPAry[0].split('.')

		resultPrefix = ''
		resultSuffix = ''

		if vpcSuffix > 23
			resultPrefix = subnetAddrAry[0] + '.' + subnetAddrAry[1] + '.' + subnetAddrAry[2] + '.'
			resultSuffix = subnetAddrAry[3] + '/' + subnetSuffix
		else
			resultPrefix = subnetAddrAry[0] + '.' + subnetAddrAry[1] + '.'
			resultSuffix = subnetAddrAry[2] + '.' + subnetAddrAry[3] + '/' + subnetSuffix

		return [resultPrefix, resultSuffix]

	isSubnetConflict = (ipCidr1, ipCidr2) ->

		ipCidr1BinStr = _getCidrBinStr(ipCidr1)
		ipCidr2BinStr = _getCidrBinStr(ipCidr2)

		ipCidr1Suffix = Number(ipCidr1.split('/')[1])
		ipCidr2Suffix = Number(ipCidr2.split('/')[1])

		if ipCidr1Suffix is 0 and (ipCidr1Suffix is ipCidr2Suffix)
			return true

		minIpCidrSuffix = ipCidr1Suffix
		if ipCidr1Suffix > ipCidr2Suffix
			minIpCidrSuffix = ipCidr2Suffix

		if ipCidr1BinStr.slice(0, minIpCidrSuffix) is ipCidr2BinStr.slice(0, minIpCidrSuffix) and minIpCidrSuffix isnt 0
			return true
		else
			return false

	isSubnetConflictInVPC = (subnetUID, originSubnetCIDR) ->

		subnetCIDR = ''
		if originSubnetCIDR
			subnetCIDR = originSubnetCIDR
		else
			subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

		vpcComp = MC.aws.subnet.getVPC(subnetUID)
		vpcUID = vpcComp.uid
		isHaveConflict = false
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is 'AWS.VPC.Subnet'
				subnetVPCUID = MC.extractID(compObj.resource.VpcId)
				currentSubnetUID = compObj.uid
				currentSubnetCIDR = compObj.resource.CidrBlock
				if subnetVPCUID is vpcUID and subnetUID isnt currentSubnetUID
					if isSubnetConflict(subnetCIDR, currentSubnetCIDR)
						isHaveConflict = true
						return false
			null
		return isHaveConflict

	isInVPCCIDR = (vpcCIDR, subnetCIDR) ->

		if MC.aws.subnet.isSubnetConflict(vpcCIDR, subnetCIDR)

			vpcCIDRSuffix = Number(vpcCIDR.split('/')[1])
			subnetCIDRSuffix = Number(subnetCIDR.split('/')[1])

			if subnetCIDRSuffix < vpcCIDRSuffix
				return false
			else
				return true

		else
			return false

	autoAssignAllCIDR = (vpcCIDR, subnetCount) ->

		needBinNum = Math.ceil((Math.log(subnetCount))/(Math.log(2)))

		vpcIPSuffix = Number(vpcCIDR.split('/')[1])
		vpcIPBinStr = _getCidrBinStr(vpcCIDR)
		vpcIPBinLeftStr = vpcIPBinStr.slice(0, vpcIPSuffix)

		newSubnetSuffix = vpcIPSuffix + needBinNum

		newSubnetAry = []

		_.each [0...subnetCount], (i) ->

			binSeq = _addZeroToLeftStr(i.toString(2), needBinNum)
			newSubnetBinStr = _addZeroToRightStr(vpcIPBinLeftStr + binSeq, 32)

			newIPAry = _.map [0, 8, 16, 24], (value) ->
				return (parseInt newSubnetBinStr.slice(value, value + 8), 2)
			newIPStr = newIPAry.join('.')
			newSubnetStr = newIPStr + '/' + newSubnetSuffix

			newSubnetAry.push(newSubnetStr)

			null

		return newSubnetAry

	autoAssignSimpleCIDR = (newVPCCIDR, oldSubnetAry, oldVPCCIDR) ->

		newSubnetAry = []

		vpcCIDRAry = newVPCCIDR.split('/')
		vpcCIDRIPStr = vpcCIDRAry[0]
		vpcCIDRSuffix = Number(vpcCIDRAry[1])
		vpcIPAry = vpcCIDRIPStr.split('.')

		oldVPCCIDRSuffix = Number(oldVPCCIDR.split('/')[1])

		if vpcCIDRSuffix is 16 or (vpcCIDRSuffix is 24 and oldVPCCIDRSuffix is vpcCIDRSuffix)
			vpcIP1 = vpcIPAry[0]
			vpcIP2 = vpcIPAry[1]
			vpcIP3 = vpcIPAry[2]
			_.each oldSubnetAry, (subnetCIDR) ->
				subnetCIDRAry = subnetCIDR.split('/')
				subnetCIDRIPStr = subnetCIDRAry[0]
				subnetCIDRSuffix = Number(subnetCIDRAry[1])
				subnetIPAry = subnetCIDRIPStr.split('.')

				subnetIPAry[0] = vpcIP1
				subnetIPAry[1] = vpcIP2
				if vpcCIDRSuffix is 24
					subnetIPAry[2] = vpcIP3

				newSubnetCIDR = subnetIPAry.join('.') + '/' + subnetCIDRSuffix
				newSubnetAry.push(newSubnetCIDR)
				# if !MC.aws.subnet.isInVPCCIDR(newVPCCIDR, subnetCIDR)
				# 	newSubnetAry = null
				# 	return false

				null

		return newSubnetAry

	getVPC = (subnetUID) ->

		subnetComp = MC.canvas_data.component[subnetUID]
		vpcUID = MC.extractID(subnetComp.resource.VpcId)
		if vpcUID
			return MC.canvas_data.component[vpcUID]
		else
			return null

	#for default vpc, subnetuid is az name
	updateAllENIIPList = (subnetUidOrAZ, notForce, outFilterAry) ->

		defaultVPC = false
		if MC.aws.aws.checkDefaultVPC()
			defaultVPC = true

		needIPCount = 0
		subnetCIDR = ''
		azName = ''
		subnetRef = ''

		filterAry = []

		if defaultVPC
			azName = subnetUidOrAZ
			subnetObj = Design.modelClassForType(constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone).getSubnetOfDefaultVPC(azName)
			if notForce
				filterAry = MC.aws.eni.getAllNoAutoAssignIPInCIDR(azName)
			subnetCIDR = subnetObj.cidrBlock
			needIPCount = MC.aws.eni.getSubnetNeedIPCount(azName)
		else
			subnetComp = MC.canvas_data.component[subnetUidOrAZ]
			if !subnetComp then return
			subnetRef = MC.aws.aws.genResRef(subnetComp.uid, 'resource.SubnetId')
			if notForce
				filterAry = MC.aws.eni.getAllNoAutoAssignIPInCIDR(subnetRef)
			subnetCIDR = subnetComp.resource.CidrBlock
			needIPCount = MC.aws.eni.getSubnetNeedIPCount(subnetComp.uid)

		if outFilterAry and _.isArray(outFilterAry)
			filterAry = _.union(filterAry, outFilterAry)

		currentAvailableIPAry = MC.aws.eni.getAvailableIPInCIDR(subnetCIDR, filterAry, needIPCount)

		# needIPCount = 0
		# _.each MC.canvas_data.component, (compObj) ->
		# 	if compObj.type is 'AWS.VPC.NetworkInterface'
		# 		if (!defaultVPC and compObj.resource.SubnetId is subnetRef) or (defaultVPC and compObj.resource.AvailabilityZone is azName)
		# 		needIPCount += compObj.resource.PrivateIpAddressSet.length

		# start auto assign ip
		assignedIPAry = []
		_.each currentAvailableIPAry, (newIPObj) ->
			if needIPCount is 0
				return false
			if newIPObj.available
				needIPCount--
				assignedIPAry.push newIPObj.ip

		i = 0
		_.each MC.canvas_data.component, (compObj) ->
			if (compObj.type isnt 'AWS.VPC.NetworkInterface')
				return
			if (!defaultVPC and compObj.resource.SubnetId is subnetRef) or (defaultVPC and compObj.resource.AvailabilityZone is azName)
				newPrivateIpAddressSet = _.map compObj.resource.PrivateIpAddressSet, (ipObj) ->
					newIpObj = $.extend true, {}, ipObj
					if !notForce or newIpObj.AutoAssign in [true, 'true']
						newIpObj.PrivateIpAddress = assignedIPAry[i++]
						newIpObj.AutoAssign = true
					return newIpObj
				MC.canvas_data.component[compObj.uid].resource.PrivateIpAddressSet = newPrivateIpAddressSet
			null

		null

	canDeleteSubnetToELBConnection = (elbUID, subnetUID) ->

		elbComp = MC.canvas_data.component[elbUID]

		todeleteAZ = MC.canvas_data.component[subnetUID].resource.AvailabilityZone

		# Comment by song, valid in TA

		# Keep connection to one subnet at least
		# if elbComp.resource.Subnets.length <= 1
		# 	return lang.ide.CVS_MSG_ERR_DEL_ELB_LINE_1

		# If we have resources connected to the elb, connection to the resources' subnet is
		# not deletable
		# Currently is Instance and ASG

		for instance in elbComp.resource.Instances
			if MC.canvas_data.component[MC.extractID(instance.InstanceId)].resource.Placement.AvailabilityZone is todeleteAZ
				return lang.ide.CVS_MSG_ERR_DEL_ELB_LINE_2

		for comp_uid, comp of MC.canvas_data.component
			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
				if comp.resource.LoadBalancerNames.join(" ").indexOf( elbUID ) != -1
					if comp.resource.AvailabilityZones.join(" ").indexOf( todeleteAZ ) != -1
						return lang.ide.CVS_MSG_ERR_DEL_ELB_LINE_2

		return true

	isConnectToELB = (subnetUID) ->
		subnetInELB =  MC.aws.aws.genResRef(subnetUID, 'resource.SubnetId')
		_.some MC.canvas_data.component, ( component, id ) ->
			component.type is 'AWS.ELB' and _.contains component.resource.Subnets, subnetInELB



	generateCIDRPossibile = () ->

		currentVPCUID = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).theVPC().id
		currentVPCCIDR = MC.canvas_data.component[currentVPCUID].resource.CidrBlock

		vpcCIDRAry = currentVPCCIDR.split('/')
		vpcCIDRIPStr = vpcCIDRAry[0]
		vpcCIDRIPStrAry = vpcCIDRIPStr.split('.')
		vpcCIDRSuffix = Number(vpcCIDRAry[1])

		if vpcCIDRSuffix isnt 16
			return null

		# get max subnet number
		maxSubnetNum = -1
		_.each MC.canvas_data.component, (comp) ->
			if comp.type is 'AWS.VPC.Subnet'
				subnetCIDR = comp.resource.CidrBlock
				subnetCIDRAry = subnetCIDR.split('/')
				subnetCIDRIPStr = subnetCIDRAry[0]
				subnetCIDRSuffix = Number(subnetCIDRAry[1])

				subnetCIDRIPAry = subnetCIDRIPStr.split('.')

				if vpcCIDRSuffix is 16
					currentSubnetNum = Number(subnetCIDRIPAry[2])
				if vpcCIDRSuffix is 24
					currentSubnetNum = Number(subnetCIDRIPAry[3])

				if maxSubnetNum < currentSubnetNum
					maxSubnetNum = currentSubnetNum

		resultSubnetNum = maxSubnetNum + 1
		if resultSubnetNum > 255
			return null

		generateSubnetAry = vpcCIDRIPStrAry
		newSubnetCIDRSuffix = ''
		if vpcCIDRSuffix is 16
			generateSubnetAry[2] = String(resultSubnetNum)
			newSubnetCIDRSuffix = '24'

		result = generateSubnetAry.join('.') + '/' + newSubnetCIDRSuffix

		return result

	isAbleConnectToELB = ( subnetUid ) ->

		subnet = MC.canvas_data.component[ subnetUid ]
		cidr = + subnet.resource.CidrBlock.split('/')[1]
		console.log subnet.resource.CidrBlock
		console.log cidr
		if cidr <= 27
			return true
		false

	isIPInSubnet = (ipAddr, subnetCIDR) ->

		subnetIPAry = subnetCIDR.split('/')
		subnetSuffix = Number(subnetIPAry[1])
		subnetAddrAry = subnetIPAry[0].split('.')
		subnetIPBinStr = _getCidrBinStr subnetIPAry[0]

		subnetIPBinStrDiv = subnetIPBinStr.slice(0, subnetSuffix)

		ipAddrBinStr = _getCidrBinStr ipAddr

		ipAddrBinStrDiv = ipAddrBinStr.slice(0, subnetSuffix)
		ipAddrBinStrDivAnti = ipAddrBinStr.slice(subnetSuffix)

		suffixLength = 32 - subnetSuffix
		suffixZeroAry = _.map [1...suffixLength + 1], () ->
			return '0'
		suffixZeroStr = suffixZeroAry.join('')
		suffixOneStr = suffixZeroStr.replace(/0/g, '1')

		suffixZeroStrNum = parseInt suffixZeroStr, 2
		suffixOneStrNum = parseInt suffixOneStr, 2

		readyAssignAry = [suffixZeroStrNum...suffixOneStrNum + 1]
		readyAssignAryLength = readyAssignAry.length

		result = false
		filterAry = []
		_.each readyAssignAry, (value, idx) ->
			newIPBinStr = _addZeroToLeftStr(value.toString(2), suffixLength)
			if idx in [0, 1, 2, 3, readyAssignAryLength - 1]
				filterAry.push(newIPBinStr)
			null

		if ipAddrBinStrDivAnti in filterAry
			return false

		if subnetIPBinStrDiv is ipAddrBinStrDiv
			return true
		else
			return false

	#public
	genCIDRPrefixSuffix            : genCIDRPrefixSuffix
	isSubnetConflict               : isSubnetConflict
	isInVPCCIDR                    : isInVPCCIDR
	autoAssignAllCIDR              : autoAssignAllCIDR
	genCIDRDivAry                  : genCIDRDivAry
	getVPC                         : getVPC
	updateAllENIIPList             : updateAllENIIPList
	isSubnetConflictInVPC          : isSubnetConflictInVPC
	autoAssignSimpleCIDR           : autoAssignSimpleCIDR
	canDeleteSubnetToELBConnection : canDeleteSubnetToELBConnection
	generateCIDRPossibile          : generateCIDRPossibile
	isConnectToELB		       : isConnectToELB
	isAbleConnectToELB	       : isAbleConnectToELB
	isIPInSubnet                   : isIPInSubnet




