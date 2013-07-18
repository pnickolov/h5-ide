#############################
#  View Mode for canvas
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore' ], (constant) ->

	CanvasModel = Backbone.Model.extend {

		defaults : {

		}

		initialize : ->
			#listen
			null


		#change node from one parent to another parent
		changeNodeParent : ( src_node, tgt_parent ) ->
			#to-do

			null

		#change group from one parent to another parent
		changeGroupParent : ( src_group, tgt_parent ) ->
			#to-do

			null

		#delete component
		deleteObject : ( option ) ->
			#to-do
			me = this

			if option.type == 'node'

				# remove node instance
				switch MC.canvas_data.component[option.id].type

					when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

					
						$.each MC.canvas_data.component, ( index, comp ) ->

							# remove instance relate sg rule or sg
							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

								me._removeInstnceFromSG comp.uid, option.id


							# remove instance relate eni

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == option.id

								# reset eni after disconnect instance
								comp.resource.Attachment.InstanceId = ''

								if comp.resource.Attachment.DeviceIndex == "0"

									delete MC.canvas_data.component[index]

							# remove instance relate volume

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume and comp.resource.AttachmentSet.InstanceId.split('.')[0][1...] == option.id

								delete MC.canvas_data.component[index]


							# remove instance relate eip

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.InstanceId.split('.')[0][1...] == option.id

								delete MC.canvas_data.component[index]

							# remove instance relate routetable
							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

								me._removeGatewayIdFromRT comp.uid, option.id

					# remove node volume just use mc.canvas.remove

					# remove node eni
					when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

						$.each MC.canvas_data.component, ( index, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.NetworkInterfaceId.split('.')[0][1...] == option.id

								delete MC.canvas_data.component[index]

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

								me._removeGatewayIdFromRT comp.uid, option.id
					
					# remove rt
					when constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

						if MC.canvas_data.component[option.id].name == 'MainRT'

							console.log 'Can not delete main routetable'

							return false

					# remove igw
					when constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway

						$.each MC.canvas_data.component, ( index, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

								me._removeGatewayIdFromRT comp.uid, option.id

					# remove vgw
					when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway

						$.each MC.canvas_data.component, ( index, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

								me._removeGatewayIdFromRT comp.uid, option.id

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection

								if comp.resource.VpnGatewayId.split('.')[0][1...] == option.id

									delete MC.canvas_data.component[index]

					when constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway

						$.each MC.canvas_data.component, ( index, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection

								if comp.resource.CustomerGatewayId.split('.')[0][1...] == option.id

									delete MC.canvas_data.component[index]

									return false


			# remove group
			if option.type == 'group'

				nodes = MC.canvas.groupChild($("#" + option.id)[0])

				$.each nodes, ( index, node ) ->

					op = {}
					op.type = $(node).data().type
					op.id = node.id

					me.deleteObject op

				delete MC.canvas_data.component[option.id]


			MC.canvas.remove $("#" + option.id)[0]

			null

		_removeGatewayIdFromRT : ( rt_uid, gateway_instance_uid) ->

			$.each MC.canvas_data.component[rt_uid].resource.RouteSet, ( index, route ) ->

				if route.InstanceId.split('.')[0][1...] == gateway_instance_uid or route.NetworkInterfaceId.split('.')[0][1...] == gateway_instance_uid

					MC.canvas_data.component[rt_uid].resource.RouteSet.splice index, 1


		_removeInstnceFromSG : ( sg_uid, instance_uid ) ->


			if MC.canvas_data.component[sg_uid].resource.IpPermissions.length != 0

				$.each MC.canvas_data.component[sg_uid].resource.IpPermissions, ( idx, rule ) ->

					if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == instance_uid

						MC.canvas_data.component[sg_uid].resource.IpPermissions.splice idx, 1

						return false

			if MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress.length != 0

				$.each MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress, ( idx, rule ) ->

					if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == instance_uid

						MC.canvas_data.component[sg_uid].resource.IpPermissionsEgress.splice idx, 1

						return false

			$.each MC.canvas_property.sg_list, ( index, sg ) ->

				if instance_uid in sg.member

					idx = sg.member.indexOf instance_uid

					sg.member.splice idx, 1

					if sg.member.length == 0 and sg.name != 'DefaultSG'

						MC.canvas_property.sg_list.splice index, 1

						delete MC.canvas_data.component[sg.uid]

						$.each MC.canvas_data.component, ( key, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

								$.each comp.resource.IpPermissions, ( i, rule ) ->

									if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg.uid

										MC.canvas_data.component[key].resource.IpPermissions.splice i, 1

								$.each comp.resource.IpPermissionsEgress, ( i, rule ) ->

									if '@' in rule.IpRanges and rule.IpRanges.split('.')[0][1...] == sg.uid

										MC.canvas_data.component[key].resource.IpPermissionsEgress.splice i, 1

					return false

		createLine : ( line_id ) ->
			#to-do

			null

	}

	model = new CanvasModel()

	return model