(function() {
  require.config({
    baseUrl: '/',
    deps: ['/test/service/aws/ec2/testsuite.js'],
    paths: {
      'jquery': 'vender/jquery/jquery',
      'underscore': 'vender/underscore/underscore',
      'MC': 'lib/MC.core',
      'constant': 'lib/constant',
      'result_vo': 'service/result_vo',
      'session_vo': 'service/session/session_vo',
      'session_parser': 'service/session/session_parser',
      'session_service': 'service/session/session_service',
      'instance_vo': 'service/aws/ec2/instance/instance_vo',
      'instance_parser': 'service/aws/ec2/instance/instance_parser',
      'instance_service': 'service/aws/ec2/instance/instance_service'
    },
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
      }
    }
  });

}).call(this);
