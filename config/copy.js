
module.exports = {

	develop: {
		files: {
			'<%= src %>/<%= vender %>/jquery/jquery.js'         : '<%= components %>/jquery/jquery.js',
			'<%= src %>/<%= vender %>/underscore/underscore.js' : '<%= components %>/underscore/underscore.js',
			'<%= src %>/<%= vender %>/backbone/backbone.js'     : '<%= components %>/backbone/backbone.js',
			'<%= src %>/<%= vender %>/handlebars/handlebars.js' : '<%= components %>/handlebars/handlebars.js',
			'<%= src %>/<%= vender %>/requirejs/require.js'     : '<%= components %>/requirejs/require.js',
			'<%= src %>/<%= vender %>/requirejs/domReady.js'    : '<%= components %>/requirejs-domready/domReady.js',
			'<%= src %>/<%= vender %>/requirejs/text.js'        : '<%= components %>/requirejs-text/text.js',
			'<%= src %>/<%= vender %>/qunit/qunit.js'           : '<%= components %>/qunit/qunit.js',
			'<%= src %>/<%= vender %>/qunit/qunit.css'          : '<%= components %>/qunit/qunit.css',
			'<%= src %>/<%= vender %>/parsleyjs/parsley.js'     : '<%= components %>/parsleyjs/parsley.js'
		}
	},

	publish: {
		files: [{
			expand : true,
			cwd    : '<%= src %>/',
			src    : [ '**' ] ,
			filter : function( filepath ) {
				if ( filepath.indexOf( 'src\\test' ) == -1 ) {
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