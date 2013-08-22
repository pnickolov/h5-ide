
module.exports = {

	compile_login: {
		options: {
			appDir         : './<%= release %>',
			baseUrl        : './',
			dir            : './<%= publish %>',
			optimize       : 'none',
			mainConfigFile : './<%= src %>/js/login/config.js',
			modules        : [{
				name       : 'main'
			}]
		}
	},

	compile_ide: {
		options: {
			appDir         : './<%= release %>',
			baseUrl        : './',
			dir            : './<%= publish %>',
			optimize       : 'none',
			mainConfigFile : './<%= src %>/js/ide/config.js',
			modules        : [{
				name       : 'main'
			}]
		}
	}

};