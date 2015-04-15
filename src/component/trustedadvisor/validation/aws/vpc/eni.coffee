define [ 'constant', 'MC','i18n!/nls/lang.js'], ( constant, MC, lang ) ->

	isENIAttachToInstance = (eniUID) ->

		eniComp = MC.canvas_data.component[eniUID]
		attachedInstanceId = eniComp.resource.Attachment.InstanceId

		if attachedInstanceId
			return null
		else
			eniName = eniComp.name
			tipInfo = sprintf lang.TA.ERROR_ENI_NOT_ATTACH_TO_INSTANCE, eniName
			level = constant.TA.ERROR
			level = constant.TA.WARNING if Design.instance().mode() is 'appedit'
			# return
			level: level
			info: tipInfo
			uid: eniUID

	isENIAttachToInstance : isENIAttachToInstance
