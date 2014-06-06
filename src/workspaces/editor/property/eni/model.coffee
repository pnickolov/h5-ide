#############################
#  View Mode for design/property/eni
#############################

define [ '../base/model', 'constant', "Design", 'i18n!nls/lang.js'  ], ( PropertyModel, constant, Design, lang ) ->

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
				Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()
			null

		removeIp : ( index ) ->
			Design.instance().component( @get("uid") ).removeIp( index )
			null

		getEniGroup : ( eni_uid ) ->

			eniComp       = Design.instance().component( eni_uid )
			resource_list = MC.data.resource_list[ Design.instance().region() ]
			appData       = resource_list[ eniComp.get("appId") ]
			name          = eniComp.get("name")

			group = [{
				appId  : eniComp.get("appId")
				name   : name + "-0"
				desc   : eniComp.get("description")
				status : if appData then appData.status else "Unknown"
				sourceDestCheck : if eniComp.get("sourceDestCheck") then "enabled" else "disabled"
			}]

			count = eniComp.serverGroupCount()

			if eniComp.groupMembers().length > count - 1
				members = eniComp.groupMembers().slice(0, count - 1)
			else
				members = eniComp.groupMembers()

			for member, index in members
				# There might be many objects in members.
				# But they might not be real. Because they might not have appId
				group.push {
					name   : name + "-" + (index+1)
					appId  : member.appId
					status : if resource_list[ member.appId ] then resource_list[ member.appId ].status else "Unknown"
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
			for eni, idx in eniComp.groupMembers()
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
