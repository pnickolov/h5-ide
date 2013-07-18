module.exports = {

	publish: {
		expand: true,
		cwd: '<%= release %>/',
		src: [ '**/*.css' ],
		dest: '<%= release %>/',
		ext: '.css'
	}

};