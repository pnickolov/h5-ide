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
			}

			@set data
			@getIpList()

			if @isAppEdit
				@getEniGroup( uid )
			null

		getIpList : ()->
			ips = Design.instance().component( @get("uid") ).getIpArray()

			ips[0].unDeletable = true

			if @isAppEdit
				ips[0].editable = false

			@set "ips", ips
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
			myEniComponent = Design.instance().component( eni_uid )
			appData        = MC.data.resource_list[ Design.instance().region() ]

			group = myEniComponent.groupMembers()
			group.unshift myEniComponent.toJSON()


			formated_group = []
			for index, eni_comp of group
				eni = $.extend true, {}, appData[ eni_comp.appId ]

				for i in eni.privateIpAddressesSet.item
					i.primary = i.primary is true

				eni.id              = eni_comp.appId
				eni.name            = if eni_comp.name then "#{eni_comp.name}-0" else "#{myEniComponent.get 'name'}-#{index}"
				eni.idx             = index
				eni.sourceDestCheck = if eni.sourceDestCheck is "true" then "enabled" else "disabled"

				formated_group.push eni

			if formated_group.length > 1
				formated_group = _.sortBy formated_group, 'idx'

				attachedInstance = myEniComponent.connectionTargets( 'EniAttachment' )[ 0 ]

				if attachedInstance
					instance_comp = attachedInstance
					instanceCount = attachedInstance.get( 'count' )

					if instance_comp and instanceCount isnt formated_group.length
						formated_group.increment = instanceCount - formated_group.length
						if formated_group.increment > 0
							formated_group.increment = "+" + formated_group.increment

							name_template = myEniComponent.get( 'name' ).split( '-' )

							for idx in [ formated_group.length..instanceCount - 1 ]
								name_template[1] = idx
								formated_group.push {
									name  : name_template.join("-")
									isNew : true
									state : "Unknown"
								}

						else
							for idx in [ instanceCount..formated_group.length - 1 ]
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
			Design.instance().component( @get("uid") ).canAddIp()


		setIp : ( idx, ip, autoAssign )->
			Design.instance().component( @get("uid") ).setIp( idx, ip, autoAssign )
			null
	}

	new ENIModel()
