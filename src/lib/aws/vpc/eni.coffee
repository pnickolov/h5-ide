define [ 'MC' ], ( MC ) ->

	#private
	getAvailableIPInCIDR = (ipCidr, filter) ->

		_addZeroToLeftStr = (str, n) ->
			count = n - str.length + 1
			strAry = _.map [1...count], () ->
				return '0'
			str = strAry.join('') + str

		cutAry = ipCidr.split('/')
		ipAddr = cutAry[0]
		suffix = Number cutAry[1]
		prefix = 32 - suffix

		ipAddrAry = ipAddr.split '.'
		ipAddrBinAry = _.map ipAddrAry, (value) ->
			return _addZeroToLeftStr(parseInt(value).toString(2), 8)

		ipAddrBinStr = ipAddrBinAry.join ''
		ipAddrBinPrefixStr = ipAddrBinStr.slice(0, suffix)

		ipAddrBinStrSuffixMin = ipAddrBinStr.slice(suffix).replace(/1/g, '0')
		ipAddrBinStrSuffixMax = ipAddrBinStrSuffixMin.replace(/0/g, '1')

		console.log(ipAddrBinStrSuffixMin, ipAddrBinStrSuffixMax)

		ipAddrNumSuffixMin = parseInt ipAddrBinStrSuffixMin, 2
		ipAddrNumSuffixMax = parseInt ipAddrBinStrSuffixMax, 2

		allIPAry = _.map [ipAddrNumSuffixMin...ipAddrNumSuffixMax + 1], (value) ->
			newIPBinStr = ipAddrBinPrefixStr + _addZeroToLeftStr(value.toString(2), prefix)

			isAvailableIP = true
			newIPAry = _.map [0, 8, 16, 24], (value) ->
				newIPNum = (parseInt newIPBinStr.slice(value, value + 8), 2)
				if value is 24 and (newIPNum in [0, 1, 2, 3, 255])
					isAvailableIP = false
				return newIPNum

			newIPStr = newIPAry.join('.')
			if newIPStr in filter
				isAvailableIP = false
			newIPObj = {
				ip: newIPStr
				available: isAvailableIP
			}

			return newIPObj

		return allIPAry

	getAllOtherIPInCIDR = (subnetUIDRef, rejectEniUID) ->

		allCompAry = MC.canvas_data.component

		allOtherIPAry = []

		_.each allCompAry, (compObj) ->
			if compObj.type is 'AWS.VPC.NetworkInterface'
				if compObj.uid is rejectEniUID
					return
				currentSubnetUIDRef = compObj.resource.SubnetId
				if currentSubnetUIDRef is subnetUIDRef
					privateIpAddressSet = compObj.resource.PrivateIpAddressSet
					_.each privateIpAddressSet, (value) ->
						allOtherIPAry.push value.PrivateIpAddress
						null
			null

		return allOtherIPAry

	saveIPList = (eniUID, ipList) ->

		eniComp = MC.canvas_data.component[eniUID]

		instanceUIDRef = eniComp.resource.Attachment.InstanceId

		privateIpAddressSet = []

		primary = true

		_.each ipList, (ipObj) ->
			ip = ipObj.ip
			eip = ipObj.eip
			auto = ipObj.auto

			instanceId = ''
			if eip then instanceId = instanceUIDRef

			privateIpAddressObj = {
				Association: {
					IpOwnerId: ''
					AssociationID: ''
					InstanceId: instanceId
					PublicDnsName: ''
					AllocationID: ''
					PublicIp: ''
				},
				PrivateIpAddress: ip
				AutoAssign: auto
				Primary: primary
			}

			primary = false

			privateIpAddressSet.push privateIpAddressObj

			null

		MC.canvas_data.component[eniUID].resource.PrivateIpAddressSet = privateIpAddressSet

	generateIPList = (eniUID, inputIPAry) ->
		
		currentEniComp = MC.canvas_data.component[eniUID]
		subnetUIDRef = currentEniComp.resource.SubnetId
		rejectEniUID = eniUID
		allOtherIPAry = MC.aws.eni.getAllOtherIPInCIDR subnetUIDRef, rejectEniUID

		# get self-set ip
		needAutoAssignIPCount = 0
		selfSetIPAry = []
		_.each inputIPAry, (ipObj) ->
			ipAddr = ipObj.ip
			if ipAddr.slice(ipAddr.length - 1) isnt 'x'
				selfSetIPAry.push ipObj.ip
			else
				needAutoAssignIPCount++

		ipFilterAry = allOtherIPAry.concat selfSetIPAry

		# get current subnet cidr
		subnetId = subnetUIDRef.slice(1).split('.')[0]
		subnetComp = MC.canvas_data.component[subnetId]
		subnetCidr = subnetComp.resource.CidrBlock

		# get current available ip
		currentAvailableIPAry = MC.aws.eni.getAvailableIPInCIDR subnetCidr, ipFilterAry

		# start auto assign ip
		assignedIPAry = []
		_.each currentAvailableIPAry, (newIPObj) ->
			if needAutoAssignIPCount is 0
				return false
			if newIPObj.available
				needAutoAssignIPCount--
				assignedIPAry.push newIPObj.ip

		# generate result ip list
		realIPAry = []
		assignNum = 0
		_.each inputIPAry, (ipObj) ->

			ipAddr = ipObj.ip
			haveEIP = ipObj.eip

			if ipAddr.slice(ipAddr.length - 1) is 'x'
				assignIP = assignedIPAry[assignNum++]
				realIPAry.push({
					ip: assignIP
					eip: haveEIP
					auto: true
				})
			else
				realIPAry.push({
					ip: ipAddr
					eip: haveEIP
					auto: false
				})

			null

		return realIPAry

	getInstanceDefaultENI = (instanceUID) ->

		eniComp = null
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is 'AWS.VPC.NetworkInterface' and
			compObj.resource.Attachment.DeviceIndex is '0' and
			compObj.resource.Attachment.InstanceId is ('@' + instanceUID + '.resource.InstanceId')
				eniComp = compObj
				return
			null

		return eniComp

	#public
	getAvailableIPInCIDR : getAvailableIPInCIDR
	getAllOtherIPInCIDR : getAllOtherIPInCIDR
	saveIPList : saveIPList
	generateIPList : generateIPList
	getInstanceDefaultENI : getInstanceDefaultENI