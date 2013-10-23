
define [ 'MC' ], ( MC ) ->

	result   = {}

	set = ( level, info, uid ) ->
		#
		result =
			level : level,
			info  : info,
			uid   : uid
		#
		MC.ta.list.push result
		#
		result

	get = ->
		result

	set  : set
	get  : get

	ERROR   : 'ERROR'
	WARNING : 'WARNING'
	NOTICE  : 'NOTICE'