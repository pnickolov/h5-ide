define [ 'MC',
		'lib/forge/stack'
		'lib/forge/cookie'
], ( MC, forge_handler_stack, cookie ) ->

	MC.forge = {
		stack  : forge_handler_stack
		cookie : cookie
	}