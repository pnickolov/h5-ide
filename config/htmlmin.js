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
		cwd: '<%= src %>/',
		src: [ '**/*.html', '!test/**/*.html' ],
		dest: '<%= release %>/',
		ext: '.html'
	}

};