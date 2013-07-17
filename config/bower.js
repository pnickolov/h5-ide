var install = require( 'bower' ).commands.install;

module.exports.run = function( grunt, callback ) {

	var comp = grunt.file.readJSON( 'bower.json' );

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