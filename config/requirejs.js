
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
			}]
		}
	},

	compile_register: {
		options: {
			appDir         : './<%= release %>',
			baseUrl        : './',
			dir            : './<%= reg_temp %>',
			optimize       : 'none',
			mainConfigFile : './<%= src %>/js/register/config.js',
			modules        : [{
				name       : 'main'
			}]
		}
	},

	compile_reset: {
		options: {
			appDir         : './<%= release %>',
			baseUrl        : './',
			dir            : './<%= reset_temp %>',
			optimize       : 'none',
			mainConfigFile : './<%= src %>/js/reset/config.js',
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