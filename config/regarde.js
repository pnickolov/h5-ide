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
		tasks: [ 'coffeelint:files', 'coffee', 'livereload' ]
	},

	index: {
		files: '<%= htmlfiles %>',
		tasks: [ 'livereload' ]
	}

};