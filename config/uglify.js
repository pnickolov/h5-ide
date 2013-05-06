module.exports = {

	publish: {
		expand: true,
		cwd: '<%= src %>/',
		src: [ '**/*.js' ],
		dest: '<%= release %>/',
		ext: '.js'
	}

};