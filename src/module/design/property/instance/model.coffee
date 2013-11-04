#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'constant', 'event', 'i18n!nls/lang.js' ], ( PropertyModel, constant, ide_event, lang ) ->

	InstanceModel = PropertyModel.extend {

		init : ( uid ) ->
			@set 'uid', uid

			@getName()
			@getInstanceType()
			@getAmi()
			@getComponent()
			@getKeyPair()
			@getEni()
			null

		setName  : ( value ) ->
			uid = this.get 'uid'
			component = MC.canvas_data.component[ uid ]

			component.name = component.serverGroupName = value

			MC.canvas.update(uid,'text','hostname', value)
			null


		getName  : () ->
			instance_uid = this.get( 'uid' )
			component = MC.canvas_data.component[ instance_uid ]

			this.set 'name',   component.name

			# Instance count
			this.set 'number', component.number
			this.set 'number_disable', false
			for uid, comp of MC.canvas_data.component
				if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
					connected = false
					for route in comp.resource.RouteSet
						if route.InstanceId.indexOf( instance_uid ) isnt -1
							connected = true
							break
					if connected
						this.set 'number_disable', true
						break

			# Classic Mode
			this.set 'classic_stack', MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC or MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.DEFAULT_VPC
			null

		setCount : ( val ) ->
			uid = @get( 'uid' )
			MC.canvas_data.component[ uid ].number = val
			MC.aws.instance.updateCount( uid, val )
			null

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
			uid = this.get 'uid'
			MC.canvas_data.component[ uid ].resource.EbsOptimized = value
			null

		setTenancy : ( value ) ->
			uid  = this.get 'uid'
			MC.canvas_data.component[ uid ].resource.Placement.Tenancy = value
			null

		setCloudWatch : ( value ) ->

			uid = this.get 'uid'
			MC.canvas_data.component[ uid ].resource.Monitoring = if value then 'enabled' else 'disabled'
			null

		setUserData : ( value ) ->

			uid = this.get 'uid'
			MC.canvas_data.component[ uid ].resource.UserData.Data = value

			null

		setEniDescription: ( value ) ->

			uid = this.get 'uid'

			_.map MC.canvas_data.component, ( val, key ) ->

				if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

					val.resource.Description = value

				null

			null

		setSourceCheck : ( value ) ->

			uid = this.get 'uid'

			_.map MC.canvas_data.component, ( val, key ) ->

				if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

					val.resource.SourceDestCheck = value

				null

			null

		setPublicIp : ( value ) ->

			uid = this.get 'uid'

			_.map MC.canvas_data.component, ( val, key ) ->

				if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

					val.resource.AssociatePublicIpAddress = value

				null

			null

		unAssignSGToComp : (sg_uid) ->

			instanceUID = this.get 'uid'

			currentSG = '@' + sg_uid + '.resource.GroupName'
			currentSGId = '@' + sg_uid + '.resource.GroupId'

			if !MC.canvas_data.component[instanceUID].resource.VpcId and !MC.aws.aws.checkDefaultVPC()
				originSGAry = MC.canvas_data.component[instanceUID].resource.SecurityGroup
				originSGIdAry = MC.canvas_data.component[instanceUID].resource.SecurityGroupId

				originSGAry = _.filter originSGAry, (value) ->
					value isnt currentSG

				originSGIdAry = _.filter originSGIdAry, (value) ->
					value isnt currentSGId

				MC.canvas_data.component[instanceUID].resource.SecurityGroup = originSGAry
				MC.canvas_data.component[instanceUID].resource.SecurityGroupId = originSGIdAry

			# remove from eni sg
			eniComp = MC.aws.eni.getInstanceDefaultENI instanceUID
			if !eniComp then return

			eniGroupSet = eniComp.resource.GroupSet

			newGroupSet = _.filter eniGroupSet, (groupObj) ->
				if groupObj.GroupName is currentSG or groupObj.GroupId is currentSGId
					return false
				else
					return true

			MC.canvas_data.component[eniComp.uid].resource.GroupSet = newGroupSet

			null

		assignSGToComp : (sg_uid) ->

			instanceUID = this.get 'uid'

			currentSG = '@' + sg_uid + '.resource.GroupName'
			currentSGId = '@' + sg_uid + '.resource.GroupId'

			if !MC.canvas_data.component[instanceUID].resource.VpcId and !MC.aws.aws.checkDefaultVPC()
				originSGAry = MC.canvas_data.component[instanceUID].resource.SecurityGroup
				originSGIdAry = MC.canvas_data.component[instanceUID].resource.SecurityGroupId

				if !Boolean(currentSG in originSGAry)
					originSGAry.push currentSG

				if !Boolean(currentSGId in originSGIdAry)
					originSGIdAry.push currentSGId

				MC.canvas_data.component[instanceUID].resource.SecurityGroup = originSGAry
				MC.canvas_data.component[instanceUID].resource.SecurityGroupId = originSGIdAry

			# add to eni sg
			eniComp = MC.aws.eni.getInstanceDefaultENI instanceUID
			if !eniComp then return

			eniGroupSet = eniComp.resource.GroupSet

			addToENISg = true
			_.each eniGroupSet, (sgObj) ->
				if sgObj.GroupName is currentSG or sgObj.GroupId is currentSGId
					addToENISg = false
					return
				null
			if addToENISg
				MC.canvas_data.component[eniComp.uid].resource.GroupSet.push {
					GroupId: currentSGId
					GroupName: currentSG
				}

			null

		getEni : () ->

			uid          = @get 'uid'
			component    = MC.canvas_data.component[ uid ]
			defaultVPCId = MC.aws.aws.checkDefaultVPC()

			if not component.resource.SubnetId and not defaultVPCId
				return

			if defaultVPCId
				subnetObj  = MC.aws.vpc.getSubnetForDefaultVPC( uid )
				subnetCIDR = subnetObj.cidrBlock
			else
				subnetUID  = MC.extractID component.resource.SubnetId
				subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

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

		getComponent : () ->
			this.set 'component', MC.canvas_data.component[ this.get( 'uid') ]
			null

		getAmi : () ->

			uid = this.get 'uid'

			ami_id = MC.canvas_data.component[ uid ].resource.ImageId
			ami    = MC.data.dict_ami[ami_id]

			if not ami
				notification 'warning', sprintf lang.ide.PROP_MSG_ERR_AMI_NOT_FOUND, ami_id
				return

			this.set 'instance_ami', {
				name : ami.name
				icon : ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"
			}

			this.set 'ami_uid', ami_id
			null

		getKeyPair : ()->

			uid = this.get 'uid'
			keypair_id = MC.extractID MC.canvas_data.component[ uid ].resource.KeyName

			kp_list = MC.aws.kp.getList( keypair_id )

			this.set 'keypair', kp_list

			null

		addKP : ( kp_name ) ->

			result = MC.aws.kp.add kp_name

			if not result
				return result

			uid = @get 'uid'
			MC.canvas_data.component[ uid ].resource.KeyName = "@#{result}.resource.KeyName"
			true

		deleteKP : ( key_name ) ->

			MC.aws.kp.del key_name

			# Update data of this model
			for kp, idx in @attributes.keypair
				if kp.name is key_name
					@attributes.keypair.splice idx, 1
					break

			null

		setKP : ( key_name ) ->

			uid = this.get 'uid'
			MC.canvas_data.component[ uid ].resource.KeyName = "@#{MC.canvas_property.kp_list[key_name]}.resource.KeyName"

			null


		getInstanceType : () ->

			uid = this.get 'uid'
			component = MC.canvas_data.component[ uid ]

			tenacy = component.resource.Placement.Tenancy isnt 'dedicated'

			this.set 'ebs_optimized', "" + component.resource.EbsOptimized is "true"
			this.set 'monitoring',    component.resource.Monitoring is 'enabled'
			this.set 'tenacy',        tenacy

			this.set 'force_tenacy', false
			for comp_uid, comp of MC.canvas_data.layout.component.group
				if comp.type is 'AWS.VPC.VPC'
					vpc = MC.canvas_data.component[ comp_uid ]
					if vpc.resource.InstanceTenancy is "dedicated"
						this.set 'force_tenacy', true
					break

			if MC.data.dict_ami and MC.data.dict_ami[ component.resource.ImageId ]
				ami_info = MC.data.dict_ami[ component.resource.ImageId ]
			else
				ami_info = MC.canvas_data.layout.component.node[ uid ]

			current_instance_type = component.resource.InstanceType


			instance_type_list = MC.aws.ami.getInstanceType( ami_info )
			if instance_type_list
				view_instance_type = _.map instance_type_list, ( value )->

					main     : constant.INSTANCE_TYPE[value][0]
					ecu      : constant.INSTANCE_TYPE[value][1]
					core     : constant.INSTANCE_TYPE[value][2]
					mem      : constant.INSTANCE_TYPE[value][3]
					name     : value
					selected : current_instance_type is value
					hide     : not tenacy and value is "t1.micro"
			else
				view_instance_type = [{
					main     : ''
					ecu      : ''
					core     : ''
					mem      : ''
					name     : ''
					selected : false
					hide     : true
				}]

			this.set 'instance_type', view_instance_type
			this.set 'can_set_ebs',   MC.aws.instance.canSetEbsOptimized component

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

						MC.canvas.update instance_uid,'image','eip_status', MC.canvas.IMAGE.EIP_ON

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

								if not existing

									MC.canvas.update instance_uid,'image','eip_status', MC.canvas.IMAGE.EIP_OFF



					return false

		getSGList : () ->

			sgUIDAry = []
			uid = this.get 'uid'

			if MC.aws.vpc.getVPCUID() || MC.aws.aws.checkDefaultVPC()

				defaultENIComp = MC.aws.eni.getInstanceDefaultENI(uid)
				eniUID = defaultENIComp.uid

				sgAry = MC.canvas_data.component[eniUID].resource.GroupSet

				sgUIDAry = []
				_.each sgAry, (value) ->
					sgUID = value.GroupId.slice(1).split('.')[0]
					sgUIDAry.push sgUID
					null
			else
				sgAry = MC.canvas_data.component[uid].resource.SecurityGroupId

				sgUIDAry = []
				_.each sgAry, (value) ->
					sgUID = value.slice(1).split('.')[0]
					sgUIDAry.push sgUID
					null

			return sgUIDAry

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

			newIP =
				customizable : parseInt( MC.canvas_data.component[ uid ].number, 10) == 1
				prefix       : prefixSuffixAry[0]
				suffix       : "x"
				deletable    : true
				ip           : prefixSuffixAry[0] + "x"
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

				for index_value in [min_index..max_index]
					modify_index_refs["@#{comp.uid}.resource.PrivateIpAddressSet.#{index_value}.PrivateIpAddress"] = true

				comp.resource.PrivateIpAddressSet.splice index, 1
				remove_uid = null

				for u, c of MC.canvas_data.component
					if c.type isnt constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
						continue
					if c.resource.NetworkInterfaceId isnt eni_ref
						continue

					if modify_index_refs[ c.resource.PrivateIpAddress ]
						idx = parseInt( c.resource.PrivateIpAddress.split('.')[3],10 )-1
						c.resource.PrivateIpAddress = "@#{comp_uid}.resource.PrivateIpAddressSet.#{idx}.PrivateIpAddress"
					else if c.resource.PrivateIpAddress is ip_ref
						remove_uid = u

				delete MC.canvas_data.component[remove_uid]
				break

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
