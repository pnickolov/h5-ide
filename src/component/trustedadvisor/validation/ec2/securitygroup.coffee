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
				tipInfo = sprintf lang.ide.TA_INFO_WARNING_SG_RULE_EXCEED_FIT_NUM, sgName, 50
				return {
					level: constant.TA.WARNING,
					info: tipInfo
				}
		else
			# no vpc
			if sgTotalRuleNum > 100
				sgName = sgComp.name
				tipInfo = sprintf lang.ide.TA_INFO_WARNING_SG_RULE_EXCEED_FIT_NUM, sgName, 100
				return {
					level: constant.TA.WARNING,
					info: tipInfo
				}

		return null

	isSGRuleExceedFitNum : isSGRuleExceedFitNum