(function() {
  require.config({
    baseUrl: '/',
    deps: ['/test/websocket/request/test.js'],
    shim: {
      'jquery': {
        exports: '$'
      },
      'MC': {
        deps: ['jquery', 'constant'],
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
        deps: ['Meteor'],
        exports: 'WS'
      }
    },
    paths: {
      'jquery': 'vender/jquery/jquery',
      'underscore': 'vender/underscore/underscore',
      'Meteor': 'vender/meteor/meteor',
      'MC': 'lib/MC.core',
      'constant': 'lib/constant',
      'WS': 'lib/websocket'
    }
  });

}).call(this);
