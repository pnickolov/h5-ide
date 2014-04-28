define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang ) ->

	isVPCAbleConnectToOutside = () ->

		if (MC.canvas_data.platform in
			[MC.canvas.PLATFORM_TYPE.EC2_CLASSIC])
				return null

		# check if have vpn and eip
		isHaveVPN = false
		isHaveEIP = false
		isHavePubIP = false

		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is constant.RESTYPE.VPN
				isHaveVPN = true
			if compType is constant.RESTYPE.EIP
				isHaveEIP = true
			if compType is constant.RESTYPE.ENI
				if compObj.index is 0
					if compObj.resource.AssociatePublicIpAddress
						isHavePubIP = true
			if compType is constant.RESTYPE.LC
				if compObj.resource.AssociatePublicIpAddress
					isHavePubIP = true
			null

		if isHaveVPN or isHaveEIP or isHavePubIP
			return null

		tipInfo = sprintf lang.ide.TA_MSG_WARNING_NOT_VPC_CAN_CONNECT_OUTSIDE

		# return
		level: constant.TA.WARNING
		info: tipInfo


	isVPCAbleConnectToOutside : isVPCAbleConnectToOutside
