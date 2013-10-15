
require [ 'domReady', 'router', 'i18n!nls/lang.js' ], ( domReady, router, lang ) ->

	### env:prod ###
	if window.location.protocol is 'http:' and window.location.hostname isnt 'localhost'
		currentLocation = window.location.toString()
		currentLocation = currentLocation.replace('http:', 'https:')
		window.location = currentLocation
	### env:prod:end ###

	domReady () ->
		router.initialize()

		#i18n
		Handlebars.registerHelper 'i18n', ( text ) ->
			new Handlebars.SafeString lang.reset[ text ]