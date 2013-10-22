
define [ 'MC' ], ( MC ) ->

	result   = {}
	list_arr = []

	set = ( uid, level, info ) ->
		result = {
			level : level,
			info  : info,
			uid   : uid
		}
		list_arr.push result

	get = ->
		result

	list = ->
		list_arr

	set  : set
	get  : get
	list : list