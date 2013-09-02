#############################
#  View Mode for design/property/instance
#############################

define [ 'constant', 'event', 'backbone', 'jquery', 'underscore', 'MC' ], (constant, ide_event) ->

	InstanceModel = Backbone.Model.extend {

		defaults :
			'uid'         : null
			'name'        : null
			'update_instance_title' : null
			'instance_type' : null
			'instance_ami' : null
			'instance_ami_property' : null
			'keypair' : null
			'component' : null
			'sg_display' : null
			'checkbox_display' : null
			'eni_display'   : null
			'ebs_optimized' : null
			'tenacy' : null
			'cloudwatch' : null
			'user_data' : null
			'base64'    :  null
			'eni_description' : null
			'source_check' : null
			'add_sg'   : null
			'remove_sg' : null
			'public_ip' : null

		initialize : ->
			this.listenTo ide_event, 'SWITCH_TAB', this.updateUID

		updateUID : ( type ) ->
			console.log 'updateUID'
			if type is 'OLD_APP' or  type is 'OLD_STACK'
				instanceUID = $( '#instance-property-detail' ).data 'uid'
				this.set 'get_uid', instanceUID
				this.set 'uid', instanceUID


		listen : ->
			#listen
			this.listenTo this, 'change:name', this.setName
			this.listenTo this, 'change:instance_type', this.setInstanceType
			this.listenTo this, 'change:ebs_optimized', this.setEbsOptimized
			this.listenTo this, 'change:cloudwatch', this.setCloudWatch
			this.listenTo this, 'change:user_data', this.setUserData
			this.listenTo this, 'change:base64' , this.setBase64Encoded
			this.listenTo this, 'change:eni_description' , this.setEniDescription
			this.listenTo this, 'change:tenacy' , this.setTenancy
			this.listenTo this, 'change:source_check', this.setSourceCheck
			this.listenTo this, 'change:add_sg', this.addSGtoInstance
			this.listenTo this, 'change:remove_sg', this.removeSG
			this.listenTo this, 'change:public_ip', this.setPublicIp

		getUID  : ( uid ) ->
			console.log 'getUID'
			instanceUID = MC.canvas_data.component[ uid ].uid
			this.set 'get_uid', instanceUID
			this.set 'uid', instanceUID
			null

		setName  : () ->
			console.log 'setName'

			uid = this.get 'get_uid'

			MC.canvas_data.component[ this.get( 'get_uid' )].name = this.get 'name'
			this.set 'update_instance_title', this.get 'name'

			MC.canvas.update(uid,'text','hostname', this.get('name'))
			null


		getName  : () ->
			console.log 'getName'

			instance_uid = this.get( 'get_uid' )
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
			null

		setCount : ( val ) ->
			uid = @get( 'get_uid' )
			MC.canvas_data.component[ uid ].number = val
			MC.aws.instance.updateCount( uid, val )
			null

		setInstanceType  : () ->

			uid = this.get 'get_uid'

			value = this.get 'instance_type'

			console.log 'setInstanceType = ' + value

			type_ary = value.split '.'

			eni_number = 0

			$.each MC.canvas_data.component, (index, comp) ->

				if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == uid

					eni_number += 1

			max_eni_num = MC.data.config[MC.canvas_data.component[uid].resource.Placement.AvailabilityZone[0...-1]].instance_type[type_ary[0]][type_ary[1]].eni

			if eni_number > 2 and eni_number > max_eni_num

				this.trigger 'EXCEED_ENI_LIMIT', uid, value, max_eni_num

			else

				MC.canvas_data.component[ uid ].resource.InstanceType = value

			null
			#this.set 'set_host', 'host'

		setEbsOptimized : ( value )->

			uid = this.get 'get_uid'

			#console.log 'setEbsOptimized = ' + value

			MC.canvas_data.component[ uid ].resource.EbsOptimized = this.get 'ebs_optimized'

			null

		setTenancy : ( value ) ->

			uid  = this.get 'get_uid'

			MC.canvas_data.component[ uid ].resource.Placement.Tenancy = this.get 'tenacy'

			null

		setCloudWatch : () ->

			#console.log 'setCloudWatch = ' + value

			uid = this.get 'get_uid'

			if this.get 'cloudwatch'

				MC.canvas_data.component[ uid ].resource.Monitoring = 'enabled'

			else
				MC.canvas_data.component[ uid ].resource.Monitoring = 'disabled'


			null

		setUserData : () ->

			#console.log 'setUserData = ' + value

			uid = this.get 'get_uid'

			MC.canvas_data.component[ uid ].resource.UserData.Data = this.get 'user_data'

			null

		setBase64Encoded : ()->

			#console.log 'setBase64Encoded = ' + value

			MC.canvas_data.component[ this.get('get_uid') ].resource.UserData.Base64Encoded = this.get 'base64'

			null

		setEniDescription: () ->

			#console.log 'setEniDescription = ' + value

			uid = this.get 'get_uid'

			that = this

			_.map MC.canvas_data.component, ( val, key ) ->

				if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

					val.resource.Description = that.get 'eni_description'

				null

			null

		setSourceCheck : () ->

			#console.log 'setSourceCheck = ' + value
			me = this

			uid = this.get 'get_uid'

			_.map MC.canvas_data.component, ( val, key ) ->

				if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

					val.resource.SourceDestCheck = me.get 'source_check'

				null

			null

		setPublicIp : () ->

			me = this

			uid = this.get 'get_uid'

			_.map MC.canvas_data.component, ( val, key ) ->

				if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

					val.resource.AssociatePublicIpAddress = me.get 'public_ip'

				null

			null

		addNewIP : () ->

			instance_uid = this.get 'get_uid'

			$.each MC.canvas_data.component, ( key, val ) ->

				if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == instance_uid and val.resource.Attachment.DeviceIndex == '0'

					ip_detail = {
						"Association" : {
								"AssociationID": ""
								"PublicDnsName": ""
								"AllocationID": ""
								"InstanceId": ""
								"IpOwnerId": ""
								"PublicIp": ""
							}
						"PrivateIpAddress": "10.0.0.1"
						"AutoAssign": "false"
						"Primary": "false"
					}
					val.resource.PrivateIpAddressSet.push ip_detail

					return false

		removeIP : ( index ) ->

			instance_uid = this.get 'get_uid'

			$.each MC.canvas_data.component, ( key, val ) ->

				if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == instance_uid and val.resource.Attachment.DeviceIndex == '0'

					ip_ref = '@' + val.uid + '.resource.PrivateIpAddressSet.' + index + '.PrivateIpAddress'

					eni_ref = '@' + val.uid + '.resource.NetworkInterfaceId'

					max_index = val.resource.PrivateIpAddressSet.length - 1

					modify_index_refs = []

					min_index = index + 1

					$.each [min_index..max_index], ( i, index_value ) ->

						modify_index_refs.push '@' + val.uid + '.resource.PrivateIpAddressSet.' + index_value + '.PrivateIpAddress'

					val.resource.PrivateIpAddressSet.splice index, 1

					remove_uid = null

					$.each MC.canvas_data.component, ( k, v ) ->

						if v.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and v.resource.NetworkInterfaceId == eni_ref

							if v.resource.PrivateIpAddress in modify_index_refs

								v.resource.PrivateIpAddress = '@' + val.uid + '.resource.PrivateIpAddressSet.' + (parseInt(v.resource.PrivateIpAddress.split('.')[3],10)-1) + '.PrivateIpAddress'

							if v.resource.PrivateIpAddress == ip_ref

								remove_uid = v.uid

							null


					delete MC.canvas_data.component[remove_uid]

					return false


			# instanceUID = this.get 'get_uid'

			# originSGAry = MC.canvas_data.component[instanceUID].resource.SecurityGroup
			# originSGIdAry = MC.canvas_data.component[instanceUID].resource.SecurityGroupId

			# currentSG = '@' + sg_uid + '.resource.GroupName'
			# currentSGId = '@' + sg_uid + '.resource.GroupId'

			# originSGAry = _.filter originSGAry, (value) ->
			# 	value isnt currentSG

			# originSGIdAry = _.filter originSGIdAry, (value) ->
			# 	value isnt currentSGId

			# MC.canvas_data.component[instanceUID].resource.SecurityGroup = originSGAry
			# MC.canvas_data.component[instanceUID].resource.SecurityGroupId = originSGIdAry

			null

		unAssignSGToComp : (sg_uid) ->

			instanceUID = this.get 'get_uid'

			originSGAry = MC.canvas_data.component[instanceUID].resource.SecurityGroup
			originSGIdAry = MC.canvas_data.component[instanceUID].resource.SecurityGroupId

			currentSG = '@' + sg_uid + '.resource.GroupName'
			currentSGId = '@' + sg_uid + '.resource.GroupId'

			originSGAry = _.filter originSGAry, (value) ->
				value isnt currentSG

			originSGIdAry = _.filter originSGIdAry, (value) ->
				value isnt currentSGId

			MC.canvas_data.component[instanceUID].resource.SecurityGroup = originSGAry
			MC.canvas_data.component[instanceUID].resource.SecurityGroupId = originSGIdAry

			# remove from eni sg
			if !MC.canvas_data.component[instanceUID].resource.VpcId then return

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

			instanceUID = this.get 'get_uid'

			originSGAry = MC.canvas_data.component[instanceUID].resource.SecurityGroup
			originSGIdAry = MC.canvas_data.component[instanceUID].resource.SecurityGroupId

			currentSG = '@' + sg_uid + '.resource.GroupName'
			currentSGId = '@' + sg_uid + '.resource.GroupId'

			if !Boolean(currentSG in originSGAry)
				originSGAry.push currentSG

			if !Boolean(currentSGId in originSGIdAry)
				originSGIdAry.push currentSGId

			MC.canvas_data.component[instanceUID].resource.SecurityGroup = originSGAry
			MC.canvas_data.component[instanceUID].resource.SecurityGroupId = originSGIdAry

			# add to eni sg
			if !MC.canvas_data.component[instanceUID].resource.VpcId then return

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

		getCheckBox : () ->

			uid = this.get 'get_uid'

			checkbox = {}

			checkbox.ebsOptimized = true if MC.canvas_data.component[ uid ].resource.EbsOptimized == true or MC.canvas_data.component[ uid ].resource.EbsOptimized == 'true'

			checkbox.monitoring = true if MC.canvas_data.component[ uid ].resource.Monitoring == 'enabled'

			checkbox.base64Encoded = true if MC.canvas_data.component[ uid ].resource.UserData.Base64Encoded == true or MC.canvas_data.component[ uid ].resource.UserData.Base64Encoded == "true"

			checkbox.tenancy = true if MC.canvas_data.component[ uid ].resource.Placement.Tenancy == 'default' or MC.canvas_data.component[ uid ].resource.Placement.Tenancy == ''

			this.set 'checkbox_display', checkbox

		getEni : () ->

			uid = this.get 'get_uid'
			instanceUID = uid

			defaultVPCId = MC.aws.aws.checkDefaultVPC()
			if !MC.canvas_data.component[uid].resource.SubnetId and !defaultVPCId
				return

			eni_detail = {}

			eni_detail.eni_ips = []

			eni_count = 0

			subnetCIDR = ''
			if defaultVPCId
				subnetObj = MC.aws.vpc.getSubnetForDefaultVPC(instanceUID)
				subnetCIDR = subnetObj.cidrBlock
			else
				subnetUID = MC.canvas_data.component[uid].resource.SubnetId.split('.')[0][1...]
				subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

			prefixSuffixAry = MC.aws.subnet.genCIDRPrefixSuffix(subnetCIDR)

			_.map MC.canvas_data.component, ( val, key ) ->

				if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid and val.resource.Attachment.DeviceIndex == '0'

					eni_detail.description = val.resource.Description

					if val.resource.AssociatePublicIpAddress

						eni_detail.asso_public_ip = val.resource.AssociatePublicIpAddress
					else
						eni_detail.asso_public_ip = false

					eni_detail.sourceCheck = true if val.resource.SourceDestCheck == 'true' or val.resource.SourceDestCheck == true

					eni_detail.eni_ips = $.extend true, {}, val.resource.PrivateIpAddressSet

					$.each eni_detail.eni_ips, ( idx, ip_detail) ->

						ip_ref = '@' + val.uid + '.resource.PrivateIpAddressSet.' + idx + '.PrivateIpAddress'

						ip_detail.prefix = prefixSuffixAry[0]

						if ip_detail.AutoAssign is true or ip_detail.AutoAssign is 'true'
							ip_detail.suffix = prefixSuffixAry[1]
						else
							# subnetComp = MC.aws.eni.getSubnetComp(uid)
							# subnetCIDR = subnetComp.resource.CidrBlock
							ipAddress = ip_detail.PrivateIpAddress
							fixPrefixSuffixAry = MC.aws.eni.getENIDivIPAry(subnetCIDR, ipAddress)
							ip_detail.suffix = fixPrefixSuffixAry[1]

						$.each MC.canvas_data.component, ( comp_uid, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.PrivateIpAddress == ip_ref

								ip_detail.has_eip = true

								return false
						eni_count += 1
						null
				else if val.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and (val.resource.Attachment.InstanceId.split ".")[0][1...] == uid

					eni_count += 1

				null

			if eni_count > 1

				eni_detail.multi_enis = true

			else
				eni_detail.multi_enis = false

			this.set 'eni_display', eni_detail

		getComponent : () ->

			this.set 'component', MC.canvas_data.component[ this.get( 'get_uid') ]

		getAmi : () ->

			uid = this.get 'get_uid'

			ami_id = MC.canvas_data.component[ uid ].resource.ImageId

			this.set 'instance_ami_property', JSON.stringify(MC.data.dict_ami[ami_id])

		getAmiDisp : () ->

			uid = this.get 'get_uid'

			disp = {}

			ami_id = MC.canvas_data.component[ uid ].resource.ImageId

			disp.name = MC.data.dict_ami[ami_id].name

			disp.icon = MC.data.dict_ami[ami_id].osType + '.' + MC.data.dict_ami[ami_id].architecture + '.' + MC.data.dict_ami[ami_id].rootDeviceType + ".png"

			this.set 'instance_ami', disp

		getKeyPair : ()->

			uid = this.get 'get_uid'
			keypair_id = MC.extractID MC.canvas_data.component[ uid ].resource.KeyName

			kp_list = MC.aws.kp.getList( keypair_id )

			this.set 'keypair', kp_list

			null

		addKP : ( kp_name ) ->

			result = MC.aws.kp.add kp_name

			if not result
				return result

			uid = @get 'get_uid'
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

			uid = this.get 'get_uid'
			MC.canvas_data.component[ uid ].resource.KeyName = "@#{MC.canvas_property.kp_list[key_name]}.resource.KeyName"

			null


		getInstanceType : () ->

			uid = this.get 'get_uid'

			ami_info = MC.canvas_data.layout.component.node[ uid ]

			current_instance_type = MC.canvas_data.component[ uid ].resource.InstanceType

			view_instance_type = []
			instance_types = this._getInstanceType ami_info
			_.map instance_types, ( value )->
				tmp = {}

				if current_instance_type == value
					tmp.selected = true
				tmp.main = constant.INSTANCE_TYPE[value][0]
				tmp.ecu  = constant.INSTANCE_TYPE[value][1]
				tmp.core = constant.INSTANCE_TYPE[value][2]
				tmp.mem  = constant.INSTANCE_TYPE[value][3]
				tmp.name = value
				view_instance_type.push tmp

			this.set 'instance_type', view_instance_type

		_getInstanceType : ( ami ) ->
			instance_type = MC.data.instance_type[MC.canvas_data.region]
			if ami.virtualizationType == 'hvm'
				instance_type = instance_type.windows
			else
				instance_type = instance_type.linux
			if ami.rootDeviceType == 'ebs'
				instance_type = instance_type.ebs
			else
				instance_type = instance_type['instance store']
			if ami.architecture == 'x86_64'
				instance_type = instance_type["64"]
			else
				instance_type = instance_type["32"]
			instance_type = instance_type[ami.virtualizationType]

			instance_type

		attachEIP : ( eip_index, attach ) ->

			instance_uid = this.get 'get_uid'

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

		removeSG : () ->

			uid = this.get 'get_uid'

			sg_uid = this.get 'remove_sg'

			sg_id_ref = "@"+sg_uid+'.resource.GroupId'

			if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

				sg_ids = MC.canvas_data.component[ uid ].resource.SecurityGroupId

				if sg_ids.length != 1

					sg_ids.splice sg_ids.indexOf sg_id_ref, 1

					$.each MC.canvas_property.sg_list, ( key, value ) ->

						if value.uid == sg_uid

							index = value.member.indexOf uid

							value.member.splice index, 1

							# delete member 0 sg

							if value.member.length == 0 and value.name != 'DefaultSG'

								MC.canvas_property.sg_list.splice key, 1

								delete MC.canvas_data.component[sg_uid]

								$.each MC.canvas_data.component, ( key, comp ) ->

									if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

										$.each comp.resource.IpPermissions, ( i, rule ) ->

											if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

												MC.canvas_data.component[key].resource.IpPermissions.splice i, 1

										$.each comp.resource.IpPermissionsEgress, ( i, rule ) ->

											if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

												MC.canvas_data.component[key].resource.IpPermissionsEgress.splice i, 1

							return false

			else

				$.each MC.canvas_data.component, ( key, comp ) ->

					if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == uid and comp.resource.Attachment.DeviceIndex == '0'

						if comp.GroupId.length != 1

							$.each comp.GroupId, ( index, group) ->

								if group.GroupId == sg_id_ref

									comp.GroupId.splice index, 1

									return false

							$.each MC.canvas_property.sg_list, ( idx, value ) ->

								if value.uid == sg_uid

									index = value.member.indexOf uid

									value.member.splice index, 1

									# delete member 0 sg

									if value.member.length == 0 and value.name != 'DefaultSG'

										MC.canvas_property.sg_list.splice idx, 1

										delete MC.canvas_data.component[sg_uid]

										$.each MC.canvas_data.component, ( key, comp ) ->

											if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

												$.each comp.resource.IpPermissions, ( i, rule ) ->

													if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

														MC.canvas_data.component[key].resource.IpPermissions.splice i, 1

												$.each comp.resource.IpPermissionsEgress, ( i, rule ) ->

													if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg_uid

														MC.canvas_data.component[key].resource.IpPermissionsEgress.splice i, 1
						return false

			null

		# getSgDisp : () ->

		#     uid = this.get 'get_uid'

		#     instance_sg = {}

		#     instance_sg.detail = []

		#     instance_sg.all_sg = []

		#     instance_sg.rules_detail_ingress = []

		#     instance_sg.rules_detail_egress = []

		#     sg_ids = null

		#     if MC.canvas_data.platform != MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

		#         $.each MC.canvas_data.component, ( key, comp ) ->

		#             if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == uid and comp.resource.Attachment.DeviceIndex == '0'

		#                 sg_ids = (g.GroupId for g in MC.canvas_data.component[ comp.uid ].resource.GroupSet)

		#                 return false
		#     else
		#         sg_ids = MC.canvas_data.component[ uid ].resource.SecurityGroupId

		#     sg_id_no_ref = []

		#     _.map sg_ids, ( sg_id ) ->

		#         sg_uid = (sg_id.split ".")[0][1...]

		#         sg_id_no_ref.push sg_uid

		#         _.map MC.canvas_property.sg_list, ( value, key ) ->

		#             if value.uid == sg_uid

		#                 sg_detail = {}

		#                 sg_detail.uid = sg_uid

		#                 sg_detail.parent = uid

		#                 sg_detail.members = value.member.length

		#                 sg_detail.rules = MC.canvas_data.component[sg_uid].resource.IpPermissions.length + MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress.length

		#                 sg_detail.name = MC.canvas_data.component[sg_uid].resource.GroupName

		#                 sg_detail.desc = MC.canvas_data.component[sg_uid].resource.GroupDescription

		#                 instance_sg.rules_detail_ingress = instance_sg.rules_detail_ingress.concat MC.canvas_data.component[sg_uid].resource.IpPermissions

		#                 instance_sg.rules_detail_egress = instance_sg.rules_detail_egress.concat MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress

		#                 instance_sg.detail.push sg_detail

		#     _.map MC.canvas_property.sg_list, (sg) ->

		#         if sg.uid not in sg_id_no_ref

		#             tmp = {}

		#             tmp.name = sg.name

		#             tmp.uid = sg.uid

		#             instance_sg.all_sg.push tmp

		#     instance_sg.total = instance_sg.detail.length

		#     array_unique = ( origin_ary )->

		#         if origin_ary.length == 0

		#             return []

		#         ary = origin_ary.slice 0


		#         $.each ary, (idx, value)->

		#             ary[idx] = JSON.stringify value

		#             null

		#         ary.sort()

		#         tmp = [ary[0]]

		#         _.map ary, ( val, i ) ->

		#             if val != tmp[tmp.length - 1]

		#                 tmp.push(val)



		#         return (JSON.parse node for node in tmp)


		#     instance_sg.rules_detail_ingress = array_unique instance_sg.rules_detail_ingress
		#     instance_sg.rules_detail_egress = array_unique instance_sg.rules_detail_egress

		#     this.set 'sg_display', instance_sg

		getSGList : () ->

			uid = this.get 'get_uid'
			sgAry = MC.canvas_data.component[uid].resource.SecurityGroupId

			sgUIDAry = []
			_.each sgAry, (value) ->
				sgUID = value.slice(1).split('.')[0]
				sgUIDAry.push sgUID
				null

			return sgUIDAry

		setIPList : (inputIPAry) ->

			# find eni0
			eniUID = ''
			currentInstanceUID = this.get 'get_uid'
			currentInstanceUIDRef = '@' + currentInstanceUID + '.resource.InstanceId'
			allComp = MC.canvas_data.component
			_.each allComp, (compObj) ->
				if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
					instanceUIDRef = compObj.resource.Attachment.InstanceId
					deviceIndex = compObj.resource.Attachment.DeviceIndex
					if (currentInstanceUIDRef is instanceUIDRef) and (deviceIndex is '0')
						eniUID = compObj.uid
				null

			if eniUID
				realIPAry = MC.aws.eni.generateIPList eniUID, inputIPAry
				MC.aws.eni.saveIPList eniUID, realIPAry
	}

	model = new InstanceModel()

	return model
