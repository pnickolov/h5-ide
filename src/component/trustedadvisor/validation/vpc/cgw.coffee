define [ 'constant', 'jquery', 'MC','i18n!nls/lang.js', 'customergateway_service' , '../result_vo' ], ( constant, $, MC, lang, cgwService ) ->

	isCGWHaveIPConflict = (callback) ->

		# get current stack all cgw
		stackCGWIP = stackCGWName = null
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway
				stackCGWIP = compObj.resource.IpAddress
				stackCGWName = compObj.name
			null

		# if have cgw in stack
		if stackCGWIP and stackCGWName

			currentRegion = MC.canvas_data.region
			cgwService.DescribeCustomerGateways {sender: this},
				$.cookie( 'usercode' ),
				$.cookie( 'session_id' ),
				currentRegion,  [], null, (result) ->

					resultRrror = false
					conflictInfoAry = []

					if !result.is_error
						# get current aws all cgw
						cgwObjAry = result.resolved_data
						_.each cgwObjAry, (cgwObj) ->
							cgwId = cgwObj.customerGatewayId
							cgwIP = cgwObj.ipAddress
							if stackCGWIP isnt cgwIP
								conflictInfo = sprintf lang.ide.TA_MSG_ERROR_CGW_IP_CONFLICT, stackCGWName, stackCGWIP, cgwId, cgwIP
								conflictInfoAry.push(conflictInfo)
							null
					else
						resultRrror = true

					console.log(conflictInfoAry)
					if callback
						callback(resultRrror, conflictInfoAry)

					null

			# immediately return
			tipInfo = sprintf lang.ide.TA_MSG_ERROR_CGW_CHECKING_IP_CONFLICT
			return {
				level: constant.TA.ERROR,
				info: tipInfo
			}

		else
			return null

	isCGWHaveIPConflict : isCGWHaveIPConflict
