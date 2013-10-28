define [ 'constant', 'MC','i18n!nls/lang.js'], ( constant, MC, lang ) ->

	isHaveIGWForInternetELB = (elbUID) ->

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

	isHaveInstanceAttached = (elbUID) ->

		elbComp = MC.canvas_data.component[elbUID]

		# instance attached number
		attachedInstanceNum = elbComp.resource.Instances.length

		# asg attached number
		attachedASGNum = 0
		elbNameRef = '@' + elbUID + '.resource.LoadBalancerName'
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

	# isRegisteredInstanceEvenlyAcrossAZ = (elbUID) ->

	# 	elbComp = MC.canvas_data.component[elbUID]

	# 	# get attached instance array
	# 	attachedInstanceAry = elbComp.resource.Instances
	# 	attachedInstanceAry = _.map attachedInstanceAry, (instanceRef) ->
	# 		instanceUID = instanceRef.split('.')[0].slice(0)
	# 		return instanceUID

	# 	# get attached asg array
	# 	attachedASGAry = []
	# 	elbNameRef = '@' + elbUID + '.resource.LoadBalancerName'
	# 	_.each MC.canvas_data.component, (compObj) ->
	# 		compType = compObj.type
	# 		if compType is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
	# 			attachedELBAry = compObj.resource.LoadBalancerNames
	# 			if elbNameRef in attachedELBAry
	# 				attachedASGAry.push()
	# 		null

	isHaveIGWForInternetELB : isHaveIGWForInternetELB
	isHaveInstanceAttached : isHaveInstanceAttached
	isAttachELBToMultiAZ : isAttachELBToMultiAZ
	isRedirectPortHttpsToHttp : isRedirectPortHttpsToHttp