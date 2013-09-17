define [ 'MC',
		'lib/forge/stack',
		'lib/forge/app',
		'lib/forge/cookie'
], ( MC, forge_handler_stack, forge_handler_app, cookie ) ->

	MC.forge = {
		stack  : forge_handler_stack
		app    : forge_handler_app
		cookie : cookie
	}