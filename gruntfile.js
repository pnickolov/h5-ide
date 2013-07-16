
var path = require( 'path' ),
    os   = require( 'os' );

module.exports = function( grunt ) {

	var config = {

		pkg        : grunt.file.readJSON( 'package.json' ),

		src        : 'src',
		libs       : 'vender',
		components : 'bower_components',
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
			'!<%= sourcedir[1] %>/canvas/canvas.js',
			'!<%= sourcedir[0] %>/ide/layout.js',
			'!<%= sourcedir[0] %>/ide/canvas_layout.js',
			'!<%= sourcedir[1] %>/design/resource/temp_view.js',
			'!<%= sourcedir[1] %>/design/property/temp_view.js',
			'!<%= src %>/service/*',
			'!<%= src %>/test/*'
		],

		cssfiles   : [
			'<%= src %>/**/*.css',
			'!<%= src %>/assets/**/*.css',
			'!<%= src %>/ui/common/css/*.css',
			'!<%= src %>/vender/qunit/*.css',
			'!<%= src %>/test/console/css/*.css',
			'!<%= src %>/test/console/prettify/*.css',
			'!<%= src %>/bootstrap/**/*.css'
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

		replace          : require( './config/replace.js'        ),
		"string-replace" : require( './config/string-replace.js' ),

		cssmin     : require( './config/cssmin.js'  ),
		htmlmin    : require( './config/htmlmin.js' ),
		uglify     : require( './config/uglify.js'  ),

		concat     : require( './config/concat.js'  ),

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
		grunt.task.run([
			'coffee:compile_fast',
			'coffeelint',
			'jshint',
			'csslint'
		]);
	});
	grunt.registerTask( 'make_fast', function() {
		grunt.task.run([
			'coffee:compile_fast'
		]);
	});
	grunt.registerTask( 'make_all', function() {
		grunt.task.run([
			'coffee:compile_all',
			'coffeelint',
			'jshint',
			'csslint'
		]);
	});

	/* task of use as develop */
	grunt.registerTask( 'develop', [
									'make',
									'livereload-start',
									'connect:develop',
									'open:develop',/*modify by xjimmy*/
									'watch'
	]);
	grunt.registerTask( 'dev_fast', [
									'make_fast',
									'livereload-start',
									'connect:develop',
									'open:develop',
									'watch'
	]);
	grunt.registerTask( 'dev_all', [
									'make_all',
									'livereload-start',
									'connect:develop',
									'open:develop',
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
	grunt.registerTask( 'publish', ['all',
									'clean',
									'copy:publish',
									'htmlmin',
									'replace',/*add by xjimmy, replace version info*/
									'cssmin',
									'uglify',
									'string-replace',/*add by xjimmy, remove console.log, console.info */
									'open:publish',/*modify by xjimmy*/
									'connect:publish'
	]);

	/*
	grunt.event.on( 'regarde:file', function (status, target, filepath) {
		console.log("status = " + status );
		console.log("filepath = " + filepath );
		console.log("target = " + target );
		if ( target == 'coffee' ) {
			var config = grunt.config( 'coffee' ) || {};
			var value = config.refresh || {};
			value.files = value.files || [];
			var cwd = path.dirname(filepath),
				src = path.basename(filepath);
			console.log("cwd = " + cwd )
			console.log("src = " + src )
			value.files.push({
				expand:true,
				src:src,
				dest:'src/',
				cwd:cwd,
				ext:'.js'
			});
			grunt.config('coffee', config);
		}
	});
	*/

	/* task of use as sweep */
	/*
	grunt.registerTask( 'clean', function() {
		config.sweep.run( grunt, config );
	});
	*/

};