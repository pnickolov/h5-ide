module.exports = {

	config: {
		files: '<%= jshint.config %>',
		tasks: [ 'jshint:config' ]
	},

	jshint: {
		files: '<%= jsfiles %>',
		tasks: [ 'jshint:files', 'livereload' ]
	},

	csslint: {
		files: '<%= cssfiles %>',
		tasks: [ 'csslint:files', 'livereload' ]
	},

	coffee: {
		files: '<%= coffeefiles %>',
		tasks: [ 'coffeelint:files', 'coffee' ]
	},

	index: {
		files: '<%= htmlfiles %>',
		tasks: [ 'livereload' ]
	}

};