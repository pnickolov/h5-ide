(function() {
  require.config({
    baseUrl: '/',
    deps: ['/test/websocket/request/test.js'],
    paths: {
      'jquery': 'vender/jquery/jquery',
      'underscore': 'vender/underscore/underscore',
      'Meteor': 'vender/meteor/meteor',
      'MC': 'lib/MC.core',
      'constant': 'lib/constant',
      'WS': 'lib/websocket',
      'session_vo': 'service/session/session_vo',
      'session_parser': 'service/session/session_parser',
      'session_service': 'service/session/session_service',
      'result_vo': 'service/result_vo'
    },
    shim: {
      'jquery': {
        exports: '$'
      },
      'MC': {
        deps: ['jquery'],
        exports: 'MC'
      },
      'underscore': {
        exports: '_'
      },
      'Meteor': {
        deps: ['underscore'],
        exports: 'Meteor'
      },
      'WS': {
        deps: ['Meteor', 'underscore'],
        exports: 'WS'
      }
    }
  });

}).call(this);
