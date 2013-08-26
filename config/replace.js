module.exports = {

    dist: {
        options: {
            variables: {
                Created     : 'build <%= grunt.template.today("yy.mmdd.HHMM") %>',
                Dev         : 'Release',
                Version     : 'v<%= pkg.version %>'
            },
            prefix: '@@'
        },
        files: [
            {src: ['<%= release %>/login.html'], dest: '<%= release %>/login.html'}
        ]
    },

    dev_env_switch : {
        options: {
            variables: {
                "env}}" : "dev"
            },
            prefix: '{{'
        },
        files: [
            { src: [ 'util/include/dev_prod_switch/env_tmpl' ], dest: 'util/include/dev_prod_switch/env' }
        ]
    },

    prod_env_switch : {
        options: {
            variables: {
                "env}}" : "prod"
            },
            prefix: '{{'
        },
        files: [
            { src: [ 'util/include/dev_prod_switch/env_tmpl' ], dest: 'util/include/dev_prod_switch/env' }
        ]
    },

    json_view: {
        options: {
            variables: {
                "json_view}}" : "*/require([ 'test/json_view/json_view' ], function() {} );/*"
            },
            prefix: '{{'
        },
        files: [
            { src: [ '<%= src %>/js/ide/main.js' ], dest: '<%= src %>/js/ide/main.js' }
        ]
    },

    analytics: {
        options: {
            variables: {
                "analytics_script}}" : '<%= grunt.file.read( "util/include/analytics/analytics_script.js" ) %>'
            },
            prefix: '{{'
        },
        files: [
            { src: [ '<%= src %>/lib/analytics.js' ], dest: '<%= release %>/lib/analytics.js' }
        ]
    }
};