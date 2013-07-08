#############################
#  main for ide
#############################

require [ 'domReady', 'router' ], ( domReady, router ) ->

	domReady () ->
		router.initialize()