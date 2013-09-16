
module.exports = {

	compile_login: {
		options: {
			appDir         : './<%= release %>',
			baseUrl        : './',
			dir            : './<%= temp %>',
			optimize       : 'none',
			mainConfigFile : './<%= src %>/js/login/config.js',
			modules        : [{
				name       : 'main'
			}],
			paths          : {
				jquery     : 'vender/jquery/jquery'
			}
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
			}],
			paths          : {
				jquery     : 'vender/jquery/jquery'
			}
		}
	}

};