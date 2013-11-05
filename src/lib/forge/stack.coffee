define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->

	#expand instance,eni and volume in server group before save
	expandServerGroup = ( canvas_data ) ->

		json_data   = $.extend( true, {}, canvas_data )

		comp_data   = json_data.component
		layout_data = json_data.layout
		res_type    = constant.AWS_RESOURCE_TYPE

		# expand instance firt
		for uid, comp of comp_data

			if comp.type is res_type.AWS_EC2_Instance and json_data.layout.component.node[ uid ]

				expandInstance json_data, uid

		if canvas_data.platform isnt MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

			for uid, comp of comp_data

				if comp.type is res_type.AWS_VPC_NetworkInterface

					expandENI json_data, uid

		for uid, comp of comp_data

			if comp.type is res_type.AWS_EBS_Volume

				expandVolume json_data, uid

			if comp.type is res_type.AWS_EC2_EIP

				expandEIP json_data, uid

		json_data


	gernerateUId = ( ins_num, instance_list ) ->

		ins_comp_number = instance_list.length

		if ins_comp_number > ins_num

			i = ins_comp_number

			while i > ins_num

				instance_list.splice (i-1), 1

				i--

		else if ins_num > ins_comp_number

			i = 0

			while i < ins_num-ins_comp_number

				new_eni_uid = MC.guid()

				instance_list.push new_eni_uid

				i++

		instance_list

	#expand an instance to a server group
	expandInstance = ( json_data, uid ) ->

		comp_data         = json_data.component
		layout_data 	  = json_data.layout
		ins_comp          = comp_data[uid]
		ins_num           = ins_comp.number
		server_group_name = ins_comp.serverGroupName
		ins_comp.name     = server_group_name + '-0'
		instance_list     = json_data.layout.component.node[ uid ].instanceList

		if instance_list.length != ins_num and instance_list > 0

			console.error '[expandInstance]instance number not match'


		# check remove eip for app edit
		if json_data.platform is MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

			if not comp_data[layout_data.component.node[uid].eipList[0]]

				for k_eip in layout_data.component.node[uid].eipList

					delete comp_data[k_eip]

				layout_data.component.node[uid].eipList = []

		else

			delete_index = []

			for eip_uid, eip_tmp_list of layout_data.component.node[uid].eipList

				if not comp_data[eip_uid]

					delete_index.push eip_uid

			for k in delete_index

				for k_eip in layout_data.component.node[uid].eipList[k]

					delete comp_data[k_eip]

				delete layout_data.component.node[uid].eipList[k]

		# check remove volume for app edit
		delete_vol_index = []

		for vol_uid, vol_tmp_list of layout_data.component.node[uid].volumeList

			if not comp_data[vol_uid]

				delete_vol_index.push vol_uid

		for k in delete_vol_index

			delete layout_data.component.node[uid].volumeList[k]

		gernerateUId ins_num, instance_list
		# ins_comp_number = instance_list.length

		# if ins_comp_number > ins_num

		# 	i = ins_comp_number

		# 	while i > ins_num

		# 		instance_list.splice (i-1), 1

		# 		i--

		# else if ins_num > ins_comp_number

		# 	i = 0

		# 	while i < ins_num-1

		# 		new_eni_uid = MC.guid()

		# 		instance_list.push new_eni_uid

		# 		i++

		# collect using elb
		instance_reference = "@#{ins_comp.uid}.resource.InstanceId"

		elbs = []

		for comp_uid, comp of MC.canvas_data.component

			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_ELB

				for instance in comp.resource.Instances

					if instance_reference is instance.InstanceId

						elbs.push comp_uid

		if ins_num

			for instance_uid, instance of comp_data

				if instance.type is 'AWS.EC2.Instance' and instance_uid in MC.canvas_data.layout.component.node[uid].instanceList and instance_uid not in instance_list

					delete comp_data[instance.uid]

					for elb in elbs

						delete_index = []

						for i, ins of json_data.component[elb].resource.Instances

							if ins.InstanceId is "@#{instance_uid}.resource.InstanceId"

								delete_index.push i

						delete_index.sort()

						delete_index.reverse()

						for i in delete_index

							json_data.component[elb].resource.Instances.splice i, 1

			for i, instance_id of instance_list

				if comp_data[ instance_id ]

					for k, v of ins_comp.resource

						if k isnt "InstanceId"

							comp_data[ instance_id ].resource[k] = v


				else

					new_comp = $.extend( true, {}, ins_comp )

					#generate uid
					new_comp.uid = instance_id

					#generate name
					new_comp.name = server_group_name + '-' + i

					#index in server group
					new_comp.index = parseInt(i, 10)

					new_comp.resource.InstanceId = ""

					new_comp.resource.PrivateIpAddress = ""

					comp_data[ new_comp.uid ] = new_comp

					if elbs.length > 0 and new_comp.uid isnt uid

						for elb in elbs

							json_data.component[elb].resource.Instances.push {"InstanceId": "@#{new_comp.uid}.resource.InstanceId"}

		else

			#error
			console.error '[expandInstance] can not found number of instance'


		json_data.layout.component.node[ uid ].instanceList = instance_list

		null

	#expand an eni to a server group
	expandENI = ( json_data, uid ) ->

		comp_data   = json_data.component

		layout_data = json_data.layout

		instance_uid = json_data.component[uid].resource.Attachment.InstanceId

		if not json_data.layout.component.node[ instance_uid.split('.')[0][1...] ]

			return

		instance_uid = if instance_uid then instance_uid.split('.')[0][1...] else null

		if not instance_uid

			console.error "Eni(#{uid}) do not attach to any instance"

		server_group_name = json_data.component[instance_uid].serverGroupName

		eni_name = json_data.component[ uid ].name

		instance_list = json_data.layout.component.node[ instance_uid ].instanceList

		eni_number = json_data.component[instance_uid].number

		if comp_data[ uid ].resource.Attachment.DeviceIndex in [0,'0']

			eni_list = json_data.layout.component.node[instance_uid].eniList

			if eni_list.length is 0

				eni_list = json_data.layout.component.node[instance_uid].eniList = [ uid ]

		else
			eni_list = json_data.layout.component.node[ uid ].eniList

			if eni_list.length is 0

				eni_list = json_data.layout.component.node[uid].eniList = [ uid ]

			# app edit check remove eip

			delete_index = []

			for eip_uid, eip_tmp_list of layout_data.component.node[uid].eipList

				if not comp_data[eip_uid]

					delete_index.push eip_uid

			for k in delete_index

				for k_eip in layout_data.component.node[uid].eipList[k]

					delete comp_data[k_eip]

				delete layout_data.component.node[uid].eipList[k]

		gernerateUId eni_number, eni_list
		# eni_comp_number = eni_list.length

		# if eni_comp_number > eni_number

		# 	i = eni_comp_number

		# 	while i > eni_number

		# 		eni_list.splice (i-1), 1

		# 		i--

		# else if eni_number > eni_comp_number

		# 	i = 0

		# 	while i < eni_number-1

		# 		new_eni_uid = MC.guid()

		# 		eni_list.push new_eni_uid

		# 		i++
		for e_uid, eni of comp_data

			if eni.type is 'AWS.VPC.NetworkInterface'

				tmp_eni_list = if MC.canvas_data.layout.component.node[uid] then MC.canvas_data.layout.component.node[uid].eniList else MC.canvas_data.layout.component.node[instance_uid].eniList

				if e_uid in tmp_eni_list and e_uid not in eni_list

					delete comp_data[eni.uid]

		$.each eni_list, ( idx, eni_uid ) ->

			if not json_data.component[eni_uid]

				origin_eni = $.extend true, {}, json_data.component[uid]

				origin_eni.uid = eni_uid

				origin_eni.index = idx

				origin_eni.number = eni_number

				origin_eni.serverGroupENIName = eni_name

				origin_eni.resource.NetworkInterfaceId = ""

				if eni_name.indexOf("#{server_group_name}-0") >= 0

					origin_eni.name = eni_name.replace "#{server_group_name}-0", "#{server_group_name}-#{idx}"

				else
					origin_eni.name = if eni_name.indexOf("#{server_group_name}-#{idx}")<0 then "#{server_group_name}-#{idx}-#{eni_name}" else eni_name


				for k, v of origin_eni.resource.PrivateIpAddressSet

					v.AutoAssign = true

				attach_instance = "@#{instance_list[idx]}.resource.InstanceId"

				origin_eni.resource.Attachment.InstanceId = attach_instance

				origin_eni.resource.Attachment.AttachmentId = ""

				comp_data[eni_uid] = origin_eni
			else

				for k, v of json_data.component[uid].resource

					if k isnt "NetworkInterfaceId" and k isnt "Attachment" and k isnt "PrivateIpAddressSet"

						comp_data[ eni_uid ].resource[k] = v

					if k is "PrivateIpAddressSet"

						ipset = $.extend true, [], v

						for i, j of ipset

							if j.AutoAssign in [false, 'false']

								ipset[i].PrivateIpAddress = comp_data[ eni_uid ].resource.PrivateIpAddressSet[i].PrivateIpAddress

						comp_data[ eni_uid ].resource[k] = ipset


				json_data.component[eni_uid].name = if json_data.component[eni_uid].name.indexOf("#{server_group_name}-#{idx}")<0  then "#{server_group_name}-#{idx}-#{eni_name}" else json_data.component[eni_uid].name

				json_data.component[eni_uid].number = eni_number

		# stage canvas comps
		temp_comps = $.extend( true, {}, MC.canvas_data.component )
		MC.canvas_data.component = comp_data

		# generate eni ip
		if MC.canvas_data.platform is MC.canvas.PLATFORM_TYPE.DEFAULT_VPC
			azUID = if layout_data.component.node[ uid ] then layout_data.component.node[ uid ].groupUId else layout_data.component.node[ MC.canvas_data.component[ uid ].resource.Attachment.InstanceId.split('.')[0].slice(1) ].groupUId
			azName = MC.canvas_data.layout.component.group[azUID].name
			if MC.canvas.getState() is 'appedit'
				MC.aws.subnet.updateAllENIIPList(azName, true)
			else
				MC.aws.subnet.updateAllENIIPList(azName, false)
		else
			if MC.canvas.getState() is 'appedit'
				MC.aws.subnet.updateAllENIIPList(comp_data[uid].resource.SubnetId.split('.')[0].slice(1), true)
			else
				MC.aws.subnet.updateAllENIIPList(comp_data[uid].resource.SubnetId.split('.')[0].slice(1), false)


		# restore canvas comps
		comp_data = $.extend( true, {}, MC.canvas_data.component )
		MC.canvas_data.component = temp_comps

		#return
		null

	#expand a volume to a server group
	expandVolume = ( json_data, uid ) ->

		comp_data   = json_data.component

		layout_data = json_data.layout

		instance_uid = json_data.component[uid].resource.AttachmentSet.InstanceId

		instance_uid = if instance_uid then instance_uid.split('.')[0][1...] else null

		if not json_data.layout.component.node[ instance_uid ]

			return

		if not instance_uid

			console.error "Volume(#{uid}) do not attach to any instance"

		server_group_name = json_data.component[instance_uid].serverGroupName

		instance_list = json_data.layout.component.node[ instance_uid ].instanceList

		vol_number = json_data.component[instance_uid].number


		vol_list = json_data.layout.component.node[ instance_uid ].volumeList[ uid ]

		if not vol_list

			vol_list = json_data.layout.component.node[ instance_uid ].volumeList[ uid ] = [ uid ]

		gernerateUId vol_number, vol_list
		# vol_comp_number = vol_list.length

		# if vol_comp_number > vol_number

		# 	i = vol_comp_number

		# 	while i > vol_number

		# 		vol_list.splice (i-1), 1

		# 		i--

		# else if vol_number > vol_comp_number

		# 	i = 0

		# 	while i < vol_number-1

		# 		new_vol_uid = MC.guid()

		# 		vol_list.push new_vol_uid

		# 		i++

		for v_uid, volume of comp_data

			if volume.type is 'AWS.EC2.EBS.Volume'

				v_list = MC.canvas_data.layout.component.node[ instance_uid ].volumeList[ uid ]

				if not v_list

					v_list = []
					#v_list =  [ uid ]

				if v_uid in v_list and v_uid not in vol_list

					delete comp_data[volume.uid]

		$.each vol_list, ( idx, vol_uid ) ->

			if not json_data.component[vol_uid]

				origin_eni = $.extend true, {}, json_data.component[uid]

				origin_eni.uid = vol_uid

				origin_eni.index = idx

				origin_eni.number = vol_number

				origin_eni.resource.VolumeId = ""

				if origin_eni.name.indexOf("#{server_group_name}-0") >= 0

					origin_eni.name = origin_eni.name.replace "#{server_group_name}-0", "#{server_group_name}-#{idx}"
				else

					origin_eni.name = if "#{server_group_name}-#{idx}" not in origin_eni.name then "#{server_group_name}-#{idx}-#{origin_eni.serverGroupName}" else origin_eni.name

				attach_instance = "@#{instance_list[idx]}.resource.InstanceId"

				origin_eni.resource.AttachmentSet.InstanceId = attach_instance

				origin_eni.resource.AttachmentSet.VolumeId = "@#{vol_uid}.resource.VolumeId"

				comp_data[vol_uid] = origin_eni
			else

				json_data.component[vol_uid].name = if "#{server_group_name}" not in json_data.component[vol_uid].name then "#{server_group_name}-#{idx}-#{json_data.component[vol_uid].serverGroupName}" else json_data.component[vol_uid].name

				json_data.component[vol_uid].number = vol_number

				json_data.component[vol_uid].resource.AttachmentSet.VolumeId = "@#{vol_uid}.resource.VolumeId"


		#return
		null


	#expand a eip to a server group
	expandEIP = ( json_data, uid ) ->

		comp_data   = json_data.component

		layout_data = json_data.layout

		instance_uid = json_data.component[uid].resource.InstanceId

		instance_uid = if instance_uid then instance_uid.split('.')[0][1...] else null

		eni_uid 	 = json_data.component[uid].resource.NetworkInterfaceId

		eni_uid 	 = if eni_uid then eni_uid.split('.')[0][1...] else null

		eip_number 	 = 0

		eip_comp_number = 0

		eip_list = []

		ref_list = []

		instance_list = []

		eni_list = []

		if not eni_uid

			if not json_data.layout.component.node[ instance_uid ]

				return

			instance_list = json_data.layout.component.node[ instance_uid ].instanceList

			eip_number = json_data.component[instance_uid].number

			eip_list = json_data.layout.component.node[ instance_uid ].eipList

			if eip_list.length is 0

				eip_list = json_data.layout.component.node[ instance_uid ].eipList = [ uid ]

			eip_comp_number = eip_list.length

		else

			if not json_data.layout.component.node[ eni_uid ] and not json_data.layout.component.node[json_data.component[eni_uid].resource.Attachment.InstanceId.split('.')[0].slice(1)]

				return

			eni_list = if json_data.layout.component.node[ eni_uid ] then json_data.layout.component.node[ eni_uid ].eniList else json_data.layout.component.node[json_data.component[eni_uid].resource.Attachment.InstanceId.split('.')[0].slice(1)].eniList

			eip_number = json_data.component[json_data.component[eni_uid].resource.Attachment.InstanceId.split('.')[0].slice(1)].number

			eip_list = if json_data.layout.component.node[ eni_uid ] then json_data.layout.component.node[ eni_uid ].eipList[ uid ] else json_data.layout.component.node[json_data.component[eni_uid].resource.Attachment.InstanceId.split('.')[0].slice(1)].eipList[ uid ]

			if (eip_list and eip_list.length is 0) or not eip_list

				eip_list =  [ uid ]


			eip_comp_number = eip_list.length

		gernerateUId eip_number, eip_list
		# if eip_comp_number > eip_number

		# 	i = eip_comp_number

		# 	while i > eip_number

		# 		eip_list.splice (i-1), 1

		# 		i--

		# else if eip_number > eip_comp_number

		# 	i = 0

		# 	while i < eip_number-1

		# 		new_eip_uid = MC.guid()

		# 		eip_list.push new_eip_uid

		# 		i++

		if json_data.layout.component.node[ eni_uid ]

			json_data.layout.component.node[ eni_uid ].eipList[ uid ] = eip_list

		else
			if not eni_uid

				json_data.layout.component.node[instance_uid].eipList = eip_list
			else
				json_data.layout.component.node[json_data.component[eni_uid].resource.Attachment.InstanceId.split('.')[0].slice(1)].eipList[ uid ] = eip_list


		for eip_uid, eip of comp_data

			if eip.type is 'AWS.EC2.EIP'
				e_list = []
				if not eni_uid

					e_list = MC.canvas_data.layout.component.node[ instance_uid ].eipList

				else
					e_list = if MC.canvas_data.layout.component.node[ eni_uid ] then MC.canvas_data.layout.component.node[ eni_uid ].eipList[ uid ] else MC.canvas_data.layout.component.node[MC.canvas_data.component[eni_uid].resource.Attachment.InstanceId.split('.')[0].slice(1)].eipList[ uid ]

				if not e_list

					e_list = []

				#if e_list.length is 0

				#	e_list = [eip_uid]

				if eip_uid in e_list and eip_uid not in eip_list

					delete comp_data[eip_uid]

		$.each eip_list, ( idx, eip_uid ) ->

			if not json_data.component[eip_uid]

				origin_eip = $.extend true, {}, json_data.component[uid]

				origin_eip.uid = eip_uid

				origin_eip.index = idx

				origin_eip.number = eip_number

				origin_eip.resource.AllocationId = origin_eip.resource.AssociationId = origin_eip.resource.InstanceId = origin_eip.resource.NetworkInterfaceId = origin_eip.resource.PublicIp = ""

				origin_eip.resource.PublicIp = ""

				if eni_uid

					if origin_eip.resource.InstanceId

						origin_eip.resource.InstanceId = "@#{json_data.component[eni_list[idx]].resource.Attachment.InstanceId.split('.')[0].slice(1)}.resource.InstanceId"

					origin_eip.resource.NetworkInterfaceId = "@#{eni_list[idx]}.resource.NetworkInterfaceId"

					origin_eip.resource.PrivateIpAddress = origin_eip.resource.PrivateIpAddress.replace(eni_list[0], eni_list[idx])

				else

					origin_eip.resource.InstanceId = "@#{instance_list[idx]}.resource.InstanceId"

				comp_data[eip_uid] = origin_eip
			else

				json_data.component[eip_uid].index = idx
				json_data.component[eip_uid].number = eip_number


		null

	#compact instance,eni and volume in server group after load
	compactServerGroup = ( canvas_data ) ->

		json_data   = $.extend( true, {}, canvas_data )
		comp_data   = json_data.component
		layout_data = json_data.layout
		res_type    = constant.AWS_RESOURCE_TYPE

		for uid, comp of comp_data

			switch comp.type

				when res_type.AWS_EC2_Instance
					if comp.index == 0
						compactInstance json_data, uid

				#when res_type.AWS_VPC_NetworkInterface and comp.number > 1 and comp.index == 0  then compactENI json_data, uid

				#when res_type.AWS_EBS_Volume           and comp.number > 1 and comp.index == 0  then compactVolume json_data, uid

		json_data


		#expand an instance to a server group
	compactInstance = ( json_data, uid ) ->

		json_data.layout.component.node[ uid ].instanceList = if json_data.layout.component.node[ uid ].instanceList then json_data.layout.component.node[ uid ].instanceList else []
		json_data.layout.component.node[ uid ].eniList = if json_data.layout.component.node[ uid ].eniList then json_data.layout.component.node[ uid ].eniList else []
		json_data.layout.component.node[ uid ].volumeList = if json_data.layout.component.node[ uid ].volumeList then json_data.layout.component.node[ uid ].volumeList else []

		comp_data     = json_data.component
		ins_comp      = comp_data[uid]
		ins_comp.name = ins_comp.serverGroupName
		instance_list = json_data.layout.component.node[ uid ].instanceList
		eni_list 	  = json_data.layout.component.node[ uid ].eniList
		vol_list 	  = json_data.layout.component.node[ uid ].volumeList
		ins_num       = ins_comp.number


		instance_ref_list = []

		for instance_id in instance_list

			if instance_id isnt uid

				instance_ref_list.push "@#{instance_id}.resource.InstanceId"

		eni_ref_list = []

		if eni_list.length > 0

			for eni in eni_list

				if eni_list.indexOf(eni) != 0

					eni_ref_list.push "@#{eni}.resource.NetworkInterfaceId"

		for comp_uid, comp of comp_data

			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId in instance_ref_list

				eni = "@#{comp_uid}.resource.NetworkInterfaceId"

				if eni not in eni_ref_list

					eni_ref_list.push eni


		# remove eni
		for comp_uid, comp of comp_data

			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId in instance_ref_list

				delete comp_data[comp_uid]

			else if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId not in instance_ref_list
				if !comp.name || comp.name.indexOf("eni0") >=0
					comp.name = "eni0"
				else
					comp.name = comp.serverGroupName

			else if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and (comp.resource.InstanceId in instance_ref_list or comp.resource.NetworkInterfaceId in eni_ref_list)

				delete comp_data[comp_uid]

		# remove volume
		for vol_uid, vol_data of vol_list

			for comp_uid, comp of comp_data

				if comp_uid in vol_data and comp_uid isnt vol_uid

					delete comp_data[comp_uid]

		for comp_uid, comp of comp_data

			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume

				comp.name = comp.serverGroupName


		for comp_uid, comp of comp_data

			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_ELB

				remove_idx = []

				$.each comp.resource.Instances, ( i, instance ) ->

					if instance.InstanceId in instance_ref_list

						remove_idx.push i

				if remove_idx.length > 0

					$.each remove_idx.sort().reverse(), (idx, instance_ref) ->

						comp.resource.Instances.splice instance_ref, 1



		#init instance_list
		if instance_list.length != ins_num

			instance_list = [ uid ]

			i = 1
			while i < ins_num

				instance_list[ i ] = ''

				i++



		if ins_num

			i = 1
			while i < ins_num

				new_comp = $.extend( true, {}, ins_comp )

				if !instance_list[i]
					instance_list[i] = MC.guid()

				else
					comp_uid = instance_list[i]
					if comp_data[ comp_uid ]

						delete comp_data[ comp_uid ]

				i++
		else

			#error
			console.error '[compactInstance] can not found number of instance'


		null


	getAllImageId = ( json_data ) ->

		ami_list = {}

		_.each json_data.component, (compObj) ->

			if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance  or compObj.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
				imageId = compObj.resource.ImageId
				if imageId
					ami_list[imageId] = MC.data.dict_ami[imageId]
				else
					console.log '[getAllImageId]ImageId of ' + compObj.type + '(' + compObj.uid + ') is empty'
		
		#return
		ami_list


	checkStoppable = ( json_data ) ->
		#if has any instance-store ami, then stoppable is true

		stoppable = true

		ami_list = getAllImageId json_data

		_.each ami_list, (data, imageId) ->

			if data and data.rootDeviceType == 'instance-store'
				stoppable = false
				return

			null

		#set stoppable
		json_data.property.stoppable = stoppable

		null
		

	#public
	expandServerGroup  : expandServerGroup
	compactServerGroup : compactServerGroup
	getAllImageId      : getAllImageId
	checkStoppable     : checkStoppable
