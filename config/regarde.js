module.exports = {

	config: {
		files: '<%= jshint.config %>',
		tasks: [ 'jshint:config' ]
	},

	csslint: {
		files: '<%= cssfiles %>',
		tasks: [ 'csslint:files', 'livereload' ]
	},

	coffee: {
		files: '<%= coffeefiles %>',
		tasks: [ 'coffeelint:files', 'coffee:compile_fast', 'livereload' ]
	},

	index: {
		files: '<%= htmlfiles %>',
		tasks: [ 'livereload' ]
	}

};