#############################
#  View Mode for canvas
#############################
define [ 'constant',
		'backbone', 'jquery', 'underscore' ], ( constant ) ->

	CanvasModel = Backbone.Model.extend {

		defaults : {

		}

		initialize : ->
			#listen

			resource_type = constant.AWS_RESOURCE_TYPE

			resource_map = {
				'AWS_EC2_Instance'         : 'Instance'
				'AWS_EBS_Volume'           : 'Volume'
				'AWS_VPC_Subnet'           : 'Subnet'
				'AWS_VPC_NetworkInterface' : 'Eni'
			}

			this.changeParentMap = {}
			this.validateDropMap = {}

			for key, value of resource_map
				this.changeParentMap[ resource_type[key] ] = this['changeP_'   + value]
				this.validateDropMap[ resource_type[key] ] = this['validateD_' + value]

			null

		# An object is about to be dropped. Test if the object can be dropped
		onBeforeDrop : ( event, src_node, tgt_parent ) ->
			debugger
			null

		#change node from one parent to another parent
		changeNodeParent : ( event, src_node, tgt_parent ) ->
			debugger
			node = MC.canvas_data.layout.component.group[src_node]
			if !node
				node = MC.canvas_data.layout.component.node[src_node]
			if !node || !node.groupUId || node.groupUId == tgt_parent
				return

			# Dispatch the event-handling to real handler
			component = MC.canvas_data.component[ src_node ]
			handler   = this.changeParentMap[ component.type ]
			if handler
				handler component, tgt_parent
			else
				console.log "No handler for dragging node:", component
			null

		changeP_Instance : ( component, tgt_parent ) ->

			resource_type = constant.AWS_RESOURCE_TYPE
			parent        = MC.canvas_data.layout.component.group[ tgt_parent ]

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
			updateVolume = ( component ) ->
				if component.type == resource_type.AWS_EBS_Volume and
				component.resource.AttachmentSet.InstanceId.indexOf( this )
					 component.resource.AvailabilityZone = newAZ
				null

			_.each MC.canvas_data.component, updateVolume, component.uid
			null

		changeP_Volume : () ->
			null

		changeP_Subnet : ( component, tgt_parent ) ->

			debugger

			parent        = MC.canvas_data.layout.component.group[ tgt_parent ]
			resource_type = constant.AWS_RESOURCE_TYPE

			component.resource.AvailabilityZone = parent.name

			# Update Subnet's children's AZ
			for key, value of MC.canvas_data.component

				if value.type == resource_type.AWS_EC2_Instance
					if value.resource.SubnetId.indexOf( component.uid ) != -1
						value.resource.Placement.AvailabilityZone = component.resource.AvailabilityZone
						for key2, volume of MC.canvas_data.component
							if volume.type == resource_type.AWS_EBS_Volume && volume.resource.AttachmentSet.InstanceId.indexOf( value.uid ) != -1
								volume.resource.AvailabilityZone = component.resource.AvailabilityZone

				else if value.type == resource_type.AWS_VPC_NetworkInterface
					if value.resource.SubnetId.indexOf( component.uid ) != -1
						value.resource.AvailabilityZone = component.resource.AvailabilityZone
			null

		changeP_Eni : ( component, tgt_parent ) ->
			component.resource.SubnetId = "@" + tgt_parent + ".resource.SubnetId"
			component.resource.AvailabilityZone = MC.canvas_data.component[tgt_parent].resource.AvailabilityZone
			null

		#delete component
		deleteObject : ( event, option ) ->

			# type: line | node | group

			console.info 'type:' + option.type + 'id' + option.id

			#to-do
			me = this
			is_delete = false

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

						is_delete = true

					# remove node volume just use mc.canvas.remove

					# remove node eni
					when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

						$.each MC.canvas_data.component, ( index, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.NetworkInterfaceId.split('.')[0][1...] == option.id

								delete MC.canvas_data.component[index]

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

								me._removeGatewayIdFromRT comp.uid, option.id

						is_delete = true


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

						is_delete = true


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

						is_delete = true


					when constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway

						$.each MC.canvas_data.component, ( index, comp ) ->

							if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection

								if comp.resource.CustomerGatewayId.split('.')[0][1...] == option.id

									delete MC.canvas_data.component[index]

									return false

						is_delete = true

			# remove group
			else if option.type == 'group'

				nodes = MC.canvas.groupChild($("#" + option.id)[0])

				$.each nodes, ( index, node ) ->

					op = {}
					op.type = $(node).data().type
					op.id = node.id

					me.deleteObject op

				delete MC.canvas_data.component[option.id]

				is_delete = true


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
				if portMap['elb-sg-out'] and portMap['instance-sg']

					MC.aws.elb.removeInstanceFromELB(portMap['elb-sg-out'], portMap['instance-sg'])

					is_delete = true


				#connect elb and subnet
				if portMap['elb-assoc'] and portMap['subnet-assoc-in']

					deleteE_SLen = MC.aws.elb.removeSubnetFromELB portMap['elb-assoc'], portMap['subnet-assoc-in']

					is_delete = true

				if portMap['instance-attach'] and portMap['eni-attach']

					MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.InstanceId = ''

					MC.canvas.update portMap['eni-attach'], 'image', 'eni_status', MC.canvas.IMAGE.ENI_CANVAS_UNATTACHED

					is_delete = true


				# remove line between igw and rt
				if portMap['igw-tgt'] and portMap['rtb-tgt-left']

					remove_index = []

					$.each MC.canvas_data.component[portMap['rtb-tgt-left']].resource.RouteSet, ( index, route ) ->

						if route.GatewayId and route.GatewayId.split('.')[0][1...] == portMap['igw-tgt']

							remove_index.push index

					$.each remove_index.sort().reverse(), ( i, v) ->

						MC.canvas_data.component[portMap['rtb-tgt-left']].resource.RouteSet.splice v, 1

					is_delete = true


				# remove line between subnet and rt
				if portMap['subnet-assoc-out'] and portMap['rtb-src']

					rt_uid = portMap['rtb-src']

					if MC.canvas_data.component[rt_uid].resource.AssociationSet != 0 and MC.canvas_data.component[rt_uid].resource.AssociationSet[0].Main != 'true'

						$.each MC.canvas_data.component[rt_uid].resource.AssociationSet, ( index, route ) ->

							if route.SubnetId.split('.')[0][1...] == portMap['subnet-assoc-out']

								MC.canvas_data.component[rt_uid].resource.AssociationSet.splice index, 1

								return false

					is_delete = true


				# remove line between instance and rt
				if portMap['instance-sg'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

					rt_uid = null

					if portMap['rtb-tgt-left'] then rt_uid = portMap['rtb-tgt-left'] else rt_uid = portMap['rtb-tgt-right']

					remove_index = []

					$.each MC.canvas_data.component[rt_uid].resource.RouteSet, ( index, route ) ->

						if route.InstanceId and route.InstanceId.split('.')[0][1...] == portMap['instance-sg']

							remove_index.push index

					$.each remove_index.sort().reverse(), ( i, v) ->

						MC.canvas_data.component[rt_uid].resource.RouteSet.splice v, 1

					is_delete = true


				# remove line between eni and rt
				if portMap['eni-sg'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

					rt_uid = null

					if portMap['rtb-tgt-left'] then rt_uid = portMap['rtb-tgt-left'] else rt_uid = portMap['rtb-tgt-right']

					remove_index = []

					$.each MC.canvas_data.component[rt_uid].resource.RouteSet, ( index, route ) ->

						if route.NetworkInterfaceId and route.NetworkInterfaceId.split('.')[0][1...] == portMap['eni-sg']

							remove_index.push index

					$.each remove_index.sort().reverse(), ( i, v) ->

						MC.canvas_data.component[rt_uid].resource.RouteSet.splice v, 1

					is_delete = true


				# remove line between vgw and rt
				if portMap['vgw-tgt'] and portMap['rtb-tgt-right']

					remove_index = []

					$.each MC.canvas_data.component[portMap['rtb-tgt-right']].resource.RouteSet, ( index, route ) ->

						if route.GatewayId and route.GatewayId.split('.')[0][1...] == portMap['vgw-tgt']

							remove_index.push index

					$.each remove_index.sort().reverse(), ( i, v) ->

						MC.canvas_data.component[portMap['rtb-tgt-right']].resource.RouteSet.splice v, 1

					is_delete = true


				if portMap['vgw-vpn'] and portMap['cgw-vpn']

					MC.aws.vpn.delVPN(portMap['vgw-vpn'], portMap['cgw-vpn'])

					is_delete = true


				if portMap['instance-sg'] or portMap['eni-sg'] or portMap['elb-sg-in'] or portMap['elb-sg-out']

					this.trigger 'SHOW_SG_LIST', option.id

					return false




			MC.canvas.remove $("#" + option.id)[0]




			if is_delete

				this.trigger 'DELETE_OBJECT_COMPLETE'


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
		createLine : ( event, line_id ) ->

			me = this

			line_option = MC.canvas.lineTarget line_id

			if line_option.length == 2

				console.info line_option[0].uid + ',' + line_option[0].port + " | " + line_option[1].uid + ',' + line_option[1].port

				portMap = {}

				$.each line_option, ( i, obj ) ->
					portMap[obj.port] = obj.uid
					null

				#connect elb and instance
				if portMap['instance-sg'] and portMap['elb-sg-out']
					linkSubnetID = MC.aws.elb.addInstanceAndAZToELB(portMap['elb-sg-out'], portMap['instance-sg'])

					if linkSubnetID
						# We need to link subnet to the elb.
						MC.canvas.connect portMap['elb-sg-out'], "elb-assoc", linkSubnetID, "subnet-assoc-in"


				#connect elb and subnet
				if portMap['elb-assoc'] and portMap['subnet-assoc-in']
					elbUid       = portMap['elb-assoc']
					deleteE_SLen = MC.aws.elb.addSubnetToELB elbUid, portMap['subnet-assoc-in']
					# Connecting Elb to Subnet might need to disconnect Elb from another Subnet
					if deleteE_SLen
						subnetLayout = MC.canvas_data.layout.component.group[deleteE_SLen]
						if subnetLayout
							for i in subnetLayout.connection
								if i.target == elbUid
									# Delete line
									this.deleteObject {
										type : "line"
										id   : i.line
									}
									break


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


				# routetable to subnet
				if portMap['subnet-assoc-out'] and portMap['rtb-src']

					rt_uid = portMap['rtb-src']

					# add association
					if MC.canvas_data.component[rt_uid].resource.AssociationSet.length == 0 or MC.canvas_data.component[rt_uid].resource.AssociationSet[0].Main != 'true'

						asso = {}

						asso.SubnetId = '@' + portMap['subnet-assoc-out'] + '.resource.SubnetId'

						asso.Main = 'false'

						asso.RouteTableId = ''

						asso.RouteTableAssociationId = ''

						MC.canvas_data.component[rt_uid].resource.AssociationSet.push asso

					#remove old connection and data
					$.each MC.canvas_data.layout.connection, ( line_uid, comp ) ->

						if line_uid != line_id

							map = {}

							$.each comp.target, ( component_uid, connection_port ) ->

								map[connection_port] = component_uid

								null

							if map['subnet-assoc-out'] and map['subnet-assoc-out'] == portMap['subnet-assoc-out']

								# remove component data and

								preview_rt_uid = null

								if map['rtb-src'] then preview_rt_uid = map['rtb-src'] else preview_rt_uid = map['rtb-src']

								if MC.canvas_data.component[preview_rt_uid].resource.AssociationSet != 0 and MC.canvas_data.component[preview_rt_uid].resource.AssociationSet[0].Main != 'true'

									$.each MC.canvas_data.component[preview_rt_uid].resource.AssociationSet, ( index, assoset ) ->

										if assoset.SubnetId.split('.')[0][1...] == map['subnet-assoc-out']

											MC.canvas_data.component[preview_rt_uid].resource.AssociationSet.splice index, 1

											return false

								MC.canvas.remove $("#" + line_uid)[0]

								return false

				# routetable to igw
				if portMap['igw-tgt'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

					rt_uid = null

					if portMap['rtb-tgt-left'] then rt_uid = portMap['rtb-tgt-left'] else rt_uid = portMap['rtb-tgt-right']

					igw_route = {
						'DestinationCidrBlock'		:	'0.0.0.0/0',
						'GatewayId'					:	'@' + portMap['igw-tgt'] + '.resource.InternetGatewayId',
						'InstanceId'				:	'',
						'InstanceOwnerId'			:	'',
						'NetworkInterfaceId'		:	'',
						'State'						:	'',
						'Origin'					:	''
					}

					MC.canvas_data.component[rt_uid].resource.RouteSet.push igw_route

				# routetable to instance
				if portMap['instance-sg'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

					rt_uid = null

					if portMap['rtb-tgt-left'] then rt_uid = portMap['rtb-tgt-left'] else rt_uid = portMap['rtb-tgt-right']

					instance_route = {
						'DestinationCidrBlock'		:	'0.0.0.0/0',
						'GatewayId'					:	'',
						'InstanceId'				:	'@' + portMap['instance-sg'] + '.resource.InstanceId',
						'InstanceOwnerId'			:	'',
						'NetworkInterfaceId'		:	'',
						'State'						:	'',
						'Origin'					:	''
					}

					MC.canvas_data.component[rt_uid].resource.RouteSet.push instance_route

				# routetable to vgw
				if portMap['vgw-tgt'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

					rt_uid = null

					if portMap['rtb-tgt-left'] then rt_uid = portMap['rtb-tgt-left'] else rt_uid = portMap['rtb-tgt-right']

					vgw_route = {
						'DestinationCidrBlock'		:	'0.0.0.0/0',
						'GatewayId'					:	'@' + portMap['vgw-tgt'] + '.resource.VpnGatewayId',
						'InstanceId'				:	'',
						'InstanceOwnerId'			:	'',
						'NetworkInterfaceId'		:	'',
						'State'						:	'',
						'Origin'					:	''
					}

					MC.canvas_data.component[rt_uid].resource.RouteSet.push vgw_route

				# routetable to eni
				if portMap['eni-sg'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

					rt_uid = null

					if portMap['rtb-tgt-left'] then rt_uid = portMap['rtb-tgt-left'] else rt_uid = portMap['rtb-tgt-right']

					instance_route = {
						'DestinationCidrBlock'		:	'0.0.0.0/0',
						'GatewayId'					:	'',
						'InstanceId'				:	'',
						'InstanceOwnerId'			:	'',
						'NetworkInterfaceId'		:	'@' + portMap['eni-sg'] + '.resource.NetworkInterfaceId',
						'State'						:	'',
						'Origin'					:	''
					}

					MC.canvas_data.component[rt_uid].resource.RouteSet.push instance_route

				#connect vgw and cgw
				if portMap['vgw-vpn'] and portMap['cgw-vpn']
					MC.aws.vpn.addVPN(portMap['vgw-vpn'], portMap['cgw-vpn'])

				$.each portMap, ( key, value ) ->

					if key.indexOf('sg') >= 0
						me.trigger 'CREATE_SG_CONNECTION', line_id

						return false
				#if (portMap['instance-sg-in'] and portMap['instance-sg-out']) or (portMap['eni-sg-in'] and portMap['instance-sg-out']) or (portMap['instance-sg-in'] and portMap['eni-sg-out']) or (portMap['eni-sg-in'] and portMap['eni-sg-out'])

				#	this.trigger 'CREATE_SG_CONNECTION', line_id

			null


		#after drag component from resource panel to canvas
		createComponent : ( event, uid ) ->

			compObj = MC.canvas_data.component[uid]

			groupObj = MC.canvas_data.layout.component.group[uid]

			if compObj
				componentType = MC.canvas_data.component[uid].type
			else
				componentType = constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

			if componentType is constant.AWS_RESOURCE_TYPE.AWS_ELB
				MC.aws.elb.init(uid)

			if componentType is constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway
				MC.aws.elb.setAllELBSchemeAsInternal()

			#
			this.trigger 'CREATE_COMPONENT_COMPLETE'

			#to-do

		reDrawSgLine : () ->

			lines = []

			sg_refs = []

			$.each MC.canvas_data.component, ( comp_uid, comp ) ->

				if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

					$.each comp.resource.IpPermissions, ( i, rule ) ->

						if rule.IpRanges.indexOf('@') >= 0

							to_sg_uid = rule.IpRanges.split('.')[0][1...]

							from_key = comp.uid + '|' + to_sg_uid

							to_key = to_sg_uid + '|' + comp.uid

							if (from_key not in sg_refs) and (to_key not in sg_refs)

								sg_refs.push from_key

					$.each comp.resource.IpPermissionsEgress, ( i, rule ) ->

						if rule.IpRanges.indexOf('@') >= 0

							to_sg_uid = rule.IpRanges.split('.')[0][1...]

							from_key = comp.uid + '|' + to_sg_uid

							to_key = to_sg_uid + '|' + comp.uid

							if (from_key not in sg_refs) and (to_key not in sg_refs)

								sg_refs.push to_key

			$.each sg_refs, ( i, val ) ->

				uids = val.split('|')

				from_sg_uid = uids[0]

				to_sg_uid = uids[1]

				from_sg_group = []

				to_sg_group = []

				$.each MC.canvas_data.component, ( comp_uid, comp )->

					switch comp.type

						when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

							if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

								$.each comp.resource.SecurityGroupId, ( idx, sgs )->

									if sgs.split('.')[0][1...] == from_sg_uid

										from_sg_group.push comp.uid

									if sgs.split('.')[0][1...] == to_sg_uid

										to_sg_group.push comp.uid

						when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

							$.each comp.resource.GroupSet, ( idx, sgs )->

								if sgs.GroupId.split('.')[0][1...] == from_sg_uid

									if comp.resource.Attachment.DeviceIndex != "0"
										from_sg_group.push comp.uid
									else
										from_sg_group.push comp.resource.Attachment.InstanceId.split('.')[0][1...]

								if sgs.GroupId.split('.')[0][1...] == to_sg_uid
									if comp.resource.Attachment.DeviceIndex != "0"
										to_sg_group.push comp.uid
									else
										to_sg_group.push comp.resource.Attachment.InstanceId.split('.')[0][1...]

						when constant.AWS_RESOURCE_TYPE.AWS_ELB

							if MC.canvas_data.platform != MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

								$.each comp.resource.SecurityGroups, ( idx, sgs )->

									if sgs.split('.')[0][1...] == from_sg_uid

										from_sg_group.push comp.uid

									if sgs.split('.')[0][1...] == to_sg_uid

										to_sg_group.push comp.uid

				$.each from_sg_group, ( i, from_comp_uid ) ->

					$.each to_sg_group, (i, to_comp_uid) ->

						if from_comp_uid != to_comp_uid

							from_port = null

							to_port = null

							switch MC.canvas_data.component[from_comp_uid].type

								when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

									from_port = 'instance-sg'

								when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

									from_port = 'eni-sg'

								when constant.AWS_RESOURCE_TYPE.AWS_ELB

									from_port = 'elb-sg-out'

							switch MC.canvas_data.component[to_comp_uid].type

								when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

									to_port = 'instance-sg'

								when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

									to_port = 'eni-sg'

								when constant.AWS_RESOURCE_TYPE.AWS_ELB

									to_port = 'elb-sg-in'

							lines.push [from_comp_uid, to_comp_uid, from_port, to_port]

			$.each MC.canvas_data.layout.connection, ( line_id, line ) ->

				if line.type == 'sg'

					MC.canvas.remove $("#"+line_id)[0]


			$.each lines, ( idx, line_data ) ->

				MC.canvas.connect $("#"+line_data[0]), line_data[2], $("#"+line_data[1]), line_data[3]

			lines

		setEip : ( uid, state ) ->

			if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

				if state == 'on'

					$.each MC.canvas_data.component, ( comp_uid, comp ) ->

						if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.InstanceId.split('.')[0][1...] == uid

							delete MC.canvas_data.component[comp_uid]

							return false

				else if state == 'off'

					eip_json = $.extend true, {}, MC.canvas.EIP_JSON.data

					gen_uid = MC.guid()

					eip_json.resource.InstanceId = '@' + uid + '.resource.InstanceId'

					eip_json.uid = gen_uid

					data = MC.canvas.data.get('component')

					data[gen_uid] = eip_json

					MC.canvas.data.set('component', data)

			else

				existing_eip_ref = []

				# collect all reference
				$.each MC.canvas_data.component, ( comp_uid, comp ) ->

					if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.PrivateIpAddress

						existing_eip_ref.push comp.resource.PrivateIpAddress

				eni = null

				if MC.canvas_data.component[uid].type == constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

					$.each MC.canvas_data.component, ( comp_uid, comp ) ->

						if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId.split('.')[0][1...] == uid and comp.resource.Attachment.DeviceIndex == '0'

							eni = comp

						null

				else

					eni = MC.canvas_data.component[uid]

				ip_number = eni.resource.PrivateIpAddressSet.length

				_.map [0...ip_number], ( index ) ->

					eip_ref = '@' + eni.uid + '.resource.PrivateIpAddressSet.' + index + '.PrivateIpAddress'

					if state == 'off' and (eip_ref not in existing_eip_ref)

						eip_json = $.extend true, {}, MC.canvas.EIP_JSON.data

						gen_uid = MC.guid()

						eip_json.resource.NetworkInterfaceId = '@' + eni.uid + '.resource.NetworkInterfaceId'

						eip_json.uid = gen_uid

						eip_json.resource.PrivateIpAddress = eip_ref

						eip_json.resource.Domain = 'vpc'

						data = MC.canvas.data.get('component')

						data[gen_uid] = eip_json

						MC.canvas.data.set('component', data)

					else if state == 'on' and eip_ref in existing_eip_ref

						$.each MC.canvas_data.component, ( k, c ) ->

							if c.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and c.resource.PrivateIpAddress == eip_ref

								delete MC.canvas_data.component[k]

								return false


				if state == 'off'

					MC.canvas.update uid,'image','eip_status', MC.canvas.IMAGE.EIP_ON

					MC.canvas.update uid,'eip','eip_status', 'on'

				else
					MC.canvas.update uid,'image','eip_status', MC.canvas.IMAGE.EIP_OFF

					MC.canvas.update uid,'eip','eip_status', 'off'

	}

	model = new CanvasModel()

	return model
