module.exports = {

    compile_fast: {

        files: [{
            expand : true,
            cwd    : '<%= src %>/',
            src    : [ '**/*.coffee', '!service/**/**/*.coffee', '!test/**/**/*.coffee' ],
            dest   : '<%= src %>/',
            ext    : '.js'
        }]

    },

    compile_all: {

        files: [{
            expand : true,
            cwd    : '<%= src %>/',
            src    : [ '**/*.coffee' ],
            dest   : '<%= src %>/',
            ext    : '.js'
        }]

    },

    changed: {

        files: [{
            expand : true,
            src    : '<%= grunt.regarde.changed %>',
            ext    : '.js'
        }]

    }

};