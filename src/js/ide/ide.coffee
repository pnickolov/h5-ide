#############################
#  main for ide
#############################

define [ 'MC', 'event', 'handlebars'
         'i18n!/nls/lang.js',
         'view', 'layout', 'canvas_layout',
         'header', 'navigation', 'tabbar', 'dashboard', 'design', 'process',
         'WS', 'constant', 'aws_handle', 'test/json_view/json_view'
], ( MC, ide_event, Handlebars, lang, view, layout, canvas_layout, header, navigation, tabbar, dashboard, design, process, WS, constant ) ->

	console.info canvas_layout

	initialize : () ->

		#############################
		#  validation cookie
		#############################
		#
		if $.cookie( 'usercode' ) is undefined then window.location.href = 'login.html'

		#############################
		#  initialize MC.data
		#############################

		#set MC.data
		#MC.data = {}

		#global config data by region
		MC.data.config = {}

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

		#############################
		#  WebSocket
		#############################

		WS.websocketInit()
		websocket = new WS.WebSocket()
		initialize = true

		status = () ->
			websocket.status false, ()->
				# do thing alert here, may trigger several time
				console.log 'connection failed'
			websocket.status true, ()->
				if initialize == false
					# do something here, trigger when connection recover
					console.log 'connection succeed'
				else
					initialize = false
				null
		#
		setTimeout status, 10000

		subScriptionError = ( error ) ->
			console.log 'session invalid'
			console.log error
			#redirect to page ide.html
			window.location.href = 'login.html'
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
				canvas_layout.ready()
			, 2000

		#listen DESIGN_COMPLETE
		ide_event.onListen ide_event.DESIGN_COMPLETE, () ->
			console.log 'DESIGN_COMPLETE'
			process.loadModule()

		#listen RESOURCE_COMPLETE
		#ide_event.onListen ide_event.RESOURCE_COMPLETE, () ->
		#	console.log 'RESOURCE_COMPLETE'

		#i18n
		Handlebars.registerHelper 'i18n', ( text ) ->
			new Handlebars.SafeString lang.ide[ text ]

		analytics.identify($.cookie("userid"),, {
			name : $.cookie("username"),
			username : $.cookie("username"),
			email : MC.base64Decode($.cookie("email")),
			region : MC.base64Decode($.cookie("region_name")),
			created : 1328260166
			}, {
			Intercom : {
				userHash : '5add343430ecaf54f7c1a6285758fcccb87fb365d089d6e1a520b2d7fa49fb05'
			}
		});
		
		analytics.track('Loaded IDE', { });
