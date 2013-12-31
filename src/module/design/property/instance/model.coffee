#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant', 'event', 'i18n!nls/lang.js' ], ( PropertyModel, constant, ide_event, lang ) ->

	InstanceModel = PropertyModel.extend {

		init : ( uid ) ->

			component = Design.instance().component( uid )

			attr = component.toJSON()
			attr.uid = uid
			attr.number_disable = component.getEmbedEni().connections('RTB_Route').length > 0
			attr.classic_stack  = not Design.instance().typeIsVpc()
			attr.can_set_ebs    = component.isEbsOptimizedEnabled()
			attr.instance_type  = component.getInstanceTypeList()
			attr.tenancy        = component.isDefaultTenancy()

			# If Vpc is dedicated, instance should be dedicated.
			vpc = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).allObjects()[0]
			attr.force_tenacy = vpc and not vpc.isDefaultTenancy()

			@set attr

			@getAmi()
			@getKeyPair()
			# @getEni()
			null

		getKeyPair : ()->
			selectedKP = Design.instance().component(@get("uid")).connectionTargets("KeypairUsage")[0]

			@set "keypair", selectedKP.getKPList()
			null

		addKP : ( kp_name ) ->

			KpModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair )

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

		canSetInstanceType : ( value ) ->
			uid        = this.get 'uid'
			type_ary   = value.split '.'
			eni_number = 0

			for index, comp of MC.canvas_data.component
				if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and MC.extractID( comp.resource.Attachment.InstanceId ) is uid

					++eni_number

			config = MC.data.config[MC.canvas_data.component[uid].resource.Placement.AvailabilityZone[0...-1]]
			max_eni_num = config.instance_type[type_ary[0]][type_ary[1]].eni

			if eni_number <= 2 or eni_number <= max_eni_num
				return true

			return sprintf lang.ide.PROP_WARN_EXCEED_ENI_LIMIT, value, max_eni_num


		setInstanceType  : ( value ) ->

			uid = @get 'uid'

			component = MC.canvas_data.component[ uid ]
			component.resource.InstanceType = value

			has_ebs = MC.aws.instance.canSetEbsOptimized component
			if not has_ebs
				component.resource.EbsOptimized = "false"

			MC.aws.eni.reduceAllENIIPList( uid )

			# Update IP List
			@getEni()

			has_ebs


		setEbsOptimized : ( value )->
			Design.instance().component( @get("uid") ).set( "ebsOptimized", value )

		setTenancy : ( value ) ->
			Design.instance().component( @get("uid") ).set( "tenancy", value )

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

		getAmi : () ->
			ami_id = @get("imageId")
			ami    = Design.instance().component( @get("uid") ).getAmi()

			if not ami
				data = {
					name        : ami_id + " is not available."
					icon        : "ami-not-available.png"
					unavailable : true
				}
			else
				data = {
					name : ami.name
					icon : ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"
				}

			@set 'instance_ami', data
			null

		getEni : () ->

			uid          = @get 'uid'
			attr    = @instance.attributes
			defaultVPCId = MC.aws.aws.checkDefaultVPC()

			if @instance.parent().type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet and not defaultVPCId
				return

			if defaultVPCId
				subnetObj  = MC.aws.vpc.getSubnetForDefaultVPC( uid )
				subnetCIDR = subnetObj.cidrBlock
			else
				subnetUID  = MC.extractID attr.parent.id
				subnetCIDR = attr.CidrBlock

			prefixSuffixAry = MC.aws.subnet.genCIDRPrefixSuffix( subnetCIDR )
			ip_customizable = parseInt( component.number, 10) == 1
			checkEIPMap     = {}
			eni_count       = 0

			for comp_uid, comp of MC.canvas_data.component
				if comp.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
					continue
				if MC.extractID( comp.resource.Attachment.InstanceId ) isnt uid
					continue
				if "" + comp.resource.Attachment.DeviceIndex isnt '0'
					++eni_count
					continue

				eni_detail = {
					description    : comp.resource.Description
					asso_public_ip : comp.resource.AssociatePublicIpAddress || false
					sourceCheck    : "" + comp.resource.SourceDestCheck is "true"
				}

				eni_ips = []

				for ip, idx in comp.resource.PrivateIpAddressSet

					primary = "" + ip.Primary is "true"

					ip_view = {
						prefix          : prefixSuffixAry[0]
						eip             : false
						customizable    : ip_customizable
						deletable       : not primary
						# Editable is for primary ip. In AppEdit, it's always false.
						notEditable     : @isAppEdit and primary
					}

					if "" + ip.AutoAssign is "true"
						ip_view.suffix = prefixSuffixAry[1]
					else
						ip_view.suffix = MC.aws.eni.getENIDivIPAry(subnetCIDR, ip.PrivateIpAddress)[1]

					ip_view.ip = ip_view.prefix + ip_view.suffix

					checkEIPMap[ "@#{comp_uid}.resource.PrivateIpAddressSet.#{idx}.PrivateIpAddress" ] = ip_view
					eni_ips.push ip_view

				for comp_uid, comp of MC.canvas_data.component
					if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.PrivateIpAddress
							ip = checkEIPMap[ comp.resource.PrivateIpAddress ]
							if ip
								ip.eip = true

			eni_detail.multi_enis = eni_count > 1

			this.set 'eni_display', eni_detail
			this.set 'eni_ips',     eni_ips
			null

		attachEIP : ( eip_index, attach ) ->

			instance_uid = this.get 'uid'

			# Update eip state in model data
			@attributes.eni_ips[ eip_index ].eip = attach

			# Update component
			$.each MC.canvas_data.component, ( key, val ) ->

				if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == instance_uid and val.resource.Attachment.DeviceIndex == '0'

					if attach

						eip_component = $.extend true, {}, MC.canvas.EIP_JSON.data

						eip_uid = MC.guid()

						eip_component.uid = eip_uid

						eip_component.resource.PrivateIpAddress = '@' + val.uid + '.resource.PrivateIpAddressSet.' + eip_index + '.PrivateIpAddress'

						eip_component.resource.NetworkInterfaceId = '@' +  val.uid + '.resource.NetworkInterfaceId'

						eip_component.resource.Domain = 'vpc'

						data = MC.canvas.data.get('component')

						data[eip_uid] = eip_component

						MC.canvas.data.set('component', data)

						if eip_index is 0
							MC.canvas.update instance_uid,'image','eip_status', MC.canvas.IMAGE.EIP_ON

						ide_event.trigger ide_event.NEED_IGW

					else

						ip_ref = '@' + val.uid + '.resource.PrivateIpAddressSet.' + eip_index + '.PrivateIpAddress'

						$.each MC.canvas_data.component, ( comp_uid, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.PrivateIpAddress == ip_ref

								delete MC.canvas_data.component[comp_uid]

								#determine whether all eip are detach

								existing = false

								$.each MC.canvas_data.component, ( k, v ) ->

									if v.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and v.resource.NetworkInterfaceId == '@' +  val.uid + '.resource.NetworkInterfaceId'

										existing = true

										return false

								# if not existing
								if eip_index is 0
									MC.canvas.update instance_uid,'image','eip_status', MC.canvas.IMAGE.EIP_OFF



					return false

		addIP : () ->

			uid = @get 'uid'
			for comp_uid, comp of MC.canvas_data.component
				if comp.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
					continue
				if MC.extractID( comp.resource.Attachment.InstanceId ) isnt uid
					continue
				if "" + comp.resource.Attachment.DeviceIndex isnt "0"
					continue

				eniUID = comp_uid
				break

			# Return a newly created IP object to view, so that it can render it
			defaultVPCId = MC.aws.aws.checkDefaultVPC()
			subnetCIDR   = ''

			if defaultVPCId
				subnetObj  = MC.aws.vpc.getSubnetForDefaultVPC( uid )
				subnetCIDR = subnetObj.cidrBlock
			else
				subnetUID  = MC.extractID MC.canvas_data.component[uid].resource.SubnetId
				subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

			prefixSuffixAry = MC.aws.subnet.genCIDRPrefixSuffix( subnetCIDR )

			ipStr = prefixSuffixAry.join('')
			newIP =
				customizable : parseInt( MC.canvas_data.component[ uid ].number, 10) == 1
				prefix       : prefixSuffixAry[0]
				suffix       : prefixSuffixAry[1]
				deletable    : true
				ip           : ipStr
				eip          : false

			@attributes.eni_ips.push newIP

			# Re-generate IP for ENI component
			realIPAry = MC.aws.eni.generateIPList eniUID, @attributes.eni_ips
			MC.aws.eni.saveIPList eniUID, realIPAry

			# Return newly created IP to view to render
			newIP

		removeIP : ( index ) ->

			uid = @get 'uid'

			# Update Model data
			@attributes.eni_ips.splice index, 1

			# Update EIP Component
			for comp_uid, comp of MC.canvas_data.component
				if comp.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
					continue
				if MC.extractID( comp.resource.Attachment.InstanceId ) isnt uid
					continue
				if "" + comp.resource.Attachment.DeviceIndex isnt "0"
					continue

				eniUID = comp_uid

				ip_ref  = "@#{comp.uid}.resource.PrivateIpAddressSet.#{index}.PrivateIpAddress"
				eni_ref = "@#{comp.uid}.resource.NetworkInterfaceId"

				max_index = comp.resource.PrivateIpAddressSet.length - 1
				min_index = index + 1
				modify_index_refs = {}

				if min_index <= max_index
					for index_value in [min_index..max_index]
						modify_index_refs["@#{comp.uid}.resource.PrivateIpAddressSet.#{index_value}.PrivateIpAddress"] = true

				for u, c of MC.canvas_data.component
					if c.type isnt constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
						continue
					if c.resource.NetworkInterfaceId isnt eni_ref
						continue

					if modify_index_refs[ c.resource.PrivateIpAddress ]
						idx = parseInt( c.resource.PrivateIpAddress.split('.')[3],10 )-1
						c.resource.PrivateIpAddress = "@#{comp_uid}.resource.PrivateIpAddressSet.#{idx}.PrivateIpAddress"
					else if c.resource.PrivateIpAddress is ip_ref
						delete MC.canvas_data.component[ u ]

				comp.resource.PrivateIpAddressSet.splice index, 1
				break

			stillHasEIP = _.some @attributes.eni_ips, ( ip )->
				ip.eip

			if not stillHasEIP
				MC.canvas.update uid,'image','eip_status', MC.canvas.IMAGE.EIP_OFF

			# Re-generate IP for ENI component
			realIPAry = MC.aws.eni.generateIPList eniUID, @attributes.eni_ips
			MC.aws.eni.saveIPList eniUID, realIPAry
			null

		canAddIP : () ->
			uid      = @get 'uid'
			eniComp  = MC.aws.eni.getInstanceDefaultENI( uid )

			if not eniComp
				return false

			maxIPNum  = MC.aws.eni.getENIMaxIPNum( uid )
			currIPNum = eniComp.resource.PrivateIpAddressSet.length

			if currIPNum >= maxIPNum
				instanceType = MC.canvas_data.component[ uid ].resource.InstanceType
				error = sprintf(lang.ide.PROP_MSG_WARN_ENI_IP_EXTEND, instanceType, maxIPNum)
				return error

			return true

		setIPList : (inputIPAry) ->

			# find eni0
			eniUID = ''
			currentInstanceUID = this.get 'uid'
			currentInstanceUIDRef = '@' + currentInstanceUID + '.resource.InstanceId'
			_.each MC.canvas_data.component, (compObj) ->
				if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
					instanceUIDRef = compObj.resource.Attachment.InstanceId
					deviceIndex = compObj.resource.Attachment.DeviceIndex
					if (currentInstanceUIDRef is instanceUIDRef) and (deviceIndex is '0')
						eniUID = compObj.uid
				null

			# Update data in model
			for ip, idx in inputIPAry
				model_ip = @attributes.eni_ips[ idx ]

				model_ip.ip     = ip.ip
				model_ip.eip    = ip.eip
				model_ip.suffix = ip.suffix

			# Update data in component
			if eniUID
				realIPAry = MC.aws.eni.generateIPList eniUID, inputIPAry
				MC.aws.eni.saveIPList eniUID, realIPAry
	}

	new InstanceModel()
