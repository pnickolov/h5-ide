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

		json_data


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

		#init instance_list
		if instance_list.length != ins_num

			instance_list = [ uid ]

			i = 1
			while i < ins_num

				instance_list[ i ] = ''

				i++

		# collect using elb
		instance_reference = "@#{ins_comp}.resource.InstanceId"

		elbs = []

		for comp_uid, comp of MC.canvas_data.component

			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_ELB

				if instance_reference in comp.resource.Instances

					elbs.push comp_uid

		if ins_num

			i = 1
			while i < ins_num

				new_comp = $.extend( true, {}, ins_comp )

				if !instance_list[i]
					instance_list[i] = MC.guid()

				#generate uid
				new_comp.uid = instance_list[i]

				#generate name
				new_comp.name = server_group_name + '-' + i

				#index in server group
				new_comp.index = i

				comp_data[ new_comp.uid ] = new_comp
				i++

				if elbs.length > 0

					for elb in elbs

						json_data.component[elb].resource.Instances.push "@#{new_comp.uid}.resource.InstanceId"

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

			eni_list = json_data.component[instance_uid].eniList = [ uid ]

		else
			eni_list = json_data.layout.component.node[ uid ].eniList

		eni_comp_number = eni_list.length

		if eni_comp_number > eni_number

			i = eni_number

			while i > eni_comp_number

				eni_list.splice (i-1), 1

				i--

		else if eni_number > eni_comp_number

			i = 0

			while i < eni_number-1

				new_eni_uid = MC.guid()

				eni_list.push new_eni_uid

				i++

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

		vol_comp_number = vol_list.length

		if vol_comp_number > vol_number

			i = vol_number

			while i > vol_comp_number

				vol_list.splice (i-1), 1

				i--

		else if vol_number > vol_comp_number

			i = 0

			while i < vol_number-1

				new_vol_uid = MC.guid()

				vol_list.push new_vol_uid

				i++

		$.each vol_list, ( idx, vol_uid ) ->

			if not json_data.component[vol_uid]

				origin_eni = $.extend true, {}, json_data.component[uid]

				origin_eni.uid = vol_uid

				origin_eni.index = idx

				origin_eni.number = vol_number

				origin_eni.name = if "#{server_group_name}-#{idx}" not in origin_eni.name then "#{server_group_name}-#{idx}-#{origin_eni.serverGroupName}" else origin_eni.name

				attach_instance = "@#{instance_list[idx]}.resource.InstanceId"

				origin_eni.resource.AttachmentSet.InstanceId = attach_instance

				comp_data[vol_uid] = origin_eni
			else

				json_data.component[vol_uid].name = if "#{server_group_name}-#{idx}" not in json_data.component[vol_uid].name then "#{server_group_name}-#{idx}-#{json_data.component[vol_uid].serverGroupName}" else json_data.component[vol_uid].name

				json_data.component[vol_uid].number = vol_number


		#return
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
					if comp.number > 1 and comp.index == 0
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

		if instance_list.length != ins_num and instance_list > 0

			console.error '[expandInstance]instance number not match'

		instance_ref_list = []

		for instance_id in instance_list

			if instance_id isnt uid

				instance_ref_list.push "@#{instance_id}.resource.InstanceId"


		# remove eni0
		for comp_uid, comp of comp_data

			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.DeviceIndex in [0, '0'] and comp.resource.Attachment.InstanceId in instance_ref_list

				delete comp_data[comp_uid]

		# remove volume
		for vol_uid, vol_data of vol_list

			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume and comp.resource.AttachmentSet.InstanceId in instance_ref_list

				delete comp_data[comp_uid]

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
