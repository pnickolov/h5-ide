module.exports = {

    string: {
        src: [ '<%= src %>/js/login/config.js', '<%= src %>/js/ide/config.js', '<%= src %>/js/register/config.js', '<%= src %>/js/reset/config.js' ],
        actions: [
            {
                name: 'language',
                search: 'locale: language',
                replace: 'locale: "en-us"',
                flags: 'g'
            }
        ]
    },

    language: {
        src: [ '<%= src %>/js/login/config.js', '<%= src %>/js/ide/config.js', '<%= src %>/js/register/config.js', '<%= src %>/js/reset/config.js' ],
        actions: [
            {
                name: 'language',
                search: 'locale: "en-us"',
                replace: 'locale: language',
                flags: 'g'
            }
        ]
    },

    intercome: {
        src: [ '<%= release %>/ide.html' ],
        actions: [
            {
                name: 'prod',
                search: '<!-- env:prod --#>',
                replace: '<!-- env:prod -->',
                flags: 'g'
            }
        ]
    },

};