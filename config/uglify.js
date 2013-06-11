module.exports = {

	publish: {
		expand: true,
		cwd: '<%= src %>/',
		src: [ '**/*.js', '!lib/*.js', '!ui/common/*.js', '!test/**/*.js' ],
		dest: '<%= release %>/',
		ext: '.js'
	},

	special: {
		files: {
			'<%= release %>/lib/MC.core.js'            : [ '<%= src %>/lib/MC.core.js' ],
			'<%= release %>/lib/MC.canvas.js'          : [ '<%= src %>/lib/MC.canvas.js' ],
			'<%= release %>/lib/MC.topo.js'            : [ '<%= src %>/lib/MC.topo.js' ],
			'<%= release %>/ui/common/UI.scrollbar.js' : [ '<%= src %>/ui/common/UI.scrollbar.js' ],
			'<%= release %>/ui/common/UI.tooltip.js'   : [ '<%= src %>/ui/common/UI.tooltip.js' ]
		}
	},

	meteor: {
		files: {
			'./meteor/meteor.min.js'                   : [ './meteor/meteor.js' ]
		}
	}

};