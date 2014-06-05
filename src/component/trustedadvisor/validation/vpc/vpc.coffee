define [ 'constant', 'MC', 'i18n!nls/lang.js' , 'Design', 'CloudResources', '../../helper', '../result_vo' ], ( constant, MC, lang, Design, CloudResources, Helper ) ->

	i18n = Helper.i18n.short()

	__hasState = ( uid ) ->
		if Design.instance().get('agent').enabled is false
			return false
		if uid
			component = Design.instance().component uid
			if component
				state = component.get 'state'
				state and state.length
			else
				false
		else
			had = false
			Design.instance().eachComponent ( component ) ->
				if __hasState component.id
					had = true
					false
			had

	isVPCAbleConnectToOutside = () ->

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

	isVPCUsingNoneDHCPAndVisualops = ( uid ) ->
		if not __hasState()
			return null

		vpc = Design.modelClassForType(constant.RESTYPE.VPC).theVPC()
		dhcpId = vpc.get( 'dhcp' ).get( 'appId' )
		if dhcpId isnt 'default'
			return null

		Helper.message.warning vpc.id, i18n.TA_MSG_WARNING_VPC_CANNOT_USE_DEFAULT_DHCP_WHEN_USE_VISUALOPS




	isVPCUsingNonexistentDhcp = ( callback ) ->
		vpc = Design.modelClassForType(constant.RESTYPE.VPC).theVPC()
		dhcpId = vpc.get( 'dhcp' ).get 'appId'
		if not dhcpId or dhcpId is 'default'
			callback null
			return

		dhcpCol = CloudResources constant.RESTYPE.DHCP, Design.instance().region()

		dhcpCol.fetchForce().fin ->
			if dhcpCol.get dhcpId
				callback null
			else
				callback Helper.message.error vpc.id, i18n.TA_MSG_ERROR_VPC_DHCP_NONEXISTENT

		null




	isVPCAbleConnectToOutside 		: isVPCAbleConnectToOutside
	isVPCUsingNonexistentDhcp 		: isVPCUsingNonexistentDhcp
	isVPCUsingNoneDHCPAndVisualops 	: isVPCUsingNoneDHCPAndVisualops
