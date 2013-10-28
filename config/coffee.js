module.exports = {

    compile_fast: {
        options: {
            sourceMap: false
        },
        files: [{
            expand : true,
            cwd    : '<%= src %>/',
            src    : [ '**/*.coffee', '!service/**/**/*.coffee', '!test/**/**/*.coffee', '!nls/lang-source.coffee' ],
            dest   : '<%= src %>/',
            ext    : '.js'
        }]

    },

    compile_normal: {
        options: {
            sourceMap: true
        },
        files: [{
            expand : true,
            cwd    : '<%= src %>/',
            src    : [ '**/*.coffee', '!service/**/**/*.coffee', '!test/**/**/*.coffee', '!nls/lang-source.coffee' ],
            dest   : '<%= src %>/',
            ext    : '.js'
        }]

    },

    compile_all: {
        options: {
            sourceMap: false
        },
        files: [{
            expand : true,
            cwd    : '<%= src %>/',
            src    : [ '**/*.coffee', '!nls/lang-source.coffee' ],
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