
###
require [ 'ide' ], ( ide ) ->
	ide.ready()
###

require [ 'router' ], ( AppRouter ) ->
	AppRouter.initialize()