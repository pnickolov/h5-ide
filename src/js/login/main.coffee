
###
//main
require( [ 'login' ], function( login ) {
	login.ready();
});
###

require [ 'domReady', 'login' ], ( domReady, login ) ->

	### env:prod ###
	# if window.location.protocol is 'http:'
	# 	currentLocation = window.location.toString()
	# 	currentLocation = currentLocation.replace('http:', 'https:')
	# 	window.location = currentLocation
	### env:prod:end ###

	domReady () ->
		login.ready()