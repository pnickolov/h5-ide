module.exports = {

	options: {
		environment    : '<%= grunt.file.read( "util/include/dev_prod_switch/env" ) %>',
		env_char       : '#',
		env_block_dev  : 'env:dev',
		env_block_prod : 'env:prod'
	},

	release: {
		files: {
			'<%= release %>/js/ide/main.js'                            : '<%= src %>/js/ide/main.js',
			'<%= release %>/module/design/toolbar/view.js'             : '<%= src %>/module/design/toolbar/view.js',
			'<%= release %>/module/design/toolbar/stack_template.html' : '<%= src %>/module/design/toolbar/stack_template.html',
			'<%= release %>/module/design/toolbar/app_template.html'   : '<%= src %>/module/design/toolbar/app_template.html',
		}
	}

};