define [ 'constant', 'MC' ], ( constant, MC ) ->

	#private
	isNotCIDRConflict = (currentCIDR, otherCIDRAry) ->

		noConflict = true
		_.each otherCIDRAry, (cidrValue) ->
			if MC.aws.subnet.isSubnetConflict(currentCIDR, cidrValue)
				noConflict = false

		return noConflict

	updateRT_SubnetLines = () ->
		subnets = {}
		rts     = []
		mainRt  = null
		for uid, comp of MC.canvas_data.component
			if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
				subnets[ uid ] = false
			else if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
				rts.push comp
				if comp.resource.AssociationSet.length and "" + comp.resource.AssociationSet[0].Main is "true"
					mainRt = uid

		# Finds out which subnet should be link to which rt
		for rt in rts
			for asso in rt.resource.AssociationSet
				if "" + asso.Main is "true"
					continue
				subnets[ MC.extractID( asso.SubnetId ) ] = rt.uid

		# Get all subnet <==> rt connections
		connects = {}
		for uid, connect of MC.canvas_data.layout.connection
			if connect.type isnt "association"
				continue

			portMap = {}
			for id, port of connect.target
				portMap[ port ] = id

			if portMap[ "subnet-assoc-out" ] and portMap[ "rtb-src" ]
				connects[ portMap["subnet-assoc-out"] ] = uid

		# Delete and create
		for uid, target_uid of subnets
			if not target_uid
				target_uid = mainRt

			exist_connect = MC.canvas_data.layout.connection[ connects[ uid ] ]
			if exist_connect
				if exist_connect.target[ uid ] and exist_connect.target[ target_uid ]
					continue
				else
					MC.canvas.remove document.getElementById connects[uid]

			MC.canvas.connect uid, "subnet-assoc-out", target_uid, 'rtb-src'

		null

	#public
	{
		isNotCIDRConflict    : isNotCIDRConflict
		updateRT_SubnetLines : updateRT_SubnetLines
	}
