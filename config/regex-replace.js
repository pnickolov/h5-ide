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


    href: {
        src: [ '<%= release %>/component/awscredential/view.coffee', '<%= release %>/js/ide/ide.coffee', '<%= release %>/js/login/template.html', '<%= release %>/module/header/model.coffee', '<%= release %>/module/register/*.*', '<%= release %>/module/reset/*.*' ],
        actions: [
            {
                name: 'href-register',
                search: '"register.html',
                replace: '"/register/',
                flags: 'g'
            },
            {
                name: 'href-reset',
                search: '"reset.html',
                replace: '"/reset/',
                flags: 'g'
            },
            {
                name: 'href-login',
                search: '"login.html',
                replace: '"/login/',
                flags: 'g'
            }
        ]
    }

};