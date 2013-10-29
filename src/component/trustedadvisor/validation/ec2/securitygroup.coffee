define [ 'constant', 'MC','i18n!nls/lang.js'], ( constant, MC, lang ) ->

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

		# check platform type
		platformType = MC.canvas_data.platform
		if platformType isnt MC.canvas.PLATFORM_TYPE.EC2_CLASSIC
			# have vpc
			if sgTotalRuleNum > 50
				sgName = sgComp.name
				tipInfo = sprintf lang.ide.TA_MSG_WARNING_SG_RULE_EXCEED_FIT_NUM, sgName, 50
				return {
					level: constant.TA.WARNING,
					info: tipInfo
				}
		else
			# no vpc
			if sgTotalRuleNum > 100
				sgName = sgComp.name
				tipInfo = sprintf lang.ide.TA_MSG_WARNING_SG_RULE_EXCEED_FIT_NUM, sgName, 100
				return {
					level: constant.TA.WARNING,
					info: tipInfo
				}

		return null

	isStackUsingOnlyOneSG = () ->

		refSGNum = 0
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
				sgUID = compObj.uid
				allRefComp = MC.aws.sg.getAllRefComp(sgUID)
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

	isSGRuleExceedFitNum : isSGRuleExceedFitNum
	isStackUsingOnlyOneSG : isStackUsingOnlyOneSG