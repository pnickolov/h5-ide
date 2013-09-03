define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->

	#expand instance,eni and volume in server group before save
	expandServerGroup = ( canvas_data ) ->

		json_data   = $.extend( true, {}, canvas_data )

		comp_data   = json_data.component
		layout_data = json_data.layout
		res_type    = constant.AWS_RESOURCE_TYPE

		# expand instance firt
		for uid, comp of comp_data

			if comp.type is res_type.AWS_EC2_Instance

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

			while i < ins_num-1

				new_eni_uid = MC.guid()

				instance_list.push new_eni_uid

				i++

		instance_list

	#expand an instance to a server group
	expandInstance = ( json_data, uid ) ->

		comp_data         = json_data.component
		ins_comp          = comp_data[uid]
		ins_num           = ins_comp.number
		server_group_name = ins_comp.serverGroupName
		ins_comp.name     = server_group_name + '-0'
		instance_list     = json_data.layout.component.node[ uid ].instanceList

		if instance_list.length != ins_num and instance_list > 0

			console.error '[expandInstance]instance number not match'

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

			for i, instance_id of instance_list

				new_comp = $.extend( true, {}, ins_comp )

				#generate uid
				new_comp.uid = instance_id

				#generate name
				new_comp.name = server_group_name + '-' + i

				#index in server group
				new_comp.index = parseInt(i, 10)

				comp_data[ new_comp.uid ] = new_comp

				if elbs.length > 0

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

		$.each eni_list, ( idx, eni_uid ) ->

			if not json_data.component[eni_uid]

				origin_eni = $.extend true, {}, json_data.component[uid]

				origin_eni.uid = eni_uid

				origin_eni.index = idx

				origin_eni.number = eni_number

				origin_eni.serverGroupENIName = eni_name

				origin_eni.name = if "#{server_group_name}-#{idx}" not in eni_name then "#{server_group_name}-#{idx}-#{eni_name}" else eni_name

				attach_instance = "@#{instance_list[idx]}.resource.InstanceId"

				origin_eni.resource.Attachment.InstanceId = attach_instance

				comp_data[eni_uid] = origin_eni
			else

				json_data.component[eni_uid].name = if "#{server_group_name}-#{idx}" not in json_data.component[eni_uid].name then "#{server_group_name}-#{idx}-#{eni_name}" else json_data.component[eni_uid].name

				json_data.component[eni_uid].number = eni_number


		# generate eni ip
		if MC.canvas_data.platform is MC.canvas.PLATFORM_TYPE.DEFAULT_VPC

			az = layout_data.groupUId

			MC.aws.subnet.updateAllENIIPList(az)

		else

			MC.aws.subnet.updateAllENIIPList(comp_data[uid].resource.SubnetId.split('.')[0].slice(1))

		#return
		null

	#expand a volume to a server group
	expandVolume = ( json_data, uid ) ->

		comp_data   = json_data.component

		layout_data = json_data.layout

		instance_uid = json_data.component[uid].resource.AttachmentSet.InstanceId

		instance_uid = if instance_uid then instance_uid.split('.')[0][1...] else null

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

		$.each vol_list, ( idx, vol_uid ) ->

			if not json_data.component[vol_uid]

				origin_eni = $.extend true, {}, json_data.component[uid]

				origin_eni.uid = vol_uid

				origin_eni.index = idx

				origin_eni.number = vol_number

				origin_eni.name = if "#{server_group_name}-#{idx}" not in origin_eni.name then "#{server_group_name}-#{idx}-#{origin_eni.serverGroupName}" else origin_eni.name

				attach_instance = "@#{instance_list[idx]}.resource.InstanceId"

				origin_eni.resource.AttachmentSet.InstanceId = attach_instance

				origin_eni.resource.AttachmentSet.VolumeId = "@#{vol_uid}.resource.VolumeId"

				comp_data[vol_uid] = origin_eni
			else

				json_data.component[vol_uid].name = if "#{server_group_name}-#{idx}" not in json_data.component[vol_uid].name then "#{server_group_name}-#{idx}-#{json_data.component[vol_uid].serverGroupName}" else json_data.component[vol_uid].name

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

			instance_list = json_data.layout.component.node[ instance_uid ].instanceList

			eip_number = json_data.component[instance_uid].number

			eip_list = json_data.layout.component.node[ instance_uid ].eipList

			if eip_list.length is 0

				eip_list = json_data.layout.component.node[ instance_uid ].eipList = [ uid ]

			eip_comp_number = eip_list.length

		else

			eni_list = if json_data.layout.component.node[ eni_uid ] then json_data.layout.component.node[ eni_uid ].eniList else json_data.layout.component.node[json_data.component[eni_uid].resource.Attachment.InstanceId.split('.')[0].slice(1)].eniList

			eip_number = json_data.component[json_data.component[eni_uid].resource.Attachment.InstanceId.split('.')[0].slice(1)].number

			eip_list = if json_data.layout.component.node[ eni_uid ] then json_data.layout.component.node[ eni_uid ].eipList[ uid ] else json_data.layout.component.node[json_data.component[eni_uid].resource.Attachment.InstanceId.split('.')[0].slice(1)].eipList

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
				json_data.layout.component.node[json_data.component[eni_uid].resource.Attachment.InstanceId.split('.')[0].slice(1)].eipList = eip_list

		$.each eip_list, ( idx, eip_uid ) ->

			if not json_data.component[eip_uid]

				origin_eip = $.extend true, {}, json_data.component[uid]

				origin_eip.uid = eip_uid

				origin_eip.index = idx

				origin_eip.number = eip_number

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
				if comp.name.indexOf("eni0") >=0
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



	#public
	expandServerGroup  : expandServerGroup
	compactServerGroup : compactServerGroup
