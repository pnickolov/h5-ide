
define [ 'event', 'MC', 'underscore' ], ( ide_event, MC ) ->

	########## Functional Method ##########

	_hash = ( str ) ->
		hash = 0
		if str.length is 0
			return hash

		_.each str, ( v, i ) ->
			char = str.charCodeAt(i)
			hash = ( ( hash<<5 ) - hash ) + char
			hash = hash & hash # Convert to 32bit integer

		hash

	_genKey = ( key, uid ) ->
		_hash "#{key}|uid"

	_genRes = ( key, level, info, uid ) ->
		key   : _genKey key, uid
		level : level
		info  : info
		uid   : uid

	_del = ( key ) ->
		delete_obj = {}

		_.map MC.ta.list, ( obj ) ->
			if obj.key is key
				delete_obj = obj

		MC.ta.list = _.without( MC.ta.list, delete_obj )

		ide_event.trigger ide_event.UPDATE_STATUS_BAR, 'delete', delete_obj.level if delete_obj.level

		null

	_add = ( result ) ->
		MC.ta.list.push result

		ide_event.trigger ide_event.UPDATE_STATUS_BAR, 'add', result.level

	_exist = ( key ) ->
		_.contains( _.pluck( MC.ta.list, 'key' ) , key )

	########## Public Method ##########

	set = ( key, level, info, uid ) ->

		res = _genRes.apply @, arguments
		key = res.key

		if not _exist key
			_add res
		else
			_del key

		result()


	reset = () ->
		MC.ta.list = []


	result = () ->
		MC.ta.list



	set  		: set
	reset		: reset
	result		: result

