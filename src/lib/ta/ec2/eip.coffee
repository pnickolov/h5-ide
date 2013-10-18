define [ 'constant', 'MC' ], ( constant, MC ) ->

	updateStackTooltip = (parentCompUID, isAssociate) ->

		tootipStr = 'Remove Elastic IP'
		if isAssociate then tootipStr = 'Associate Elastic IP'
		MC.canvas.update(parentCompUID, 'tooltip', 'eip_status', tootipStr)

	updateAppTooltip = (parentCompUID) ->
		parentComp = MC.canvas_data.component[parentCompUID]
		parentCompType = parentComp.type
		ipAddress = ''
		if parentCompType is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
			if MC.canvas_data.component[parentCompUID]
				instanceId = MC.canvas_data.component[parentCompUID].resource.InstanceId
				if MC.data and MC.data.resource_list
					appComp = MC.data.resource_list[MC.canvas_data.region][instanceId]
					if appComp
						ipAddress = appComp.ipAddress
		else if parentCompType is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
			if MC.canvas_data.component[parentCompUID]
				eniId = MC.canvas_data.component[parentCompUID].resource.NetworkInterfaceId
				if MC.data and MC.data.resource_list
					appComp = MC.data.resource_list[MC.canvas_data.region][eniId]
					if appComp and appComp.association
						ipAddress = appComp.association.publicIp
		MC.canvas.update(parentCompUID, 'tooltip', 'eip_status', ipAddress)

	isInstanceHaveEIPInClassic = (instanceUID) ->

		result = false
		_.each MC.canvas_data.component, (compObj) ->
			if compObj.type is 'AWS.EC2.EIP'
				instanceUIDRef = compObj.resource.InstanceId
				currentInstanceUID = ''
				if instanceUIDRef
					currentInstanceUID = instanceUIDRef.split('.')[0].slice(1)
					if currentInstanceUID is instanceUID
						result = true
			null
		return result

	#public
	updateStackTooltip : updateStackTooltip
	updateAppTooltip : updateAppTooltip
	isInstanceHaveEIPInClassic : isInstanceHaveEIPInClassic