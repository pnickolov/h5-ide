
var fs = require( 'fs' );

module.exports = {

	develop: {
		files: {
			'<%= src %>/<%= vender %>/jquery/jquery.js'                : '<%= components %>/jquery/jquery.js',
			'<%= src %>/<%= vender %>/underscore/underscore.js'        : '<%= components %>/underscore/underscore.js',
			'<%= src %>/<%= vender %>/backbone/backbone.js'            : '<%= components %>/backbone/backbone.js',
			'<%= src %>/<%= vender %>/handlebars/handlebars.js'        : '<%= components %>/handlebars/handlebars.js',
			'<%= src %>/<%= vender %>/requirejs/require.js'            : '<%= components %>/requirejs/require.js',
			'<%= src %>/<%= vender %>/requirejs/domReady.js'           : '<%= components %>/requirejs-domready/domReady.js',
			'<%= src %>/<%= vender %>/requirejs/text.js'               : '<%= components %>/requirejs-text/text.js',
			'<%= src %>/<%= vender %>/qunit/qunit.js'                  : '<%= components %>/qunit/qunit.js',
			'<%= src %>/<%= vender %>/qunit/qunit.css'                 : '<%= components %>/qunit/qunit.css',
			'<%= src %>/<%= vender %>/parsleyjs/parsley.js'            : '<%= components %>/parsleyjs/parsley.js',
			'<%= src %>/<%= vender %>/zeroclipboard/ZeroClipboard.js'  : '<%= components %>/zeroclipboard/ZeroClipboard.js',
			'<%= src %>/<%= vender %>/zeroclipboard/ZeroClipboard.swf' : '<%= components %>/zeroclipboard/ZeroClipboard.swf'
		}
	},

	publish: {
		files: [{
			expand : true,
			cwd    : '<%= src %>/',
			src    : [ '**', '!lib/**', '!ui/common/*.js' ] ,
			dest   : '<%= release %>/',
			filter : function( filepath ) {
				if ( filepath.indexOf( 'src\\test' ) == -1 ) {
					return filepath.indexOf( '.coffee' )  == -1 && filepath.indexOf( 'min.js' )  == -1 ? true : false;
				}
				else {
					return false;
				}
			}
		}]
	},

	special_lib: {
		files: [{
			expand : true,
			cwd    : '<%= src %>/lib/',
			src    : [ '*.js' ] ,
			dest   : '<%= release %>/lib/',
			rename: function( dest, src ) {
				var temp = src.split('/')[ src.split('/').length - 1 ].replace( /.js/g, "" );
				temp     = temp.split('.').join('_');
				return dest + temp + '.js';
			}
		}]
	},

	special_lib_rename: {
		files: [{
			expand : true,
			cwd    : '<%= release %>/lib/',
			src    : [ '*.js' ] ,
			dest   : '<%= release %>/lib/',
			rename: function( dest, src ) {
				var new_name = src;
				return dest + new_name.replace( /_/g, '.' );
			}
		}]
	},

	special_lib_del: {
		files: [{
			expand : true,
			cwd    : '<%= release %>/lib/',
			src    : [ '*.js' ] ,
			dest   : '<%= release %>/lib/',
			filter : function ( filepath ) {
				if ( filepath.indexOf('_') != -1 ) {
					fs.unlink( fs.realpathSync( '.' ) + '\\' + filepath );
				}
			}
		}]
	},

	special_ui: {
		files: [{
			expand : true,
			cwd    : '<%= src %>/ui/common/',
			src    : [ '*.js' ] ,
			dest   : '<%= release %>/ui/common/',
			rename: function( dest, src ) {
				var temp = src.split('/')[ src.split('/').length - 1 ].replace( /.js/g, "" );
				temp     = temp.split('.').join('_');
				return dest + temp + '.js';
			}
		}]
	},

	special_ui_rename: {
		files: [{
			expand : true,
			cwd    : '<%= release %>/ui/common/',
			src    : [ '*.js' ] ,
			dest   : '<%= release %>/ui/common/',
			rename: function( dest, src ) {
				var new_name = src;
				return dest + new_name.replace( /_/g, '.' );
			}
		}]
	},

	special_ui_del: {
		files: [{
			expand : true,
			cwd    : '<%= release %>/ui/common/',
			src    : [ '*.js' ] ,
			dest   : '<%= release %>/ui/common/',
			filter : function ( filepath ) {
				if ( filepath.indexOf('_') != -1 ) {
					fs.unlink( fs.realpathSync( '.' ) + '\\' + filepath );
				}
			}
		}]
	}

};