module.exports = {

	options: {
		no_tabs: {
			level: 'ignore'
		},
		max_line_length: {
			level: 'ignore'
		},
		indentation: {
			level: 'ignore'
		}
	},

	files   : '<%= coffeefiles %>',
	changed : '<%= grunt.regarde.changed %>'

};