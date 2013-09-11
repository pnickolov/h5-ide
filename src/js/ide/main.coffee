#############################
#  main for ide
#############################

require [ 'domReady', 'router' ], ( domReady, router ) ->

	### env:dev ###
	require [ 'test/json_view/json_view' ]
	### env:dev:end ###

	### env:prod ###
	if window.location.protocol is 'http:'
		currentLocation = window.location.toString()
		currentLocation = currentLocation.replace('http:', 'https:')
		window.location = currentLocation
	### env:prod:end ###

	domReady () ->
		router.initialize()