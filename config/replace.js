module.exports = {

    /*add by xjimmy*/

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
    }

};