define [ 'constant', 'jquery', 'MC','i18n!nls/lang.js', 'customergateway_service' , '../result_vo' ], ( constant, $, MC, lang, cgwService ) ->

	isCGWHaveIPConflict = (callback) ->

		try
			if !callback
				callback = () ->

			currentState = MC.canvas.getState()
			if currentState is 'appedit'
				callback(null)
				return null

			# get current stack all cgw
			stackCGWIP = stackCGWName = stackCGWUID = null
			_.each MC.canvas_data.component, (compObj) ->
				if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway
					stackCGWIP = compObj.resource.IpAddress
					stackCGWName = compObj.name
					stackCGWUID = compObj.uid
				null

			# if have cgw in stack
			if stackCGWIP and stackCGWName and stackCGWUID

				currentRegion = MC.canvas_data.region
				cgwService.DescribeCustomerGateways {sender: this},
					$.cookie( 'usercode' ),
					$.cookie( 'session_id' ),
					currentRegion,  [], null, (result) ->

						checkResult = true
						conflictInfo = null

						if !result.is_error
							# get current aws all cgw
							cgwObjAry = result.resolved_data
							_.each cgwObjAry, (cgwObj) ->
								cgwId = cgwObj.customerGatewayId
								cgwIP = cgwObj.ipAddress
								cgwState = cgwObj.state
								if stackCGWIP is cgwIP and cgwState is 'available'
									conflictInfo = sprintf lang.ide.TA_MSG_ERROR_CGW_IP_CONFLICT, stackCGWName, stackCGWIP, cgwId, cgwIP
									checkResult = false
								null
						else
							callback(null)

						if checkResult
							callback(null)
						else
							validResultObj =
								level: constant.TA.ERROR
								info: conflictInfo

							callback(validResultObj)
							console.log(validResultObj)

						null

				# immediately return
				tipInfo = sprintf lang.ide.TA_MSG_ERROR_CGW_CHECKING_IP_CONFLICT
				return {
					level: constant.TA.ERROR,
					info: tipInfo
				}

			else
				callback(null)
		catch err
			callback(null)

	isValidCGWIP = (uid) ->

		pubIPAry = [
			{
				low: '1.0.0.1',
				high: '126.255.255.254'
			},
			{
				low: '128.1.0.1',
				high: '191.254.255.254'
			},
			{
				low: '192.0.1.1',
				high: '223.255.254.254'
			}
		]

		ipRangeValid = (ipAryStr1, ipAryStr2, ipStr) ->

			ipAry1 = ipAryStr1.split('.')
			ipAry2 = ipAryStr2.split('.')
			curIPAry = ipStr.split('.')

			isInIPRange = true
			_.each curIPAry, (ipNum, idx) ->
				if not (Number(curIPAry[idx]) >= Number(ipAry1[idx]) and
				Number(curIPAry[idx]) <= Number(ipAry2[idx]))
					isInIPRange = false
				null

			return isInIPRange

		cgwComp = MC.canvas_data.component[uid]
		cgwName = cgwComp.name
		cgwIP = cgwComp.resource.IpAddress

		isInAnyRange = false
		_.each pubIPAry, (ipRangeObj) ->
			lowRange = ipRangeObj.low
			highRange = ipRangeObj.high
			isInRange = ipRangeValid(lowRange, highRange, cgwIP)
			if isInRange
				isInAnyRange = true
			null

		if not isInAnyRange

			tipInfo = sprintf lang.ide.TA_MSG_ERROR_CGW_IP_RANGE_ERROR, cgwName, cgwIP

			return {
				level: constant.TA.ERROR
				info: tipInfo
				uid: uid
			}

		return null

	isCGWHaveIPConflict : isCGWHaveIPConflict
	isValidCGWIP : isValidCGWIP