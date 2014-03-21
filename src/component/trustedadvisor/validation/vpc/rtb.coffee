define [ 'constant', 'MC', 'validation_helper', 'Design' ], ( CONST, MC, Helper, Design ) ->

	i18n = Helper.i18n.short()

	isRtbConnectedNatAndItConnectedSubnet = ( uid ) ->
		rtb = Design.instance().component uid
		rtbName = rtb.get 'name'
		suspectInstances = rtb.connectionTargets 'RTB_Route'
		subnets = rtb.connectionTargets 'RTB_Asso'
		instanceNameStr = ''
		connectedInstances = _.filter suspectInstances, ( comp ) ->
			comp.type is CONST.RESTYPE.INSTANCE

		notices = []

		if subnets.length
			for instance in connectedInstances
				instanceName = instance.get 'name'
				notices.push Helper.message.notice uid + instance.id, i18n.TA_MSG_NOTICE_RT_ROUTE_NAT, instanceName, rtbName, instanceName, rtbName

			return notices

		null




	isRtbConnectedNatAndItConnectedSubnet : isRtbConnectedNatAndItConnectedSubnet