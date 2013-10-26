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
			tipInfo = sprintf lang.ide.TA_ERROR_VPC_HAVE_INTERNET_ELB_AND_NO_HAVE_IGW, elbName
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
			tipInfo = sprintf lang.ide.TA_ERROR_ELB_NO_ATTACH_INSTANCE_OR_ASG, elbName
			# return
			level: constant.TA.ERROR
			info: tipInfo

	isHaveIGWForInternetELB : isHaveIGWForInternetELB
	isHaveInstanceAttached : isHaveInstanceAttached