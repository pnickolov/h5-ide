#############################
#  main for ide
#############################

define [ 'event', 'layout', 'header', 'navigation', 'tabbar', 'dashboard', 'design' ], ( event, layout, header, navigation, tabbar, dashboard, design ) ->

	initialize : () ->

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
		event.onListen event.NAVIGATION_COMPLETE, () ->
			console.log 'NAVIGATION_COMPLETE'

			setTimeout () ->
				#load layout
				layout.ready()
			,2000
		#event.onListen event.DESIGN_COMPLETE, () ->
		#	console.log 'DESIGN_COMPLETE'