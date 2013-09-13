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
				appComp = MC.data.resource_list[MC.canvas_data.region][instanceId]
				if appComp
					ipAddress = appComp.ipAddress
		else if parentCompType is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
			if MC.canvas_data.component[parentCompUID]
				eniId = MC.canvas_data.component[parentCompUID].resource.NetworkInterfaceId
				appComp = MC.data.resource_list[MC.canvas_data.region][eniId]
				if appComp
					ipAddress = appComp.association.publicIp
		MC.canvas.update(parentCompUID, 'tooltip', 'eip_status', ipAddress)

	#public
	updateStackTooltip : updateStackTooltip
	updateAppTooltip : updateAppTooltip