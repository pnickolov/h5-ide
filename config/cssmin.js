module.exports = {

	publish: {
		expand: true,
		cwd: '<%= src %>/',
		src: [ '**/*.css', '!test/**/*.css' ],
		dest: '<%= release %>/',
		ext: '.css'
	}

};