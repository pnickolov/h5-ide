###
//app initialize
require( [ 'domReady!', 'router' ], function( dom, AppRouter ) {

	AppRouter.initialize();

});
###

#app initialize
require [ 'domReady!', 'router' ], ( dom, router ) ->
	router.initialize()