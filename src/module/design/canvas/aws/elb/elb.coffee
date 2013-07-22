define [ 'MC' ], ( MC ) ->
	return {
		addInstanceAndAZToELB: (elbUID, instanceUID) ->
			elbComp = MC.canvas_data.component[elbUID]
			instanceComp = MC.canvas_data.component[instanceUID]

			currentInstanceAZ = instanceComp.resource.Placement.AvailabilityZone

			instanceUID = instanceComp.uid
			instanceRef = '@' + instanceUID + '.resource.InstanceId'

			elbInstanceAry = elbComp.resource.Instances
			elbInstanceAryLength = elbInstanceAry.length

			elbAZAry = elbComp.resource.AvailabilityZones
			elbAZAryLength = elbAZAry.length

			addInstanceToElb = true
			_.each elbInstanceAry, (elem, index) ->
				if elem.InstanceId is instanceRef
					addInstanceToElb = false
					null

			if addInstanceToElb
				MC.canvas_data.component[elbUID].resource.Instances.push({
					InstanceId: instanceRef
				})

			addAZToElb = true
			_.each elbAZAry, (elem, index) ->
				if elem is currentInstanceAZ
					addAZToElb = false
					null

			if addAZToElb
				MC.canvas_data.component[elbUID].resource.AvailabilityZones.push(currentInstanceAZ)

			null

		removeInstanceFromELB: (elbUID, instanceUID) ->
			elbComp = MC.canvas_data.component[elbUID]
			instanceComp = MC.canvas_data.component[instanceUID]

			instanceUID = instanceComp.uid
			instanceRef = '@' + instanceUID + '.resource.InstanceId'

			elbInstanceAry = elbComp.resource.Instances
			elbInstanceAryLength = elbInstanceAry.length

			instanceAry = MC.canvas_data.component[elbUID].resource.Instances

			newInstanceAry = _.filter instanceAry, (value) ->
				if value.InstanceId is instanceRef
					false
				else
					true

			MC.canvas_data.component[elbUID].resource.Instances = newInstanceAry

			null
	}