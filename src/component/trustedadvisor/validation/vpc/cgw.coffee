define [ 'constant', 'jquery', 'MC','i18n!/nls/lang.js', 'customergateway_service', 'TaHelper' ], ( constant, $, MC, lang, cgwService, Helper ) ->

	i18n = Helper.i18n.short()

	isCGWHaveIPConflict = (callback) ->

		try
			if !callback
				callback = () ->

			# get current stack all cgw
			stackCGWIP = stackCGWName = stackCGWUID = stackCGWId = null
			_.each MC.canvas_data.component, (compObj) ->
				if compObj.type is constant.RESTYPE.CGW
					stackCGWId = compObj.resource.CustomerGatewayId
					stackCGWIP = compObj.resource.IpAddress
					stackCGWName = compObj.name
					stackCGWUID = compObj.uid
				null

			# if have cgw in stack
			if stackCGWIP and stackCGWName and stackCGWUID and not stackCGWId

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
									conflictInfo = sprintf lang.TA.ERROR_CGW_IP_CONFLICT, stackCGWName, stackCGWIP, cgwId, cgwIP
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
				tipInfo = sprintf lang.TA.ERROR_CGW_CHECKING_IP_CONFLICT
				return {
					level: constant.TA.ERROR,
					info: tipInfo
				}

			else
				callback(null)
		catch err
			callback(null)

	isValidCGWIP = (uid) ->

		cgwComp = MC.canvas_data.component[uid]
		cgwName = cgwComp.name
		cgwIP = cgwComp.resource.IpAddress

		# isInAnyPubIPRange = MC.aws.aws.isValidInIPRange(cgwIP, 'public')
		isInAnyPriIPRange = MC.aws.aws.isValidInIPRange(cgwIP, 'private')

		if isInAnyPriIPRange

			tipInfo = sprintf lang.TA.WARNING_CGW_IP_RANGE_ERROR, cgwName, cgwIP

			return {
				level: constant.TA.WARNING
				info: tipInfo
				uid: uid
			}

		return null

	isAttachVGW = ( uid ) ->
		cgw = Design.instance().component uid
		hasAttachVgw = cgw.connections(constant.RESTYPE.VPN).length

		if hasAttachVgw then return null

		Helper.message.error uid, i18n.ERROR_CGW_MUST_ATTACH_VPN, cgw.get 'name'



	isCGWHaveIPConflict : isCGWHaveIPConflict
	isValidCGWIP 		: isValidCGWIP
	isAttachVGW 		: isAttachVGW


