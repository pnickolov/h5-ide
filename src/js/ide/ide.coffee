#############################
#  main for ide
#############################

define [ 'MC', 'event', 'view', 'layout', 'header', 'navigation', 'tabbar', 'dashboard', 'design', 'WS' ], ( MC, ide_event, view, layout, header, navigation, tabbar, dashboard, design, WS ) ->

	initialize : () ->

		#set MC.data
		MC.data = {}
		#set untitled
		MC.data.untitled = 0
		#set tab
		MC.tab  = {}

		#listen main view event
		#listen RETURN_OVERVIEW_TAB and RETURN_REGION_TAB
		ide_event.onLongListen ide_event.RETURN_OVERVIEW_TAB, () -> view.showOverviewTab()
		ide_event.onLongListen ide_event.RETURN_REGION_TAB,   () -> view.showRegionTab()
		#listen SWITCH_TAB and SWITCH_DASHBOARD
		ide_event.onLongListen ide_event.SWITCH_TAB,          () -> view.showTab()
		ide_event.onLongListen ide_event.SWITCH_DASHBOARD,    () -> view.showDashbaordTab()

		#load header
		header.loadModule()
		#load tabbar
		tabbar.loadModule()
		#load design
		design.loadModule()
		#load dashboard
		dashboard.loadModule()

		setTimeout () ->
			#load navigation
			navigation.loadModule()
		,2000

		#temp
		ide_event.onListen ide_event.NAVIGATION_COMPLETE, () ->
			console.log 'NAVIGATION_COMPLETE'

			setTimeout () ->
				#load layout
				layout.ready()
			,2000
		#ide_event.onListen ide_event.DESIGN_COMPLETE, () ->
		#	console.log 'DESIGN_COMPLETE'

		# WebSocket initialize

		WS.websocketInit()

		websocket = new WS.WebSocket()

		initialize = true

		status = () ->

			websocket.status false, ()->

				# do thing alert here, may trigger several time
				
				alert 'connection failed'

			websocket.status true, ()->

				if initialize == false

					# do something here, trigger when connection recover
					alert 'connection succeed'

				else

					initialize = false

				null

		setTimeout status, 10000

		websocket.sub "request", $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, null

		MC.data.websocket = websocket

		null