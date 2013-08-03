#############################
#  View Mode for canvas
#############################
define [ 'constant',
		'backbone', 'jquery', 'underscore', 'UI.modal' ], ( constant ) ->

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
				#'AWS_EBS_Volume'           : 'Volume'
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
			console.log("morris", component)
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

			component = MC.canvas_data.component[ option.id ]

			switch option.type
				when 'node'
					handler = this.deleteResMap[ component.type ]
				when 'group'
					result = this.deleteGroup component, option.force
					if !result
						handler = this.deleteResMap[ component.type ]
				when 'line'
					result = this.deleteLine option

			if handler
				result = handler.call( this, component, option.force )


			if typeof result is "string"
				# Delete Handler returns a comfirmation string.
				# TODO : ###########
				if result[0] == '!'
					# This is an error, not confimation
					if event && event.preventDefault
						event.preventDefault()
					notification "error", result[1...]
				else
					# Confimation
					self = this
					template = MC.template[ "canvasDeleteConfirm" ]( {
						name    : component.name
						content : result
					})
					modal template, true
					$("#canvas-delete-confirm").one "click", ()->
						# Do the delete operation
						opts = $.extend true, { force : true }, option
						self.deleteObject null, opts
						modal.close()

			else if result isnt false
				# MC.canvas.remove actually remove the component from MC.canvas_data.component.
				# Consider this as bad coding pattern, because its canvas/model's job to do that.
				MC.canvas.remove $("#" + option.id)[0]
				this.trigger 'DELETE_OBJECT_COMPLETE'

			else if event && event.preventDefault
				event.preventDefault()

			result

		deleteR_Instance : ( component ) ->

			resource_type = constant.AWS_RESOURCE_TYPE

			for key, value in MC.canvas_data.component

				# remove instance relate sg rule or sg
				if value.type == resource_type.AWS_EC2_SecurityGroup
					this._removeInstanceFromSG key, component.uid

				# remove instance relate eni

				else if value.type == resource_type.AWS_VPC_NetworkInterface
					if MC.extractID( value.resource.Attachment.InstanceId ) == component.uid

						# reset eni after disconnect instance
						value.resource.Attachment.InstanceId = ''

						if "" + value.resource.Attachment.DeviceIndex == "0"
							delete MC.canvas_data.component[index]

				# remove instance relate volume

				else if value.type == resource_type.AWS_EBS_Volume
					if MC.extractID( value.resource.AttachmentSet.InstanceId ) == component.uid
						delete MC.canvas_data.component[index]

				# remove instance relate eip

				else if value.type == resource_type.AWS_EC2_EIP
					if MC.extractID( value.resource.InstanceId ) == component.uid
						delete MC.canvas_data.component[index]

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
				return '!Main route table #{ component.name } cannot be deleted.'
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
					return "Internet-facing Load Balancers or Elastic IP will not function without an Internet Gateway, conﬁrm to delete Internet Gateway?"
				null

			for key, value of MC.canvas_data.component
				if value.type == resource_type.AWS_VPC_RouteTable
					this._removeGatewayIdFromRT key, component.uid

			$.each $(".resource-item[data-type='#{resource_type.AWS_VPC_InternetGateway}']"), ( idx, item ) ->
				data = $(item).data()
				tmp  =
					enable  : true
					tooltip : "Drag and drop to canvas to create a new Internet Gateway."

				$(item)
					.data(tmp)
					.removeClass('resource-disabled')

				return false


			null

		deleteR_VGW : ( component ) ->

			resource_type = constant.AWS_RESOURCE_TYPE

			for key, value of MC.canvas_data.component
				if value.type == resource_type.AWS_VPC_RouteTable
					this._removeGatewayIdFromRT key, component.uid

				else if value.type == resource_type.AWS_VPC_VPNConnection and MC.extractID( value.resource.VpnGatewayId ) == component.uid
					delete mc.canvas_data.component[ key ]

			$.each $(".resource-item[data-type='#{resource_type.AWS_VPC_VPNGateway}']"), ( idx, item ) ->

				data = $(item).data()
				tmp  =
					enable : true
					tooltip: "Drag and drop to canvas to create a new VPN Gateway."

				$(item)
					.data(tmp)
					.removeClass('resource-disabled')

				return false

			null

		deleteR_CGW : ( component ) ->
			for key, value of MC.canvas_data.component
				if value.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection
					continue

				if MC.extractID( value.resource.CustomerGatewayId ) is component.id
					delete MC.canvas_data.component[ key ]
					break

			null

		deleteGroup : ( component, force ) ->
			nodes  = MC.canvas.groupChild($("#" + component.uid)[0])
			result = true

			handler = this.beforeDeleteMap[ component.type ]
			if handler
				result = handler.call( this, component )

			# The component prevents deleting
			if result
				return result

			# Ask user to confirm delete parent who has children
			if !force and nodes.length
				return "Deleting #{component.name} will also remove all resources inside. Do you confirm to delete?"

			# Delete all the children
			for node, index in nodes
				op =
					type : $(node).data().type
					id   : node.id

				# Recursively delete children in this group
				# [ @@@ Warning @@@ ] If there's one child that cannot be deleted for any reason. Data is corrupted.
				this.deleteObject null, op

			null


		deleteR_AZ : ( component ) ->
			# Update resource panel, so that deleted AZ can be drag again
			# Consider this as bad coding pattern, because it's MC.canvas's job to do that
			$.each $(".resource-item[data-type='#{constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone}']"), ( idx, item ) ->

				$item = $(item)
				data  = $item.data()
				if data.option.name isnt component.name
					return

				tmp =
					enable : true
					tooltip: "Drag and drop to canvas"

				$(item)
					.data(tmp)
					.removeClass('resource-disabled')
					.addClass("tooltip")
				return false
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

				# Do nothing if the RT is main RT
				if component_resource.AssociationSet.length and "" + component_resource.AssociationSet[0].Main == 'true'
					return false

				# Disconnect
				for i, index in component_resource.AssociationSet
					if MC.extractID( i.SubnetId ) is sb_uid
						component_resource.AssociationSet.splice index, 1
						break

				# Connect to Main
				for key, value of MC.canvas_data.component
					if value.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
						if value.resource.AssociationSet.length and "" + value.resource.AssociationSet[0].Main is 'true'
							mainRT_Id = key
							break

				if mainRT_Id
					MC.canvas.connect sb_uid, 'subnet-assoc-out', mainRT_Id, 'rtb-src'

				return


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
									this.deleteObject null, {
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
