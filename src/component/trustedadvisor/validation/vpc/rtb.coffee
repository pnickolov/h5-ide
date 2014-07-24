define [ 'constant', 'MC', 'TaHelper', 'Design' ], ( CONST, MC, Helper, Design ) ->

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

	isRtbHaveConflictDestination = ( uid ) ->

		rtb = MC.canvas_data.component[uid]
		routeSet = rtb.resource.RouteSet
		rtbName = rtb.name

		routeDesAry = []
		notices = []

		_.each routeSet, (route) ->

			currentRouteDes = route.DestinationCidrBlock

			_.each routeDesAry, (routeDes) ->

				SubnetModel = Design.modelClassForType( CONST.RESTYPE.SUBNET )

				if SubnetModel.isCidrConflict(currentRouteDes, routeDes)

					tipInfo = sprintf i18n.TA_MSG_ERROR_RT_HAVE_CONFLICT_DESTINATION, rtbName
					notices.push({
						level: CONST.TA.ERROR
						info: tipInfo
						uid: uid
					})

			routeDesAry.push(currentRouteDes)

		return notices if notices.length

		null

	isRtbConnectedNatAndItConnectedSubnet : isRtbConnectedNatAndItConnectedSubnet
	isRtbHaveConflictDestination : isRtbHaveConflictDestination
