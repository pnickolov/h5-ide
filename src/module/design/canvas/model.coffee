#############################
#  View Mode for canvas
#############################
define [ 'constant', 'event'
		'backbone', 'jquery', 'underscore', 'UI.modal' ], ( constant, ide_event ) ->

	CanvasModel = Backbone.Model.extend {

		initialize : ->
			#listen

			resource_type = constant.AWS_RESOURCE_TYPE

			resource_map = {
				'AWS_EC2_Instance'         : 'Instance'
				'AWS_VPC_Subnet'           : 'Subnet'
				'AWS_VPC_NetworkInterface' : 'Eni'
				'AWS_VPC_RouteTable'       : 'RouteTable'
				'AWS_VPC_InternetGateway'  : 'IGW'
				'AWS_VPC_VPNGateway'       : 'VGW'
				'AWS_VPC_CustomerGateway'  : 'CGW'
				'AWS_EC2_AvailabilityZone' : 'AZ'
				'AWS_ELB'                  : 'ELB'
				'AWS_AutoScaling_Group'    : 'ASG'
				'AWS_AutoScaling_Group'           : 'ASG'
				'AWS_AutoScaling_LaunchConfiguration' : 'ASG_LC'
			}

			this.changeParentMap = {}
			this.validateDropMap = {}
			this.deleteResMap    = {}
			this.beforeDeleteMap = {}

			for key, value of resource_map
				this.changeParentMap[ resource_type[key] ] = this['changeP_'   + value]
				this.validateDropMap[ resource_type[key] ] = this['beforeD_'   + value]
				this.deleteResMap[    resource_type[key] ] = this['deleteR_'   + value]
				this.beforeDeleteMap[ resource_type[key] ] = this['beforeDel_' + value]

			null

		# An object is about to be dropped. Test if the object can be dropped
		beforeDrop : ( event, src_node, tgt_parent ) ->
			node = MC.canvas_data.layout.component.group[src_node]
			if !node
				node = MC.canvas_data.layout.component.node[src_node]
			if !node || !node.groupUId || node.groupUId == tgt_parent
				return

			# Dispatch the event-handling to real handler
			component = MC.canvas_data.component[ src_node ]
			handler   = this.validateDropMap[ component.type ]
			if handler
				error = handler.call( this, component, tgt_parent )
				if error
					event.preventDefault()
					notification "error", error
			else
				console.log "Morris : No handler for validate dragging node:", component
			null

		beforeD_Subnet : ( component, tgt_parent ) ->
			null

		beforeD_Instance : ( component, tgt_parent ) ->
			resource_type = constant.AWS_RESOURCE_TYPE
			parent = MC.canvas_data.layout.component.group[ tgt_parent ]

			if component.type == resource_type.AWS_EC2_AvailabilityZone
				check = true
			else if MC.canvas_data.component[ tgt_parent ].resource.AvailabilityZone != component.resource.Placement.AvailabilityZone
				check = true

			if !check
				return

			# Only detect when the component's az is changed.

			for key, value of MC.canvas_data.component
				if value.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
					attachment = value.resource.Attachment
					if "" + attachment.DeviceIndex != "0" && attachment.InstanceId.indexOf( component.uid ) != -1
						return "Network Interface must be attached to instance within the same availability zone."
			null

		beforeD_Eni : ( component, tgt_parent ) ->
			# Eni can only be in subnet
			if MC.canvas_data.component[ tgt_parent ].resource.AvailabilityZone == component.resource.AvailabilityZone
				return

			if component.resource.Attachment.InstanceId
				return "Network Interface must be attached to instance within the same availability zone."
			null

		#change node from one parent to another parent
		changeParent : ( event, src_node, tgt_parent ) ->
			node = MC.canvas_data.layout.component.group[src_node]
			if !node
				node = MC.canvas_data.layout.component.node[src_node]
			if !node || !node.groupUId || node.groupUId == tgt_parent
				return

			# Dispatch the event-handling to real handler
			component = MC.canvas_data.component[ src_node ]
			handler   = this.changeParentMap[ component.type ]
			if handler
				handler.call( this, component, tgt_parent )
			else
				console.log "No handler for dragging node:", component
			null

		changeP_Instance : ( component, tgt_parent ) ->

			resource_type = constant.AWS_RESOURCE_TYPE
			parent        = MC.canvas_data.layout.component.group[ tgt_parent ]

			# Parent can be AvailabilityZone or Subnet
			if parent.type == resource_type.AWS_VPC_Subnet
				parent = MC.canvas_data.component[ tgt_parent ]

				# Nothing is changed
				if component.resource.SubnetId.indexOf( tgt_parent ) != -1
					return

				newAZ = parent.resource.AvailabilityZone
				# Update instance's subnet
				component.resource.SubnetId = "@" + tgt_parent + ".resource.SubnetId"
			else

				# Nothing is changed
				if parent.name == component.resource.Placement.AvailabilityZone
					return

				newAZ = parent.name

			component.resource.Placement.AvailabilityZone = newAZ

			# Update ELB's AZ property
			console.log "morris", component
			components = MC.canvas_data.component
			for key, value of components
				if value.type == resource_type.AWS_ELB
					azs = []
					for i in value.resource.Instances
						azs.push( components[ MC.extractID( i.InstanceId ) ].resource.Placement.AvailabilityZone )
					value.resource.AvailabilityZones = azs

			console.log "morris", components

			# We should also update those Volumes that are attached to this Instance.
			updateVolume = ( component ) ->
				if component.type == resource_type.AWS_EBS_Volume and
				component.resource.AttachmentSet.InstanceId.indexOf( this )
					 component.resource.AvailabilityZone = newAZ
				null

			_.each MC.canvas_data.component, updateVolume, component.uid
			null

		changeP_Subnet : ( component, tgt_parent ) ->

			parent        = MC.canvas_data.layout.component.group[ tgt_parent ]
			resource_type = constant.AWS_RESOURCE_TYPE

			component.resource.AvailabilityZone = parent.name

			# Update Subnet's children's AZ
			for key, value of MC.canvas_data.component

				if value.type == resource_type.AWS_EC2_Instance
					if value.resource.SubnetId.indexOf( component.uid ) != -1
						value.resource.Placement.AvailabilityZone = "1" # Set the Instance's subnet to something else, so we can change it.
						this.changeP_Instance value, component.uid

				else if value.type == resource_type.AWS_VPC_NetworkInterface
					if value.resource.SubnetId.indexOf( component.uid ) != -1
						value.resource.AvailabilityZone = component.resource.AvailabilityZone

				# Disconnect ELB and Subnet, if the newly moved to AZ has a subnet which is connected to the same ELB.
				else if value.type == resource_type.AWS_ELB
				  linkedELBIndex = undefined
				  linkedELB      = false
				  for sb, key in value.resource.Subnets
				  	if sb.indexOf( component.uid ) != -1
				  		linkedELBIndex = key
				  	else if MC.canvas_data.component[ MC.extractID( sb ) ].resource.AvailabilityZone == parent.name
				  	  linkedELB = true

				  # Disconnect
				  if linkedELBIndex != undefined && linkedELB
				  	value.resource.Subnets.splice linkedELBIndex, 1
				  	subnetLayout = MC.canvas_data.layout.component.group[ component.uid ]
						if subnetLayout
							for i in subnetLayout.connection
								if i.target == value.uid
									# Delete line
									this.deleteObject null, {
										type : "line"
										id   : i.line
									}
									break
			null

		changeP_Eni : ( component, tgt_parent ) ->
			component.resource.SubnetId = "@" + tgt_parent + ".resource.SubnetId"
			component.resource.AvailabilityZone = MC.canvas_data.component[tgt_parent].resource.AvailabilityZone
			null

		deleteObject : ( event, option ) ->

			component = MC.canvas_data.component[ option.id ] ||
			if not component
				component = $.extend true, {uid:option.id}, MC.canvas_data.layout.component.group[ option.id ]

			switch option.type
				when 'node'
					handler = this.deleteResMap[ component.type ]
				when 'group'
					result = this.deleteGroup component, option.force
				when 'line'
					result = this.deleteLine option

			if handler
				result = handler.call( this, component, option.force )


			if typeof result is "string"
				# Delete Handler returns a comfirmation string.
				if result[0] == '!'
					# This is an error, not confimation
					if event && event.preventDefault
						event.preventDefault()
					notification "error", result[1...]
				else
					# Confimation
					self = this
					template = MC.template.canvasOpConfirm {
						operation : "delete #{component.name}"
						content   : result
						color     : "red"
						proceed   : "Delete"
						cancel    : "Cancel"
					}
					modal template, true
					$("#canvas-op-confirm").one "click", ()->
						# Do the delete operation
						opts = $.extend true, { force : true }, option
						self.deleteObject null, opts
						modal.close()

			else if result isnt false
				# MC.canvas.remove actually remove the component from MC.canvas_data.component.
				# Consider this as bad coding pattern, because its canvas/model's job to do that.
				MC.canvas.remove $("#" + option.id)[0]
				delete MC.canvas_data.component[option.id]
				this.trigger 'DELETE_OBJECT_COMPLETE'

			else if event && event.preventDefault
				event.preventDefault()

			result

		deleteR_ASG : ( component ) ->

			layout_data = MC.canvas_data.layout.component.node[component.uid]

			asg_uid = component.uid

			if component.resource.LaunchConfigurationName
				lc_uid = component.resource.LaunchConfigurationName.split('.')[0][1...]
				delete MC.canvas_data.component[lc_uid]

			MC.canvas.remove $("#" + asg_uid)[0]

			$.each MC.canvas_data.layout.component.group, ( comp_uid, comp ) ->

				if comp.type == constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group and comp.originalId is asg_uid

					MC.canvas.remove $("#" + comp_uid)[0]

				null

			delete MC.canvas_data.component[component.uid]

			false

		deleteR_ASG_LC : ( component ) ->

			layout_data = MC.canvas_data.layout.component.node[component.uid]

			if layout_data

				asg_uid = layout_data.groupUId

				lc_uid = layout_data.originalId

				MC.canvas.remove $("#" + lc_uid)[0]

				existing = false

				$.each MC.canvas_data.layout.component.node, ( comp_uid, comp ) ->

					if comp.type == constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration and comp.originalId is lc_uid

						existing = true

						return false

					null

				if not existing

					delete MC.canvas_data.component[lc_uid]


			false

		deleteR_Instance : ( component ) ->

			resource_type = constant.AWS_RESOURCE_TYPE

			for key, value of MC.canvas_data.component

				# remove instance relate sg rule or sg
				if value.type == resource_type.AWS_EC2_SecurityGroup
					this._removeInstanceFromSG key, component.uid

				# remove instance relate eni

				else if value.type == resource_type.AWS_VPC_NetworkInterface
					if MC.extractID( value.resource.Attachment.InstanceId ) == component.uid

						# reset eni after disconnect instance
						value.resource.Attachment.InstanceId = ''

						if "" + value.resource.Attachment.DeviceIndex == "0"
							delete MC.canvas_data.component[key]

				# remove instance relate volume

				else if value.type == resource_type.AWS_EBS_Volume
					if MC.extractID( value.resource.AttachmentSet.InstanceId ) == component.uid
						delete MC.canvas_data.component[key]

				# remove instance relate eip

				else if value.type == resource_type.AWS_EC2_EIP
					if MC.extractID( value.resource.InstanceId ) == component.uid
						delete MC.canvas_data.component[key]

				# remove instance relate routetable
				else if value.type == resource_type.AWS_VPC_RouteTable

					this._removeGatewayIdFromRT key, component.uid

			null

		deleteR_Eni : ( component ) ->
			for key, value of MC.canvas_data.component
				if value.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
					this._removeGatewayIdFromRT key, component.uid
				else if value.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
					if MC.extractID( value.resource.NetworkInterfaceId ) == component.uid
						delete mc.canvas_data.component[ key ]

			null

		deleteR_RouteTable : ( component ) ->
			if component.resource.AssociationSet.length > 0 and "" + component.resource.AssociationSet[0].Main == 'true'
				return "!Main route table #{component.name} cannot be deleted."

			if component.resource.AssociationSet.length > 0
				return "!Subnet must be associated to a route table. "
			null

		deleteR_IGW : ( component, force ) ->

			resource_type = constant.AWS_RESOURCE_TYPE

			if not force
				# Deleting IGW when ELB/EIP in VPC, need to be confirmed by user.
				for key, value of MC.canvas_data.component
					if value.type == resource_type.AWS_EC2_EIP
						confirm = true
						break
					else if value.type == resource_type.AWS_ELB and value.resource.Scheme == "internet-facing"
						confirm = true
						break
				if confirm
					return "Internet-facing Load Balancers or Elastic IP will not function without an Internet Gateway, confirm to delete Internet Gateway?"

			for key, value of MC.canvas_data.component
				if value.type == resource_type.AWS_VPC_RouteTable
					this._removeGatewayIdFromRT key, component.uid

			# Enable IGW in resource panel
			ide_event.trigger ide_event.ENABLE_RESOURCE_ITEM, resource_type.AWS_VPC_InternetGateway

			null

		deleteR_VGW : ( component ) ->

			resource_type = constant.AWS_RESOURCE_TYPE

			for key, value of MC.canvas_data.component
				if value.type == resource_type.AWS_VPC_RouteTable
					this._removeGatewayIdFromRT key, component.uid

				else if value.type == resource_type.AWS_VPC_VPNConnection and MC.extractID( value.resource.VpnGatewayId ) == component.uid
					delete mc.canvas_data.component[ key ]


			# Enable VGW in resource panel
			ide_event.trigger ide_event.ENABLE_RESOURCE_ITEM, resource_type.AWS_VPC_VPNGateway

			null

		deleteR_CGW : ( component ) ->
			for key, value of MC.canvas_data.component
				if value.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection
					continue

				if MC.extractID( value.resource.CustomerGatewayId ) is component.id
					delete MC.canvas_data.component[ key ]
					break

			null

		deleteR_ELB : ( component ) ->
			sg_uid = MC.aws.elb.getElbDefaultSG component.uid
			delete MC.canvas_data.component[ component.uid ]
			delete MC.canvas_data.component[ sg_uid ]

		deleteGroup : ( component, force ) ->
			nodes  = MC.canvas.groupChild( $("#" + (component.uid) )[0] )

			handler = this.beforeDeleteMap[ component.type ]
			if handler
				result = handler.call( this, component )

			# The component prevents deleting
			if result
				return result

			# Ask user to confirm delete parent who has children
			if !force and nodes.length
				return "Deleting #{component.name} will also remove all resources inside. Do you confirm to delete?"


			# It's time to delete the resource,
			# Make sure everything is delete-able at this moment !

			# Delete the parent first
			handler = this.deleteResMap[ component.type ]
			if handler
				handler.call this, component

			# Delete all the children
			for node, index in nodes
				op =
					type : $(node).data().type
					id   : node.id

				# Recursively delete children in this group
				# [ @@@ Warning @@@ ] If there's one child that cannot be deleted for any reason. Data is corrupted.
				this.deleteObject null, op

			false

		deleteR_AZ : ( component ) ->

			# Although Subnet connected with an ELB cannot be delete
			# But if we delete the az, then the its subnets can be deleted.

			# Modify the subnet children to bypass their check
			childSubnetIds = {}
			for key, value of MC.canvas_data.component
				if value.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
					continue

				if value.resource.AvailabilityZone isnt component.name
					continue

				childSubnetIds[ key ] = true

			for key, value of MC.canvas_data.component
				if value.type isnt constant.AWS_RESOURCE_TYPE.AWS_ELB
					continue

				keepArray = []
				for i in value.resource.Subnets
					if not childSubnetIds[ MC.extractID( i ) ]
						keepArray.push i
				value.resource.Subnets = keepArray


			# Update resource panel, so that deleted AZ can be drag again
			# Consider this as bad coding pattern, because it's MC.canvas's job to do that
			# Enable AZ in resource panel
			filter = ( data ) ->
				data.option.name is component.name

			ide_event.trigger ide_event.ENABLE_RESOURCE_ITEM, constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone, filter
			null

		beforeDel_Subnet : ( component ) ->
			for key, value of MC.canvas_data.component
				if value.type isnt constant.AWS_RESOURCE_TYPE.AWS_ELB
					continue

				for sb in value.resource.Subnets
					if sb.indexOf( component.uid ) != -1
						return "!The subnet cannot be deleted since it has association with load balancer."

		deleteR_Subnet : ( component ) ->
			# Delete route table connection
			for key, value of MC.canvas_data.component
				if value.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
					continue

				if "" + value.resource.AssociationSet[0].Main is 'true'
					continue

				for i, index in value.resource.AssociationSet
					if i.SubnetId.indexOf( component.uid ) != -1
						value.resource.AssociationSet.splice index, 1
						return

			# Delete All Associated ACL
			_.each MC.canvas_data.component, (compObj) ->
				compType = compObj.type
				if compType is 'AWS.VPC.NetworkAcl'
					MC.aws.acl.removeAssociationFromACL component.uid, compObj.uid
				null

			null

		deleteLine : ( option ) ->

			portMap   = {}
			for id, port of MC.canvas_data.layout.connection[option.id].target
				portMap[ port ] = id

			# ELB <==> Instance
			if portMap['elb-sg-out'] and portMap['instance-sg']
				MC.aws.elb.removeInstanceFromELB portMap['elb-sg-out'], portMap['instance-sg']
				return

			# ELB <==> Subnet
			if portMap['elb-assoc'] and portMap['subnet-assoc-in']
				MC.aws.elb.removeSubnetFromELB portMap['elb-assoc'], portMap['subnet-assoc-in']
				return

			# Eni <==> Instance
			if portMap['instance-attach'] and portMap['eni-attach']
				MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.InstanceId = ''
				MC.canvas.update portMap['eni-attach'], 'image', 'eni_status', MC.canvas.IMAGE.ENI_CANVAS_UNATTACHED

				#hide sg port of eni when delete line
				#MC.canvas.display portMap['eni-attach'], 'eni_sg_left', false
				#MC.canvas.display portMap['eni-attach'], 'eni_sg_right', false
				return

			# IGW <==> RouteTable
			if portMap['igw-tgt'] and portMap['rtb-tgt-left']

				keepArray = []
				component_resource = MC.canvas_data.component[portMap['rtb-tgt-left']].resource

				for i in component_resource.RouteSet
					if MC.extractID( i.GatewayId ) isnt portMap['igw-tgt']
						keepArray.push i

				component_resource.RouteSet = keepArray
				return


			# Subnet <==> RouteTable
			if portMap['subnet-assoc-out'] and portMap['rtb-src']

				rt_uid = portMap['rtb-src']
				sb_uid = portMap['subnet-assoc-out']

				component_resource = MC.canvas_data.component[rt_uid].resource

				return "!Subnet must be associated to a route table."


			# Instance <==> RouteTable
			if portMap['instance-sg'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

				rt_uid = null

				if portMap['rtb-tgt-left'] then rt_uid = portMap['rtb-tgt-left'] else rt_uid = portMap['rtb-tgt-right']

				keepArray = []
				component_resource = MC.canvas_data.component[ rt_uid ].resource

				for i in component_resource.RouteSet
					if MC.extractID( i.InstanceId ) isnt portMap['instance-sg']
						keepArray.push i

				component_resource.RouteSet = keepArray
				return

			# Eni <==> RouteTable
			if portMap['eni-sg'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

				rt_uid = null

				if portMap['rtb-tgt-left'] then rt_uid = portMap['rtb-tgt-left'] else rt_uid = portMap['rtb-tgt-right']

				remove_index = []
				keepArray = []
				component_resource = MC.canvas_data.component[rt_uid].resource

				for i in component_resource.RouteSet
					if MC.extractID( i.NetworkInterfaceId ) isnt portMap['eni-sg']
						keepArray.push i

				component_resource.RouteSet = keepArray
				return

			# VGW <==> RouteTable
			if portMap['vgw-tgt'] and portMap['rtb-tgt-right']

				component_resource = MC.canvas_data.component[portMap['rtb-tgt-right']].resource
				keepArray = []

				for i in component_resource.RouteSet
					if MC.extractID( i.GatewayId ) != portMap['vgw-tgt']
						keepArray.push i

				component_resource.RouteSet = keepArray
				return

			# VGW <==> CGW
			if portMap['vgw-vpn'] and portMap['cgw-vpn']
				MC.aws.vpn.delVPN(portMap['vgw-vpn'], portMap['cgw-vpn'])
				return

			# Instance/ENI SG
			if portMap['instance-sg'] or portMap['eni-sg'] or portMap['elb-sg-in'] or portMap['elb-sg-out']
				this.trigger 'SHOW_SG_LIST', option.id
				return

			null

		_removeGatewayIdFromRT : ( rt_uid, gateway_instance_uid) ->

			$.each MC.canvas_data.component[rt_uid].resource.RouteSet, ( index, route ) ->

				if route.InstanceId.split('.')[0][1...] == gateway_instance_uid or route.NetworkInterfaceId.split('.')[0][1...] == gateway_instance_uid

					MC.canvas_data.component[rt_uid].resource.RouteSet.splice index, 1

		_removeInstanceFromSG : ( sg_uid, instance_uid ) ->


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


		createLine : ( event, line_id ) ->

			result = this.doCreateLine line_id
			if typeof result is "string"
				notification "error", result

			# We don't need this line
			# Currently need to remove the line here.
			# Because the event cannot be prevented.
			if typeof result is "string" or result is false
				if event and event.preventDefault
					event.preventDefault()

				MC.canvas.remove $("#" + line_id)[0]



		doCreateLine : ( line_id ) ->

			line_option = MC.canvas.lineTarget line_id

			if line_option.length != 2
				return

			console.info line_option[0].uid + ',' + line_option[0].port + " | " + line_option[1].uid + ',' + line_option[1].port

			portMap = {}
			for obj in line_option
				portMap[ obj.port ] = obj.uid


			# ELB <==> Instance
			if portMap['instance-sg'] and portMap['elb-sg-out']
				linkSubnetID = MC.aws.elb.addInstanceAndAZToELB portMap['elb-sg-out'], portMap['instance-sg']

				if linkSubnetID
					# We need to link subnet to the elb.
					MC.canvas.connect portMap['elb-sg-out'], "elb-assoc", linkSubnetID, "subnet-assoc-in"


			# ELB <==> Subnet
			else if portMap['elb-assoc'] and portMap['subnet-assoc-in']
				elbUid       = portMap['elb-assoc']
				deleteE_SLen = MC.aws.elb.addSubnetToELB elbUid, portMap['subnet-assoc-in']

				# Connecting Elb to Subnet might need to disconnect Elb from another Subnet
				if not deleteE_SLen
					return
				subnetLayout = MC.canvas_data.layout.component.group[deleteE_SLen]

				if not subnetLayout
					return

				for i in subnetLayout.connection
					if i.target isnt elbUid
						continue
					# Delete line
					this.deleteObject null, { type : "line", id : i.line }
					break

			# Instance <==> Eni
			else if portMap['instance-attach'] and portMap['eni-attach']

				# check whether instance has position to add one more eni
				instance_component 	= 	MC.canvas_data.component[portMap['instance-attach']]

				instance_type 		= 	instance_component.resource.InstanceType.split('.')

				max_eni_number 		= 	MC.data.config[instance_component.resource.Placement.AvailabilityZone[0...-1]].instance_type[instance_type[0]][instance_type[1]].eni

				current_eni_number 	= 	0

				reach_max 			= 	false

				total_device_index  = 	[0...16]

				for key, value of MC.canvas_data.component
					if value.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and portMap['instance-attach'] == MC.extractID( value.resource.Attachment.InstanceId )

						device_index_int = parseInt(value.resource.Attachment.DeviceIndex, 10)

						if device_index_int in total_device_index

							total_device_index.splice total_device_index.indexOf(device_index_int), 1

						current_eni_number += 1

						if current_eni_number >= max_eni_number
							reach_max = true
							break


				if reach_max
					return "#{instance_component.name}'s Instance Type: #{instance_component.resource.InstanceType} only support at most #{max_eni_number} Network Interfaces (including the primary)."

				MC.canvas.update portMap['eni-attach'], 'image', 'eni_status', MC.canvas.IMAGE.ENI_CANVAS_ATTACHED

				MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.DeviceIndex = total_device_index[0].toString()

				MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.InstanceId = '@' + portMap['instance-attach'] + '.resource.InstanceId'

				#show sg port of eni when create line
				#MC.canvas.display portMap['eni-attach'], 'eni_sg_left', true
				#MC.canvas.display portMap['eni-attach'], 'eni_sg_right', true


			# Subnet <==> RouteTable
			else if portMap['subnet-assoc-out'] and portMap['rtb-src']

				rt_uid = portMap['rtb-src']

				# add association
				assoSet = MC.canvas_data.component[rt_uid].resource.AssociationSet

				if assoSet.length == 0 or "" + assoSet[0].Main != 'true'
					assoSet.push {
						SubnetId     : "@#{portMap['subnet-assoc-out']}.resource.SubnetId"
						Main         : "false"
						RouteTableId : ""
						RouteTableAssociationId : ""
					}

				# remove old connection and data
				for line_uid, comp of MC.canvas_data.layout.connection
					if line_uid == line_id
						continue


					map = {}
					for tgt_comp_uid, tgt_comp_port of comp.target
						map[ tgt_comp_port ] = tgt_comp_uid

					if not map['subnet-assoc-out'] or map['subnet-assoc-out'] isnt portMap['subnet-assoc-out']
						continue



					# remove component data
					old_rt_uid = map['rtb-src']
					assoSet = MC.canvas_data.component[old_rt_uid].resource.AssociationSet

					for asso, index in assoSet
						if MC.extractID( asso.SubnetId ) == map['subnet-assoc-out']
							assoSet.splice index, 1
							break

					MC.canvas.remove $("#" + line_uid)[0]
					break

			# IGW <==> RouteTable
			else if portMap['igw-tgt'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

				rt_uid = if portMap['rtb-tgt-left'] then portMap['rtb-tgt-left'] else portMap['rtb-tgt-right']
				MC.canvas_data.component[rt_uid].resource.RouteSet.push {
					'DestinationCidrBlock' : "0.0.0.0/0",
					'GatewayId'            : "@#{portMap['igw-tgt']}.resource.InternetGatewayId",
					'InstanceId'           : "",
					'InstanceOwnerId'      : "",
					'NetworkInterfaceId'   : "",
					'State'                : "",
					'Origin'               : ""
				}


			# Instance <==> RouteTable
			else if portMap['instance-rtb'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

				rt_uid = if portMap['rtb-tgt-left'] then portMap['rtb-tgt-left'] else portMap['rtb-tgt-right']
				MC.canvas_data.component[rt_uid].resource.RouteSet.push {
					'DestinationCidrBlock' : "0.0.0.0/0",
					'GatewayId'            : "",
					'InstanceId'           : "@#{portMap['instance-rtb']}.resource.InstanceId",
					'InstanceOwnerId'      : "",
					'NetworkInterfaceId'   : "",
					'State'                : "",
					'Origin'               : ""
				}

			# VGW <==> RouteTable
			else if portMap['vgw-tgt'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

				rt_uid = if portMap['rtb-tgt-left'] then portMap['rtb-tgt-left'] else portMap['rtb-tgt-right']
				MC.canvas_data.component[rt_uid].resource.RouteSet.push {
					'DestinationCidrBlock' : "0.0.0.0/0",
					'GatewayId'            : "@#{portMap['vgw-tgt']}.resource.VpnGatewayId",
					'InstanceId'           : "",
					'InstanceOwnerId'      : "",
					'NetworkInterfaceId'   : "",
					'State'                : "",
					'Origin'               : ""
				}

			# Eni <==> RouteTable
			else if portMap['eni-rtb'] and ( portMap['rtb-tgt-left'] or portMap['rtb-tgt-right'] )

				rt_uid = if portMap['rtb-tgt-left'] then portMap['rtb-tgt-left'] else portMap['rtb-tgt-right']
				MC.canvas_data.component[rt_uid].resource.RouteSet.push {
					'DestinationCidrBlock' : "0.0.0.0/0",
					'GatewayId'            : "",
					'InstanceId'           : "",
					'InstanceOwnerId'      : "",
					'NetworkInterfaceId'   : "@#{portMap['eni-rtb']}.resource.NetworkInterfaceId",
					'State'                : "",
					'Origin'               : ""
				}

			# VGW <==> CGW
			else if portMap['vgw-vpn'] and portMap['cgw-vpn']
				MC.aws.vpn.addVPN(portMap['vgw-vpn'], portMap['cgw-vpn'])


			for key, value of portMap
				if key.indexOf('sg') >= 0
					this.trigger 'CREATE_SG_CONNECTION', line_id
			null


		#after drag component from resource panel to canvas
		createComponent : ( event, uid ) ->
			resource_type = constant.AWS_RESOURCE_TYPE

			componentType = MC.canvas_data.component[uid]
			componentType = if componentType then componentType.type else resource_type.AWS_EC2_AvailabilityZone

			switch componentType

				when resource_type.AWS_ELB
					MC.aws.elb.init(uid)

				when resource_type.AWS_VPC_InternetGateway
					ide_event.trigger ide_event.DISABLE_RESOURCE_ITEM, componentType

				when resource_type.AWS_VPC_VPNGateway
					ide_event.trigger ide_event.DISABLE_RESOURCE_ITEM, componentType

				when resource_type.AWS_VPC_Subnet
					# Connect to main RT
					for key, value of MC.canvas_data.component
						if value.type isnt resource_type.AWS_VPC_RouteTable
							continue

						if "" + value.resource.AssociationSet[0].Main is 'true'
							rtId = key
							break

					MC.canvas.connect uid, "subnet-assoc-out", rtId, 'rtb-src'

					# Associate to default acl
					defaultACLComp = MC.aws.acl.getDefaultACL()
					MC.aws.acl.addAssociationToACL uid, defaultACLComp.uid

			console.log "Morris : #{componentType}"

			#
			this.trigger 'CREATE_COMPONENT_COMPLETE'

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
					for comp_uid, comp of MC.canvas_data.component
						if comp.type isnt constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP or MC.extractID( comp.resource.InstanceId ) isnt uid
							delete 	MC.canvas_data.component[comp_uid]
							break

				else if state == 'off'

					eip_json = $.extend true, {}, MC.canvas.EIP_JSON.data
					eip_json.uid = MC.guid()
					eip_json.resource.InstanceId = "@#{uid}.resource.InstanceId"

					data = MC.canvas.data.get('component')
					data[ eip_json.uid ] = eip_json
					MC.canvas.data.set('component', data)

				return


			## ## ## ## ## ##
			# For VPC stack
			existing_eip_ref = []
			instanceId = ""

			# collect all reference
			for comp_uid, comp of MC.canvas_data.component
				if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and comp.resource.PrivateIpAddress
					existing_eip_ref.push comp.resource.PrivateIpAddress

			# Find ENI
			eni = MC.canvas_data.component[uid]

			if eni.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
				eni = null
				for comp_uid, comp of MC.canvas_data.component
					if comp.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
						continue

					if "" + comp.resource.Attachment.DeviceIndex isnt "0"
						continue

					if MC.extractID( comp.resource.Attachment.InstanceId ) isnt uid
						continue

					eni = comp
					break

				instanceId = "@#{uid}.resource.InstanceId"


			ip_number = eni.resource.PrivateIpAddressSet.length

			_.map [0...ip_number], ( index ) ->

				eip_ref = "@#{eni.uid}.resource.PrivateIpAddressSet.#{index}.PrivateIpAddress"

				if state == 'off' and (eip_ref not in existing_eip_ref)

					eip_json = $.extend true, {}, MC.canvas.EIP_JSON.data

					eip_json.resource.InstanceId = instanceId
					eip_json.resource.NetworkInterfaceId = "@#{eni.uid}.resource.NetworkInterfaceId"
					eip_json.uid = MC.guid()
					eip_json.resource.PrivateIpAddress = eip_ref
					eip_json.resource.Domain = 'vpc'

					data = MC.canvas.data.get('component')

					data[eip_json.uid] = eip_json

					MC.canvas.data.set('component', data)

				else if state == 'on' and eip_ref in existing_eip_ref

					for k, c of MC.canvas_data.component
						if c.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP and c.resource.PrivateIpAddress == eip_ref
							delete MC.canvas_data.component[k]
							break

			if state == 'off'
				MC.canvas.update uid,'image','eip_status', MC.canvas.IMAGE.EIP_ON
				MC.canvas.update uid,'eip','eip_status', 'on'

				# Ask the user the add IGW
				this.askToAddIGW 'EIP'

			else
				MC.canvas.update uid,'image','eip_status', MC.canvas.IMAGE.EIP_OFF
				MC.canvas.update uid,'eip','eip_status', 'off'

		askToAddIGW : ( component ) ->

			resource_type = constant.AWS_RESOURCE_TYPE

			for uid, comp of MC.canvas_data.component
				if comp.type == resource_type.AWS_VPC_InternetGateway
					hasIGW = true
					break

			if hasIGW
				return

			if component.type == resource_type.AWS_ELB
				res = "internet-facing Load Balancer"
			else if component.type == resource_type.AWS_EC2_EIP
				res = "Elastic IP"

			# Confimation
			self = this
			template = MC.template.canvasOpConfirm {
				operation : "add Internet Gateway"
				content   : "Automatically add an Internet Gateway to allow this #{res} to be addressable?"
				color     : "blue"
				proceed   : "Add"
				cancel    : "Don't Add"
			}
			modal template, true
			$("#canvas-op-confirm").one "click", ()->
				modal.close()

				# THIS PIECE OF CODE SHOULD NOT EXIST HERE.
				# BECAUSE THE MODEL DON'T CARE HOW TO CREATE A IGW

				vpc_id   = $('.AWS-VPC-VPC').attr 'id'
				vpc_data = MC.canvas.data.get "layout.component.group.#{vpc_id}"
				vpc_coor = vpc_data.coordinate

				component_size = MC.canvas.COMPONENT_SIZE[ resource_type.AWS_VPC_InternetGateway ]

				node_option =
					groupUId : vpc_id
					name     : "IGW"

				coordinate =
					x : vpc_coor[0] - component_size[1] / 2
					y : vpc_coor[1] + (vpc_data.size[1] - component_size[1]) / 2

				MC.canvas.add resource_type.AWS_VPC_InternetGateway, node_option, coordinate
	}

	model = new CanvasModel()

	return model
