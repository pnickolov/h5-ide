#############################
#  View Mode for canvas
#############################
define [ 'constant',
         'event',
         'lib/forge/app',
         'i18n!nls/lang.js',
'backbone', 'UI.modal' ], ( constant, ide_event, forge_app, lang ) ->

	CanvasModel = Backbone.Model.extend {

		deleteObject : ( event, option ) ->

			# In AppEdit mode, we use a different method collection to deal with deleting object.
			# See if we need to hackjack the deleteResMap / beforeDeleteResMap here
			hijack = MC.canvas.getState() is "appedit"
			if hijack
				deleteMapBU       = this.deleteResMap
				beforeDeleteMapBU = this.beforeDeleteMap
				this.deleteResMap       = this.deleteResAppEditMap
				this.beforeDeleteResMap = this.beforeDeleteAppEditMap

			option = $.extend {}, option

			component = MC.canvas_data.component[ option.id ] ||
			if not component
				component = $.extend true, {uid:option.id}, MC.canvas_data.layout.component.group[ option.id ]

			# Treat ASG as a node, not a group
			if component.type == constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
				option.type = 'node'

			# Default to not allow delete things in app
			# In hijack mode, if we don't have a handler to
			# delete resource. Then we show error
			if hijack and not @deleteResMap[ component.type ]
				notification 'error', "This operation is not supported yet."
				return

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

				#check stoppable after delete AMI
				if component.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance or component.type == constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
					MC.forge.stack.checkStoppable MC.canvas_data

				this.trigger 'DELETE_OBJECT_COMPLETE'

			else if event && event.preventDefault
				event.preventDefault()


			# Restore hijack Maps
			if hijack
				this.deleteResMap    = deleteMapBU
				this.beforeDeleteMap = beforeDeleteMapBU

			result

		deleteR_AE_Instance : ( component ) ->

			# if not forge_app.existing_app_resource( option.id ) is true

			groupUID = component.uid
			groupMap = {}

			deleteUID = []

			# Find out instance in server group
			for comp_uid, comp of MC.canvas_data.component
				if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
					if comp.serverGroupUid is groupUID
						groupMap[ comp_uid ] = true
						MC.aws.elb.removeAllELBForInstance(comp_uid)
						deleteUID.push comp_uid

			eniMap = {}
			for comp_uid, comp of MC.canvas_data.component

				# Related Eni
				if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
					instance_uid = MC.extractID comp.resource.Attachment.InstanceId
					if groupMap[ instance_uid ]
						eniMap[ comp_uid ] = true
						deleteUID.push comp_uid

				# Related Volume
				else if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume
					instance_uid = MC.extractID comp.resource.AttachmentSet.InstanceId
					if groupMap[ instance_uid ]
						delete MC.canvas_data.component[ comp_uid ]

			# EIP, RTB
			for comp_uid, comp of MC.canvas_data.component
				if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP
					eni_uid = MC.extractID comp.resource.NetworkInterfaceId
					if eniMap[eni_uid]
						deleteUID.push comp_uid

				else if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
					for rmID in deleteUID
						this._removeFromRTB comp_uid, rmID

			# Remove resource
			for comp_uid in deleteUID
				el = $("#" + comp_uid)
				if el.length
					MC.canvas.remove el[0]
				delete MC.canvas_data.component[ comp_uid ]


			this.trigger "DELETE_OBJECT_COMPLETE"
			# Return false to do nothing, since we have done them already
			false

		doCreateLine : ( line_id ) ->

			line_option = MC.canvas.lineTarget line_id

			if line_option.length != 2
				return

			console.info line_option[0].uid + ',' + line_option[0].port + " | " + line_option[1].uid + ',' + line_option[1].port

			portMap = {}
			for obj in line_option
				portMap[ obj.port ] = obj.uid


			if not (MC.canvas_data.platform is MC.canvas.PLATFORM_TYPE.EC2_CLASSIC and (portMap['elb-sg-in'] or portMap['elb-sg-out']))

				# # Prevent SG Rule create from AMI to attached ENI
				# eni_comp = MC.canvas_data.component[ portMap["eni-sg"] ]
				# if eni_comp and eni_comp.resource.Attachment and eni_comp.resource.Attachment.InstanceId.indexOf( portMap["instance-sg"] ) isnt -1
				# 	return "The Network Interface is attached to the instance. No need to connect them by security group rule."

				for key, value of portMap
					if key.indexOf('sg') >= 0
						this.trigger 'CREATE_SG_CONNECTION', line_id
						break
			null

		createComponent : ( event, uid ) ->
			resource_type = constant.AWS_RESOURCE_TYPE

			componentType = if MC.canvas_data.component[uid] then MC.canvas_data.component[uid] else MC.canvas_data.layout.component.group[uid]
			componentType = if componentType then componentType.type else resource_type.AWS_EC2_AvailabilityZone

			switch componentType

				when resource_type.AWS_EC2_Instance

					defaultVPC = false
					if MC.aws.aws.checkDefaultVPC()
						defaultVPC = true

					if defaultVPC
						azName = MC.canvas_data.component[uid].resource.Placement.AvailabilityZone
						MC.aws.subnet.updateAllENIIPList(azName, true)
					else
						subnetUIDRef = MC.canvas_data.component[uid].resource.SubnetId
						subnetUID = subnetUIDRef.split('.')[0].slice(1)
						MC.aws.subnet.updateAllENIIPList(subnetUID, true)

					#check stoppable when add AMI
					MC.forge.stack.checkStoppable MC.canvas_data

				when resource_type.AWS_VPC_NetworkInterface

					defaultVPC = false
					if MC.aws.aws.checkDefaultVPC()
						defaultVPC = true

					if defaultVPC
						eniAZName = MC.canvas_data.component[uid].resource.AvailabilityZone
						MC.aws.subnet.updateAllENIIPList(eniAZName, true)
					else
						subnetUIDRef = MC.canvas_data.component[uid].resource.SubnetId
						subnetUID = subnetUIDRef.split('.')[0].slice(1)
						MC.aws.subnet.updateAllENIIPList(subnetUID, true)
	}

	model = new CanvasModel()

	return model
