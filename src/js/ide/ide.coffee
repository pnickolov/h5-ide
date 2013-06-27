#############################
#  main for ide
#############################

define [ 'MC', 'event',
         'view', 'layout',
         'header', 'navigation', 'tabbar', 'dashboard', 'design',
         'WS'
], ( MC, ide_event, view, layout, header, navigation, tabbar, dashboard, design, WS ) ->

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
		MC.data = {}
		#set untitled
		MC.data.untitled = 0
		#set tab
		MC.tab  = {}

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
		#
		websocket.sub "request", $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null, subScriptionError
		#
		websocket.sub "stack", $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null, null

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

		#############################
		#  load module
		#############################

		#load header
		header.loadModule()
		#load tabbar
		tabbar.loadModule()
		#listen DASHBOARD_COMPLETE
		ide_event.onListen ide_event.DASHBOARD_COMPLETE, () ->
			console.log 'DASHBOARD_COMPLETE'
			navigation.loadModule()
		#load dashboard
		dashboard.loadModule()

		#listen NAVIGATION_COMPLETE
		ide_event.onListen ide_event.NAVIGATION_COMPLETE, () ->
			console.log 'NAVIGATION_COMPLETE'

			setTimeout () ->
				#load layout
				layout.ready()
			, 2000
		#load design
		design.loadModule()

		null