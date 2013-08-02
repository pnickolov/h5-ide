module.exports = {

    compile_fast: {
        options: {
            sourceMap: true
        },
        files: [{
            expand : true,
            cwd    : '<%= src %>/',
            src    : [ '**/*.coffee', '!service/**/**/*.coffee', '!test/**/**/*.coffee' ],
            dest   : '<%= src %>/',
            ext    : '.js'
        }]

    },

    compile_all: {
        options: {
            sourceMap: true
        },
        files: [{
            expand : true,
            cwd    : '<%= src %>/',
            src    : [ '**/*.coffee' ],
            dest   : '<%= src %>/',
            ext    : '.js'
        }]

    },

    changed: {
        options: {
            sourceMap: true
        },
        files: [{
            expand : true,
            src    : '<%= grunt.regarde.changed %>',
            ext    : '.js'
        }]

    }

};