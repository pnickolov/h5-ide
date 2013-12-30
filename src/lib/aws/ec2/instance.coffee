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

	canSetEbsOptimized = ( instance_attr ) ->

		if not EbsMap.hasOwnProperty instance_attr.InstanceType
			return false

		if instance_attr.rootDeviceType is "instance-store"
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

	updateServerGroupState = ( app_id, server_group_uid ) ->

		if MC.canvas.getState() == 'stack'

			return null

		if app_id and MC.canvas.data.get('id') == app_id

			comp_data = MC.canvas.data.get("component")
			instance_id = undefined
			instance_data = undefined
			$.each comp_data, (uid, comp) ->
				if comp.type is "AWS.EC2.Instance" and comp.number > 1 and comp.index is 0
					#ServerGroup node
					if server_group_uid is comp.serverGroupUid || !server_group_uid
					# no server_group_uid specified or current component is server_group_uid
						instance_list = getInstanceInServerGroup comp_data, comp.serverGroupUid
						if instance_list.length isnt comp.number
							#lack of instance
							Canvon('#' + uid + '_instance-number-group').addClass 'deleted'
							Canvon('#' + uid).addClass 'deleted'
						else
							#instances are all in readiness
							Canvon('#' + uid + '_instance-number-group').removeClass 'deleted'
							Canvon('#' + uid).removeClass 'deleted'

					if server_group_uid is comp.serverGroupUid
						return false;#break


		null


	getInstanceInServerGroup = ( comp_data, server_group_uid ) ->

		instance_list = []

		if comp_data and server_group_uid

			$.each comp_data, (uid, comp) ->

				if comp.type is "AWS.EC2.Instance" and comp.serverGroupUid is server_group_uid
					instance_id = comp.resource.InstanceId
					instance_data = MC.data.resource_list[MC.canvas.data.get('region')][instance_id]
					if instance_id and instance_data and instance_data.instanceState.name isnt 'terminated' and instance_data.instanceState.name isnt 'shutting-down'
						#instance existed
						instance_list.push comp.resource.InstanceId

		#return
		instance_list


	#public
	updateCount        : updateCount
	updateStateIcon    : updateStateIcon
	canSetEbsOptimized : canSetEbsOptimized
	getInstanceState   : getInstanceState
	updateServerGroupState : updateServerGroupState
	getInstanceInServerGroup : getInstanceInServerGroup
