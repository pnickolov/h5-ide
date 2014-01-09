#############################
#  View Mode for design/property/instance (app)
#############################

define [ '../base/model',
	'../instance/model'
	'constant',
	'i18n!nls/lang.js'
	'Design'
], ( PropertyModel, instance_model, constant, lang, Design ) ->

	ServerGroupModel = PropertyModel.extend {

		init : ( uid ) ->

			@set 'uid', uid
			@set 'readOnly', not @isAppEdit

			myInstanceComponent = Design.instance().component( uid )

			# Find out AMI
			ami_id = myInstanceComponent.get 'ImageId'
			ami    = MC.data.dict_ami[ ami_id ] || MC.canvas_data.layout.component.node[ uid ]

			if ami
				@set 'ami', {
					id   : ami_id
					name : ami.name
					icon : "#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"
				}

				@set 'type_editable', ami.rootDeviceType isnt "instance-store"
			else
				notification 'warning', sprintf lang.ide.PROP_MSG_ERR_AMI_NOT_FOUND, ami_id

			# Find out Instance Type
			tenancy = myInstanceComponent.get 'tenancy' isnt 'dedicated'
			instance_type_list = @getInstanceTypeList( ami, tenancy, myInstanceComponent.get 'InstanceType' )

			# Ebs Optimized
			@set 'instance_type', instance_type_list
			@set 'ebs_optimized', "" + myInstanceComponent.get 'EbsOptimized' is "true"
			@set 'can_set_ebs',   MC.aws.instance.canSetEbsOptimized myInstanceComponent


		 	routeCount = myInstanceComponent.connectionTargets( 'RTB_Route' ).length

		 	if routeCount
		 		@set 'number_disable', true


			@set 'number', myInstanceComponent.get 'count'
			@set 'name',   myInstanceComponent.get 'name'

			@getGroupList()
			@getEni()
			null

		getInstanceTypeList : ( ami, tenancy, current_instance_type ) ->
			list = MC.aws.ami.getInstanceType( ami )

			if list.length
				list =_.map list, ( value ) ->
					main     : constant.INSTANCE_TYPE[value][0]
					ecu      : constant.INSTANCE_TYPE[value][1]
					core     : constant.INSTANCE_TYPE[value][2]
					mem      : constant.INSTANCE_TYPE[value][3]
					name     : value
					selected : current_instance_type is value
					hide     : not tenancy and value is "t1.micro"
				return list
			else
				return []

			null

		setCount : ( count ) ->
			uid = @get( 'uid' )
			Design.instance().component( uid ).setCount  count

			@getGroupList()

			null

		getGroupList : ()->

			uid = @get( 'uid' )

			component   = Design.instance().component( uid )
			app_data    = MC.data.resource_list[ Design.instance().region() ]
			count      = component.get 'count'

			if "" + count is "1"
				instance_id = component.get 'appId'
				instance    = app_data[ instance_id ]
				if not instance
					@set "group",  {
						id         : instance_id
						isPending  : true
						state      : "Unknown"
					}
					return
				else
					@set "group", {
						id         : instance_id
						state      : MC.capitalize instance.instanceState.name
						launchTime : instance.launchTime
					}
			else
				old_components   = MC.data.origin_canvas_data.component
				old_server_count = old_components[ uid ].number
				groupname_prefix = component.get 'name' + "-"

				group = []

				for old_uid, old_comp of old_components
					if old_comp.serverGroupUid is uid
						# This is our server group member.
						# It might need to be removed
						instance = app_data[ old_comp.resource.InstanceId ]
						group.push {
							name  : old_comp.name
							id    : old_comp.resource.InstanceId
							idx   : parseInt( old_comp.name.replace( groupname_prefix, "" ), 10 )
							state : if instance then MC.capitalize(instance.instanceState.name) else "Unknown"
						}

				group = _.sortBy group, "idx"

				if count != old_server_count
					group.increment = count - old_server_count
					if group.increment > 0
						group.increment = "+" + group.increment

					if count < old_server_count
						for idx in [count..old_server_count-1]
							group[ idx ].isOld = true

					else
						for idx in [old_server_count..count-1]
							group.push {
								name  : groupname_prefix + idx
								isNew : true
								state : "Unknown"
							}

						attr = if count < old_server_count then "isOld" else "isNew"

				@set "group", group
			null


		getSGList        : instance_model.getSGList
		assignSGToComp   : instance_model.assignSGToComp
		unAssignSGToComp : instance_model.unAssignSGToComp

		getEni : instance_model.getEni

		setEbsOptimized    : instance_model.setEbsOptimized
		canSetInstanceType : instance_model.canSetInstanceType
		setInstanceType    : instance_model.setInstanceType

		addIP     : instance_model.addIP
		removeIP  : instance_model.removeIP
		attachEIP : instance_model.attachEIP
		canAddIP  : instance_model.canAddIP
		setIPList : instance_model.setIPList
	}

	new ServerGroupModel()
