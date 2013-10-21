
define [ 'MC' ], ( MC ) ->

	result = {}

	set = ( uid, level, info ) ->
		result = {
			level : level,
			info  : info,
			uid   : uid
		}

	get = () ->
		result

	set : set
	get : get