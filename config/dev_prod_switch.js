module.exports = {

	options: {
		environment    : 'prod',
		env_char       : '#',
		env_block_dev  : 'env:dev',
		env_block_prod : 'env:prod'
	},
	all: {
		files: {
			'<%= src %>/js/ide/main.js'                : '<%= src %>/js/ide/main.js',
			'<%= src %>/module/design/toolbar/view.js' : '<%= src %>/module/design/toolbar/view.js'
		}
	}

};