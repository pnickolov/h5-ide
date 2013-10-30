#############################
#  View Mode for design/property/eni
#############################

define [ '../base/model', 'constant', 'i18n!nls/lang.js'  ], ( PropertyModel, constant, lang ) ->

	ENIModel = PropertyModel.extend {

		defaults :
			'uid'       : null
			'isAppEdit' : false

		init : ( uid ) ->

			component = MC.canvas_data.component[ uid ]

			data = {
				uid  : uid
				name : component.name
				ips  : []
				desc : component.resource.Description
				sourceDestCheck : "" + component.resource.SourceDestCheck is "true"
				isAppEdit : @isAppEdit
			}

			if component.resource.Attachment and component.resource.Attachment.InstanceId.length
				data.attached = true

				instance_component = MC.canvas_data.component[ MC.extractID component.resource.Attachment.InstanceId ]

				ip_customizable = parseInt(instance_component.number, 10) is 1

			# Get Ip List
			defaultVPCId = MC.aws.aws.checkDefaultVPC()
			if defaultVPCId
				subnetObj  = MC.aws.vpc.getSubnetForDefaultVPC(uid)
				subnetCIDR = subnetObj.cidrBlock
			else
				subnetUID  = MC.extractID component.resource.SubnetId
				subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

			prefixSuffixAry = MC.aws.subnet.genCIDRPrefixSuffix(subnetCIDR)

			checkEIPMap = {}
			for ip, idx in component.resource.PrivateIpAddressSet
				ip_view = {
					prefix       : prefixSuffixAry[0]
					customizable : ip_customizable
					deletable    : "" + ip.Primary isnt "true"
					eip          : false
				}

				if "" + ip.AutoAssign is "true"
					ip_view.suffix = prefixSuffixAry[1]
				else
					ip_view.suffix = MC.aws.eni.getENIDivIPAry(subnetCIDR, ip.PrivateIpAddress)[1]

				ip_view.ip = ip_view.prefix + ip_view.suffix

				checkEIPMap[ "@#{uid}.resource.PrivateIpAddressSet.#{idx}.PrivateIpAddress" ] = ip_view
				data.ips.push ip_view

			for comp_uid, comp of MC.canvas_data.component
				if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.PrivateIpAddress
						ip = checkEIPMap[ comp.resource.PrivateIpAddress ]
						if ip
							ip.eip = true

			@set data
			null

		setEniDesc : ( value ) ->
			uid = @get 'uid'
			MC.canvas_data.component[uid].resource.Description = value

			null

		setSourceDestCheck : ( value ) ->
			uid = @get 'uid'
			MC.canvas_data.component[uid].resource.SourceDestCheck = value

			null

		getSGList : () ->

			uid = this.get 'uid'
			sgAry = MC.canvas_data.component[uid].resource.GroupSet

			sgUIDAry = []
			_.each sgAry, (value) ->
				sgUID = value.GroupId.slice(1).split('.')[0]
				sgUIDAry.push sgUID
				null

			return sgUIDAry

		unAssignSGToComp : (sg_uid) ->

			eniUID = this.get 'uid'

			originSGAry = MC.canvas_data.component[eniUID].resource.GroupSet

			currentSG = '@' + sg_uid + '.resource.GroupName'
			currentSGId = '@' + sg_uid + '.resource.GroupId'

			originSGAry = _.filter originSGAry, (value) ->
				value.GroupId isnt currentSGId

			MC.canvas_data.component[eniUID].resource.GroupSet = originSGAry

			null

		assignSGToComp : (sg_uid) ->

			eniUID = this.get 'uid'

			originSGAry = MC.canvas_data.component[eniUID].resource.GroupSet

			currentSG = '@' + sg_uid + '.resource.GroupName'
			currentSGId = '@' + sg_uid + '.resource.GroupId'

			isInGroup = false

			_.each originSGAry, (value) ->
				if value.GroupId is currentSGId
					isInGroup = true
				null

			if !isInGroup
				originSGAry.push {
					GroupName: currentSG
					GroupId: currentSGId
				}

			MC.canvas_data.component[eniUID].resource.GroupSet = originSGAry

			null

		addIP : () ->
			uid  = @get 'uid'
			comp = MC.canvas_data.component[ uid ]

			# Return a newly created IP object to view, so that it can render it
			defaultVPCId = MC.aws.aws.checkDefaultVPC()
			subnetCIDR   = ''

			if defaultVPCId
				subnetObj  = MC.aws.vpc.getSubnetForDefaultVPC( uid )
				subnetCIDR = subnetObj.cidrBlock
			else
				subnetUID  = MC.extractID comp.resource.SubnetId
				subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

			prefixSuffixAry = MC.aws.subnet.genCIDRPrefixSuffix( subnetCIDR )

			ip_customizable = true
			if comp.resource.Attachment and comp.resource.Attachment.InstanceId.length
				instance = MC.canvas_data.component[ MC.extractID comp.resource.Attachment.InstanceId ]

				ip_customizable = parseInt(instance.number, 10) is 1

			newIP =
				customizable : ip_customizable
				prefix       : prefixSuffixAry[0]
				suffix       : "x"
				deletable    : true
				ip           : prefixSuffixAry[0] + "x"
				eip          : false

			@attributes.ips.push newIP

			# Re-generate IP for ENI component
			realIPAry = MC.aws.eni.generateIPList uid, @attributes.ips
			MC.aws.eni.saveIPList uid, realIPAry

			# Return newly created IP to view to render
			newIP

		attachEIP : ( eip_index, attach ) ->

			eni_uid = @get 'uid'

			# Update eip state in model data
			@attributes.ips[ eip_index ].eip = attach


			# Update component
			if attach

				eip_component = $.extend true, {}, MC.canvas.EIP_JSON.data

				eip_uid = MC.guid()

				eip_component.uid = eip_uid

				eip_component.resource.PrivateIpAddress = '@' + eni_uid + '.resource.PrivateIpAddressSet.' + eip_index + '.PrivateIpAddress'

				eip_component.resource.NetworkInterfaceId = '@' +  eni_uid + '.resource.NetworkInterfaceId'

				eip_component.resource.Domain = 'vpc'

				data = MC.canvas.data.get('component')

				data[eip_uid] = eip_component

				MC.canvas.data.set('component', data)

				MC.canvas.update eni_uid,'image','eip_status', MC.canvas.IMAGE.EIP_ON

			else

				ip_ref = '@' + eni_uid + '.resource.PrivateIpAddressSet.' + eip_index + '.PrivateIpAddress'

				$.each MC.canvas_data.component, ( comp_uid, comp ) ->

					if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.PrivateIpAddress == ip_ref

						delete MC.canvas_data.component[comp_uid]

						#determine whether all eip are detach

						existing = false

						$.each MC.canvas_data.component, ( k, v ) ->

							if v.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and v.resource.NetworkInterfaceId == '@' +  eni_uid + '.resource.NetworkInterfaceId'

								existing = true

								return false

						if not existing

							MC.canvas.update eni_uid,'image','eip_status', MC.canvas.IMAGE.EIP_OFF

		removeIP : ( index ) ->
			uid  = @get 'uid'
			comp = MC.canvas_data.component[uid]

			# Update Model data
			@attributes.ips.splice index, 1

			# Update EIP Component
			ip_ref  = "@#{uid}.resource.PrivateIpAddressSet.#{index}.PrivateIpAddress"
			eni_ref = "@#{uid}.resource.NetworkInterfaceId"

			min_index = index + 1
			max_index = comp.resource.PrivateIpAddressSet.length - 1

			modify_index_refs = {}

			for index_value in [min_index..max_index]
				modify_index_refs["@#{uid}.resource.PrivateIpAddressSet.#{index_value}.PrivateIpAddress"] = true

			comp.resource.PrivateIpAddressSet.splice index, 1
			remove_uid = null

			for u, c of MC.canvas_data.component
				if c.type isnt constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
					continue
				if c.resource.NetworkInterfaceId isnt eni_ref
					continue

				if modify_index_refs[ c.resource.PrivateIpAddress ]
					idx = parseInt(c.resource.PrivateIpAddress.split('.')[3],10)-1
					c.resource.PrivateIpAddress = "@#{uid}.resource.PrivateIpAddressSet.#{idx}.PrivateIpAddress"
				else if c.resource.PrivateIpAddress is ip_ref
					remove_uid = u

			delete MC.canvas_data.component[remove_uid]

			# Re-generate IP for ENI component
			realIPAry = MC.aws.eni.generateIPList uid, @attributes.ips
			MC.aws.eni.saveIPList uid, realIPAry
			null

		canAddIP : ()->
			uid  = @get 'uid'
			comp = MC.canvas_data.component[ uid ]

			maxIPNum  = MC.aws.eni.getENIMaxIPNum(uid)
			currIPNum = comp.resource.PrivateIpAddressSet.length
			if currIPNum < maxIPNum
				return true

			instanceUid = MC.extractID comp.resource.Attachment.InstanceId
			if instanceUid
				instanceType = MC.canvas_data.component[ instanceUid ].resource.InstanceType
				error = sprintf(lang.ide.PROP_MSG_WARN_ENI_IP_EXTEND, instanceType, maxIPNum)
				return error

			return false

		setIPList : (inputIPAry) ->

			eniUID = this.get 'uid'

			# Update data in model
			for ip, idx in inputIPAry
				model_ip = @attributes.ips[ idx ]

				model_ip.ip     = ip.ip
				model_ip.eip    = ip.eip
				model_ip.suffix = ip.suffix

			# Update data in component
			realIPAry = MC.aws.eni.generateIPList eniUID, inputIPAry
			MC.aws.eni.saveIPList eniUID, realIPAry

	}

	new ENIModel()
