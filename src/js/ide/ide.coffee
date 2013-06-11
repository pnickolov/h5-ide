#############################
#  main for ide
#############################

define [ 'event', 'view', 'layout', 'header', 'navigation', 'tabbar', 'dashboard', 'design' ], ( ide_event, view, layout, header, navigation, tabbar, dashboard, design ) ->

	initialize : () ->

		#listen main view event
		ide_event.onLongListen ide_event.RETURN_OVERVIEW_TAB, () -> view.showDashbaordTab()
		ide_event.onLongListen ide_event.RETURN_REGION_TAB, ()   -> view.showRegionTab()

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