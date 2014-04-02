#############################
#  main for ide
#############################

define [ 'MC', 'event', 'handlebars'
		 'i18n!nls/lang.js',
		 'view', 'canvas_layout',
		 'header', 'navigation', 'tabbar', 'dashboard', 'design_module', 'process',
		 'WS', 'constant',
		 'base_model',
		 'common_handle', 'validation', 'aws_handle', "MC.template"
], ( MC, ide_event, Handlebars, lang, view, canvas_layout, header, navigation, tabbar, dashboard, design, process, WS, constant, base_model, common_handle, validation ) ->

	console.info canvas_layout

	#getMadeiracloudIDESessionID = ( ) ->
	#
	#	result = null
	#
	#	madeiracloud_ide_session_id = $.cookie 'madeiracloud_ide_session_id'
	#	if madeiracloud_ide_session_id
	#		try
	#			result = JSON.parse ( MC.base64Decode madeiracloud_ide_session_id )
	#		catch err
	#			result = null
	#
	#	if result and $.type result == "array" and result.length == 7
	#		{
	#			userid      : result[0] ,
	#			usercode    : result[1] ,
	#			session_id  : result[2] ,
	#			region_name : result[3] ,
	#			email       : result[4] ,
	#			has_cred    : result[5] ,
	#			account_id	: result[6] ,
	#		}
	#	else
	#		null

	initialize : () ->

		#############################
		#  check network
		#############################

		_.delay () ->
			console.log '---------- check network ----------'
			if !MC.data.is_loading_complete and $( '#loading-bar-wrapper' ).html().trim() isnt ''
				ide_event.trigger ide_event.SWITCH_MAIN
				notification 'error', lang.ide.IDE_MSG_ERR_CONNECTION, true
		, 50 * 1000

		#############################
		#  validation cookie
		#############################

		#clear path=/v2 cookie(patch)
		#common_handle.cookie.clearV2Cookie '/v2'
		#common_handle.cookie.clearV2Cookie '/v2/'

		#if common_handle.cookie.getIDECookie()
		#	common_handle.cookie.setCookie common_handle.cookie.getIDECookie()
		#else
		#	if !common_handle.cookie.checkAllCookie()
		#		#user session not exist, go to login page
		#
        #        window.location.href = "login.html"

		#user session not exist, go to login page
		if !common_handle.cookie.checkAllCookie()
			window.location.href = "login.html"

		#clear cookie in 'ide.visualops.io'
		#common_handle.cookie.clearInvalidCookie()

		#############################
		#  initialize MC.data
		#############################

		#set MC.data
		#MC.data = {}

		# set default 'dashboard'
		MC.data.current_tab_id = 'dashboard'

		#global config data by region
		MC.data.config = {}
		MC.data.config[r] = {} for r in constant.REGION_KEYS

		#global cache for all ami
		MC.data.dict_ami = {}

		#global stack name list
		MC.data.stack_list = {}
		MC.data.stack_list[r] = [] for r in constant.REGION_KEYS
		#global app name list
		MC.data.app_list = {}
		MC.data.app_list[r] = [] for r in constant.REGION_KEYS

		#
		MC.data.nav_new_stack_list = {}
		MC.data.nav_app_list       = {}
		MC.data.nav_stack_list     = {}

		#global resource data (Describe* return)
		MC.data.resource_list = {}
		MC.data.resource_list[r] = {} for r in constant.REGION_KEYS

		#set untitled
		MC.data.untitled = 0
		#set tab
		MC.tab          = {}
		#set process tab
		MC.process      = {}
		MC.data.process = {}
		MC.storage.remove 'process'

		#save <div class="loading-wrapper" class="main-content active">
		MC.data.loading_wrapper_html = null
		MC.data.is_loading_complete = false

		#save resouce service name
		MC.data.resouceapi = []
		#dependency MC.data.is_loading_complete and MC.data.design_submodule_count = -1
		MC.data.ide_available_count = 0

		#temp
		#MC.data.IDEView = view

		MC.data.account_attribute = {}
		MC.data.account_attribute[r] = { 'support_platform':'', 'default_vpc':'', 'default_subnet':{} } for r in constant.REGION_KEYS

		#
		MC.data.demo_stack_list = constant.DEMO_STACK_NAME_LIST
		#
		MC.open_failed_list = {}

		#trusted advisor
		MC.ta            = {}
		MC.ta            = validation
		MC.ta.list       = []
		MC.ta.state_list = {}

		#state editor
		MC.data.state = {}

		# State clipboard
		MC.data.stateClipboard = []

		#test
		MC.ide_event = ide_event

		#temp
		MC.data.running_app_list = {}

		# include 'NEW_STACK' 'OPEN_STACK' 'OPEN_APP'
		MC.data.open_tab_data    = {}

		#############################
		#  WebSocket
		#############################

		WS.websocketInit()
		websocket = new WS.WebSocket()
		initialize = true

		relogin = () ->
			console.log 'relogin'
			ide_event.trigger ide_event.SWITCH_MAIN
			require [ 'component/session/main' ], ( session_main ) -> session_main.loadModule()

		status = () ->
			websocket.status false, ()->
				# do thing alert here, may trigger several time
				console.log '---------- connection failed ----------'
				view.disconnectedMessage 'show'
			websocket.status true, ()->
				console.log 'connection succeed'
				view.disconnectedMessage 'hide'

		setTimeout status, 15000

		subScriptionError = ( error ) ->
			console.log '---------- session invalid ----------'
			console.log error
			relogin()
			null

		subRequestReady = () ->
			console.log 'collection request ready'

			ide_event.trigger ide_event.WS_COLLECTION_READY_REQUEST

		#
		subScoket = () ->
			console.log 'subScoket'
			websocket.sub "request", $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, subRequestReady, subScriptionError
			websocket.sub "stack",   $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null, null
			websocket.sub "app",     $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null, null
			websocket.sub "status",  $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null, null
			websocket.sub "imports", $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null, null
		subScoket()

		#set MC.data.websocket
		MC.data.websocket = websocket

		#############################
		#  listen ide_event
		#############################

		#listen main view event
		#listen RETURN_OVERVIEW_TAB and RETURN_REGION_TAB
		ide_event.onLongListen ide_event.RETURN_OVERVIEW_TAB, () -> view.showOverviewTab()
		ide_event.onLongListen ide_event.RETURN_REGION_TAB,   () -> view.showRegionTab()
		#listen SWITCH_TAB and SWITCH_DASHBOARD
		ide_event.onLongListen ide_event.SWITCH_TAB,          () -> view.showTab()
		ide_event.onLongListen ide_event.SWITCH_DASHBOARD,    () -> view.showDashbaordTab()
		ide_event.onLongListen ide_event.SWITCH_PROCESS,      () -> view.showProcessTab()
		#
		ide_event.onLongListen ide_event.SWITCH_MAIN,         () -> view.showMain()
		ide_event.onLongListen ide_event.SWITCH_LOADING_BAR,  ( tab_id, is_transparent ) -> view.showLoading tab_id, is_transparent
		ide_event.onLongListen ide_event.SWITCH_WAITING_BAR,  () -> view.toggleWaiting()
		ide_event.onLongListen ide_event.HIDE_STATUS_BAR,     () -> view.hideStatubar()

		#listen IDE_AVAILABLE
		ide_event.onLongListen ide_event.IDE_AVAILABLE, () ->
			console.log 'IDE_AVAILABLE'
			MC.data.ide_available_count = MC.data.ide_available_count + 1
			console.log '----------- ide:SWITCH_MAIN -----------'
			ide_event.trigger ide_event.SWITCH_MAIN if MC.data.ide_available_count is 4

		#listen RECONNECT_WEBSOCKET
		ide_event.onLongListen ide_event.RECONNECT_WEBSOCKET, () -> subScoket()

		#############################
		#  load module
		#############################

		if window.location.pathname isnt '/import-test.html'
			#load header
			header.loadModule()
			#load tabbar
			tabbar.loadModule()
			#load dashboard
			dashboard.loadModule()

		#listen DASHBOARD_COMPLETE
		ide_event.onListen ide_event.DASHBOARD_COMPLETE, () ->
			console.log 'DASHBOARD_COMPLETE'
			navigation.loadModule()

		#listen NAVIGATION_COMPLETE
		ide_event.onListen ide_event.NAVIGATION_COMPLETE, () ->
			console.log 'NAVIGATION_COMPLETE'
			#load design
			design.loadModule()
			#temp
			setTimeout () ->
				#load layout
				console.log 'layout'
				#layout.ready()
				canvas_layout.canvas_initialize()
			, 2000

		#listen DESIGN_COMPLETE
		ide_event.onListen ide_event.DESIGN_COMPLETE, () ->
			console.log 'DESIGN_COMPLETE'
			process.loadModule()
			#
			#ide_event.trigger ide_event.SWITCH_MAIN

		#listen RESOURCE_COMPLETE
		#ide_event.onListen ide_event.RESOURCE_COMPLETE, () ->
		#	console.log 'RESOURCE_COMPLETE'

		#############################
		# Handlebars helper
		#############################

		# i18n
		Handlebars.registerHelper 'i18n', ( text ) ->
			### env:prod ###
			if lang.ide[ text ]
				return new Handlebars.SafeString lang.ide[ text ]
			### env:prod:end ###

			### env:dev ###
			new Handlebars.SafeString lang.ide[ text ]
			### env:dev:end ###

		# nl2br
		Handlebars.registerHelper 'nl2br', (text) ->
			nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
			return new Handlebars.SafeString(nl2br)

		# if equal
		Handlebars.registerHelper 'ifCond', ( v1, v2, options ) ->
			return options.fn this if v1 is v2
			return options.inverse this

		# deal break line
		Handlebars.registerHelper('breaklines', (text) ->
			text = Handlebars.Utils.escapeExpression(text)
			text = text.replace(/(\r\n|\n|\r)/gm, '<br>')
			return new Handlebars.SafeString(text)
		)

		#############################
		#  analytics
		#############################

		#temp disable analytics

		# analytics.identify($.cookie("userid"), {
		# 	name : $.cookie("username"),
		# 	username : $.cookie("username"),
		# 	email : MC.base64Decode($.cookie("email")),
		# 	region : $.cookie("region_name"),
		# 	created : 1328260166
		# 	}, {
		# 	Intercom : {
		# 		userHash : '5add343430ecaf54f7c1a6285758fcccb87fb365d089d6e1a520b2d7fa49fb05'
		# 	}
		# })

		# analytics.track('Loaded IDE', { })

		#intercom
		#window.intercomSettings.email      = MC.base64Decode( common_handle.cookie.getCookieByName( 'email' ))
		#window.intercomSettings.username   = common_handle.cookie.getCookieByName( 'username' )
		#window.intercomSettings.created_at = MC.dateFormat( new Date(), 'hh:mm MM-dd-yyyy' )
		#intercom_sercure_mode_hash         = () ->
		#	intercom_api_secret = '4tGsMJzq_2gJmwGDQgtP2En1rFlZEvBhWQWEOTKE'
		#	hash = CryptoJS.HmacSHA256( MC.base64Decode($.cookie('email')), intercom_api_secret )
		#	console.log 'hash.toString(CryptoJS.enc.Hex) = ' + hash.toString(CryptoJS.enc.Hex)
		#	return hash.toString CryptoJS.enc.Hex
		#if !window.intercomSettings.user_hash
		#	localStorage.setItem 'user_hash', intercom_sercure_mode_hash()
		#	window.intercomSettings.user_hash  = intercom_sercure_mode_hash()

		#window.intercomSettings.stack_total= 0

		#############################
		#  base model
		#############################

		base_model.sub ( error ) ->
			console.log 'sub'
			if error.return_code is constant.RETURN_CODE.E_SESSION
				relogin()
				if error.param[0].method is 'info'
					if error.param[0].url in [ '/stack/', '/app/' ]
						ide_event.trigger ide_event.CLOSE_DESIGN_TAB, error.param[4][0]
			else

				label = 'ERROR_CODE_' + error.return_code + '_MESSAGE'
				console.warn lang.service[ label ],error

				return if error.error_message.indexOf( 'AWS was not able to validate the provided access credentials' ) isnt -1
				return if error.param[0].url is '/session/' and error.param[0].method is 'login'

				if error.return_code == -1 and error.error_message == "200"
					if error.param[0].url is '/aws/' and error.param[0].method is 'resource'
						notification 'warning', lang.service["ERROR_CODE_-1_MESSAGE_AWS_RESOURCE"]
					else
						notification 'warning', lang.service[label]
					return null

				if lang.service[ label ]
					error_msg = lang.service[ label ] + "(" + error.return_code + ")"
				else
					error_msg = "unknown error (" + error.return_code + ")"

				if error_msg and $(".error_item").text().indexOf(error_msg) is -1
					notification 'error', error_msg, false

			null

		###########################
		#listen to the request list
		###########################
		listenRequestList = () ->
			console.log 'listen to request list'

			MC.data.websocket.collection.request.find().fetch()
			query = MC.data.websocket.collection.request.find()
			handle = query.observeChanges {
				added : (idx, dag) ->
					ide_event.trigger ide_event.UPDATE_REQUEST_ITEM, idx, dag

				changed : (idx, dag) ->
					ide_event.trigger ide_event.UPDATE_REQUEST_ITEM, idx, dag
			}

			null

		listenRequestList()

		###########################
		#listen to the import list
		###########################
		listenImportList = () ->
			console.log 'listen to import list'

			MC.data.websocket.collection.imports.find().fetch()
			query = MC.data.websocket.collection.imports.find()
			handle = query.observe {
				added : (idx, dag) ->
					ide_event.trigger ide_event.UPDATE_IMPORT_ITEM, idx

				changed : (idx, dag) ->
					ide_event.trigger ide_event.UPDATE_IMPORT_ITEM, idx
			}

			null

		listenImportList()


		###########################
		# Dispaly stop supporting classic and default VPC notification
		###########################
		displaySystemNotice = () ->

			isDisplayed = $.cookie('notice-sn')

			if isDisplayed is undefined
				$( "#wrapper" ).before MC.template.systemNotice

			$('#system-notice-close').on 'click', () ->
				$('#system-notice').remove()

				$.cookie 'notice-sn', '1'

		displaySystemNotice()

		null
