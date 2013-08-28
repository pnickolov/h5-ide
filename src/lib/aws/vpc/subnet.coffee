define [ 'MC' ], ( MC ) ->

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
				subnetVPCUID = compObj.resource.VpcId.split('.')[0].slice(1)
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
		vpcUID = subnetComp.resource.VpcId.slice(1).split('.')[0]
		if vpcUID
			return MC.canvas_data.component[vpcUID]
		else
			return null

	updateAllENIIPList = (subnetUID) ->

		subnetComp = MC.canvas_data.component[subnetUID]
		if !subnetComp then return
		subnetRef = '@' + subnetComp.uid + '.resource.SubnetId'
		subnetCIDR = subnetComp.resource.CidrBlock

		needIPCount = MC.aws.eni.getSubnetNeedIPCount(subnetComp.uid)
		currentAvailableIPAry = MC.aws.eni.getAvailableIPInCIDR(subnetCIDR, [], needIPCount)

		needIPCount = 0

		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is 'AWS.VPC.NetworkInterface' and compObj.resource.SubnetId is subnetRef
				needIPCount += compObj.resource.PrivateIpAddressSet.length

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
			if compObj.type is 'AWS.VPC.NetworkInterface' and compObj.resource.SubnetId is subnetRef
				newPrivateIpAddressSet = _.map compObj.resource.PrivateIpAddressSet, (ipObj) ->
					ipObj.PrivateIpAddress = assignedIPAry[i++]
					ipObj.AutoAssign = true
					return ipObj
				MC.canvas_data.component[compObj.uid].resource.PrivateIpAddressSet = newPrivateIpAddressSet
			null

		null

	canDeleteSubnetToELBConnection = (elbUID, subnetUID) ->

		elbComp = MC.canvas_data.component[elbUID]
		instanceRefAry = elbComp.resource.Instances
		subnetRefAry = elbComp.resource.Subnets

		isCanDelete = true

		subnetAry = []
		_.each MC.canvas_data.component, (comp) ->
			if comp.type is 'AWS.VPC.Subnet'
				subnetAry.push(comp)

		azAry = []
		_.each subnetRefAry, (subnetRef) ->
			subnetUID = subnetRef.split('.')[0].slice(1)
			subnetComp = MC.canvas_data.component[subnetUID]
			subnetAZ = subnetComp.resource.AvailabilityZone
			azAry.push(subnetAZ)
			null

		azSubnetNumMap = {}
		_.each azAry, (azName) ->
			azSubnetNumMap[azName] = 0
			_.each subnetAry, (subnetComp) ->
				subnetAZ = subnetComp.resource.AvailabilityZone
				if subnetAZ is azName
					azSubnetNumMap[azName]++
				null
			null

		currentAZ = MC.canvas_data.component[subnetUID].resource.AvailabilityZone
		_.each azSubnetNumMap, (subnetNum, azName) ->
			if subnetNum is 1 and azName is currentAZ
				isCanDelete = false
			null

		return isCanDelete

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
