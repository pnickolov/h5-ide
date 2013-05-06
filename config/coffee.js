module.exports = {

	compile: {

		files: [{
			expand : true,
			cwd    : '<%= src %>/',
			src    : '**/*.coffee',
			dest   : '<%= src %>/',
			ext    : '.js'
		}]

	}

};