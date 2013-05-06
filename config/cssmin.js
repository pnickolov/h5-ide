module.exports = {

	publish: {
		expand: true,
		cwd: '<%= src %>/',
		src: [ '**/*.css' ],
		dest: '<%= release %>/',
		ext: '.css'
	}

};