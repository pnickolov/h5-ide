define [ 'MC' ], ( MC ) ->

	#private
	getVPCUID = () ->
		vpcUID = ''
		_.each MC.canvas_data.layout.component.group, (groupObj, groupUID) ->
			if groupObj.type is 'AWS.VPC.VPC'
				vpcUID = groupUID
				return false
		return vpcUID

	#public
	getVPCUID : getVPCUID