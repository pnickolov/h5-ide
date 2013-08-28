#############################
#  main for ide
#############################

require [ 'domReady', 'router' ], ( domReady, router ) ->

	### env:dev ###
	require [ 'test/json_view/json_view' ]
	### env:dev:end ###

	domReady () ->
		router.initialize()