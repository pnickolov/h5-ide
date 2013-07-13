#*************************************************************************************
#* Filename     : instance_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 17:15:13
#* Description  : qunit test config for instance_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require.config {


    baseUrl         : '/'

    deps            : [ '/test/service/aws/rds/testsuite.js' ]

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
        'session_service'   : 'service/session/session_service'

        #test_util(for qunit test)
        'test_util'         : 'test/service/test_util'



    
        'instance_service'   : 'service/aws/rds/instance/instance_service'

        'optiongroup_service'   : 'service/aws/rds/optiongroup/optiongroup_service'

        'parametergroup_service'   : 'service/aws/rds/parametergroup/parametergroup_service'

        'rds_service'   : 'service/aws/rds/rds/rds_service'

        'reservedinstance_service'   : 'service/aws/rds/reservedinstance/reservedinstance_service'

        'securitygroup_service'   : 'service/aws/rds/securitygroup/securitygroup_service'

        'snapshot_service'   : 'service/aws/rds/snapshot/snapshot_service'

        'subnetgroup_service'   : 'service/aws/rds/subnetgroup/subnetgroup_service'
}#end
