({
    appDir: "./",
    baseUrl: './',
    dir: "../release2",
    optimize : 'none',
    modules: [{
            name: "js/login/main"
    }],
    paths: {
      'jquery': 'vender/jquery/jquery',
      'underscore': 'vender/underscore/underscore',
      'backbone': 'vender/backbone/backbone',
      'handlebars': 'vender/handlebars/handlebars',
      'domReady': 'vender/requirejs/domReady',
      'i18n': 'vender/requirejs/i18n',
      'text': 'vender/requirejs/text',
      'MC': 'lib/MC.core',
      'constant': 'lib/constant',
      'result_vo': 'service/result_vo',
      'session_service': 'service/session/session_service',
      'session_model': 'model/session_model'
    },
    shim: {
      'jquery': {
        exports: '$'
      },
      'underscore': {
        exports: '_'
      },
      'backbone': {
        deps: ['underscore', 'jquery'],
        exports: 'Backbone'
      },
      'handlebars': {
        exports: 'Handlebars'
      },
      'MC': {
        deps: ['jquery', 'constant'],
        exports: 'MC'
      }
    }
})