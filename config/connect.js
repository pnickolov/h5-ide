
var lrSnippet       = require( 'grunt-contrib-livereload/lib/utils' ).livereloadSnippet;
var proxyMiddleware = require( '../config/proxy.js' ).proxyMiddleware;

module.exports = {

	options: {
		port: 3000,
		hostname: '0.0.0.0' /*add by xjimmy*/
	},

	unittest: {
		options: {
			base       : '<%= src %>',
			middleware : function( connect, options ) {

				return [
					lrSnippet,
					connect.bodyParser(),
					proxyMiddleware,
					connect.static( options.base )
				];

			}
		}
	},

	develop: {
		options: {
			base       : '<%= src %>',
			middleware : function( connect, options ) {

				return [
					lrSnippet,
					connect.bodyParser(),
					proxyMiddleware,
					connect.static( options.base )
				];

			}
		}
	},

	release: {
		options: {
			base: '<%= release %>',
			keepalive: true,
			middleware: function( connect, options ) {
				return [
					connect.bodyParser(),
					proxyMiddleware,
					connect.static( options.base )
				];
			}
		}
	},

	publish: {
		options: {
			base: '<%= publish %>',
			keepalive: true,
			middleware: function( connect, options ) {
				return [
					connect.bodyParser(),
					proxyMiddleware,
					connect.static( options.base )
				];
			}
		}
	}

};