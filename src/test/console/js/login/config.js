/*
//config
require.config({

	baseUrl         : './',

	deps            : [ 'js/login/main' ],

	paths           : {

		'jquery'    : 'vender/jquery/jquery',

		'MC'        : 'lib/MC.core',

		'login'     : 'js/login/login'

	},

	shim            : {

		'jquery'    : {
			exports : '$'
		},

		'MC'        : {
			deps    : [ 'jquery' ],
			exports : 'MC'
		}
	}

});
*/


(function() {
  require.config({
    baseUrl: '/',
    deps: ['/test/console/js/login/main.js'],
    paths: {
      'jquery': 'vender/jquery/jquery',
      'underscore': 'vender/underscore/underscore',
      'backbone': 'vender/backbone/backbone',
      'MC': 'lib/MC.core',
      'constant': 'lib/constant',
      'result_vo': 'service/result_vo',
      'session_vo': 'service/session/session_vo',
      'session_parser': 'service/session/session_parser',
      'session_service': 'service/session/session_service',
      'session_model': 'model/session_model',
      'instance_vo': 'service/aws/ec2/instance/instance_vo',
      'instance_parser': 'service/aws/ec2/instance/instance_parser',
      'instance_service': 'service/aws/ec2/instance/instance_service',
      'login': '/test/console/js/login/login',
      'apiList': '/test/console/apiList'
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
      'MC': {
        deps: ['jquery', 'constant'],
        exports: 'MC'
      },
      'login': {
        deps: ['apiList']
      }
    }
  });

}).call(this);
