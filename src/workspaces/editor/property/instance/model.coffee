#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant', 'event', 'i18n!/nls/lang.js' ], ( PropertyModel, constant, ide_event, lang ) ->

	InstanceModel = PropertyModel.extend {

		init : ( uid ) ->

			component = Design.instance().component( uid )

			attr = component?.toJSON()
			attr.uid = uid
			attr.classic_stack  = false
			attr.can_set_ebs    = component.isEbsOptimizedEnabled()
			attr.instance_type  = component.getInstanceTypeList()
			attr.tenancy        = component.isDefaultTenancy()
			attr.displayCount   = attr.count - 1

			eni = component.getEmbedEni()
			attr.number_disable = eni and eni.connections('RTB_Route').length > 0

			# If Vpc is dedicated, instance should be dedicated.
			vpc = Design.modelClassForType( constant.RESTYPE.VPC ).allObjects()[0]
			attr.force_tenacy = vpc and not vpc.isDefaultTenancy()

			# if stack enable agent
			design = Design.instance()
			agentData = design.get('agent')
			attr.stackAgentEnable = agentData.enabled

			@set attr

			@getAmi()
			@getKeyPair()
			@getEni()
			null

		getKeyPair : ()->
			selectedKP = Design.instance().component(@get("uid")).connectionTargets("KeypairUsage")[0]

			if selectedKP
				@set "keypair", selectedKP.getKPList()
			null

		addKP : ( kp_name ) ->

			KpModel = Design.modelClassForType( constant.RESTYPE.KP )

			for kp in KpModel.allObjects()
				if kp.get("name") is kp_name
					return false

			kp = new KpModel( { name : kp_name } )
			kp.id

		deleteKP : ( kp_uid ) ->
			Design.instance().component( kp_uid ).remove()
			null

		setKP : ( kp_uid ) ->
			design  = Design.instance()
			instance = design.component( @get("uid") )
			design.component( kp_uid ).assignTo( instance )
			null

		setCount : ( val ) ->
			Design.instance().component( @get("uid") ).setCount( val )

		setEbsOptimized : ( value )->
			Design.instance().component( @get("uid") ).set( "ebsOptimized", value )

		setTenancy : ( value ) ->
			Design.instance().component( @get("uid") ).setTenancy( value )

		setMonitoring : ( value ) ->
			Design.instance().component( @get("uid") ).set( "monitoring", value )

		setUserData : ( value ) ->
			Design.instance().component( @get("uid") ).set( "userData", value )

		setEniDescription: ( value ) ->
			Design.instance().component( @get("uid") ).getEmbedEni().set("description", value)

		setSourceCheck : ( value ) ->
			Design.instance().component( @get("uid") ).getEmbedEni().set("sourceDestCheck", value)

		setPublicIp : ( value ) ->
			Design.instance().component( @get("uid") ).getEmbedEni().set("assoPublicIp", value)
			if value
				Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()

		getAmi : () ->
			ami_id = @get("imageId")
			comp   = Design.instance().component( @get("uid") )
			ami    = comp.getAmi()

			if not ami
				data = {
					name        : ami_id + " is not available."
					icon        : "ami-not-available.png"
					unavailable : true
				}
			else
				data = {
					name : ami.name or ami.description or ami.id
					icon : ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"
				}

			@set 'instance_ami', data

			if ami and ami.blockDeviceMapping and not $.isEmptyObject(ami.blockDeviceMapping)
				rdName = ami.rootDeviceName
				rdEbs = ami.blockDeviceMapping[ rdName ]

				if rdName and not rdEbs
				#rootDeviceName is partition
					_.each ami.blockDeviceMapping, (value,key) ->
						if rdName.indexOf(key) isnt -1 and not rdEbs
							rdEbs  = value
							rdName = key
						null

				deviceType = comp.get("rdType")

				rootDevice =
					name : rdName
					size : parseInt( comp.get("rdSize"), 10 )
					iops : comp.get("rdIops")
					encrypted : rdEbs.encrypted
					isStandard: deviceType is 'standard'
					isIo1 : deviceType is 'io1'
					isGp2 : deviceType is 'gp2'




				if rootDevice.size < 10
					rootDevice.iops = ""
					rootDevice.iopsDisabled = true
				@set "rootDevice", rootDevice

			@set "min_volume_size", comp.getAmiRootDeviceVolumeSize()

			null

		canSetInstanceType : ( value ) ->
			instance   = Design.instance().component( @get("uid") )
			eni_number = instance.connectionTargets("EniAttachment").length + 1
			config     = instance.getInstanceTypeConfig( value )

			max_eni_num = if config then config.max_eni else 2

			if eni_number <= 2 or eni_number <= max_eni_num
				return true

			return sprintf lang.PROP.WARN_EXCEED_ENI_LIMIT, value, max_eni_num

		setInstanceType  : ( value ) ->
			instance = Design.instance().component( @get("uid") )
			instance.setInstanceType( value )

			# Update IP List
			@getEni()
			instance.isEbsOptimizedEnabled()

		getEni : () ->
			instance = Design.instance().component(@get("uid"))

			eni = instance.getEmbedEni()
			if not eni then return

			eni_obj     = eni.toJSON()
			eni_obj.ips = eni.getIpArray()
			eni_obj.ips[0].unDeletable = true

			@set "eni", eni_obj
			@set "multi_enis", instance.connections("EniAttachment").length > 0
			null




		attachEip : ( eip_index, attach ) ->
			Design.instance().component( @get("uid") ).getEmbedEni().setIp( eip_index, null, null, attach )
			@attributes.eni.ips[ eip_index ].hasEip = attach

			if attach
				Design.modelClassForType( constant.RESTYPE.IGW ).tryCreateIgw()
			null

		removeIp : ( index ) ->
			Design.instance().component( @get("uid") ).getEmbedEni().removeIp( index )
			null

		addIp : () ->
			comp = Design.instance().component( @get("uid") ).getEmbedEni()
			comp.addIp()

			ips = comp.getIpArray()
			ips[0].unDeletable = true

			@get("eni").ips = ips
			null

		isValidIp : ( ip )->
			Design.instance().component( @get("uid") ).getEmbedEni().isValidIp( ip )

		canAddIP : ()->
			Design.instance().component( @get("uid") ).getEmbedEni().canAddIp()

		setIp : ( idx, ip, autoAssign )->
			Design.instance().component( @get("uid") ).getEmbedEni().setIp( idx, ip, autoAssign )
			null

		getStateData : () ->
			Design.instance().component( @get("uid") ).getStateData()

		setIops : ( iops )->
			Design.instance().component( @get("uid") ).set("rdIops", iops)
			null

		setVolumeType: ( type ) ->
			Design.instance().component( @get("uid") ).set("rdType", type)
			null


		setVolumeSize : ( size )->
			Design.instance().component( @get("uid") ).set("rdSize", size)
			null
	}

	new InstanceModel()
