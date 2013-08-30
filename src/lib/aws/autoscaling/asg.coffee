define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->

	getAZofASGNode = ( uid ) ->

		#uid is asg layout uid ( maybe original asg, or expand asg )

		comp_data   = MC.canvas_data.component
		layout_data = MC.canvas_data.layout
		res_type    = constant.AWS_RESOURCE_TYPE
		tgt_az      = ''

		parent_id   = layout_data.component.group[uid].groupUId
		asg_parent  = layout_data.component.group[ parent_id ]


		if asg_parent

			switch asg_parent.type

				when res_type.AWS_EC2_AvailabilityZone then tgt_az = asg_parent.name

				when res_type.AWS_VPC_Subnet           then tgt_az = comp_data[ parent_id ].resource.AvailabilityZone

		#return
		tgt_az


	getASGInAZ = ( orig_uid, az ) ->
		#uid is original asg uid

		result      = ''

		comp_data   = MC.canvas_data.component
		layout_data = MC.canvas_data.layout
		res_type    = constant.AWS_RESOURCE_TYPE
		tgt_az      = ''

		asg_layout  = layout_data.component.group[orig_uid]


		if asg_layout

			#if orig_uid is expand asg ,then use originalId
			if asg_layout.originalId

				orig_uid = asg_layout.originalId
				asg_layout  = layout_data.component.group[orig_uid]


			parent_id   = asg_layout.groupUId

			asg_parent  = layout_data.component.group[ parent_id ]


			for uid, group of layout_data.component.group

				if group.type is res_type.AWS_AutoScaling_Group

					tgt_layout = layout_data.component.group[group.groupUId]

					if tgt_layout

						switch tgt_layout.type

							when res_type.AWS_EC2_AvailabilityZone then tgt_az = tgt_layout.name

							when res_type.AWS_VPC_Subnet           then tgt_az = comp_data[group.groupUId].resource.AvailabilityZone


						if ( group.originalId is orig_uid  or  uid is orig_uid )  and  az == getAZofASGNode uid

							result = uid

		result


	#public
	getAZofASGNode      : getAZofASGNode
	getASGInAZ          : getASGInAZ

