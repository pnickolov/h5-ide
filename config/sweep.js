module.exports.run = function( grunt, config ) {

	/* clean js files by coffee generate */
	var coffeeSrc = [
		config.src + '/**/*.coffee',
		'!' + config.src + '/' + config.libs + '/**/*.coffee'
	];

	var coffeeFileAry = grunt.file.expand( coffeeSrc );

	for( var i in coffeeFileAry ) {

		//delete js file of same as coffee
		var coffeePath = coffeeFileAry[i];
		var jsPath     = coffeePath.replace( /.coffee$/, '.js' );

		if( grunt.file.exists( jsPath )) {
			grunt.file.delete( jsPath );
			console.log( 'deleted: ' + jsPath );
		}

	}
};