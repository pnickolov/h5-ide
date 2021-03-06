#############################
#  View Mode for design/property/instance (app)
#############################

define [ '../base/model',
	'../instance/model'
	'constant',
	'i18n!/nls/lang.js'
	'Design'
    'CloudResources'
], ( PropertyModel, instance_model, constant, lang, Design, CloudResources ) ->

	ServerGroupModel = PropertyModel.extend {

		init : ( uid ) ->
			@set 'uid', uid
			@set 'readOnly', not @isAppEdit

			@set 'isMesos', @resModel.isMesos()
			@set 'isMesosMaster', @resModel.isMesosMaster()
			@set 'isMesosSlave', @resModel.isMesosSlave()

			@set 'tags', Design.instance().component(uid).tags()
			# Find out AMI
			ami_id = @resModel.get("imageId")
			ami    = @resModel.getAmi() or @resModel.get("cachedAmi")

			if ami
				@set 'ami', {
					id   : ami_id
					name : ami.name or ami.description or ami.id
					icon : "#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"
					type : ami.rootDeviceType
				}

				@set 'type_editable', ami.rootDeviceType isnt "instance-store"
			else
				notification 'warning', sprintf lang.NOTIFY.ERR_AMI_NOT_FOUND, ami_id

			#root device
			rd = @resModel.getBlockDeviceMapping()
			if rd.length is 1
				@set "rootDevice", rd[0]

			# Find out Instance Type
			tenancy = @resModel.get 'tenancy' isnt 'dedicated'

			# Ebs Optimized
			@set 'instance_type', @resModel.getInstanceTypeList()
			@set 'ebs_optimized', @resModel.get("ebsOptimized")
			@set 'can_set_ebs',   @resModel.isEbsOptimizedEnabled()
			routeCount = @resModel.connectionTargets( 'RTB_Route' ).length

			if routeCount
				@set 'number_disable', true

			@set 'number', @resModel.get 'count'
			@set 'name',   @resModel.get 'name'
			@set 'monitoring', @resModel.get 'monitoring'
			@set 'description', @resModel.get 'description'
			@set 'displayCount', @resModel.get('count') - 1
			@set 'userData', @resModel.get("userData")
			#@set "stackAgentEnable", Design.instance().get("agent").enabled

			@getGroupList()
			@getEni()
			null

		setCount : ( count ) ->
			uid = @get( 'uid' )
			Design.instance().component( uid ).setCount  count

			@getGroupList()

			null

		getGroupList : ()->

			uid = @get( 'uid' )

			comp          = Design.instance().component( uid )
			resource_list = CloudResources(Design.instance().credentialId(), constant.RESTYPE.INSTANCE, Design.instance().region())
			appData       = CloudResources(Design.instance().credentialId(), constant.RESTYPE.INSTANCE, Design.instance().region()).get(comp.get('appId'))?.toJSON()
			name          = comp.get("name")

			group = [{
				appId      : comp.get("appId")
				name       : name + "-0"
				status     : if appData then appData.instanceState.name else "Unknown"
				launchTime : if appData then appData.launchTime else ""
			}]

			count = comp.get("count")

			if comp.groupMembers().length > count - 1
				members = comp.groupMembers().slice(0, count - 1)
			else
				members = comp.groupMembers()

			for member, index in members
				# There might be many objects in members.
				# But they might not be real. Because they might not have appId
				group.push {
					name   : name + "-" + (index+1)
					appId  : member.appId
					status : if resource_list.get( member.appId ) then resource_list.get( member.appId ).attributes.instanceState.name else "Unknown"
					isNew  : not member.appId
					isOld  : member.appId and ( index + 1 >= count )
				}

			while group.length < count
				group.push {
					name   : name + "-" + group.length
					isNew  : true
					status : "Unknown"
				}

			existingLength = 0
			for eni, idx in comp.groupMembers()
				if eni.appId
					existingLength = idx + 1
				else
					break
			existingLength += 1

			if group.length > 1
				@set 'group', group

				if existingLength > count
					group.increment = "-" + ( existingLength - count )
				else if existingLength < count
					group.increment = "+" + ( count - existingLength )
			else
				@set 'group', group[0]
			null


		getEni : instance_model.getEni

		setEbsOptimized    : instance_model.setEbsOptimized
		canSetInstanceType : instance_model.canSetInstanceType
		setInstanceType    : instance_model.setInstanceType

		setIp     : instance_model.setIp
		canAddIP  : instance_model.canAddIP
		isValidIp : instance_model.isValidIp
		addIp     : instance_model.addIp
		removeIp  : instance_model.removeIp
		attachEip : instance_model.attachEip
		setMonitoring : instance_model.setMonitoring
		setSourceCheck : instance_model.setSourceCheck
		setUserData    : instance_model.setUserData
	}

	new ServerGroupModel()
