#############################
#  View Mode for design/property/eni
#############################

define [ '../base/model', 'constant', "Design", "event", 'i18n!nls/lang.js'  ], ( PropertyModel, constant, Design, ide_event, lang ) ->

	ENIModel = PropertyModel.extend {

		defaults :
			'uid'       : null
			'isAppEdit' : false

		init : ( uid ) ->

			component = Design.instance().component( uid )

			data = {
				uid             : uid
				name            : component.get("name")
				desc            : component.get("description")
				sourceDestCheck : component.get("sourceDestCheck")
				isAppEdit       : @isAppEdit
				isGroupMode     : @isGroupMode
				attached        : component.connections("EniAttachment").length > 0
				ips             : component.getIpArray()
			}

			data.ips[0].unDeletable = true

			if @isAppEdit
				data.ips[0].editable = false

			@set data

			if @isAppEdit
				@getEniGroup( uid )
			null

		setEniDesc : ( value ) ->
			Design.instance().component( @get("uid") ).set("description", value)
			null

		setSourceDestCheck : ( value ) ->
			Design.instance().component( @get("uid") ).set("sourceDestCheck", value)
			null

		attachEip : ( eip_index, attach ) ->
			Design.instance().component( @get("uid") ).setIp( eip_index, null, null, attach )
			this.attributes.ips[ eip_index ].hasEip = attach

			if attach
				Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway ).tryCreateIgw()
			null

		removeIp : ( index ) ->
			Design.instance().component( @get("uid") ).removeIp( index )
			null

		getEniGroup : ( eni_uid ) ->

			group          = []
			myEniComponent = MC.canvas_data.component[ eni_uid ]
			appData        = MC.data.resource_list[ MC.canvas_data.region ]

			for uid, component of MC.canvas_data.component
				if component.serverGroupUid is myEniComponent.serverGroupUid
					group.push component


			formated_group = []
			for eni_comp in group
				eni = $.extend true, {}, appData[ eni_comp.resource.NetworkInterfaceId ]

				for i in eni.privateIpAddressesSet.item
					i.primary = i.primary is true

				eni.id              = eni_comp.resource.NetworkInterfaceId
				eni.name            = eni_comp.name
				eni.idx             = parseInt( eni_comp.name.split("-")[1], 10 )
				eni.sourceDestCheck = if eni.sourceDestCheck is "true" then "enabled" else "disabled"

				formated_group.push eni

			if formated_group.length > 1
				formated_group = _.sortBy formated_group, 'idx'

				if myEniComponent.resource.Attachment and myEniComponent.resource.Attachment.InstanceId
					instance_comp = MC.canvas_data.component[ MC.extractID( myEniComponent.resource.Attachment.InstanceId ) ]

					if instance_comp and instance_comp.number isnt formated_group.length
						formated_group.increment = instance_comp.number - formated_group.length
						if formated_group.increment > 0
							formated_group.increment = "+" + formated_group.increment

							name_template = myEniComponent.name.split("-")

							for idx in [formated_group.length..instance_comp.number-1]
								name_template[1] = idx
								formated_group.push {
									name  : name_template.join("-")
									isNew : true
									state : "Unknown"
								}

						else
							for idx in [instance_comp.number..formated_group.length-1]
								formated_group[ idx ].isOld = true

				@set 'group', formated_group
			else
				@set 'group', formated_group[0]

			@set 'readOnly', false


			null

		addIp : () ->
			comp = Design.instance().component( @get("uid") )
			comp.addIp()
			ips = comp.getIpArray()
			ips[0].unDeletable = true

			@set "ips", ips
			null

		isValidIp : ( ip )->
			Design.instance().component( @get("uid") ).isValidIp( ip )

		canAddIP : ()->

			eni   = Design.instance().component( @get("uid") )
			maxIp = eni.maxIpCount()

			if @get("ips").length < maxIp
				return true

			instance = eni.attachedInstance()
			if not instance
				return null

			sprintf( lang.ide.PROP_MSG_WARN_ENI_IP_EXTEND, instance.get("instanceType"), maxIp )

		setIp : ( idx, ip, autoAssign )->
			Design.instance().component( @get("uid") ).setIp( idx, ip, autoAssign )
			null
	}

	new ENIModel()
