module.exports = {

	options: {
		removeComments: true,
		removeCommentsFromCDATA: true,
		removeCDATASectionsFromCDATA: true,
		collapseWhitespace: true,
		collapseBooleanAttributes: true,
		removeAttributeQuotes: true,
		removeRedundantAttributes: true,
		useShortDoctype: true
	},

	publish: {
		expand: true,
		cwd: '<%= release %>/',
		src: [ '**/*.html', '!module/design/property/instance/template.html' ],
		dest: '<%= release %>/',
		ext: '.html'
	}

};