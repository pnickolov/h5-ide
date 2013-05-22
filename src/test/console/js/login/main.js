/*
//main
require( [ 'login' ], function( login ) {
	login.ready();
});
*/


(function() {
  require(['login'], function(login) {
    return login.ready();
  });

}).call(this);
