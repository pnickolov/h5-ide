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

        'WS'        :
            deps    : ['Meteor','underscore']
            exports : 'WS'

}#end
