
require.config {


    baseUrl         : '/'

    deps            : [ '/test/service/aws/ec2/testsuite.js' ]

    paths           :

        #vender
        'jquery'    : 'vender/jquery/jquery'
        'underscore': 'vender/underscore/underscore'

        #core lib
        'MC'        : 'lib/MC.core'

        #common lib
        'constant'  : 'lib/constant'

        #result_vo
        'result_vo'          : 'service/result_vo'

        #service
        'session_vo'        : 'service/handler/session/session_vo'
        'session_parser'    : 'service/handler/session/session_parser'
        'session_service'   : 'service/handler/session/session_service'

        #service
        'instance_vo'        : 'service/aws/ec2/instance/instance_vo'
        'instance_parser'    : 'service/aws/ec2/instance/instance_parser'
        'instance_service'   : 'service/aws/ec2/instance/instance_service'


    shim            :

        'jquery'    :
            exports : '$'

        'MC'        :
            deps    : [ 'jquery','constant' ]
            exports : 'MC'

        'underscore':
            exports : '_'
    }
