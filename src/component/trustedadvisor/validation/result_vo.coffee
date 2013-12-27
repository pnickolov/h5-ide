
define [ 'event', 'MC', 'underscore' ], ( ide_event, MC ) ->

	########## Polyfill ##########

	if not Design
		Design =
			instance: ->
				{
					component: ( uid ) ->
						MC.canvas_data.component[ uid ]
				}

	########## Functional Method ##########

	_hash = ( str ) ->
		hash = 0
		if str.length is 0
			return hash

		_.each str, ( v, i ) ->
			char = str.charCodeAt(i)
			hash = ( ( hash<<5 ) - hash ) + char
			hash = hash & hash # Convert to 32bit integer

		"k#{hash}"

	_genKey = ( key, uid ) ->
		_hash "#{key}|#{uid}"

	_genRes = ( key, result, uid ) ->
		uid = uid or result and result.uid or null
		_.extend {}, result, {key: _genKey(key, uid), type: key}


	_del = ( key ) ->
		delete_obj = {}

		_.map MC.ta.list, ( obj ) ->
			if obj.key is key
				delete_obj = obj

		if delete_obj
			MC.ta.list = _.without( MC.ta.list, delete_obj )
			ide_event.trigger ide_event.UPDATE_STATUS_BAR, 'delete', delete_obj.level if delete_obj.level

		null

	_add = ( result ) ->
		MC.ta.list.push result

		ide_event.trigger ide_event.UPDATE_STATUS_BAR, 'add', result.level

	_replace = ( result ) ->
		MC.ta.list = _.map MC.ta.list, ( item ) ->
			if item.key is result.key
				return result
			item

	_exist = ( key ) ->
		_.contains( _.pluck( MC.ta.list, 'key' ) , key )

	########## Public Method ##########

	set = ( key, result, uid ) ->

		res = _genRes key, result, uid
		k = res.key

		if _.isArray result
			_.each result, ( r ) ->
				set key, r, r.uid

		if result
			if not _exist k
				_add res
			else
				_replace res
		else
			_del k

		MC.ta.list


	reset = () ->
		MC.ta.list = []


	result = () ->
		MC.ta.list



	set  		: set
	reset		: reset
	result		: result

