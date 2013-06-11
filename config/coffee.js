module.exports = {

	compile: {

		files: [{
			expand : true,
			cwd    : '<%= src %>/',
			src    : [ '**/*.coffee', '!service/**/**/*.coffee' ],
			dest   : '<%= src %>/',
			ext    : '.js'
		}]

	}

};