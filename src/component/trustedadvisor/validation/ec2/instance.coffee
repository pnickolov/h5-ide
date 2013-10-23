define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang, resultVO ) ->

	isVPCCanConnectOutside = () ->

		# check if have vpn and eip
		isHaveVPN = false
		isHaveEIP = false
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection
				isHaveVPN = true
			if compType is constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
				isHaveEIP = true
			null

		if isHaveVPN or isHaveEIP
			return null

		tipInfo = sprintf lang.ide.TA_WARNING_NOT_VPC_CAN_CONNECT_OUTSIDE
		resultVO.set resultVO.WARNING, tipInfo

	isVPCCanConnectOutside : isVPCCanConnectOutside