var install = require( 'bower' ).commands.install;

var paths   = [
	'jquery',
	'underscore',
	'backbone',
	'handlebars',
	'requirejs',
	'requirejs-text',
	'requirejs-domready'
];

module.exports.run = function( callback ) {

	install( paths )
	.on( 'data', function( data ) {
		console.log( data );
	})
	.on( 'end', function() {
		callback();
	});

};