#*************************************************************************************
#* Filename     : guest_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 17:15:00
#* Description  : qunit test config for guest_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require.config {


    baseUrl         : '/'

    deps            : [ '/test/websocket/request/test.js' ]

    paths           :

        #vender
        'jquery'    : 'vender/jquery/jquery'
        'underscore': 'vender/underscore/underscore'
        'Meteor'    : 'vender/meteor/meteor'

        #core lib
        'MC'        : 'lib/MC.core'

        #common lib
        'constant'  : 'lib/constant'

        'WS'		: 'lib/websocket'

        #session_service
        'session_vo'        : 'service/session/session_vo'
        'session_parser'    : 'service/session/session_parser'
        'session_service'   : 'service/session/session_service'

        #result_vo
        'result_vo'          : 'service/result_vo'
              
    shim            :

        'jquery'    :
            exports : '$'

        'MC'        :
            deps    : [ 'jquery' ]
            exports : 'MC'

        'underscore':
            exports : '_'

        'Meteor'    :
            deps    : ['underscore']
            exports : 'Meteor'

        'WS'        :
            deps    : ['Meteor','underscore']
            exports : 'WS'

}#end
