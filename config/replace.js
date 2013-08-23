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
                "analytics_script}}" : '<%= grunt.file.read( "util/incloud/analytics/analytics_script.js" ) %>'
            },
            prefix: '{{'
        },
        files: [
            { src: [ '<%= src %>/lib/analytics.js' ], dest: '<%= release %>/lib/analytics.js' }
        ]
    }
};