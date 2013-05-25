#*************************************************************************************
#* Filename     : cloudwatch_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:05
#* Description  : qunit test config for cloudwatch_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require.config {


    baseUrl         : '/'

    deps            : [ '/test/service/aws/cloudwatch/testsuite.js' ]

    shim            :

        'jquery'    :
            exports : '$'

        'MC'        :
            deps    : [ 'jquery','constant' ]
            exports : 'MC'

        'underscore':
            exports : '_'

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

        #session_service
        'session_vo'        : 'service/session/session_vo'
        'session_parser'    : 'service/session/session_parser'
        'session_service'   : 'service/session/session_service'

        #test_util(for qunit test)
        'test_util'         : 'test/service/test_util'



        #cloudwatch service
        'cloudwatch_vo'        : 'service/aws/cloudwatch/cloudwatch/cloudwatch_vo'
        'cloudwatch_parser'    : 'service/aws/cloudwatch/cloudwatch/cloudwatch_parser'
        'cloudwatch_service'   : 'service/aws/cloudwatch/cloudwatch/cloudwatch_service'
}#end
