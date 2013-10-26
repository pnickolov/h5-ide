
define [ 'event', 'MC', 'underscore' ], ( ide_event, MC ) ->

	result   = {}

	add = ( key, level, info, uid ) ->
		#
		result =
			key   : key
			level : level
			info  : info
			uid   : uid
		#
		if !_.contains( _.pluck( MC.ta.list, 'key' ) , key )
			#
			MC.ta.list.push result
			#
			ide_event.trigger ide_event.UPDATE_STATUS_BAR, 'add', result.level
		#
		result

	del = ( key ) ->
		delete_obj = {}
		#
		_.map MC.ta.list, ( obj ) ->
			if obj.key is key
				delete_obj = obj
		#
		MC.ta.list = _.without( MC.ta.list, delete_obj )
		#
		ide_event.trigger ide_event.UPDATE_STATUS_BAR, 'delete', delete_obj.level if delete_obj.level
		#
		MC.ta.list

	hash = ( str ) ->
		hash = 0
		if str.length is 0
			return hash

		_.each str, ( v, i ) ->
			char = str.charCodeAt(i)
			hash = ( ( hash<<5 ) - hash ) + char
			hash = hash & hash # Convert to 32bit integer

		hash

	reset = () ->
		MC.ta.list = []


	add  	: add
	del  	: del
	reset	: reset