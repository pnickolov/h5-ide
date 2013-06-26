
module.exports = {

	develop: {
		files: {
			'<%= src %>/<%= libs %>/jquery/jquery.js'         : '<%= components %>/jquery/jquery.js',
			'<%= src %>/<%= libs %>/underscore/underscore.js' : '<%= components %>/underscore/underscore.js',
			'<%= src %>/<%= libs %>/backbone/backbone.js'     : '<%= components %>/backbone/backbone.js',
			'<%= src %>/<%= libs %>/handlebars/handlebars.js' : '<%= components %>/handlebars/handlebars.js',
			'<%= src %>/<%= libs %>/requirejs/require.js'     : '<%= components %>/requirejs/require.js',
			'<%= src %>/<%= libs %>/requirejs/domReady.js'    : '<%= components %>/requirejs-domready/domReady.js',
			'<%= src %>/<%= libs %>/requirejs/text.js'        : '<%= components %>/requirejs-text/text.js',
			'<%= src %>/<%= libs %>/qunit/qunit.js'           : '<%= components %>/qunit/qunit.js',
			'<%= src %>/<%= libs %>/qunit/qunit.css'          : '<%= components %>/qunit/qunit.css'
		}
	},

	publish: {
		files: [{
			expand : true,
			cwd    : '<%= src %>/',
			src    : [ '**' ] ,
			filter : function( filepath ) {
				if ( filepath.indexOf( 'test' ) == -1 ) {
					return filepath.indexOf( '.coffee' )  == -1 && filepath.indexOf( 'min.js' )  == -1 ? true : false;
				}
				else {
					return false;
				}
			},
			dest   : '<%= release %>/'
		}]
	}

};