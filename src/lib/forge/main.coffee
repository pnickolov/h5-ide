define [ 'MC',
		'lib/forge/stack',
		'lib/forge/app',
    "Design" # Don't know why we need Design here. But the js/ide/config's shim indicate we need. Kinda ridiculous.
], ( MC, forge_handler_stack, forge_handler_app) ->

	MC.forge = {
		stack  : forge_handler_stack
		app    : forge_handler_app
	}
