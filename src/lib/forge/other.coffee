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

	addProcess = ( id, data ) ->
		console.log 'addProcess', id, data
		MC.process[ id ] = data
		null

	deleteProcess = ( id ) ->
		console.log 'deleteProcess', id
		delete MC.process[ id ]
		delete MC.data.process[ id ]
		MC.storage.set 'process', $.extend true, {}, MC.data.process
		null

	filterProcess = ( id ) ->
		console.log 'filterProcess', id

		obj = @searchStackAppById id

		if obj and obj.state in [ constant.APP_STATE.APP_STATE_RUNNING, constant.APP_STATE.APP_STATE_STOPPED, constant.APP_STATE.APP_STATE_TERMINATED ]
			@deleteProcess id

		null

	setCurrentTabId = ( tab_id ) ->
		console.log 'setCurrentTabId', tab_id
		MC.data.current_tab_id = tab_id
		null

	#public
	searchStackAppById : searchStackAppById

	addProcess         : addProcess
	deleteProcess      : deleteProcess
	filterProcess      : filterProcess

	setCurrentTabId    : setCurrentTabId
