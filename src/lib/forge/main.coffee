define [ 'MC',
		'lib/forge/stack',
		'lib/forge/app'
], ( MC, forge_handler_stack, forge_handler_app) ->

	MC.forge = {
		stack  : forge_handler_stack
		app    : forge_handler_app
	}
