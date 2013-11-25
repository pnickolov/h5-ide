define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->


	searchStackAppById = ( id ) ->

		value = null

		try

			temp  = if id.split('-')[0] is 'stack' then MC.data.nav_stack_list else MC.data.nav_app_list
			_.each temp, ( obj ) ->
				_.each obj.region_name_group, ( item ) ->
					value = item if item.id is id
					return true

		catch error
			console.log 'searchStackAppById error, id is ' + id
			console.log error

		value

	deleteProcess = ( id ) ->
		console.log 'deleteProcess', id
		delete MC.process[ id ]
		delete MC.data.process[ id ]
		null

	#public
	searchStackAppById : searchStackAppById
	deleteProcess      : deleteProcess
