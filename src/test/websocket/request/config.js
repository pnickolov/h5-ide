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
      'WS': 'lib/websocket'
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
        deps: ['underscore']
      },
      'WS': {
        deps: ['Meteor', 'underscore'],
        exports: 'WS'
      }
    }
  });

}).call(this);
