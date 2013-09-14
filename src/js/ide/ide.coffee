#############################
#  main for ide
#############################

define [ 'MC', 'event', 'handlebars'
		 'i18n!nls/lang.js',
		 'view', 'layout', 'canvas_layout',
		 'header', 'navigation', 'tabbar', 'dashboard', 'design', 'process',
		 'WS', 'constant',
		 'base_model',
		 'forge_handle', 'aws_handle', 'vender/crypto-js/hmac-sha256'
], ( MC, ide_event, Handlebars, lang, view, layout, canvas_layout, header, navigation, tabbar, dashboard, design, process, WS, constant, base_model, forge_handle ) ->

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
		forge_handle.cookie.clearV2Cookie '/v2'
		forge_handle.cookie.clearV2Cookie '/v2/'

		if forge_handle.cookie.getIDECookie()
			forge_handle.cookie.setCookie forge_handle.cookie.getIDECookie()
		else
			if !forge_handle.cookie.checkAllCookie()
				#user session not exist, go to login page
				window.location.href = 'login.html'

		#############################
		#  initialize MC.data
		#############################

		#set MC.data
		#MC.data = {}

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

		#global resource data (Describe* return)
		MC.data.resource_list = {}
		MC.data.resource_list[r] = {} for r in constant.REGION_KEYS

		#set untitled
		MC.data.untitled = 0
		#set tab
		MC.tab  = {}
		#set process tab
		MC.process = {}
		#save <div class="loading-wrapper" class="main-content active">
		MC.data.loading_wrapper_html = null
		#
		MC.data.is_reset_session = false
		#
		MC.data.is_loading_complete = false
		#save resouce service name
		MC.data.resouceapi = []

		#temp
		MC.data.IDEView = view

		MC.data.account_attribute = {}
		MC.data.account_attribute[r] = { 'support_platform':'', 'default_vpc':'', 'default_subnet':{} } for r in constant.REGION_KEYS

		#############################
		#  WebSocket
		#############################

		WS.websocketInit()
		websocket = new WS.WebSocket()
		initialize = true

		relogin = () ->
			console.log 'relogin'
			#
			MC.data.is_reset_session = true
			#
			ide_event.trigger ide_event.SWITCH_MAIN
			#
			require [ 'component/session/main' ], ( session_main ) -> session_main.loadModule()

		status = () ->
			websocket.status false, ()->
				# do thing alert here, may trigger several time
				console.log '---------- connection failed ----------'
				view.disconnectedMessage 'show'
			websocket.status true, ()->
				if initialize == false
					# do something here, trigger when connection recover
					console.log 'connection succeed'
					view.disconnectedMessage 'hide'
				else
					initialize = false
				null
		#
		setTimeout status, 10000

		subScriptionError = ( error ) ->
			console.log '---------- session invalid ----------'
			console.log error
			#redirect to page ide.html
			if MC.data.is_reset_session
				MC.data.is_reset_session = false
			else
				#window.location.href = 'login.html'
				#
				relogin()
			null

		subRequestReady = () ->
			console.log 'collection request ready'

			ide_event.trigger ide_event.WS_COLLECTION_READY_REQUEST

		#
		websocket.sub "request", $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, subRequestReady, subScriptionError
		#
		websocket.sub "stack", $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null, null

		websocket.sub "app", $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null, null

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
		ide_event.onLongListen ide_event.SWITCH_APP_PROCESS,  () -> view.showProcessTab()
		#
		ide_event.onLongListen ide_event.SWITCH_MAIN,         () -> view.showMain()
		ide_event.onLongListen ide_event.SWITCH_LOADING_BAR,  ( tab_id ) -> view.showLoading tab_id
		ide_event.onLongListen ide_event.SWITCH_WAITING_BAR,  () -> view.toggleWaiting()

		#############################
		#  load module
		#############################

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
				layout.ready()
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
		#  i18n
		#############################

		#i18n
		Handlebars.registerHelper 'i18n', ( text ) ->
			new Handlebars.SafeString lang.ide[ text ]

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
		#window.intercomSettings.email      = MC.base64Decode( forge_handle.cookie.getCookieByName( 'email' ))
		#window.intercomSettings.username   = forge_handle.cookie.getCookieByName( 'username' )
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
			console.log error
			if error.return_code is constant.RETURN_CODE.E_SESSION
				relogin()
				if error.param[0].method is 'info'
					if error.param[0].url in [ '/stack/', '/app/' ]
						ide_event.trigger ide_event.CLOSE_TAB, null, error.param[4][0]
			else
				label = 'ERROR_CODE_' + error.return_code + '_MESSAGE'
				console.log lang.service[ label ]
				return if error.error_message.indexOf( 'AWS was not able to validate the provided access credentials' ) isnt -1
				#
				notification 'error', lang.service[ label ], true if lang.service[ label ] and MC.forge.cookie.getCookieByName('has_cred') is 'true'

		null
