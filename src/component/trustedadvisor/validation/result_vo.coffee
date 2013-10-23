
define [ 'MC' ], ( MC ) ->

	result   = {}
	list_arr = []

	set = ( level, info, uid ) ->
		#
		result =
			level : level,
			info  : info,
			uid   : uid
		#
		list_arr.push result
		#
		result

	get = ->
		result

	list = ->
		list_arr

	set  : set
	get  : get
	list : list

	ERROR   : 'ERROR'
	WARNING : 'WARNING'
	NOTICE  : 'NOTICE'