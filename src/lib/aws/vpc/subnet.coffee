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

		if ipCidr1BinStr.slice(0, minIpCidrSuffix) is ipCidr2BinStr.slice(0, minIpCidrSuffix)
			return true
		else
			return false

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

	getVPC = (subnetUID) ->

		subnetComp = MC.canvas_data.component[subnetUID]
		vpcUID = subnetComp.resource.VpcId.slice(1).split('.')[0]
		if vpcUID
			return MC.canvas_data.component[vpcUID]
		else
			return null

	updateAllENIIPList = (subnetUID) ->

		subnetComp = MC.canvas_data.component[subnetUID]
		subnetRef = '@' + subnetComp.uid + '.resource.SubnetId'
		subnetCIDR = subnetComp.resource.CidrBlock
		currentAvailableIPAry = MC.aws.eni.getAvailableIPInCIDR subnetCIDR, []

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

	#public
	genCIDRPrefixSuffix : genCIDRPrefixSuffix
	isSubnetConflict : isSubnetConflict
	isInVPCCIDR : isInVPCCIDR
	autoAssignAllCIDR : autoAssignAllCIDR
	genCIDRDivAry : genCIDRDivAry
	getVPC : getVPC
	updateAllENIIPList : updateAllENIIPList