define [ 'MC' ], ( MC ) ->

	#private
	isNotCIDRConflict = (currentCIDR, otherCIDRAry) ->

		noConflict = true
		_.each otherCIDRAry, (cidrValue) ->
			if MC.aws.subnet.isSubnetConflict(currentCIDR, cidrValue)
				noConflict = false

		return noConflict

	#public
	isNotCIDRConflict : isNotCIDRConflict