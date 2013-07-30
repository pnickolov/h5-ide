define [ 'MC' ], ( MC ) ->

	#private
	getAllRefComp = (sgUID) ->

		refNum = 0
		sgAry = []
		refCompAry = []
		_.each MC.canvas_data.component, (comp) ->
			compType = comp.type
			if compType is 'AWS.ELB'
				sgAry = comp.resource.SecurityGroups
				sgAry = _.map sgAry, (value) ->
					refSGUID = value.slice(1).split('.')[0]
					return refSGUID
				if sgUID in sgAry
					refCompAry.push comp

			if compType is 'AWS.EC2.Instance'
				sgAry = comp.resource.SecurityGroupId
				sgAry = _.map sgAry, (value) ->
					refSGUID = value.slice(1).split('.')[0]
					return refSGUID
				if sgUID in sgAry
					refCompAry.push comp

			if compType is 'AWS.VPC.NetworkInterface'
				_sgAry = []
				_.each comp.resource.GroupSet, (sgObj) ->
					_sgAry.push sgObj.GroupId
					null

				sgAry = _sgAry
				sgAry = _.map sgAry, (value) ->
					refSGUID = value.slice(1).split('.')[0]
					return refSGUID

				if sgUID in sgAry
					refCompAry.push comp
			null

		return refCompAry

	#public
	getAllRefComp : getAllRefComp