define [ 'constant', 'MC' ], ( constant, MC ) ->

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

			if eni
				MC.canvas.display( eni, 'eni-number-group', true )
				MC.canvas.update( eni, 'text', 'eni-number', count )
				MC.canvas.display( eni, 'port-eni-rtb', false )

		else
			MC.canvas.display( uid, 'instance-number-group', false )
			MC.canvas.display( uid, 'port-instance-rtb', true )
			if eni
				MC.canvas.display( eni, 'eni-number-group', false )
				MC.canvas.display( eni, 'port-eni-rtb', true )



	#update state icon of instance
	updateStateIcon = ( app_id ) ->

		if MC.canvas.getState() == 'stack'

			return null

		if app_id and MC.canvas.data.get('id') == app_id

			MC.canvas.updateInstanceState()

		null

	getInstanceType = ( ami, ami_instance_type ) ->

		instance_type = ami_instance_type
		if ami.virtualizationType == 'hvm'
			instance_type = instance_type.windows
		else
			instance_type = instance_type.linux
		if ami.rootDeviceType == 'ebs'
			instance_type = instance_type.ebs
		else
			instance_type = instance_type['instance store']
		if ami.architecture == 'x86_64'
			instance_type = instance_type["64"]
		else
			instance_type = instance_type["32"]
		instance_type = instance_type[ami.virtualizationType]

		instance_type.join ', '

	#public
	updateCount : updateCount
	updateStateIcon : updateStateIcon
	getInstanceType : getInstanceType
