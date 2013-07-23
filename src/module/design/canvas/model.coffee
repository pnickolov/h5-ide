#############################
#  View Mode for canvas
#############################
define [ 'constant',
		'canvas_handle_elb',
		'canvas_handle_vpn',
		'backbone', 'jquery', 'underscore' ], ( constant, canvas_handle_elb, canvas_handle_vpn ) ->

	CanvasModel = Backbone.Model.extend {

		defaults : {

		}

		initialize : ->
			#listen
			null


		#change node from one parent to another parent
		changeNodeParent : ( src_node, tgt_parent ) ->
			#to-do
			component     = MC.canvas_data.component[ src_node ]
			resource_type = constant.AWS_RESOURCE_TYPE

			# Deal with dragging "Instance" to different AvailabilityZone
			if component.type == resource_type.AWS_EC2_Instance
				parent = MC.canvas_data.layout.component.group[ tgt_parent ]

				# Parent can be AvailabilityZone or Subnet
				if parent.type == resource_type.AWS_VPC_Subnet
					parent = MC.canvas_data.component[ tgt_parent ]
					console.log "Instance:", src_node, "dragged from subnet:", component.resource.SubnetId, "to:", tgt_parent

					# Nothing is changed
					if component.resource.SubnetId.indexOf( tgt_parent ) != -1
						return

					newAZ = parent.resource.AvailabilityZone
					# Update instance's subnet
					component.resource.SubnetId = "@" + tgt_parent + ".resource.SubnetId"
				else
					console.log "Instance:", src_node, "dragged from:", component.resource.Placement.AvailabilityZone, "to:", parent.name

					# Nothing is changed
					if parent.name == component.resource.Placement.AvailabilityZone
						return

					newAZ = parent.name

				component.resource.Placement.AvailabilityZone = newAZ

				#We should also update those Volumes that are attached to this Instance.
				updateVolume = ( component, id ) ->
					if component.type == resource_type.AWS_EBS_Volume and component.resource.AttachmentSet.InstanceId.indexOf( this )
						 component.resource.AvailabilityZone = newAZ
					null

				_.each MC.canvas_data.component, updateVolume, component.uid
			# end of dragging "Instance" to different AvailabilityZone

			null

		#change group from one parent to another parent
		changeGroupParent : ( src_group, tgt_parent ) ->
			#to-do

			null

		#delete component
		deleteObject : ( option ) ->

			# type: line | node | group

			console.info 'type:' + option.type + 'id' + option.id

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

								delete MC.canvas_data.componentreturn[index]

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

						$.each $(".resource-item"), ( idx, item) ->
					
							data = $(item).data()
							
							if data.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway

								tmp = {
									enable : true
									tooltip: "Drag and drop to canvas to create a new Internet Gateway."
								}
								$(item)
									.data(tmp)
									.removeClass('resource-disabled')
								
								return false

					# remove vgw
					when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway

						$.each MC.canvas_data.component, ( index, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

								me._removeGatewayIdFromRT comp.uid, option.id

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection

								if comp.resource.VpnGatewayId.split('.')[0][1...] == option.id

									delete MC.canvas_data.component[index]

						$.each $(".resource-item"), ( idx, item) ->
					
							data = $(item).data()
							
							if data.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway

								tmp = {
									enable : true
									tooltip: "Drag and drop to canvas to create a new VPN Gateway."
								}
								$(item)
									.data(tmp)
									.removeClass('resource-disabled')
								
								return false

					when constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway

						$.each MC.canvas_data.component, ( index, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection

								if comp.resource.CustomerGatewayId.split('.')[0][1...] == option.id

									delete MC.canvas_data.component[index]

									return false


			# remove group
			else if option.type == 'group'

				nodes = MC.canvas.groupChild($("#" + option.id)[0])

				$.each nodes, ( index, node ) ->

					op = {}
					op.type = $(node).data().type
					op.id = node.id

					me.deleteObject op

				delete MC.canvas_data.component[option.id]


				# recover az dragable
				if $("#" + option.id).data().class == constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

					az_name = $("#" + option.id).text()

					$.each $(".resource-item"), ( idx, item) ->
					
						data = $(item).data()
						
						if data.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone and data.option.name == az_name

							tmp = {
								enable : true
								tooltip: "Drag and drop to canvas"
							}
							$(item)
								.data(tmp)
								.removeClass('resource-disabled')
								.addClass("tooltip")
							
							return false
								
					


			# remove line
			else if option.type == 'line'

				connectionObj =  MC.canvas_data.layout.connection[option.id]

				targetObj = connectionObj.target
				portMap = {}

				_.each targetObj, (value, key) ->
					portMap[value] = key
					null

				#delete line between elb and instance
				if portMap['elb-sg-out'] and portMap['instance-sg-in']
					canvas_handle_elb.removeInstanceFromELB(portMap['elb-sg-out'], portMap['instance-sg-in'])

				if portMap['instance-attach'] and portMap['eni-attach']

					MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.InstanceId = ''

					MC.canvas.update portMap['eni-attach'], 'image', 'eni_status', MC.canvas.IMAGE.ENI_CANVAS_UNATTACHED

				if portMap['vgw-vpn'] and portMap['cgw-vpn']
					canvas_handle_vpn.delVPN(portMap['vgw-vpn'], portMap['cgw-vpn'])


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

		#after connect two port
		createLine : ( line_id ) ->
			
			me = this

			line_option = MC.canvas.lineTarget line_id

			if line_option.length == 2

				console.info line_option[0].uid + ',' + line_option[0].port + " | " + line_option[1].uid + ',' + line_option[1].port

				portMap = {}

				$.each line_option, ( i, obj ) ->
					portMap[obj.port] = obj.uid
					null

				#connect elb and instance
				if portMap['instance-sg-in'] and portMap['elb-sg-out']
					canvas_handle_elb.addInstanceAndAZToELB(portMap['elb-sg-out'], portMap['instance-sg-in'])

				if portMap['instance-attach'] and portMap['eni-attach']

					# check whether instance has position to add one more eni
					instance_component 	= 	MC.canvas_data.component[portMap['instance-attach']]

					instance_type 		= 	instance_component.resource.InstanceType.split('.')

					max_eni_number 		= 	MC.data.config[instance_component.resource.Placement.AvailabilityZone[0...-1]].instance_type[instance_type[0]][instance_type[1]].eni

					current_eni_number 	= 	0

					reach_max 			= 	false

					total_device_index  = 	[0...16]

					$.each MC.canvas_data.component, ( uid, comp ) ->

						if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == portMap['instance-attach']

							device_index_int = parseInt(comp.resource.Attachment.DeviceIndex, 10)

							if device_index_int in total_device_index

								total_device_index.splice total_device_index.indexOf(device_index_int), 1

							current_eni_number += 1

							if current_eni_number >= max_eni_number

								reach_max = true

								return false

					if reach_max

						me.trigger 'ENI_REACH_MAX'

						MC.canvas.remove $("#" + line_id)[0]

					else

						MC.canvas.update portMap['eni-attach'], 'image', 'eni_status', MC.canvas.IMAGE.ENI_CANVAS_ATTACHED

						MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.DeviceIndex = total_device_index[0].toString()

						MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.InstanceId = '@' + portMap['instance-attach'] + '.resource.InstanceId'

				#connect vgw and cgw
				if portMap['vgw-vpn'] and portMap['cgw-vpn']
					canvas_handle_vpn.addVPN(portMap['vgw-vpn'], portMap['cgw-vpn'])

			null


		#after drag component from resource panel to canvas
		createComponent : ( uid ) ->

			componentType = MC.canvas_data.component[uid].type

			if componentType is 'AWS.ELB'
				canvas_handle_elb.init(uid)

			if componentType is 'AWS.VPC.InternetGateway'
				canvas_handle_elb.setAllELBSchemeAsInternal()

			#to-do

	}

	model = new CanvasModel()

	return model
