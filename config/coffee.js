module.exports = {

    compile: {

        files: [{
            expand : true,
            cwd    : '<%= src %>/',
            src    : [ '**/*.coffee', '!=service/**/**/*.coffee', '!test/**/**/*.coffee' ],
            dest   : '<%= src %>/',
            ext    : '.js'
        }]

    }

};