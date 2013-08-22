#############################
#  main for ide
#############################

require [ 'domReady', 'router' ], ( domReady, router ) ->

	### ##json_view ###

	domReady () ->
		router.initialize()