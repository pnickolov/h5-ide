#############################
#  View Mode for canvas
#############################
define [ 'constant', 'event', 'i18n!/nls/lang.js',
		'backbone', 'jquery', 'underscore', 'UI.modal' ], ( constant, ide_event, lang ) ->

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

		#show notification when place is blank
		showOverlapNotification : () ->

			notification 'warning', lang.ide.CVS_MSG_WARN_COMPONENT_OVERLAP, false
			null

		#show notification when node not matchplace
		showNotMatchNotification : ( comp_type ) ->
			console.log comp_type + ' place to wrong place!'

			res_type = constant.AWS_RESOURCE_TYPE

			switch comp_type

				when res_type.AWS_EBS_Volume            then notification 'warning', lang.ide.CVS_MSG_WARN_NOTMATCH_VOLUME , false

				when res_type.AWS_VPC_Subnet            then notification 'warning', lang.ide.CVS_MSG_WARN_NOTMATCH_SUBNET, false

				when res_type.AWS_EC2_Instance

					if  MC.canvas.data.get('platform') == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC or MC.canvas.data.get('platform') == MC.canvas.PLATFORM_TYPE.DEFAULT_VPC

						notification 'warning', lang.ide.CVS_MSG_WARN_NOTMATCH_INSTANCE_AZ     , false
					else

						notification 'warning', lang.ide.CVS_MSG_WARN_NOTMATCH_INSTANCE_SUBNET , false

				when res_type.AWS_VPC_NetworkInterface  then notification 'warning', lang.ide.CVS_MSG_WARN_NOTMATCH_ENI , false

				when res_type.AWS_VPC_RouteTable        then notification 'warning', lang.ide.CVS_MSG_WARN_NOTMATCH_RTB , false

				when res_type.AWS_ELB                   then notification 'warning', lang.ide.CVS_MSG_WARN_NOTMATCH_ELB , false

				when res_type.AWS_VPC_CustomerGateway   then notification 'warning', lang.ide.CVS_MSG_WARN_NOTMATCH_CGW , false


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
			handler   = if component then this.validateDropMap[ component.type ] else null
			if handler
				error = handler.call( this, component, tgt_parent )
				if error
					event.preventDefault()
					notification "error", error
			else
				console.log "Morris : No handler for validate dragging node:", component

			null

		beforeD_Subnet : ( component, tgt_parent ) ->

			# First set the tgt_parent to
			parent = MC.canvas_data.layout.component.group[ tgt_parent ]
			old_az = component.resource.AvailabilityZone
			component.resource.AvailabilityZone = parent.name

			for uid, node of MC.canvas_data.layout.component.node
				if node.groupUId is component.uid
					handler = this.validateDropMap[ node.type ]
					if handler
						error = handler.call( this, MC.canvas_data.component[uid], component.uid )

					if error
						break

			component.resource.AvailabilityZone = old_az

			error

		beforeD_Instance : ( component, tgt_parent ) ->
			resource_type = constant.AWS_RESOURCE_TYPE
			parent = MC.canvas_data.layout.component.group[ tgt_parent ]

			if parent.type == resource_type.AWS_EC2_AvailabilityZone
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
						return lang.ide.CVS_MSG_ERR_MOVE_ATTACHED_ENI
			null

		beforeD_Eni : ( component, tgt_parent ) ->
			# Eni can only be in subnet
			if MC.canvas_data.component[ tgt_parent ].resource.AvailabilityZone == component.resource.AvailabilityZone
				return

			if component.resource.Attachment.InstanceId
				return lang.ide.CVS_MSG_ERR_MOVE_ATTACHED_ENI
			null

		beforeD_ASG : ( component, tgt_parent ) ->
			for key, group of MC.canvas_data.layout.component.group
				if group.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
					if group.originalId is component.uid and group.groupUId is tgt_parent
						parent = MC.canvas_data.component[ tgt_parent ]
						if !parent
							parent = MC.canvas_data.layout.component.group[ tgt_parent ]

						return sprintf lang.ide.CVS_MSG_ERR_DROP_ASG, component.name, parent.name

		#change node from one parent to another parent
		changeParent : ( event, src_node, tgt_parent ) ->
			node = MC.canvas_data.layout.component.group[src_node]
			if !node
				node = MC.canvas_data.layout.component.node[src_node]
			if !node || !node.groupUId || node.groupUId == tgt_parent
				return

			# Update layout parent id
			node.groupUId = tgt_parent

			# Dispatch the event-handling to real handler
			component = MC.canvas_data.component[ src_node ]

			if !component
				return

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

				else if value.type == resource_type.AWS_AutoScaling_Group
					if value.resource.VPCZoneIdentifier.indexOf( component.uid ) != -1
						this.changeP_ASG value, component.uid

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

		changeP_ASG : ( component, tgt_parent ) ->

			parents = [ tgt_parent ]
			sbs     = []
			azs     = []
			map     = {}

			for uid, node of MC.canvas_data.layout.component.group
				if node.type isnt constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
					continue

				if node.originalId is component.uid
					parents.push node.groupUId

			for p in parents

				parent = MC.canvas_data.component[ p ]

				if parent
					# VPC mode
					az = parent.resource.AvailabilityZone
					sbs.push "@#{p}.resource.SubnetId"
				else
					az = MC.canvas_data.layout.component.group[ p ].name

				if map[ az ]
					continue
				else
					map[ az ] = true
					azs.push az

			component.resource.AvailabilityZones = azs
			component.resource.VPCZoneIdentifier = sbs.join " , "

			null

		deleteObject : ( event, option ) ->

			option = $.extend {}, option

			component = MC.canvas_data.component[ option.id ] ||
			if not component
				component = $.extend true, {uid:option.id}, MC.canvas_data.layout.component.group[ option.id ]

			# Treat ASG as a node, not a group
			if component.type == constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
				option.type = 'node'

			# Find Handler to delete the resource
			switch option.type
				when 'node'
					handler = this.deleteResMap[ component.type ]
					if handler
						result = handler.call( this, component, option.force )
				when 'group'
					result = this.deleteGroup component, option.force
				when 'line'
					result = this.deleteLine option


			# If the handler returns false or string or object,
			# The delete operation is prevented.
			if result

				if typeof result is 'object' and result.error
					if event && event.preventDefault
							event.preventDefault()
						notification "error", result.error

				else if typeof result is "string"
					# Confimation
					self = this
					template = MC.template.canvasOpConfirm {
						operation : sprintf lang.ide.CVS_CFM_DEL, component.name
						content   : result
						color     : "red"
						proceed   : lang.ide.CFM_BTN_DELETE
						cancel    : lang.ide.CFM_BTN_CANCEL
					}
					modal template, true
					$("#canvas-op-confirm").one "click", ()->
						# Do the delete operation
						opts = $.extend true, { force : true }, option
						self.deleteObject null, opts
						modal.close()


			else if result isnt false

				MC.canvas.remove $("#" + option.id)[0]
				delete MC.canvas_data.component[option.id]
				this.trigger 'DELETE_OBJECT_COMPLETE'

			else if event && event.preventDefault
				event.preventDefault()

			result

		deleteR_ASG : ( component, force ) ->
			layout_data = MC.canvas_data.layout.component.group[component.uid]

			if not layout_data
				return

			if layout_data.originalId.length
				# This is a extended ASG
				asg_comp = MC.canvas_data.component[ layout_data.originalId ]
				vpcs = asg_comp.resource.VPCZoneIdentifier.split " , "
				for subnet, i in vpcs
					if subnet.indexOf layout_data.groupUId
						vpcs.splice i, 1
						break
				asg_comp.resource.VPCZoneIdentifier = vpcs.join " , "
				return

			# Ask user to comfirm the delete operation
			if not force
				return sprintf lang.ide.CVS_CFM_DEL_ASG, component.name

			###################################
			###################################
			###################################
			###################################
			###################################
			###################################
			###################################
			###################################
			# Delete the component
			asg_uid = component.uid

			# Delete extentions
			for comp_uid, comp of MC.canvas_data.layout.component.group
				if comp.type == constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group and comp.originalId is asg_uid
					MC.canvas.remove $("#" + comp_uid)[0]

			# Delete the component
			delete MC.canvas_data.component[component.uid]

			if not component.resource.LaunchConfigurationName
				return

			# Delete the LC if there's only one asg is using.
			lc_uid    = component.resource.LaunchConfigurationName
			lc_shared = false
			for comp_uid, comp of MC.canvas_data.component
				if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
					if comp.resource.LaunchConfigurationName is lc_uid
						lc_shared = true
						break

			if not lc_shared
				lc_uid = MC.extractID lc_uid
				delete MC.canvas_data.component[lc_uid]
			null

		deleteR_ASG_LC : ( component, force ) ->
			if not force
				return { error : lang.ide.CVS_MSG_ERR_DEL_LC }

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

					this._removeFromRTB key, component.uid

				# remove all associted ELB
				MC.aws.elb.removeAllELBForInstance(component.uid)

			null

		deleteR_Eni : ( component ) ->
			for key, value of MC.canvas_data.component
				if value.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
					this._removeFromRTB key, component.uid
				else if value.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
					if MC.extractID( value.resource.NetworkInterfaceId ) == component.uid
						delete MC.canvas_data.component[ key ]

			null

		deleteR_RouteTable : ( component ) ->
			if component.resource.AssociationSet.length > 0 and "" + component.resource.AssociationSet[0].Main == 'true'
				return { error : sprintf lang.ide.CVS_MSG_ERR_DEL_MAIN_RT, component.name }

			delete MC.canvas_data.component[component.uid]
			MC.aws.rtb.updateRT_SubnetLines()
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
					return lang.ide.CVS_CFM_DEL_IGW

			for key, value of MC.canvas_data.component
				if value.type == resource_type.AWS_VPC_RouteTable
					this._removeFromRTB key, component.uid

			# Enable IGW in resource panel
			ide_event.trigger ide_event.ENABLE_RESOURCE_ITEM, resource_type.AWS_VPC_InternetGateway

			null

		deleteR_VGW : ( component ) ->

			resource_type = constant.AWS_RESOURCE_TYPE

			for key, value of MC.canvas_data.component
				if value.type == resource_type.AWS_VPC_RouteTable
					this._removeFromRTB key, component.uid

				else if value.type == resource_type.AWS_VPC_VPNConnection and MC.extractID( value.resource.VpnGatewayId ) == component.uid
					delete MC.canvas_data.component[ key ]


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
			elbSGObj = MC.aws.elb.getElbDefaultSG component.uid
			delete MC.canvas_data.component[ component.uid ]
			delete MC.canvas_data.component[ elbSGObj.uid ]

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
				return sprintf lang.ide.CVS_CFM_DEL_GROUP, component.name


			# It's time to delete the resource,
			# Make sure everything is delete-able at this moment !

			# Delete the parent first
			handler = this.deleteResMap[ component.type ]
			if handler
				handler.call this, component

			# Delete all the children
			for node, index in nodes
				op =
					type  : $(node).data().type
					id    : node.id
					force : true

				# Recursively delete children in this group
				# [ @@@ Warning @@@ ] If there's one child that cannot be deleted for any reason. Data is corrupted.
				this.deleteObject null, op

			null

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
				az_idx = value.resource.AvailabilityZones.indexOf component.name
				if az_idx != -1
					value.resource.AvailabilityZones.splice az_idx, 1


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
						return { error : lang.ide.CVS_MSG_ERR_DEL_LINKED_ELB }

		deleteR_Subnet : ( component ) ->
			# Delete route table connection
			for key, value of MC.canvas_data.component
				if value.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
					continue

				if not value.resource.AssociationSet.length
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
				if compType is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
					MC.aws.acl.removeAssociationFromACL component.uid, compObj.uid
				null

			null

		deleteLine : ( option ) ->
			me = this
			portMap   = {}
			for id, port of MC.canvas_data.layout.connection[option.id].target
				portMap[ port ] = id

			# ELB <==> Subnet
			if portMap['elb-assoc'] and portMap['subnet-assoc-in']
				elbUID = portMap['elb-assoc']
				subnetUID = portMap['subnet-assoc-in']
				if !MC.aws.subnet.isCanDeleteSubnetToELBConnection(elbUID)
					return { error : lang.ide.CVS_MSG_ERR_DEL_ELB_INSTANCE_LINE }
				MC.aws.elb.removeSubnetFromELB elbUID, subnetUID

			# Eni <==> Instance
			else if portMap['instance-attach'] and portMap['eni-attach']
				MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.InstanceId = ''
				MC.canvas.update portMap['eni-attach'], 'image', 'eni_status', MC.canvas.IMAGE.ENI_CANVAS_UNATTACHED
				ide_event.trigger ide_event.REDRAW_SG_LINE

				#hide sg port of eni when delete line
				#MC.canvas.display portMap['eni-attach'], 'eni_sg_left', false
				#MC.canvas.display portMap['eni-attach'], 'eni_sg_right', false

			# IGW <==> RouteTable
			else if portMap['igw-tgt'] and portMap['rtb-tgt']

				keepArray = []
				component_resource = MC.canvas_data.component[portMap['rtb-tgt']].resource

				for i in component_resource.RouteSet
					if MC.extractID( i.GatewayId ) isnt portMap['igw-tgt']
						keepArray.push i

				component_resource.RouteSet = keepArray
				return


			# Subnet <==> RouteTable
			else if portMap['subnet-assoc-out'] and portMap['rtb-src']

				rt_uid = portMap['rtb-src']
				sb_uid = portMap['subnet-assoc-out']

				# Remove asso
				assoSet = MC.canvas_data.component[ rt_uid ].resource.AssociationSet
				for asso, index in assoSet
					if asso.SubnetId.indexOf( sb_uid ) != -1
						assoSet.splice index, 1
						break

				# If this is main rt, keep the connection
				if assoSet.length and "" + assoSet[0].Main is "true"
					return false
				else
					MC.canvas.connect sb_uid, "subnet-assoc-out", this._findMainRT(), 'rtb-src'
					return

			# Instance <==> RouteTable
			else if portMap['instance-rtb'] and portMap['rtb-tgt']

				rt_uid = null

				rt_uid = portMap['rtb-tgt']

				keepArray = []
				component_resource = MC.canvas_data.component[ rt_uid ].resource

				for i in component_resource.RouteSet
					if MC.extractID( i.InstanceId ) isnt portMap['instance-rtb']
						keepArray.push i

				component_resource.RouteSet = keepArray

			# Eni <==> RouteTable
			else if portMap['eni-rtb'] and portMap['rtb-tgt']

				rt_uid = null

				rt_uid = portMap['rtb-tgt']

				remove_index = []
				keepArray = []
				component_resource = MC.canvas_data.component[rt_uid].resource

				for i in component_resource.RouteSet
					if MC.extractID( i.NetworkInterfaceId ) isnt portMap['eni-rtb']
						keepArray.push i

				component_resource.RouteSet = keepArray

			# VGW <==> RouteTable
			else if portMap['vgw-tgt'] and portMap['rtb-tgt']

				component_resource = MC.canvas_data.component[portMap['rtb-tgt']].resource
				keepArray = []

				for i in component_resource.RouteSet
					if MC.extractID( i.GatewayId ) != portMap['vgw-tgt']
						keepArray.push i

				component_resource.RouteSet = keepArray

			# VGW <==> CGW
			else if portMap['vgw-vpn'] and portMap['cgw-vpn']
				MC.aws.vpn.delVPN(portMap['vgw-vpn'], portMap['cgw-vpn'])

			# === SG Lines ===
			# ELB <==> Instance
			else if portMap['elb-sg-out'] and portMap['instance-sg']
				MC.aws.elb.removeInstanceFromELB portMap['elb-sg-out'], portMap['instance-sg']

			# SG Supports
			if portMap['instance-sg'] or portMap['eni-sg'] or portMap['elb-sg-in'] or portMap['launchconfig-sg']

				if portMap['elb-sg-out'] and portMap['launchconfig-sg']
					elb_ref = '@' + portMap['elb-sg-out'] + '.resource.LoadBalancerName'
                    # if select the main launch configuration and elb line
					if MC.canvas_data.component[portMap['launchconfig-sg']]

						selected_line_id = option.id

						original_group_uid = MC.canvas_data.layout.component.node[portMap['launchconfig-sg']].groupUId

						#reset health  check type
						MC.canvas_data.component[original_group_uid].resource.HealthCheckType = 'EC2'

						$.each MC.canvas_data.layout.component.group, ( comp_uid, comp ) ->

	                        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group and comp.originalId is original_group_uid

	                        	$.each MC.canvas_data.layout.connection, ( line_id, line )->

	                        		if line.type is 'elb-sg'
	                        			tmp_map = {}
	                        			$.each line.target, (k, v)->
	                        				tmp_map[v] = k
	                        				null

	                        			if tmp_map['elb-sg-out'] is portMap['elb-sg-out'] and tmp_map['launchconfig-sg'] is comp_uid
	                        				MC.canvas.remove $("#" + line_id)[0]

	                        				return false

	                        			if tmp_map['elb-sg-out'] is portMap['elb-sg-out'] and tmp_map['launchconfig-sg'] is portMap['launchconfig-sg']

	                        				selected_line_id = line_id

	                        			null
	                    elb_index = MC.canvas_data.component[original_group_uid].resource.LoadBalancerNames.indexOf(elb_ref)
						if elb_index >= 0
							MC.canvas_data.component[original_group_uid].resource.LoadBalancerNames.splice elb_index, 1
						MC.canvas.remove $("#" + selected_line_id)[0]
                    # select the expand lanchconfiguration and elb line
					else
						original_group_uid = MC.canvas_data.layout.component.group[portMap['launchconfig-sg']].originalId

						#reset health  check type
						MC.canvas_data.component[original_group_uid].resource.HealthCheckType = 'EC2'

						$.each MC.canvas_data.layout.component.node, ( comp_uid, comp ) ->

							if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration and comp.groupUId is original_group_uid

								elb_index = MC.canvas_data.component[original_group_uid].resource.LoadBalancerNames.indexOf(elb_ref)
								if elb_index >= 0
									MC.canvas_data.component[original_group_uid].resource.LoadBalancerNames.splice elb_index, 1

								$.each MC.canvas_data.layout.connection, ( l_id, line_comp ) ->

							        tmp_portMap = {}

							        $.each line_comp.target, ( key, val ) ->

							            tmp_portMap[val] = key

							            null

							        if tmp_portMap['elb-sg-out'] is portMap['elb-sg-out'] and tmp_portMap['launchconfig-sg'] is comp_uid

							            MC.canvas.remove $("#" + l_id)[0]

							        else
							        	$.each MC.canvas_data.layout.component.group, ( group_id, group ) ->

							        		if group.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group and group.originalId and group.originalId is original_group_uid

							        			if tmp_portMap['elb-sg-out'] is portMap['elb-sg-out'] and tmp_portMap['launchconfig-sg'] is group_id

							        				MC.canvas.remove $("#" + l_id)[0]

							        				return false

				else if portMap['launchconfig-sg']

					line_id = MC.aws.lc.getLCLine option.id

					this.trigger 'SHOW_SG_LIST', line_id

				else if portMap['elb-sg-out'] and portMap['instance-sg']
					instnace_ref = '@' + portMap['instance-sg'] + '.resource.InstanceId'
					instance_index = MC.canvas_data.component[portMap['elb-sg-out']].resource.Instances.indexOf(instnace_ref)
					if instance_index >= 0
						MC.canvas_data.component[portMap['elb-sg-out']].resource.Instances.splice instance_index, 1
					MC.canvas.remove $("#" + option.id)[0]

				else
					this.trigger 'SHOW_SG_LIST', option.id

				# Deleting SG needs confirmation, return false to prevent the line being deleted.
				return false

			null

		_removeFromRTB : ( rt_uid, component_uid ) ->

			routeSet  = MC.canvas_data.component[rt_uid].resource.RouteSet

			for route, i in routeSet
				if route.GatewayId.indexOf( component_uid ) != -1 or route.InstanceId.indexOf( component_uid ) != -1 or route.NetworkInterfaceId.indexOf( component_uid ) != -1
					routeSet.splice i, 1
					break

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
				instance_component = MC.canvas_data.component[portMap['instance-attach']]
				eni_component      = MC.canvas_data.component[portMap['eni-attach']]
				if eni_component.resource.AvailabilityZone isnt instance_component.resource.Placement.AvailabilityZone
					return lang.ide.CVS_MSG_ERR_CONNECT_ENI_AMI

				instance_type 		= 	instance_component.resource.InstanceType.split('.')

				max_eni_number 		= 	MC.data.config[instance_component.resource.Placement.AvailabilityZone[0...-1]].instance_type[instance_type[0]][instance_type[1]].eni

				current_eni_number 	= 	0

				reach_max 			= 	false

				total_device_index  = 	[0...16]

				assoc_public_ip 	= 	false

				main_eni_uid 		= 	null

				for key, value of MC.canvas_data.component
					if value.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and portMap['instance-attach'] == MC.extractID( value.resource.Attachment.InstanceId )

						device_index_int = parseInt(value.resource.Attachment.DeviceIndex, 10)

						if device_index_int in total_device_index

							total_device_index.splice total_device_index.indexOf(device_index_int), 1

						current_eni_number += 1

						if current_eni_number >= max_eni_number
							reach_max = true
							break

						for comp_uid, comp of MC.canvas_data.component

							if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and MC.extractID( comp.resource.Attachment.InstanceId ) is portMap['instance-attach'] and comp.resource.Attachment.DeviceIndex in ['0',0] and comp.resource.AssociatePublicIpAddress

								main_eni_uid = comp_uid

								assoc_public_ip = true




				if reach_max
					return sprintf lang.ide.CVS_WARN_EXCEED_ENI_LIMIT, instance_component.name, instance_component.resource.InstanceType, max_eni_number

				if assoc_public_ip
					template = MC.template.modalAttachingEni {
						host : MC.canvas_data.component[portMap['instance-attach']].name
						eni  : MC.canvas_data.component[portMap['eni-attach']].name
					}
					modal template, true
					$("#canvas-op-confirm").one "click", ()->
						if main_eni_uid

							MC.canvas_data.component[main_eni_uid].resource.AssociatePublicIpAddress = false

							MC.canvas.update portMap['eni-attach'], 'image', 'eni_status', MC.canvas.IMAGE.ENI_CANVAS_ATTACHED

							MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.DeviceIndex = total_device_index[0].toString()

							MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.InstanceId = '@' + portMap['instance-attach'] + '.resource.InstanceId'

							MC.canvas.connect $("#"+portMap['instance-attach']), 'instance-attach', $("#"+portMap['eni-attach']), 'eni-attach'

						modal.close()

					MC.canvas.remove $("#" + line_id)[0]
				else

					MC.canvas.update portMap['eni-attach'], 'image', 'eni_status', MC.canvas.IMAGE.ENI_CANVAS_ATTACHED

					MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.DeviceIndex = total_device_index[0].toString()

					MC.canvas_data.component[portMap['eni-attach']].resource.Attachment.InstanceId = '@' + portMap['instance-attach'] + '.resource.InstanceId'

				ide_event.trigger ide_event.REDRAW_SG_LINE
				#show sg port of eni when create line
				#MC.canvas.display portMap['eni-attach'], 'eni_sg_left', true
				#MC.canvas.display portMap['eni-attach'], 'eni_sg_right', true


			# Subnet <==> RouteTable
			else if portMap['subnet-assoc-out'] and portMap['rtb-src']

				rt_uid = portMap['rtb-src']
				sb_uid = portMap['subnet-assoc-out']

				# add association
				assoSet = MC.canvas_data.component[rt_uid].resource.AssociationSet
				assoSet.push {
					SubnetId     : "@#{portMap['subnet-assoc-out']}.resource.SubnetId"
					Main         : "false"
					RouteTableId : ""
					RouteTableAssociationId : ""
				}

				for line_uid, comp of MC.canvas_data.layout.connection
					if line_uid is line_id
						continue

					if comp.target[ sb_uid ] isnt 'subnet-assoc-out'
						continue

					map = {}
					for tgt_comp_uid, tgt_comp_port of comp.target
						map[ tgt_comp_port ] = tgt_comp_uid

					if not map['rtb-src']
						continue

					assoSet = MC.canvas_data.component[ map['rtb-src'] ].resource.AssociationSet
					for asso, index in assoSet
						if asso.SubnetId.indexOf( sb_uid ) != -1
							assoSet.splice index, 1
							break

					MC.canvas.remove document.getElementById line_uid
					break

			# IGW <==> RouteTable
			else if portMap['igw-tgt'] and ( portMap['rtb-tgt'] or portMap['rtb-tgt'] )

				rt_uid = if portMap['rtb-tgt'] then portMap['rtb-tgt'] else portMap['rtb-tgt']
				MC.canvas_data.component[rt_uid].resource.RouteSet.push {
					'DestinationCidrBlock' : "0.0.0.0/0",
					'GatewayId'            : "@#{portMap['igw-tgt']}.resource.InternetGatewayId",
					'InstanceId'           : "",
					'InstanceOwnerId'      : "",
					'NetworkInterfaceId'   : "",
					'State'                : "",
					'Origin'               : ""
				}

				MC.canvas.select(line_id)

			# Instance <==> RouteTable
			else if portMap['instance-rtb'] and ( portMap['rtb-tgt'] or portMap['rtb-tgt'] )

				rt_uid = if portMap['rtb-tgt'] then portMap['rtb-tgt'] else portMap['rtb-tgt']
				MC.canvas_data.component[rt_uid].resource.RouteSet.push {
					'DestinationCidrBlock' : "",
					'GatewayId'            : "",
					'InstanceId'           : "@#{portMap['instance-rtb']}.resource.InstanceId",
					'InstanceOwnerId'      : "",
					'NetworkInterfaceId'   : "",
					'State'                : "",
					'Origin'               : ""
				}

				MC.canvas.select(line_id)

			# VGW <==> RouteTable
			else if portMap['vgw-tgt'] and ( portMap['rtb-tgt'] or portMap['rtb-tgt'] )

				rt_uid = if portMap['rtb-tgt'] then portMap['rtb-tgt'] else portMap['rtb-tgt']
				MC.canvas_data.component[rt_uid].resource.RouteSet.push {
					'DestinationCidrBlock' : "",
					'GatewayId'            : "@#{portMap['vgw-tgt']}.resource.VpnGatewayId",
					'InstanceId'           : "",
					'InstanceOwnerId'      : "",
					'NetworkInterfaceId'   : "",
					'State'                : "",
					'Origin'               : ""
				}

				MC.canvas.select(line_id)

			# Eni <==> RouteTable
			else if portMap['eni-rtb'] and ( portMap['rtb-tgt'] or portMap['rtb-tgt'] )

				rt_uid = if portMap['rtb-tgt'] then portMap['rtb-tgt'] else portMap['rtb-tgt']
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
				MC.canvas.select(line_id)

			else if portMap['elb-sg-out'] and portMap['launchconfig-sg']

				elb_ref = '@' + portMap['elb-sg-out'] + '.resource.LoadBalancerName'

				if elb_ref not in MC.canvas_data.component[MC.canvas_data.layout.component.node[portMap['launchconfig-sg']].groupUId].resource.LoadBalancerNames

					MC.canvas_data.component[MC.canvas_data.layout.component.node[portMap['launchconfig-sg']].groupUId].resource.LoadBalancerNames.push elb_ref

				# expand asg need to draw the connection between elb and asg
				asg_uid = MC.canvas_data.layout.component.node[portMap['launchconfig-sg']].groupUId

				$.each MC.canvas_data.layout.component.group, ( comp_uid, comp ) ->

					if comp.type is 'AWS.AutoScaling.Group' and comp.originalId and comp.originalId is asg_uid

						MC.canvas.connect $("#"+portMap['elb-sg-out']), 'elb-sg-out', $("#"+comp_uid), 'launchconfig-sg'


			if not (MC.canvas_data.platform is MC.canvas.PLATFORM_TYPE.EC2_CLASSIC and (portMap['elb-sg-in'] or portMap['elb-sg-out']))
				for key, value of portMap
					if key.indexOf('sg') >= 0
						this.trigger 'CREATE_SG_CONNECTION', line_id
						break
			null


		#after drag component from resource panel to canvas
		_findMainRT : () ->
			resource_type = constant.AWS_RESOURCE_TYPE
			for key, value of MC.canvas_data.component
					if value.type isnt resource_type.AWS_VPC_RouteTable
						continue

					if not value.resource.AssociationSet.length
						continue

					if "" + value.resource.AssociationSet[0].Main is 'true'
						return key
			null

		createComponent : ( event, uid ) ->
			resource_type = constant.AWS_RESOURCE_TYPE

			componentType = if MC.canvas_data.component[uid] then MC.canvas_data.component[uid] else MC.canvas_data.layout.component.group[uid]
			componentType = if componentType then componentType.type else resource_type.AWS_EC2_AvailabilityZone

			switch componentType

				when resource_type.AWS_EC2_Instance
					subnetUIDRef = MC.canvas_data.component[uid].resource.SubnetId
					subnetUID = subnetUIDRef.split('.')[0].slice(1)
					MC.aws.subnet.updateAllENIIPList(subnetUID)
					#update sg color label
					MC.aws.sg.updateSGColorLabel uid

				when resource_type.AWS_ELB
					MC.aws.elb.init(uid)

				when resource_type.AWS_VPC_InternetGateway
					ide_event.trigger ide_event.DISABLE_RESOURCE_ITEM, componentType
					# Automatically connect IGW and main RT
					# Coommented out, because we don't need to add the route anymore.
					# line_id = MC.canvas.connect uid, "igw-tgt", this._findMainRT(), 'rtb-tgt'
					# this.createLine null, line_id

				when resource_type.AWS_VPC_VPNGateway
					ide_event.trigger ide_event.DISABLE_RESOURCE_ITEM, componentType

				when resource_type.AWS_VPC_Subnet
					# Connect to main RT
					line_id = MC.canvas.connect uid, "subnet-assoc-out", this._findMainRT(), 'rtb-src'

					# Associate to default acl
					defaultACLComp = MC.aws.acl.getDefaultACL()
					MC.aws.acl.addAssociationToACL uid, defaultACLComp.uid

					# select subnet
					if MC.canvas_data.component[uid].autoCreate
						MC.canvas.select(uid)
						delete MC.canvas_data.component[uid].autoCreate

				when resource_type.AWS_AutoScaling_Group
					if MC.canvas_data.layout.component.group[uid].originalId
						asg_comp = MC.canvas_data.component[MC.canvas_data.layout.component.group[uid].originalId]
						if asg_comp and asg_comp.resource.LoadBalancerNames.length > 0
							$.each asg_comp.resource.LoadBalancerNames, (idx, loadbalancername)->
						 		lb_uid = loadbalancername.split('.')[0].slice(1)
						 		MC.canvas.connect($("#"+lb_uid), 'elb-sg-out', $("#"+uid), 'launchconfig-sg')

			if componentType in [resource_type.AWS_AutoScaling_Group, resource_type.AWS_VPC_NetworkInterface, resource_type.AWS_EC2_Instance, resource_type.AWS_ELB]
				ide_event.trigger ide_event.REDRAW_SG_LINE

			console.log "Morris : #{componentType}"

		reDrawSgLine : () ->
			MC.canvas.reDrawSgLine()
			# lines = []

			# sg_refs = []

			# $.each MC.canvas_data.component, ( comp_uid, comp ) ->

			# 	if comp.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup

			# 		$.each comp.resource.IpPermissions, ( i, rule ) ->

			# 			if rule.IpRanges.indexOf('@') >= 0

			# 				to_sg_uid = rule.IpRanges.split('.')[0][1...]

			# 				if to_sg_uid isnt comp.uid

			# 					from_key = comp.uid + '|' + to_sg_uid

			# 					to_key = to_sg_uid + '|' + comp.uid

			# 					if (from_key not in sg_refs) and (to_key not in sg_refs)

			# 						sg_refs.push from_key

			# 		$.each comp.resource.IpPermissionsEgress, ( i, rule ) ->

			# 			if rule.IpRanges.indexOf('@') >= 0

			# 				to_sg_uid = rule.IpRanges.split('.')[0][1...]

			# 				if to_sg_uid isnt comp.uid

			# 					from_key = comp.uid + '|' + to_sg_uid

			# 					to_key = to_sg_uid + '|' + comp.uid

			# 					if (from_key not in sg_refs) and (to_key not in sg_refs)

			# 						sg_refs.push to_key

			# $.each sg_refs, ( i, val ) ->

			# 	uids = val.split('|')

			# 	from_sg_uid = uids[0]

			# 	to_sg_uid = uids[1]

			# 	from_sg_group = []

			# 	to_sg_group = []

			# 	$.each MC.canvas_data.component, ( comp_uid, comp )->

			# 		switch comp.type

			# 			when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

			# 				if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

			# 					$.each comp.resource.SecurityGroupId, ( idx, sgs )->

			# 						if sgs.split('.')[0][1...] == from_sg_uid

			# 							from_sg_group.push comp.uid

			# 						if sgs.split('.')[0][1...] == to_sg_uid

			# 							to_sg_group.push comp.uid

			# 			when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

			# 				$.each comp.resource.GroupSet, ( idx, sgs )->

			# 					if sgs.GroupId.split('.')[0][1...] == from_sg_uid

			# 						if comp.resource.Attachment.DeviceIndex != "0"
			# 							from_sg_group.push comp.uid
			# 						else
			# 							from_sg_group.push comp.resource.Attachment.InstanceId.split('.')[0][1...]

			# 					if sgs.GroupId.split('.')[0][1...] == to_sg_uid
			# 						if comp.resource.Attachment.DeviceIndex != "0"
			# 							to_sg_group.push comp.uid
			# 						else
			# 							to_sg_group.push comp.resource.Attachment.InstanceId.split('.')[0][1...]

			# 			when constant.AWS_RESOURCE_TYPE.AWS_ELB

			# 				if MC.canvas_data.platform != MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

			# 					$.each comp.resource.SecurityGroups, ( idx, sgs )->

			# 						if sgs.split('.')[0][1...] == from_sg_uid

			# 							from_sg_group.push comp.uid

			# 						if sgs.split('.')[0][1...] == to_sg_uid

			# 							to_sg_group.push comp.uid

			# 			when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

			# 				$.each comp.resource.SecurityGroups, ( idx, sgs )->

			# 					if sgs.split('.')[0][1...] == from_sg_uid

			# 						from_sg_group.push comp.uid

			# 						asg_uid = MC.canvas_data.layout.component.node[comp.uid].groupUId

			# 						$.each MC.canvas_data.layout.component.group, ( group_id, group ) ->

			# 							if group.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group and group.originalId and group.originalId is asg_uid

			# 								from_sg_group.push group_id

			# 					if sgs.split('.')[0][1...] == to_sg_uid

			# 						to_sg_group.push comp.uid

			# 						asg_uid = MC.canvas_data.layout.component.node[comp.uid].groupUId

			# 						$.each MC.canvas_data.layout.component.group, ( group_id, group ) ->

			# 							if group.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group and group.originalId and group.originalId is asg_uid

			# 								to_sg_group.push group_id


			# 	$.each from_sg_group, ( i, from_comp_uid ) ->

			# 		$.each to_sg_group, (i, to_comp_uid) ->

			# 			if from_comp_uid != to_comp_uid

			# 				from_port = null

			# 				to_port = null

			# 				if MC.canvas_data.component[from_comp_uid]

			# 					switch MC.canvas_data.component[from_comp_uid].type

			# 						when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

			# 							from_port = 'instance-sg'

			# 						when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

			# 							from_port = 'eni-sg'

			# 						when constant.AWS_RESOURCE_TYPE.AWS_ELB

			# 							if MC.canvas_data.component[from_comp_uid].resource.Scheme is 'internet-facing'
			# 								return

			# 							from_port = 'elb-sg-in'

			# 						when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

			# 							from_port = 'launchconfig-sg'

			# 				else
			# 					from_port = 'launchconfig-sg'

			# 				if MC.canvas_data.component[to_comp_uid]

			# 					switch MC.canvas_data.component[to_comp_uid].type

			# 						when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

			# 							to_port = 'instance-sg'

			# 						when constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

			# 							to_port = 'eni-sg'

			# 						when constant.AWS_RESOURCE_TYPE.AWS_ELB
			# 							if MC.canvas_data.component[to_comp_uid].resource.Scheme is 'internet-facing'
			# 								return
			# 							to_port = 'elb-sg-in'

			# 						when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration

			# 							to_port = 'launchconfig-sg'

			# 				else
			# 					to_port = 'launchconfig-sg'


			# 				if from_port == to_port == 'launchconfig-sg'

			# 					existing = false

			# 					$.each MC.canvas_data.layout.component.group, ( comp_uid, comp ) ->

			# 						if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group and comp.originalId and ((comp.originalId is from_comp_uid and comp_uid is to_comp_uid) or (comp.originalId is to_comp_uid and comp_uid is from_comp_uid))

			# 							existing = true

			# 							return false

			# 					if not existing

			# 						lines.push [from_comp_uid, to_comp_uid, from_port, to_port]

			# 				else if (from_port is 'instance-sg' and to_port is 'eni-sg') or (from_port is 'eni-sg' and to_port is 'instance-sg')

			# 					if MC.canvas_data.component[from_comp_uid].type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance and MC.canvas_data.component[to_comp_uid].resource.Attachment.InstanceId.split('.')[0][1...] isnt from_comp_uid

			# 						lines.push [from_comp_uid, to_comp_uid, from_port, to_port]

			# 					else if MC.canvas_data.component[to_comp_uid].type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance and MC.canvas_data.component[from_comp_uid].resource.Attachment.InstanceId.split('.')[0][1...] isnt to_comp_uid

			# 						lines.push [from_comp_uid, to_comp_uid, from_port, to_port]

			# 				else
			# 					lines.push [from_comp_uid, to_comp_uid, from_port, to_port]

			# $.each MC.canvas_data.layout.connection, ( line_id, line ) ->

			# 	if line.type == 'sg' and $("#"+line_id)[0] isnt undefined

			# 		MC.canvas.remove $("#"+line_id)[0]

			# $.each lines, ( idx, line_data ) ->

			# 	MC.canvas.connect $("#"+line_data[0]), line_data[2], $("#"+line_data[1]), line_data[3]

			# #this.initLine()

			# lines

		initLine: ()->

			MC.canvas.initLine()
			# subnet_ids = []

			# lines = []

			# main_rt = null

			# $.each MC.canvas_data.component, ( comp_uid, comp )->

			# 	if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

			# 		if comp.resource.AssociationSet.length and "" + comp.resource.AssociationSet[0].Main is 'true'

			# 			main_rt = comp_uid

			# 		$.each comp.resource.AssociationSet, ( idx, asso ) ->

			# 			if asso.SubnetId

			# 				subnet_id = asso.SubnetId.split('.')[0][1...]

			# 				subnet_ids.push subnet_id

			# 				lines.push [subnet_id, comp_uid, 'subnet-assoc-out', 'rtb-src']

			# 		$.each comp.resource.RouteSet, ( idx, route )->

			# 			if route.InstanceId

			# 				lines.push [route.InstanceId.split('.')[0][1...], comp_uid, 'instance-rtb', 'rtb-tgt']

			# 			if route.GatewayId

			# 				gateway_port = null

			# 				rtb_port = null

			# 				if route.GatewayId.indexOf('Internet') >= 0

			# 					gateway_port = 'igw-tgt'

			# 					rtb_port = 'rtb-tgt'

			# 				else
			# 					gateway_port = 'vgw-tgt'

			# 					rtb_port = 'rtb-tgt'


			# 				lines.push [route.GatewayId.split('.')[0][1...], comp_uid, gateway_port, rtb_port]

			# 			if route.NetworkInterfaceId

			# 				lines.push [route.NetworkInterfaceId.split('.')[0][1...], comp_uid, 'eni-rtb', 'rtb-tgt']


			# $.each MC.canvas_data.component, ( comp_uid, comp ) ->
			# 	# subnet with main rt
			# 	if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet and (comp_uid not in subnet_ids)

			# 		lines.push [comp_uid, main_rt, 'subnet-assoc-out', 'rtb-src']

			# 	# vpn

			# 	if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection

			# 		lines.push [comp.resource.CustomerGatewayId.split('.')[0][1...], comp.resource.VpnGatewayId.split('.')[0][1...], 'cgw-vpn', 'vgw-vpn']

			# 	# elb
			# 	if comp.type is constant.AWS_RESOURCE_TYPE.AWS_ELB

			# 		$.each comp.resource.Instances, ( i, instance ) ->

			# 			lines.push [comp_uid, instance.InstanceId.split('.')[0][1...], 'elb-sg-out', 'instance-sg']

			# 		$.each comp.resource.Subnets, ( i, subnet_id ) ->

			# 			lines.push [comp_uid, subnet_id.split('.')[0][1...], 'elb-assoc', 'subnet-assoc-in']

			# 	if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

			# 		expand_asg = []

			# 		$.each MC.canvas_data.layout.component.node, ( c, node ) ->

			# 			if node.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration and node.groupUId is comp_uid

			# 				expand_asg.push c

			# 		$.each MC.canvas_data.layout.component.group, ( c, g ) ->

			# 			if g.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group and g.originalId and g.originalId is comp_uid

			# 				expand_asg.push c

			# 		$.each expand_asg, ( i, asg ) ->

			# 			$.each comp.resource.LoadBalancerNames, ( j, elb ) ->

			# 				lines.push [asg, elb.split('.')[0][1...], 'launchconfig-sg', 'elb-sg-out']

			# 	if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface and comp.resource.Attachment.InstanceId and comp.resource.Attachment.DeviceIndex isnt '0' and comp.resource.Attachment.DeviceIndex isnt 0

			# 		lines.push [comp_uid, comp.resource.Attachment.InstanceId.split('.')[0][1...], 'eni-attach', 'instance-attach']

			# $.each lines, ( idx, line_data ) ->

			# 	MC.canvas.connect $("#"+line_data[0]), line_data[2], $("#"+line_data[1]), line_data[3]

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
				this.askToAddIGW 'Elastic IP'

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
			else if _.isString component
				res = component

			# Confimation
			self = this
			template = MC.template.canvasOpConfirm {
				operation : lang.ide.CVS_CFM_ADD_IGW
				content   : sprintf lang.ide.CVS_CFM_ADD_IGW_MSG, res
				color     : "blue"
				proceed   : lang.ide.CFM_BTN_ADD
				cancel    : lang.ide.CFM_BTN_DONT_ADD
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
