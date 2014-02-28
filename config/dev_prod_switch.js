module.exports = {

	options: {
		environment    : '<%= grunt.file.read( "util/include/dev_prod_switch/env" ) %>',
		env_char       : '#',
		env_block_dev  : 'env:dev',
		env_block_prod : 'env:prod'
	},

	develop : {
		files: {
			'<%= src %>/js/login/main.js'                              : '<%= src %>/js/login/main.js',
			'<%= src %>/js/ide/main.js'                                : '<%= src %>/js/ide/main.js',
			'<%= src %>/js/register/main.js'                           : '<%= src %>/js/register/main.js',
			'<%= src %>/js/reset/main.js'                              : '<%= src %>/js/reset/main.js',
			'<%= src %>/module/design/property/main.js'                : '<%= src %>/module/design/property/main.js'
		}
	},

	release: {
		files: {
			'<%= release %>/js/ide/main.js'                            : '<%= src %>/js/ide/main.js',
			'<%= release %>/module/design/main.js'                     : '<%= src %>/module/design/main.js',
			'<%= release %>/module/design/toolbar/view.js'             : '<%= src %>/module/design/toolbar/view.js',
			'<%= release %>/module/design/toolbar/stack_template.html' : '<%= src %>/module/design/toolbar/stack_template.html',
			'<%= release %>/module/design/toolbar/app_template.html'   : '<%= src %>/module/design/toolbar/app_template.html',
			'<%= release %>/module/design/framework/Design.js'         : '<%= src %>/module/design/framework/Design.js',
			'<%= release %>/module/design/framework/ConnectionModel.js': '<%= src %>/module/design/framework/ConnectionModel.js',
			'<%= release %>/module/design/framework/resource/SgModel.js':'<%= src %>/module/design/framework/resource/SgModel.js',
			'<%= release %>/module/design/property/base/main.js'       : '<%= src %>/module/design/property/base/main.js',
			'<%= release %>/module/design/property/main.js'            : '<%= src %>/module/design/property/main.js'
			'<%= release %>/lib/MC.core.js'            				   : '<%= src %>/lib/MC.core.js'
		}
	}

};