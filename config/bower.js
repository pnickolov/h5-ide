var install = require( 'bower' ).commands.install;

/*
var paths   = [
	'jquery',
	'underscore',
	'backbone',
	'handlebars',
	'requirejs',
	'requirejs-text',
	'requirejs-domready'
];
*/

module.exports.run = function( grunt, callback ) {

	var comp = grunt.file.readJSON( 'component.json' );

	var paths = [];

	for( var key in comp.devDependencies ) {
		paths.push( key + '#' + comp.devDependencies[ key ]);
	}

	install( paths )
	.on( 'data', function( data ) {
		console.log( data );
	})
	.on( 'end', function() {
		callback();
	});

};