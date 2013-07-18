#############################
#  View Mode for canvas
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore' ], ( constant ) ->

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

				if parent.name == component.resource.Placement.AvailabilityZone
					# Nothing is changed
					return

				console.log "Instance:", src_node, "dragged from:", component.resource.Placement.AvailabilityZone, "to:", parent.name
				component.resource.Placement.AvailabilityZone = parent.name

				#We should also update those Volumes that are attached to this Instance.
				updateVolume = ( component, id ) ->
					if component.type == resource_type.AWS_EBS_Volume and component.resource.AttachmentSet.InstanceId.indexOf( this )
						 component.resource.AvailabilityZone = parent.name
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

			null

		#after connect two port
		createLine : ( line_id ) ->
			
			line_option = MC.canvas.lineTarget uid

			if line_option.length == 2

				console.info line_option[0].uid + ',' + line_option[0].port + " | " + line_option[1].uid + ',' + line_option[1].port
				
				#to-do


			null


		#after drag component from resource panel to canvas
		createComponent : ( uid ) ->

			#to-do

	}

	model = new CanvasModel()

	return model
