
###
//main
require( [ 'login' ], function( login ) {
	login.ready();
});
###

require [ 'domReady', 'login', 'MC' ], ( domReady, login ) ->

	### env:prod ###
	if window.location.protocol is 'http:' and window.location.hostname isnt 'localhost'
		currentLocation = window.location.toString()
		currentLocation = currentLocation.replace('http:', 'https:')
		window.location = currentLocation
	### env:prod:end ###

	domReady () ->
		if MC.isSupport() == false
			$('#unsupported-browser').show()

		login.ready()