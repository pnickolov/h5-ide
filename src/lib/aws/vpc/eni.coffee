define [ 'MC' ], ( MC ) ->

	#private
	getAllIPInCIDR = (ipCidr) ->

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

		ipAddrBinStrSuffixMin = ipAddrBinStr.slice(suffix).replace(/1/g,'0')
		ipAddrBinStrSuffixMax = ipAddrBinStrSuffixMin.replace(/0/g,'1')

		console.log(ipAddrBinStrSuffixMin, ipAddrBinStrSuffixMax)

		ipAddrNumSuffixMin = parseInt ipAddrBinStrSuffixMin, 2
		ipAddrNumSuffixMax = parseInt ipAddrBinStrSuffixMax, 2

		allIPBinStrAry = _.map [ipAddrNumSuffixMin...ipAddrNumSuffixMax + 1], (value) ->
			newIPBinStr = ipAddrBinPrefixStr + _addZeroToLeftStr(value.toString(2), prefix)
			newIPAry = _.map [0, 8, 16, 24], (value) ->
				return (parseInt newIPBinStr.slice(value, value + 8), 2)
			return newIPAry.join('.')

		return allIPBinStrAry

	#public
	getAllIPInCIDR : getAllIPInCIDR