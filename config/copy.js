
module.exports = {

	develop: {
		files: {
			'<%= src %>/<%= libs %>/jquery/jquery.js'         : '<%= components %>/jquery/jquery.js',
			'<%= src %>/<%= libs %>/underscore/underscore.js' : '<%= components %>/underscore/underscore.js',
			'<%= src %>/<%= libs %>/backbone/backbone.js'     : '<%= components %>/backbone/backbone.js',
			'<%= src %>/<%= libs %>/handlebars/handlebars.js' : '<%= components %>/handlebars.js/handlebars.js',
			'<%= src %>/<%= libs %>/requirejs/require.js'     : '<%= components %>/requirejs/require.js',
			'<%= src %>/<%= libs %>/requirejs/domready.js'    : '<%= components %>/requirejs-domready/domready.js',
			'<%= src %>/<%= libs %>/requirejs/text.js'        : '<%= components %>/requirejs-text/text.js'
		}
	},

	publish: {
		files: [{
			expand : true,
			cwd    : '<%= src %>/',
			src    : '**',
			filter : function( filepath ) {
				return filepath.indexOf( '.coffee' )  == -1 && filepath.indexOf( 'min.js' )  == -1 ? true : false;
			},
			dest   : '<%= release %>/'
		}]
	}

};