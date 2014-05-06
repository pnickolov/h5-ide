define [ 'MC', 'constant', 'jquery', 'underscore' ], ( MC, constant ) ->

	#############################
	#  canvas
	#############################

	canvasData = {

		init : ( data ) ->
			console.log 'canvasData:init'
			MC.canvas_data = $.extend true, {}, data

		initSet : ( key, value ) ->
			console.log 'canvasData:initSet', key, value
			MC.canvas_data[ key ] = value

		# is_origin include bool and string
		data : ( is_origin = false ) ->
			#console.log 'canvasData:data', is_origin

			if _.isString( is_origin ) and is_origin is 'origin'

				data = MC.canvas_data

			else if is_origin

				# old design flow
				data = $.extend true, {}, MC.canvas_data

			else

				if not _.isEmpty Design.instance()

					# new design flow
					#data = $.extend true, {}, Design.instance().serialize()
					data  = Design.instance().serialize()

					# old design flow
					#data = $.extend true, {}, MC.canvas_data

			data

		save : ( data ) ->
			console.log 'canvasData:save', data

			if not _.isEmpty Design.instance()

				# new design flow
				Design.instance().save data

				# old design flow
				#MC.canvas_data = $.extend true, {}, data

		set : ( key, value ) ->
			console.log 'canvasData:set', key, value

			# when Design.instance() is null explain 'NEW_STACK' state
			if not _.isEmpty Design.instance()

				# new design flow
				Design.instance().set key, value

		get : ( key ) ->
			console.log 'canvasData:get', key

			if not _.isEmpty Design.instance()

				# new design flow
				Design.instance().get key

				# old design flow
				#MC.canvas_data[ key ]

		isModified : ->
			console.log 'canvasData:isModified'

			if not _.isEmpty Design.instance()

				Design.instance().isModified()

		origin : ( origin_data ) ->

			if _.isEmpty origin_data

				# get
				console.log 'canvasData:get origin', MC.data.origin_canvas_data
				$.extend true, {}, MC.data.origin_canvas_data

			else

				# set
				console.log 'canvasData:set origin', origin_data
				MC.data.origin_canvas_data = $.extend true, {}, origin_data

	}

	#############################
	#  core
	#############################

	createUID  = ( length = 8 ) ->
		chars  = undefined
		str    = undefined
		chars  = "0123456789abcdefghiklmnopqrstuvwxyz".split("")
		length = Math.floor(Math.random() * chars.length)  unless length
		str    = ""
		i      = 0

		while i < length
			str += chars[Math.floor(Math.random() * chars.length)]
			i++

		str

	isCurrentTab = ( tab_id ) ->
		console.log 'isCurrentTab', tab_id

		if MC.data.current_tab_id is tab_id
			true
		else
			false

	# set current tab id
	setCurrentTabId = ( tab_id ) ->
		console.log 'setCurrentTabId', tab_id
		MC.data.current_tab_id = tab_id
		null

	# get new stack app appview by id
	searchStackAppById = ( id ) ->
		console.log 'searchStackAppById', id

		value = null

		try

			prefix = id.split('-')[0]

			# id is 'appview'
			if prefix is 'appview'

				# get obj
				obj   = searchCacheMap { key : 'id', value : id.replace( 'appview', 'process' ) }

				# set region
				value = obj

			# id is 'new'
			else if prefix is 'new'

				value = MC.data.nav_new_stack_list[ id ]

			# id is 'stack' | 'app'
			else if prefix in [ 'stack', 'app' ]

				temp  = if id.split('-')[0] is 'stack' then MC.data.nav_stack_list else MC.data.nav_app_list
				_.each temp, ( obj ) ->
					_.each obj.region_name_group, ( item ) ->
						value = item if item.id is id
						return true

			else
				console.error 'unknown tab type ' + tab_id

		catch error
			console.log 'searchStackAppById error, id is ' + id
			console.log error

		value

	isResultRight = ( result ) ->
		console.log 'isResultRight'
		if result and not result.is_error and result.resolved_data and result.resolved_data.length > 0
			true
		else if not result
			'result_empty'
		else if result and result.is_error
			'result_error'
		else if result and not result.is_error and not result.resolved_data
			'resolved_data_empty'
		else if result and not result.is_error and result.resolved_data and result.resolved_data.length = 0
			'resolved_data_length'
		else
			'other_error'

	processType = ( id ) ->

		# id is String
		if not _.isString id
			return undefined

		# tab id sample dashboard
		else if id.indexOf('-') is -1
			return undefined

		# tab id sample process-cs6dbvrc
		else if getCacheMap( id ) and id.split( '-' ).length = 2
			return 'appview'

		# tab id sample process-us-west-1-untitled-112
		else if id.split('-')[0] is 'process' and id.split( '-' ).length > 2
			return 'process'

		# undefined
		else
			return undefined

	verify500 = ( result, is_test = false ) ->
		console.log 'verify500', result, result.return_code

		# add test
		if is_test
			result.is_error = true
			result.return_code = -1

		# verify
		if result and result.return_code is -1
			window.location.href = "/500/"

		return

	checkRepeatStackName = ->
		console.log 'checkRepeatStackName'
		loop
			MC.data.untitled = MC.data.untitled + 1
			break if MC.aws.aws.checkStackName null, 'untitled-' + MC.data.untitled

	#############################
	#  process
	#############################

	addProcess = ( id, data ) ->
		console.log 'addProcess', id, data
		MC.process[ id ] = data
		null

	deleteProcess = ( id ) ->
		console.log 'deleteProcess', id
		delete MC.process[ id ]
		delete MC.data.process[ id ]
		console.log MC.process
		null

	getProcess = ( id ) ->
		console.log 'getProcess', id
		MC.process[ id ]

	filterProcess = ( id ) ->
		console.log 'filterProcess', id

		obj   = @searchStackAppById id
		state = null

		if obj and obj.state in [ constant.APP_STATE.APP_STATE_STARTING, constant.APP_STATE.APP_STATE_STOPPING, constant.APP_STATE.APP_STATE_TERMINATING, constant.APP_STATE.APP_STATE_UPDATING ]
			state = obj.state

		state

	initDataProcess = ( id, type, data ) ->
		console.log 'initDataProcess', id, type, data
		MC.data.process			 = {}
		MC.data.process			 = $.extend true, {}, data
		MC.data.process[ id ].state = type if MC.data.process and MC.data.process[ id ]
		console.log 'current MC.data.process', MC.data.process
		MC.data.process

	#############################
	#  cache id by appview
	#############################

	# cacheIDMap[ tab_id ] =
	#	uid         : <uid>
	#	id          : <id>
	#	origin_id   : <vpc_id>
	#	data        : <vpc_resource result>
	#	region      : <region_name>
	#	type        : <'process', 'appview'>
	#	state       : <'OPEN', 'OLD', 'FINISH', 'ERROR'>
	#   create_time : <'timeout', 'overtime'>
	#   origin_time : <new Date()>

	cacheIDMap = {}

	listCacheMap = ->
		console.log 'listCacheMap'
		cacheIDMap

	addCacheMap = ( uid, id, origin_id, region, type, state = 'OPEN' ) ->
		console.log 'addCacheMap', uid, id, origin_id, region, type, state

		cacheIDMap[ id ] =
			'uid'         : uid
			'id'          : id
			'origin_id'   : origin_id
			'region'      : region
			'type'        : type
			'state'       : state
			'create_time' : ''
			'origin_time' : new Date()

	delCacheMap = ( id ) ->
		console.log 'delCacheMap', id

		# if appview replace process
		if id.split('-')[0] is 'appview'
			id = id.replace 'appview', 'process'

		delete cacheIDMap[ id ]

		cacheIDMap

	setCacheMap = ( vpc_id, data, state, type, create_time ) ->
		console.log 'setCacheMap', vpc_id, data, state, type, create_time

		obj = null

		_.each cacheIDMap, ( item ) ->
			if item.origin_id is vpc_id
				item.data  = $.extend true, {}, data if data
				item.state = state                   if state
				item.type  = type                    if type
				item.create_time  = create_time      if create_time
				obj        = item

		obj

	getCacheMap = ( id ) ->

		# if appview replace process
		if id.split('-')[0] is 'appview'
			id = id.replace 'appview', 'process'

		cacheIDMap[ id ]

	# conditions = { key : 'xxx', value : 'xxx' }
	searchCacheMap = ( conditions ) ->
		console.log 'searchCacheMap', conditions

		obj = null

		_.each cacheIDMap, ( item ) ->
			if item[ conditions.key ] is conditions.value
				obj = item

		obj

	#############################
	#  unmanaged vpc
	#############################

	unmanaged_resource_list = {}

	initUnmanaged = ->
		console.log 'initUnmanaged'
		unmanaged_resource_list = {}

	listUnmanaged = () ->
		console.log 'listUnmanaged'
		unmanaged_resource_list

	addUnmanaged = ( data ) ->
		console.log 'addUnmanaged', data
		unmanaged_resource_list = data

	delUnmanaged = ( vpc_id ) ->
		console.log 'delUnmanaged', vpc_id

		try

			_.each unmanaged_resource_list, ( item ) ->

				delete_item = {}

				_.each item, ( vpc_item ) ->

					if _.indexOf( _.keys( item ), vpc_id ) isnt -1
						delete_item = item[ vpc_id ]

				delete item[ vpc_id ] if delete_item

		catch error
		  console.log 'delUnmanaged', vpc_id, error

		unmanaged_resource_list

	unmanaged_vpc_list = {}

	addUnmanagedVpc = ( key, value ) ->
		unmanaged_vpc_list[ key ] = value

	getUnmanagedVpc = ( id ) ->
		console.log 'getUnmanagedVpc', id
		unmanaged_vpc_list[ id ]

	listUnmanagedVpc = ->
		console.log 'listUnmanagedVpc'
		unmanaged_vpc_list

	#############################
	#  state editor
	#############################

	# host1 is component name
	# [{ name : '{host1.privateIP}', value: '{host1.privateIP}' }, { name: '{host1.keyName}', value: '{host1.keyName}' ]
	state_editor_list = []

	initSEList = ->
		state_editor_list = []

	listSE = ->
		state_editor_list

	addSEList = ( data ) ->
		console.log 'addSEList', data

		if data and data.component

			# add name and uid object
			addSENameUIDList data

			# get components list
			comp_list = _.values data.component

			# check component list valid
			if comp_list and not _.isEmpty( comp_list ) and _.isArray( comp_list )

				# init state_editor_list
				initSEList()

				_.each comp_list, ( component ) ->

					# set name
					name = component.name

					# get component.resource to array list by key
					key_list = _.keys component.resource

					# check key list valid
					if key_list and not _.isEmpty( key_list ) and _.isArray( key_list ) and not _.isEmpty( component.name )

						_.each key_list, ( item ) ->
							str = '{' + name + '.' + item + '}'
							state_editor_list.push { 'name' : str, 'value' : str }

		# console
		console.log 'state_editor_list', state_editor_list

		# add test local storage state_editor_list
		MC.storage.set 'state_editor_list', state_editor_list

		# return
		state_editor_list

	# host1     : { uid : 'xxxxxxx-xxxx-xx', type : 'AWS.EC2.Instance' }
	# DefaultSG : { uid : 'xxxxxxx-xxxx-xx', type : 'AWS.EC2.SecurityGroup' }
	state_editor_name_list = {}

	initSENameUIDList = ->
		state_editor_name_list = {}

	listSENameUID = ->
		state_editor_name_list

	addSENameUIDList = ( data ) ->
		console.log 'addSENameUIDList', data

		if data and data.component

			# init
			initSENameUIDList()

			_.each data.component, ( item ) ->
				state_editor_name_list[ item.name ] = { uid : item.uid, type : item.type }

		# console
		console.log 'state_editor_name_list', state_editor_name_list

		# add test local storage state_editor_name_list
		MC.storage.set 'state_editor_name_list', state_editor_name_list

		# return
		state_editor_name_list

	# ssh apt@211.98.26.7/pot@{asg1.PlacementGroup} @{asg1.LoadBalancerNames} @{asg1.Status} @{asg1.AutoScalingGroupARN} @{eni0.MacAddress}
	# @{aaa.bbb}
	# [^@{][-\w\.]+[}]
	filterStateData = ( data ) ->
		console.log 'filterStateData', data

		# new obj
		filter_data = $.extend true, {}, data

		# regexp
		reg  = /[^@{][-\w\.]+[}]/igm

		_.each filter_data, ( item ) ->

			item.parameter.verify_gpg = item.parameter.verify_gpg.replace reg, ( $0 ) ->
				console.log 'sfasdfasdf', $0

				split_arr = $0.split('.')
				obj       = state_editor_name_list[ split_arr[0] ]

				if obj and obj.uid and split_arr.length > 1
					obj.uid + '.' + split_arr[1]
				else
					$0

		# return new object
		filter_data

	convertUID = ( str ) ->
		console.log 'convertUID', str

		# regexp
		reg  = /[^@{][-\w\.]+[}]/igm

		new_str = str.replace reg, ( $0 ) ->

			split_arr = $0.split('.')
			obj       = state_editor_name_list[ split_arr[0] ]

			if obj and obj.uid and split_arr.length > 1
				obj.uid + '.' + split_arr[1]
			else
				$0

		new_str

	#############################
	#  local thumbnail
	#############################

	# cacheThumb[ tab_id ] =
	#	canvas       : <$("#canvas_body").html()>
	#	svg          : <$("#svg_canvas")[0].getBBox()>

	cacheThumb = {}

	addCacheThumb = ( id, canvas, svg ) ->
		console.log 'addCacheThumb', id

		cacheThumb[ id ] =
			canvas : canvas
			svg    : svg

	getCacheThumb = ( id ) ->
		cacheThumb[ id ]

	delCacheThumb = ( id ) ->
		delete cacheThumb[ id ]

	#public
	canvasData         : canvasData

	isCurrentTab       : isCurrentTab
	isResultRight      : isResultRight
	setCurrentTabId	   : setCurrentTabId
	searchStackAppById : searchStackAppById
	processType        : processType
	verify500          : verify500
	checkRepeatStackName : checkRepeatStackName

	addProcess         : addProcess
	getProcess         : getProcess
	deleteProcess      : deleteProcess
	filterProcess      : filterProcess
	initDataProcess    : initDataProcess

	createUID          : createUID
	addCacheMap        : addCacheMap
	delCacheMap        : delCacheMap
	setCacheMap        : setCacheMap
	getCacheMap        : getCacheMap
	searchCacheMap     : searchCacheMap
	listCacheMap       : listCacheMap

	initUnmanaged      : initUnmanaged
	listUnmanaged      : listUnmanaged
	addUnmanaged       : addUnmanaged
	delUnmanaged       : delUnmanaged

	addUnmanagedVpc    : addUnmanagedVpc
	getUnmanagedVpc    : getUnmanagedVpc
	listUnmanagedVpc   : listUnmanagedVpc

	initSEList         : initSEList
	listSE             : listSE
	addSEList          : addSEList

	initSENameUIDList  : initSENameUIDList
	listSENameUID      : listSENameUID
	addSENameUIDList   : addSENameUIDList
	filterStateData    : filterStateData
	convertUID         : convertUID

	addCacheThumb      : addCacheThumb
	getCacheThumb      : getCacheThumb
	delCacheThumb      : delCacheThumb
