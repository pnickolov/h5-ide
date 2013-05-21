module.exports = function( grunt ) {

	var config = {

		pkg        : grunt.file.readJSON( 'package.json' ),
		comp       : grunt.file.readJSON( 'component.json' ),

		src        : 'src',
		libs       : 'vender',
		components : 'components',
		release    : 'release',

		gruntfile  : [
			'gruntfile.js',
			'./config/*.js',
			'!./config/sweep.js'
		],

		sourcedir  : [
			'<%= src %>/js',
			'<%= src %>/module'
		],

		jsfiles    : [
			'<%= sourcedir[0] %>/**/*.js',
			'<%= sourcedir[1] %>/**/*.js',
			'!<%= src %>/vender/*',
			'!<%= sourcedir[1] %>/canvas/canvas.js'
		],

		cssfiles   : [
			'<%= src %>/**/*.css',
			'!<%= src %>/assets/**/*.css',
			'!<%= src %>/ui/common/css/*.css',
			'!<%= src %>/vender/qunit/*.css'
		],

		coffeefiles : [
			'<%= src %>/**/*.coffee'
		],

		htmlfiles   : [
			'<%= src %>/**/*.html'
		],

		bower      : require( './config/bower.js' ),
		copy       : require( './config/copy.js'  ),

		coffee     : require( './config/coffee.js'     ),
		coffeelint : require( './config/coffeelint.js' ),

		jshint     : require( './config/jshint.js'  ),
		csslint    : require( './config/csslint.js' ),

		watch      : require( './config/regarde.js' ),

		connect    : require( './config/connect.js' ),
		open       : require( './config/open.js'    ),
		clean      : require( './config/clean.js'   ),

		cssmin     : require( './config/cssmin.js'  ),
		htmlmin    : require( './config/htmlmin.js' ),
		uglify     : require( './config/uglify.js'  ),

		sweep      : require( './config/sweep.js'   )

	};

	/* init config */
	grunt.initConfig( config );

	/*  load npm tasks
		use matchdep each grunt-* with grunt.loadNpmTasks method */
	require( 'matchdep' ).filterDev( 'grunt-*' ).forEach( grunt.loadNpmTasks );

	/* rename regarde to watch */
	grunt.renameTask( 'regarde', 'watch' );

	/* task of use as watch project */
	grunt.registerTask( 'default', [ 'watch' ] );

	/* task of use as init project */
	grunt.registerTask( 'init', function() {

		var done = this.async();

		//install dependent js libs by bower
		config.bower.run( grunt, function( err ) {

			if( err ) {
				console.log( 'bower install error, please re-install again.' );
				return;
			}

			//copy components to libs
			grunt.task.run([ 'copy:develop' ]);
			done();

		});
	});

	/* task of use as make(compiler) */
	grunt.registerTask( 'make', function() {
		grunt.task.run([ 'coffee', 'coffeelint', 'jshint', 'csslint' ]);
	});

	/* task of use as develop */
	grunt.registerTask( 'develop', ['make',
									'livereload-start',
									'connect:develop',
									'open:develop',/*modify by xjimmy*/
									'watch'
	]);

	/* task of use as unit unittest (add by xjimmy) */
	grunt.registerTask( 'unittest', ['make',
									'livereload-start',
									'connect:unittest',
									'open:unittest',
									'watch'
	]);

	/* task of use as publish */
	grunt.registerTask( 'publish', ['make',
									'clean',
									'copy:publish',
									'htmlmin',
									'cssmin',
									'uglify',
									'open:publish',/*modify by xjimmy*/
									'connect:publish'
	]);

	/* task of use as sweep */
	/*
	grunt.registerTask( 'clean', function() {
		config.sweep.run( grunt, config );
	});
	*/

};