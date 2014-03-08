define [ 'constant', 'MC','i18n!nls/lang.js'], ( constant, MC, lang ) ->

	isHaveIGWForInternetELB = (elbUID) ->

		# check platform
		if !(MC.canvas_data.platform in
			[MC.canvas.PLATFORM_TYPE.CUSTOM_VPC, MC.canvas.PLATFORM_TYPE.EC2_VPC])
				return null

		elbComp = MC.canvas_data.component[elbUID]
		isInternetELB = (elbComp.resource.Scheme is 'internet-facing')

		# check if have IGW in VPC
		haveIGW = false
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway
				haveIGW = true
			null

		if !(isInternetELB and !haveIGW)
			return null
		else
			elbName = elbComp.name
			tipInfo = sprintf lang.ide.TA_MSG_ERROR_VPC_HAVE_INTERNET_ELB_AND_NO_HAVE_IGW, elbName
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
		elbNameRef = MC.aws.aws.genResRef(elbUID, 'resource.LoadBalancerName')
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
				attachedELBAry = compObj.resource.LoadBalancerNames
				if elbNameRef in attachedELBAry
					attachedASGNum++
			null

		if attachedInstanceNum isnt 0 or attachedASGNum isnt 0
			return null
		else
			elbName = elbComp.name
			tipInfo = sprintf lang.ide.TA_MSG_ERROR_ELB_NO_ATTACH_INSTANCE_OR_ASG, elbName
			# return
			level: constant.TA.ERROR
			info: tipInfo
			uid: elbUID

	isAttachELBToMultiAZ = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]

		# attached AZ array
		attachedAZAry = elbComp.resource.AvailabilityZones
		if attachedAZAry.length isnt 1
			return null
		else
			elbName = elbComp.name
			tipInfo = sprintf lang.ide.TA_MSG_WARNING_ELB_NO_ATTACH_TO_MULTI_AZ, elbName
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
			tipInfo = sprintf lang.ide.TA_MSG_NOTICE_ELB_REDIRECT_PORT_443_TO_443, elbName
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
	# 	elbNameRef = MC.aws.aws.genResRef(elbUID, 'resource.LoadBalancerName')
	# 	_.each MC.canvas_data.component, (compObj) ->
	# 		compType = compObj.type
	# 		if compType is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
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
			tipInfo = sprintf lang.ide.TA_MSG_ERROR_ELB_HAVE_REPEAT_LISTENER_ITEM, elbName
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
			tipInfo = sprintf lang.ide.TA_MSG_ERROR_ELB_HAVE_NO_SSL_CERT, elbName
			# return
			level: constant.TA.ERROR
			info: tipInfo
			uid: elbUID

	isHaveIGWForInternetELB : isHaveIGWForInternetELB
	isHaveInstanceAttached : isHaveInstanceAttached
	isAttachELBToMultiAZ : isAttachELBToMultiAZ
	isRedirectPortHttpsToHttp : isRedirectPortHttpsToHttp
	isHaveRepeatListener : isHaveRepeatListener
	isHaveSSLCert : isHaveSSLCert