define [ 'constant', 'MC' ], ( constant, MC ) ->

	EbsMap =
		"m1.large"   : true
		"m1.xlarge"  : true
		"m2.2xlarge" : true
		"m2.4xlarge" : true
		"m3.xlarge"  : true
		"m3.2xlarge" : true
		"c1.xlarge"  : true

	updateCount = ( uid, count ) ->

		for c_uid, comp of MC.canvas_data.component
			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
				attachment = comp.resource.Attachment
				if attachment and attachment.InstanceId and attachment.InstanceId.indexOf( uid ) isnt -1 and "" + attachment.DeviceIndex isnt "0"
					eni = c_uid
					break

		if count > 1
			MC.canvas.display( uid, 'instance-number-group', true )
			MC.canvas.display( uid, 'port-instance-rtb', false )
			MC.canvas.update( uid, 'text', 'instance-number', count )
			MC.canvas.display( uid, 'instance-state', false)

			if eni
				MC.canvas.display( eni, 'eni-number-group', true )
				MC.canvas.update( eni, 'text', 'eni-number', count )
				MC.canvas.display( eni, 'port-eni-rtb', false )

		else
			MC.canvas.display( uid, 'instance-number-group', false )
			MC.canvas.display( uid, 'instance-state', true)
			MC.canvas.display( uid, 'port-instance-rtb', true )
			if eni
				MC.canvas.display( eni, 'eni-number-group', false )
				MC.canvas.display( eni, 'port-eni-rtb', true )

	canSetEbsOptimized = ( instance_component ) ->

		if not EbsMap.hasOwnProperty instance_component.resource.InstanceType
			return false

		layout = MC.canvas_data.layout.component.node[ instance_component.uid ]
		if layout and layout.rootDeviceType is "instance-store"
			return false

		return true


	#update state icon of instance
	updateStateIcon = ( app_id ) ->

		if MC.canvas.getState() == 'stack'

			return null

		if app_id and MC.canvas.data.get('id') == app_id

			MC.canvas.updateInstanceState()

		null

	#return instance state
	getInstanceState = ( instance_id ) ->

		if MC.data.resource_list

			instance_data = MC.data.resource_list[MC.canvas.data.get('region')][instance_id]

			if instance_data

				state = instance_data.instanceState.name
		#return
		state

	#public
	updateCount        : updateCount
	updateStateIcon    : updateStateIcon
	canSetEbsOptimized : canSetEbsOptimized
	getInstanceState   : getInstanceState
