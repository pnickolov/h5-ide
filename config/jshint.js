module.exports = {

	options: {
		globals: {
			jQuery   : true,
			console  : true,
			module   : true,
			document : true  
		}
	},

	config : '<%= gruntfile %>',
	files  : '<%= jsfiles %>'

};