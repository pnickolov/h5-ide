define [ 'constant', 'MC', 'Design', '../../helper' ], ( constant, MC, Design, Helper ) ->

	i18n = Helper.i18n.short()

	isNotDefaultAndRefInstance = ( uid ) ->
		kp = Design.instance().component uid
		instances = kp.connectionTargets( "KeypairUsage" )

		if kp.isDefault() or not instances.length
			return null

		lcStr = ''
		instanceStr = ''
		message = ''

		for instance in instances
			tag = if instance.type is constant.RESTYPE.LC then 'lc' else 'instance'
			if instance.type is constant.RESTYPE.LC
				tag = 'lc'
				lcStr += "<span class='validation-tag tag-#{tag}'>#{instance.get 'name'}</span>, "
			else
				tag = 'instance'
				instanceStr += "<span class='validation-tag tag-#{tag}'>#{instance.get 'name'}</span>, "

		if instanceStr
			message += 'Instance ' + instanceStr

		if lcStr
			message += 'Launch Configuration' + lcStr

		message = message.slice 0, - 2
		Helper.message.error uid, i18n.TA_MSG_ERROR_INSTANCE_REF_OLD_KEYPAIR, message, kp.get('name')


		###
		infoObjType = 'Instance'
		infoTag = 'instance'
		if instance.type is constant.RESTYPE.LC
			infoObjType = 'Launch Configuration'
			infoTag = 'lc'


		###





	isNotDefaultAndRefInstance: isNotDefaultAndRefInstance


