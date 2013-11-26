define [ 'MC',
		'lib/forge/stack',
		'lib/forge/app',
		'lib/forge/cookie',
		'lib/forge/other'
], ( MC, forge_handler_stack, forge_handler_app, cookie, other ) ->

	MC.forge = {
		stack  : forge_handler_stack
		app    : forge_handler_app
		cookie : cookie
		other  : other
	}