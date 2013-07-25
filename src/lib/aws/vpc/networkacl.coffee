define [ 'MC' ], ( MC ) ->

	#private
	getNewACLName = () ->
		maxNum = 0
		_.each MC.canvas_data.component, (compObj) ->
			compType = compObj.type
			if compType is 'AWS.VPC.NetworkAcl'
				aclName = compObj.name
				if aclName.slice(0, 10) is 'CustomACL-'
					currentNum = Number(aclName.slice(10))
					if currentNum > maxNum
						maxNum = currentNum
			null
		maxNum++
		return 'CustomACL-' + maxNum

	#public
	getNewACLName	: getNewACLName