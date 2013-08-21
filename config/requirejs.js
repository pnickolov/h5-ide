
module.exports = {

	compile: {
		options: {
			baseUrl        : './src/',
			mainConfigFile : './src/js/ide/config.js',
			optimize       : 'none',
			name           : 'js/ide/config',
			include        : [],
			out            : './release/js/ide/build.js',
			pragmasOnSave  : {
				excludeCoffeeScript : true
			}
		}
	}

};