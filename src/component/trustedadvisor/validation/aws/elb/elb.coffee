define [ 'constant', 'MC','i18n!/nls/lang.js', 'TaHelper', 'CloudResources'], ( constant, MC, lang, Helper, CloudResources ) ->

	i18n = Helper.i18n.short()

	isHaveIGWForInternetELB = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]
		isInternetELB = (elbComp.resource.Scheme is 'internet-facing')

		# check if have IGW in VPC
		haveIGW = false
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is constant.RESTYPE.IGW
				haveIGW = true
			null

		if !(isInternetELB and !haveIGW)
			return null
		else
			elbName = elbComp.name
			tipInfo = sprintf lang.TA.ERROR_VPC_HAVE_INTERNET_ELB_AND_NO_HAVE_IGW, elbName
			# return
			level: constant.TA.ERROR
			info: tipInfo
			uid: elbUID

	isHaveInstanceAttached = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]

		# instance attached number
		attachedInstanceNum = elbComp.resource.Instances.length

		# asg attached number
		attachedASGNum = 0
		elbNameRef = MC.genResRef(elbUID, 'resource.LoadBalancerName')
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is constant.RESTYPE.ASG
				attachedELBAry = compObj.resource.LoadBalancerNames
				if elbNameRef in attachedELBAry
					attachedASGNum++
			null

		if attachedInstanceNum isnt 0 or attachedASGNum isnt 0
			return null
		else
			elbName = elbComp.name
			tipInfo = sprintf lang.TA.ERROR_ELB_NO_ATTACH_INSTANCE_OR_ASG, elbName
			# return
			level: constant.TA.WARNING
			info: tipInfo
			uid: elbUID

	isHaveSubnetAttached = (elbUID) ->

		elbComp = Design.instance().component(elbUID)
		if elbComp.connections('ElbSubnetAsso').length is 0
			return {
				level: constant.TA.ERROR
				info: sprintf(lang.TA.ERROR_ELB_NO_ATTACH_SUBNET, elbComp.get('name'))
				uid: elbUID
			}
		return null

	isAttachELBToMultiAZ = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]

		# attached AZ array
		attachedAZAry = elbComp.resource.AvailabilityZones
		if attachedAZAry.length isnt 1
			return null
		else
			elbName = elbComp.name
			tipInfo = sprintf lang.TA.WARNING_ELB_NO_ATTACH_TO_MULTI_AZ, elbName
			# return
			level: constant.TA.WARNING
			info: tipInfo
			uid: elbUID

	isRedirectPortHttpsToHttp = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]

		# check if have 443 to 443 listener
		haveListener = false
		listenerAry = elbComp.resource.ListenerDescriptions
		_.each listenerAry, (listenerItem) ->
			listenerObj = listenerItem.Listener
			elbPort = listenerObj.LoadBalancerPort
			instancePort = listenerObj.InstancePort
			if elbPort in [443, '443'] and instancePort in [443, '443']
				haveListener = true
			null

		if !haveListener
			return null
		else
			elbName = elbComp.name
			tipInfo = sprintf lang.TA.NOTICE_ELB_REDIRECT_PORT_443_TO_443, elbName
			# return
			level: constant.TA.NOTICE
			info: tipInfo
			uid: elbUID

	# isRegisteredInstanceEvenlyAcrossAZ = (elbUID) ->

	# 	elbComp = MC.canvas_data.component[elbUID]

	# 	# get attached instance array
	# 	attachedInstanceAry = elbComp.resource.Instances
	# 	attachedInstanceAry = _.map attachedInstanceAry, (instanceRef) ->
	# 		instanceUID = MC.extractID(instanceRef)
	# 		return instanceUID

	# 	# get attached asg array
	# 	attachedASGAry = []
	# 	elbNameRef = MC.genResRef(elbUID, 'resource.LoadBalancerName')
	# 	_.each MC.canvas_data.component, (compObj) ->
	# 		compType = compObj.type
	# 		if compType is constant.RESTYPE.ASG
	# 			attachedELBAry = compObj.resource.LoadBalancerNames
	# 			if elbNameRef in attachedELBAry
	# 				attachedASGAry.push()
	# 		null

	isHaveRepeatListener = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]
		listenerAry = elbComp.resource.ListenerDescriptions
		portExistMap = {}

		haveRepeat = false
		_.each listenerAry, (listenerItem) ->
			listenerObj = listenerItem.Listener
			elbPort = listenerObj.LoadBalancerPort
			if not portExistMap[elbPort]
				portExistMap[String(elbPort)] = true
			else
				haveRepeat = true
			null

		if not haveRepeat
			return null
		else
			elbName = elbComp.name
			tipInfo = sprintf lang.TA.ERROR_ELB_HAVE_REPEAT_LISTENER_ITEM, elbName
			# return
			level: constant.TA.ERROR
			info: tipInfo
			uid: elbUID

	isHaveSSLCert = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]
		listenerAry = elbComp.resource.ListenerDescriptions

		isCorrect = true
		_.each listenerAry, (listenerItem) ->
			listenerObj = listenerItem.Listener
			elbProtocol = listenerObj.Protocol
			if elbProtocol in ['HTTPS', 'SSL']
				if not listenerObj.SSLCertificateId
					isCorrect = false
			null

		if isCorrect
			return null
		else
			elbName = elbComp.name
			tipInfo = sprintf lang.TA.ERROR_ELB_HAVE_NO_SSL_CERT, elbName
			# return
			level: constant.TA.ERROR
			info: tipInfo
			uid: elbUID

	isRuleInboundToELBListener = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]

		elbName = elbComp.name

		sgCompAry = Helper.sg.get(elbComp)
		portData = Helper.sg.port(sgCompAry)

		listenerAry = elbComp.resource.ListenerDescriptions

		result = true
		resultPortAry = []

		for listenerItem in listenerAry

			listenerObj = listenerItem.Listener
			elbProtocol = listenerObj.Protocol
			elbPort = listenerObj.LoadBalancerPort
			isInRange = Helper.sg.isInRange('tcp', elbPort, portData, 'in')
			if not isInRange
				result = false
				resultPortAry.push(elbProtocol + ' <span class="validation-tag tag-port">' + elbPort + '</span>')

		if not result

			elbName = elbComp.name
			tipInfo = sprintf lang.TA.ERROR_ELB_RULE_NOT_INBOUND_TO_ELB_LISTENER, elbName, resultPortAry.join(', ')

			return {
				level: constant.TA.WARNING
				info: tipInfo
				uid: elbUID
			}

		return null

	isRuleOutboundToInstanceListener = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]

		sgCompAry = Helper.sg.get(elbComp)
		portData = Helper.sg.port(sgCompAry)

		listenerAry = elbComp.resource.ListenerDescriptions

		result = true
		resultPortAry = []

		for listenerItem in listenerAry

			listenerObj = listenerItem.Listener
			instanceProtocol = listenerObj.InstanceProtocol
			instancePort = listenerObj.InstancePort
			isInRange = Helper.sg.isInRange('tcp', instancePort, portData, 'out')
			if not isInRange
				result = false
				resultPortAry.push(instanceProtocol + ' <span class="validation-tag tag-port">' + instancePort + '</span>')

		if not result

			elbName = elbComp.name
			tipInfo = sprintf lang.TA.ERROR_ELB_RULE_NOT_OUTBOUND_TO_INSTANCE_LISTENER, elbName, resultPortAry.join(', ')

			return {
				level: constant.TA.WARNING
				info: tipInfo
				uid: elbUID
			}

		return null

	isRuleInboundInstanceForELBListener = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]
		elbName = elbComp.name
		instanceAry = elbComp.resource.Instances

		listenerAry = elbComp.resource.ListenerDescriptions

		resultAry = []

		_.each instanceAry, (instanceObj) ->

			instanceUID = MC.extractID(instanceObj.InstanceId)

			if instanceUID

				resultPortAry = []

				instanceComp = MC.canvas_data.component[instanceUID]
				if instanceComp.index isnt 0
					return

				sgCompAry = Helper.sg.get(instanceComp)
				portData = Helper.sg.port(sgCompAry)

				for listenerItem in listenerAry

					listenerObj = listenerItem.Listener
					instanceProtocol = listenerObj.InstanceProtocol
					instancePort = listenerObj.InstancePort
					isInRange = Helper.sg.isInRange('tcp', instancePort, portData, 'in')
					if not isInRange
						resultPortAry.push(instanceProtocol + ' <span class="validation-tag tag-port">' + instancePort + '</span>')

				if resultPortAry.length

					targetType = 'Instance'
					targetName = instanceComp.serverGroupName
					portInfo = resultPortAry.join(', ')
					tipInfo = sprintf lang.TA.ERROR_ELB_RULE_INSTANCE_NOT_OUTBOUND_FOR_ELB_LISTENER, targetType, targetName, portInfo, elbName

					resultAry.push({
						level: constant.TA.WARNING
						info: tipInfo
						uid: elbUID
					})

		# find all asg
		asgUIDAry = []
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.RESTYPE.ASG
				elbRefAry = compObj.resource.LoadBalancerNames
				_.each elbRefAry, (elbRef) ->
					currentELBUID = MC.extractID(elbRef)
					if elbUID is currentELBUID
						asgUIDAry.push(compObj.uid)
					null
			null

		_.each asgUIDAry, (asgUID) ->

			resultPortAry = []

			asgComp = MC.canvas_data.component[asgUID]
			lcRef = asgComp.resource.LaunchConfigurationName

			if lcRef
				lcUID = MC.extractID(lcRef)
				lcComp = MC.canvas_data.component[lcUID]
			else
				return

			sgCompAry = Helper.sg.get(lcComp)
			portData = Helper.sg.port(sgCompAry)

			for listenerItem in listenerAry

				listenerObj = listenerItem.Listener
				instanceProtocol = listenerObj.InstanceProtocol
				instancePort = listenerObj.InstancePort
				isInRange = Helper.sg.isInRange('tcp', instancePort, portData, 'in')
				if not isInRange
					resultPortAry.push(instanceProtocol + ' <span class="validation-tag tag-port">' + instancePort + '</span>')

			if resultPortAry.length

				targetType = 'Launch Configuration'
				targetName = lcComp.name
				portInfo = resultPortAry.join(', ')
				tipInfo = sprintf lang.TA.ERROR_ELB_RULE_INSTANCE_NOT_OUTBOUND_FOR_ELB_LISTENER, targetType, targetName, portInfo, elbName

				resultAry.push({
					level: constant.TA.WARNING
					info: tipInfo
					uid: elbUID
				})

		return resultAry

	isRuleInboundToELBPingPort = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]

		elbName = elbComp.name

		sgCompAry = Helper.sg.get(elbComp)
		portData = Helper.sg.port(sgCompAry)

		pingPort = null

		try

			pingPort = elbComp.resource.HealthCheck.Target
			pingPort = pingPort.split(':')[1]
			pingPort = pingPort.split('/')[0]

		catch err

			return null

		isInRange = Helper.sg.isInRange('tcp', pingPort, portData, 'in')

		if not isInRange

			elbName = elbComp.name
			tipInfo = sprintf lang.TA.WARNING_ELB_RULE_NOT_INBOUND_TO_ELB_PING_PORT, elbName, pingPort

			return {
				level: constant.TA.WARNING
				info: tipInfo
				uid: elbUID
			}

		return null

	isELBSubnetCIDREnough = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]
		elbSubnetAry = elbComp.resource.Subnets
		elbName = elbComp.name

		resultAry = []

		_.each elbSubnetAry, (subnetRef) ->

			subnetUID = MC.extractID(subnetRef)
			subnetComp = MC.canvas_data.component[subnetUID]

			if subnetComp

				subnetName = subnetComp.name
				subnetUID = subnetComp.uid
				subnetCIDR = subnetComp.resource.CidrBlock
				suffixNum = Number(subnetCIDR.split('/')[1])

				if suffixNum > 27

					tipInfo = sprintf lang.TA.ERROR_ELB_ATTACHED_SUBNET_CIDR_SUFFIX_GREATE_27, elbName, subnetName

					resultAry.push({
						level: constant.TA.ERROR
						info: tipInfo
						uid: subnetUID
					})

			null

		return resultAry

	isSSLCertExist = (callback) ->

		try
			if !callback
				callback = () ->

			elbNameUIDMap = {}

			eachListener = (iterator) ->

				_.each MC.canvas_data.component, (compObj) ->

					if compObj.type is constant.RESTYPE.ELB

						elbName = compObj.name

						elbNameUIDMap[elbName] = compObj.uid

						listenerAry = compObj.resource.ListenerDescriptions

						for listenerItem in listenerAry

							listenerObj = listenerItem.Listener
							listenerCertRef = listenerObj.SSLCertificateId

							if not listenerCertRef
								continue

							listenerCertUID = MC.extractID(listenerCertRef)
							sslCertComp = MC.canvas_data.component[listenerCertUID]

							if sslCertComp

								sslCertName = sslCertComp.name
								iterator(elbName, sslCertName)

					null

			elbNotExistCertMap = {}
			allExistCertAry = []

			validResultAry = []

			haveCert = false
			eachListener () -> haveCert = true

			# if have cert, fetch aws cert res and check if exist
			if haveCert

				sslCertCol = CloudResources Design.instance().credentialId(), constant.RESTYPE.IAM, Design.instance().region()

				sslCertCol.fetchForce().then (result) ->

					sslCertAry = sslCertCol.toJSON()
					_.each sslCertAry, (sslCertData) ->
						allExistCertAry.push sslCertData.Name

					eachListener (elbName, sslCertName) ->

						if sslCertName not in allExistCertAry
							elbNotExistCertMap[elbName] = [] if not elbNotExistCertMap[elbName]
							elbNotExistCertMap[elbName].push(sslCertName)

					_.each elbNotExistCertMap, (sslCertNameAry, elbName) ->

						uniqSSLCertNameAry = _.uniq(sslCertNameAry)
						tipInfo = sprintf lang.TA.ERROR_ELB_SSL_CERT_NOT_EXIST_FROM_AWS, elbName, uniqSSLCertNameAry.join(', ')
						validResultAry.push {
							level: constant.TA.ERROR,
							info: tipInfo,
							uid: elbNameUIDMap[elbName]
						}

					if validResultAry.length
						callback(validResultAry)
						return

					callback(null)

				, () ->

					callback(null)

			else

				callback(null)

		catch err

			callback(null)

	isInternetElbRouteOut = ( uid ) ->
		elb = Design.instance().component uid

		if elb.get('internal') then return null

		subnets = elb.connectionTargets( 'ElbSubnetAsso' )
		rtbs = _.map subnets, ( sb ) -> sb.connectionTargets('RTB_Asso')[ 0 ]

		if _.some( rtbs, ( rtb ) ->
			rtbConnTarget = rtb.connectionTargets('RTB_Route')
			igw = _.where rtbConnTarget, type: constant.RESTYPE.IGW
			igw.length > 0 )

			return null

		Helper.message.error uid, i18n.ERROR_ELB_INTERNET_SHOULD_ATTACH_TO_PUBLIC_SB, elb.get 'name'

	isNameExceedLimit = ( uid ) ->
		limit = 23
		elb = Design.instance().component uid

		if elb.get( 'appId' ) then return null

		elbName = elb.get('name')
		if elbName and elbName.length > limit
			return Helper.message.error uid, i18n.ERROR_ELB_NAME_EXCEED_LIMIT, elbName, limit
		return null

	isHaveIGWForInternetELB : isHaveIGWForInternetELB
	isHaveInstanceAttached : isHaveInstanceAttached
	isAttachELBToMultiAZ : isAttachELBToMultiAZ
	isRedirectPortHttpsToHttp : isRedirectPortHttpsToHttp
	isHaveRepeatListener : isHaveRepeatListener
	isHaveSSLCert : isHaveSSLCert
	isRuleInboundToELBListener : isRuleInboundToELBListener
	isRuleOutboundToInstanceListener : isRuleOutboundToInstanceListener
	isRuleInboundInstanceForELBListener : isRuleInboundInstanceForELBListener
	isRuleInboundToELBPingPort : isRuleInboundToELBPingPort
	isELBSubnetCIDREnough : isELBSubnetCIDREnough
	isSSLCertExist : isSSLCertExist
	isInternetElbRouteOut : isInternetElbRouteOut
	isNameExceedLimit : isNameExceedLimit
	isHaveSubnetAttached : isHaveSubnetAttached
