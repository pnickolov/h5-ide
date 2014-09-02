define [
	'constant'
	'MC'
	'Design'
	'TaHelper'
	'keypair_service'
	'underscore'
	'CloudResources'
], ( constant, MC, Design, Helper, keypair_service, _, CloudResources ) ->

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
		Helper.message.error uid, i18n.ERROR_INSTANCE_REF_OLD_KEYPAIR, message, kp.get('name')

	longLiveNotice = () ->
		Helper.message.notice null, i18n.NOTICE_KEYPAIR_LONE_LIVE

	isKeyPairExistInAws = ( callback ) ->
		allInstances = Design.modelClassForType( constant.RESTYPE.INSTANCE ).allObjects()
		allLcs = Design.modelClassForType( constant.RESTYPE.LC ).allObjects()
		instanceLike = allInstances.concat allLcs

		needValidate = []
		invalid = []
		errors = {}
		results = []

		for i in instanceLike
			# Don't check instance has appId( means exsit ) and hasn't added member
			if i.type is constant.RESTYPE.INSTANCE and i.get( 'appId' ) and i.get( 'count' ) is i.groupMembers().length + 1
				continue;

			keyName = i.get( 'keyName' )
			if keyName and keyName[0] isnt '@' and not i.connectionTargets( "KeypairUsage" ).length
				needValidate.push i

		if not needValidate.length
			callback null
		else
			username = $.cookie "usercode"
			session  = $.cookie "session_id"
			region = Design.instance().region()

			kpCollection = CloudResources(constant.RESTYPE.KP, Design.instance().get("region"))
			kpCollection.fetchForce().then ( col ) ->
				kpList = col.toJSON()
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
					results.push Helper.message.error keyName, i18n.ERROR_INSTANCE_REF_OLD_KEYPAIR, message, keyName

				callback results
			, () ->
				callback null






	isNotDefaultAndRefInstance: isNotDefaultAndRefInstance
	longLiveNotice		      : longLiveNotice
	isKeyPairExistInAws       : isKeyPairExistInAws



