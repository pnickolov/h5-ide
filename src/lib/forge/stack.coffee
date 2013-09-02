define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->

	#expand instance,eni and volume in server group before save
	expandServerGroup = ( canvas_data ) ->

		json_data   = $.extend( true, {}, canvas_data )

		comp_data   = json_data.component
		layout_data = json_data.layout
		res_type    = constant.AWS_RESOURCE_TYPE

		for uid, comp of comp_data

			switch comp.type

				when res_type.AWS_EC2_Instance         then expandInstance json_data, uid

				when res_type.AWS_VPC_NetworkInterface then expandENI json_data, uid

				when res_type.AWS_EBS_Volume           then expandVolume json_data, uid

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
		else

			#error
			console.error '[expandInstance] can not found number of instance'


		json_data.layout.component.node[ uid ].instanceList = instance_list

		null

	#expand an eni to a server group
	expandENI = ( json_data, uid ) ->

		comp_data   = json_data.component
		layout_data = json_data.layout

		eni_list = []




		#return
		null

	#expand a volume to a server group
	expandVolume = ( json_data, uid ) ->

		comp_data   = json_data.component
		layout_data = json_data.layout

		volume_list = []




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
		ins_num       = ins_comp.number

		if instance_list.length != ins_num and instance_list > 0

			console.error '[expandInstance]instance number not match'

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
