define [ 'MC' ], ( MC ) ->
	return {
		init: (uid) ->

			allComp = MC.canvas_data.component
			haveVPC = allComp[uid].resource.VpcId
			if !haveVPC
				MC.canvas_data.component[uid].resource.Scheme = ''

			# have igw ?
			igwCompAry = _.filter allComp, (obj) ->
				obj.type is 'AWS.VPC.InternetGateway'
			if igwCompAry.length isnt 0
				MC.canvas_data.component[uid].resource.Scheme = 'internet-facing'

			null

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

		setAllELBSchemeAsInternal: () ->
			_.each MC.canvas_data.component, (value, key) ->
				if value.type is 'AWS.ELB'
					MC.canvas_data.component[key].resource.Scheme = 'internal'
					MC.canvas.update key, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNAL_CANVAS
				null
			null
	}