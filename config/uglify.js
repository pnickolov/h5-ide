module.exports = {

	publish: {
		expand: true,
		cwd: '<%= release %>/',
		src: [ '**/*.js' ],
		dest: '<%= release %>/',
		ext: '.js'
	}

};