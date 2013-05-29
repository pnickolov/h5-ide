
###
//main
require( [ 'login' ], function( login ) {
	login.ready();
});
###

require [ 'domReady', 'login' ], ( domReady, login ) ->

	domReady () ->
		login.ready()