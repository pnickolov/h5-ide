
var path = require( 'path' ),
    os   = require( 'os' );

module.exports = function( grunt ) {

	var config = {

		pkg        : grunt.file.readJSON( 'package.json' ),

		src        : 'src',
		release    : 'release',
		publish    : 'publish',
		temp       : '~temp',
		vender     : 'vender',
		components : 'bower_components',

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
			'!<%= src %>/bootstrap/**/*.css',
			'!<%= src %>/test/jsondiff/css/master.css'
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

		requirejs  : require( './config/requirejs.js' ),
		strip      : require( './config/strip.js'   ),
		"dev_prod_switch": require( './config/dev_prod_switch.js'),

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
	grunt.registerTask( 'make_fast', function() {
		grunt.task.run([
			'coffee:compile_fast'
		]);
	});
	grunt.registerTask( 'make', function() {
		grunt.task.run([
			'coffeelint:files',
			'coffee:compile_normal',
			'jshint',
			'csslint'
		]);
	});
	grunt.registerTask( 'make_all', function() {
		grunt.task.run([
			'coffeelint:files',
			'coffee:compile_all',
			'jshint',
			'csslint'
		]);
	});
	grunt.registerTask( 'make_release', function() {
		grunt.task.run([
			'copy:dev_prod_switch_task',
			'replace:prod_env_switch',
			'dev_prod_switch:release',
			'replace:analytics',
			'strip'
		]);
	});
	grunt.registerTask( 'dev_env', function() {
		grunt.task.run([
			'copy:dev_prod_switch_task',
			'replace:dev_env_switch',
			'dev_prod_switch:develop'
		]);
	});

	/* task of use as develop */
	grunt.registerTask( 'dev_fast', [
									'make_fast',
									'dev_env',
									'livereload-start',
									'connect:develop',
									'open:develop',
									'watch'
	]);
	grunt.registerTask( 'develop', [
									'make',
									'dev_env',
									'livereload-start',
									'connect:develop',
									'open:develop',
									'watch'
	]);
	grunt.registerTask( 'dev_all', [
									'make_all',
									'dev_env',
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

	/* task of use as release */
	grunt.registerTask( 'release', ['clean:release',
									'make_all',
									'copy:publish',
									'copy:lib_aws',
									'copy:lib_forge',
									'copy:special_lib',
									'copy:special_ui',
									'make_release',
									'cssmin',
									'uglify',
									'copy:special_lib_rename',
									'copy:special_ui_rename',
									'copy:special_lib_del',
									'copy:special_ui_del',
									'open:publish',
									'connect:release'
	]);

	/* run at r.js as publish */
	grunt.registerTask( 'publish', ['requirejs',
									'copy:publish_login',
									'clean:temp',
									'open:publish',
									'connect:publish'
	]);

	/* task of use as release */
	grunt.registerTask( 'deploy', [//release
									'clean:release',
									'make_all',
									'copy:publish',
									'copy:lib_aws',
									'copy:lib_forge',
									'copy:special_lib',
									'copy:special_ui',
									'make_release',
									'cssmin',
									'uglify',
									'copy:special_lib_rename',
									'copy:special_ui_rename',
									'copy:special_lib_del',
									'copy:special_ui_del',
									//publish
									'requirejs',
									'copy:publish_login',
									'clean:temp'
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