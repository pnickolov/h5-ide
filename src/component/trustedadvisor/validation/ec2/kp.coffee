define [ 'constant', 'MC', 'Design', '../../helper', 'keypair_service', 'underscore' ], ( constant, MC, Design, Helper, keypair_service, _ ) ->

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

	longLiveNotice = () ->
		Helper.message.notice null, i18n.TA_MSG_NOTICE_KEYPAIR_LONE_LIVE

	isKeyPairExistInAws = ( callback ) ->
		allInstances = Design.modelClassForType( constant.RESTYPE.INSTANCE ).allObjects()
		allLcs = Design.modelClassForType( constant.RESTYPE.LC ).allObjects()
		instanceLike = allInstances.concat allLcs

		needValidate = []
		invalid = []
		errors = {}
		results = []

		for i in instanceLike
			keyName = i.get( 'keyName' )
			if keyName and keyName[0] isnt '@' and not i.connectionTargets( "KeypairUsage" ).length
				needValidate.push i

		if needValidate.length
			username = $.cookie "usercode"
			session  = $.cookie "session_id"
			region = Design.instance().region()

			keypair_service.DescribeKeyPairs( null, username, session, region ).then( ( res ) ->
				if res.is_error
					throw res

				kpList = res.resolved_data or []

				_.each needValidate, ( i ) ->
					inexist = _.every kpList, ( kp ) ->
						kp.keyName isnt i.get 'keyName'

					if inexist
						keyName = i.get 'keyName'
						invalid.push i
						if not errors[ keyName ]
							errors[ keyName ] = lc: '', instance: ''

						tag = if i.type is constant.RESTYPE.LC then 'lc' else 'instance'
						if i.type is constant.RESTYPE.LC
							tag = 'lc'
							errors[ keyName ].lc += "<span class='validation-tag tag-#{tag}'>#{i.get 'name'}</span>, "
						else
							tag = 'instance'
							errors[ keyName ].instance += "<span class='validation-tag tag-#{tag}'>#{i.get 'name'}</span>, "


				_.each errors, ( err, keyName ) ->
					message = ''
					if err.instance
						message += 'Instance ' + err.instance

					if err.lc
						message += 'Launch Configuration' + err.lc

					message = message.slice 0, - 2
					results.push Helper.message.error keyName, i18n.TA_MSG_ERROR_INSTANCE_REF_OLD_KEYPAIR, message, keyName

				callback results


			).fail( ( error ) ->
				callback null
			)









	isNotDefaultAndRefInstance: isNotDefaultAndRefInstance
	longLiveNotice		      : longLiveNotice
	isKeyPairExistInAws       : isKeyPairExistInAws



