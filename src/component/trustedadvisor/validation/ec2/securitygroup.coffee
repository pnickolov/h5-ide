define [ 'constant', 'MC','i18n!/nls/lang.js'], ( constant, MC, lang ) ->

	getAllRefComp = (sgUID) ->

		refNum = 0
		sgAry = []
		refCompAry = []
		_.each MC.canvas_data.component, (comp) ->
			compType = comp.type
			if compType is 'AWS.ELB' or compType is 'AWS.AutoScaling.LaunchConfiguration'
				sgAry = comp.resource.SecurityGroups
				sgAry = _.map sgAry, (value) ->
					refSGUID = MC.extractID(value)
					return refSGUID
				if sgUID in sgAry
					refCompAry.push comp

			if compType is 'AWS.EC2.Instance'
				sgAry = comp.resource.SecurityGroupId
				sgAry = _.map sgAry, (value) ->
					refSGUID = MC.extractID(value)
					return refSGUID
				if sgUID in sgAry
					refCompAry.push comp

			if compType is 'AWS.VPC.NetworkInterface'
				_sgAry = []
				_.each comp.resource.GroupSet, (sgObj) ->
					_sgAry.push sgObj.GroupId
					null

				sgAry = _sgAry
				sgAry = _.map sgAry, (value) ->
					refSGUID = MC.extractID(value)
					return refSGUID

				if sgUID in sgAry
					refCompAry.push comp
			null

		return refCompAry

	isELBDefaultSG = (sgUID) ->
		component = MC.canvas_data.component[sgUID]
		component and component.name.indexOf("elbsg-") is 0

	isSGRuleExceedFitNum = (sgUID) ->

		sgComp = MC.canvas_data.component[sgUID]
		sgInboundRuleAry = sgComp.resource.IpPermissions
		sgOutboundRuleAry = sgComp.resource.IpPermissionsEgress

		# count sg rule total number
		sgTotalRuleNum = 0
		if sgInboundRuleAry
			sgTotalRuleNum += sgInboundRuleAry.length
		if sgOutboundRuleAry
			sgTotalRuleNum += sgOutboundRuleAry.length

		# have vpc
		if sgTotalRuleNum > 50
			sgName = sgComp.name
			tipInfo = sprintf lang.ide.TA_MSG_WARNING_SG_RULE_EXCEED_FIT_NUM, sgName, 50
			return {
				level: constant.TA.WARNING,
				info: tipInfo,
				uid: sgUID
			}

		return null

	isStackUsingOnlyOneSG = () ->

		refSGNum = 0
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.RESTYPE.SG
				sgUID = compObj.uid
				allRefComp = getAllRefComp(sgUID)
				if allRefComp.length > 0
					refSGNum++
			null

		if refSGNum is 1
			tipInfo = sprintf lang.ide.TA_MSG_NOTICE_STACK_USING_ONLY_ONE_SG
			# return
			level: constant.TA.NOTICE
			info: tipInfo
		else
			return null

	isHaveUsingAllProtocolRule = (sgUID) ->

		# only valid when use
		allRefComp = getAllRefComp(sgUID)
		if allRefComp.length is 0
			return null

		# not elb's default sg
		if isELBDefaultSG(sgUID)
			return null

		sgComp = MC.canvas_data.component[sgUID]
		sgInboundRuleAry = sgComp.resource.IpPermissions
		sgOutboundRuleAry = sgComp.resource.IpPermissionsEgress

		# check if have ALL protocol's rule
		haveAllProtocolRule = false
		_.each sgInboundRuleAry, (ruleObj) ->
			ruleProtocol = ruleObj.IpProtocol
			if ruleProtocol in ['-1', -1]
				haveAllProtocolRule = true
			null
		if !haveAllProtocolRule
			_.each sgOutboundRuleAry, (ruleObj) ->
				ruleProtocol = ruleObj.IpProtocol
				if ruleProtocol in ['-1', -1]
					haveAllProtocolRule = true
				null

		if haveAllProtocolRule
			sgName = sgComp.name
			tipInfo = sprintf lang.ide.TA_MSG_WARNING_SG_USING_ALL_PROTOCOL_RULE, sgName
			return {
				level: constant.TA.WARNING,
				info: tipInfo,
				uid: sgUID
			}

		return null

	isHaveFullZeroSourceToHTTPRule = (sgUID) ->

		# only valid when use
		allRefComp = getAllRefComp(sgUID)
		if allRefComp.length is 0
			return null

		# not elb's default sg
		if isELBDefaultSG(sgUID)
			return null

		sgComp = MC.canvas_data.component[sgUID]
		sgInboundRuleAry = sgComp.resource.IpPermissions

		# check source 0.0.0.0 target to port 80/443
		isFullZeroTargetOtherPort = false
		validPortAry1 = [80, '80']
		validPortAry2 = [443, '443']
		_.each sgInboundRuleAry, (ruleObj) ->
			if ruleObj.IpRanges is '0.0.0.0/0'
				if !((ruleObj.FromPort in validPortAry1 and ruleObj.ToPort in validPortAry1) or
					(ruleObj.FromPort in validPortAry2 and ruleObj.ToPort in validPortAry2))
						isFullZeroTargetOtherPort = true
			null

		if isFullZeroTargetOtherPort
			sgName = sgComp.name
			tipInfo = sprintf lang.ide.TA_MSG_WARNING_SG_RULE_FULL_ZERO_SOURCE_TARGET_TO_OTHER_PORT, sgName
			return {
				level: constant.TA.WARNING,
				info: tipInfo,
				uid: sgUID
			}
		return null

	isHaveUsingPort22Rule = (sgUID) ->

		# only valid when use
		allRefComp = getAllRefComp(sgUID)
		if allRefComp.length is 0
			return null

		# not elb's default sg
		if isELBDefaultSG(sgUID)
			return null

		sgComp = MC.canvas_data.component[sgUID]
		sgInboundRuleAry = sgComp.resource.IpPermissions
		sgOutboundRuleAry = sgComp.resource.IpPermissionsEgress

		# check if rule using port 22
		isUsingPort22 = false
		validPortAry = [22, '22']
		_.each sgInboundRuleAry, (ruleObj) ->
			if ruleObj.FromPort in validPortAry and ruleObj.ToPort in validPortAry
				isUsingPort22 = true
			null

		if isUsingPort22
			sgName = sgComp.name
			tipInfo = sprintf lang.ide.TA_MSG_NOTICE_SG_RULE_USING_PORT_22, sgName
			return {
				level: constant.TA.NOTICE,
				info: tipInfo,
				uid: sgUID
			}
		return null

	isHaveFullZeroOutboundRule = (sgUID) ->

		# only valid when use
		allRefComp = getAllRefComp(sgUID)
		if allRefComp.length is 0
			return null

		# not elb's default sg
		if isELBDefaultSG(sgUID)
			return null

		sgComp = MC.canvas_data.component[sgUID]
		sgOutboundRuleAry = sgComp.resource.IpPermissionsEgress

		# check if outbound rule have 0.0.0.0/0
		isHaveFullZeroOutbound = false
		_.each sgOutboundRuleAry, (ruleObj) ->
			if ruleObj.IpRanges is '0.0.0.0/0'
				isHaveFullZeroOutbound = true
			null

		if isHaveFullZeroOutbound
			sgName = sgComp.name
			tipInfo = sprintf lang.ide.TA_MSG_WARNING_SG_RULE_HAVE_FULL_ZERO_OUTBOUND, sgName
			return {
				level: constant.TA.WARNING,
				info: tipInfo,
				uid: sgUID
			}
		return null

	isAssociatedSGNumExceedLimit = () ->

		maxSGNumLimit = 5

		taResultAry = []

		_.each MC.canvas_data.component, (comp) ->

			compType = comp.type
			compName = comp.name
			compUID = comp.uid
			isExceedLimit = false

			sgAry = []
			resTypeName = ''
			tagName = ''
			if compType is constant.RESTYPE.ELB
				sgAry = comp.resource.SecurityGroups
				resTypeName = 'Load Balancer'
				tagName = 'elb'

			if compType is constant.RESTYPE.LC
				sgAry = comp.resource.SecurityGroups
				resTypeName = 'Launch Configuration'
				tagName = 'lc'

			else if compType is constant.RESTYPE.INSTANCE
				sgAry = comp.resource.SecurityGroupId
				resTypeName = 'Instance'
				tagName = 'instance'

			else if compType is constant.RESTYPE.ENI
				_.each comp.resource.GroupSet, (sgObj) ->
					sgAry.push sgObj.GroupId
					null

				resTypeName = 'Network Interface'
				tagName = 'eni'

				# if is instance default eni
				if comp.resource.Attachment.DeviceIndex in [0, '0']
					instanceUIDRef = comp.resource.Attachment.InstanceId
					if instanceUIDRef
						instanceUID = MC.extractID(instanceUIDRef)
						instanceComp = MC.canvas_data.component[instanceUID]
						if instanceComp
							instanceName = instanceComp.name
							resTypeName = 'Instance'
							tagName = 'instance'
							compName = instanceName

			if sgAry.length > maxSGNumLimit

				tipInfo = sprintf lang.ide.TA_MSG_ERROR_RESOURCE_ASSOCIATED_SG_EXCEED_LIMIT, resTypeName, tagName, compName, maxSGNumLimit
				taObj =
					level: constant.TA.ERROR
					info: tipInfo
					uid: compUID

				taResultAry.push taObj

			null

		if taResultAry.length > 0
			return taResultAry

		null

	isSGRuleExceedFitNum : isSGRuleExceedFitNum
	isStackUsingOnlyOneSG : isStackUsingOnlyOneSG
	isHaveUsingAllProtocolRule : isHaveUsingAllProtocolRule
	isHaveFullZeroSourceToHTTPRule : isHaveFullZeroSourceToHTTPRule
	isHaveUsingPort22Rule : isHaveUsingPort22Rule
	isHaveFullZeroOutboundRule : isHaveFullZeroOutboundRule
	isAssociatedSGNumExceedLimit : isAssociatedSGNumExceedLimit
