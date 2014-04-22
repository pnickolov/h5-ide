define [ 'constant', 'MC','i18n!nls/lang.js' , '../result_vo' ], ( constant, MC, lang ) ->

	isVPCAbleConnectToOutside = () ->

		# check if have vpn and eip
		isHaveVPN = false
		isHaveEIP = false
		isHavePubIP = false

		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection
				isHaveVPN = true
			if compType is constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
				isHaveEIP = true
			if compType is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
				if compObj.index is 0
					if compObj.resource.AssociatePublicIpAddress
						isHavePubIP = true
			if compType is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
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
