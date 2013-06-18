#############################
#  main for ide
#############################

define [ 'MC', 'event', 'view', 'layout', 'header', 'navigation', 'tabbar', 'dashboard', 'design' ], ( MC, ide_event, view, layout, header, navigation, tabbar, dashboard, design ) ->

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
		#load navigation
		navigation.loadModule()
		#temp
		ide_event.onListen ide_event.NAVIGATION_COMPLETE, () ->
			console.log 'NAVIGATION_COMPLETE'

			setTimeout () ->
				#load layout
				layout.ready()
			,2000
		#ide_event.onListen ide_event.DESIGN_COMPLETE, () ->
		#	console.log 'DESIGN_COMPLETE'