#*************************************************************************************
#* Filename     : instance_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-29 14:09:45
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
        'session_vo'        : 'service/session/session_vo'
        'session_parser'    : 'service/session/session_parser'
        'session_service'   : 'service/session/session_service'

        #test_util(for qunit test)
        'test_util'         : 'test/service/test_util'



        #instance service
        'instance_vo'        : 'service/aws/rds/instance/instance_vo'
        'instance_parser'    : 'service/aws/rds/instance/instance_parser'
        'instance_service'   : 'service/aws/rds/instance/instance_service'

        #optiongroup service
        'optiongroup_vo'        : 'service/aws/rds/optiongroup/optiongroup_vo'
        'optiongroup_parser'    : 'service/aws/rds/optiongroup/optiongroup_parser'
        'optiongroup_service'   : 'service/aws/rds/optiongroup/optiongroup_service'

        #parametergroup service
        'parametergroup_vo'        : 'service/aws/rds/parametergroup/parametergroup_vo'
        'parametergroup_parser'    : 'service/aws/rds/parametergroup/parametergroup_parser'
        'parametergroup_service'   : 'service/aws/rds/parametergroup/parametergroup_service'

        #rds service
        'rds_vo'        : 'service/aws/rds/rds/rds_vo'
        'rds_parser'    : 'service/aws/rds/rds/rds_parser'
        'rds_service'   : 'service/aws/rds/rds/rds_service'

        #reservedinstance service
        'reservedinstance_vo'        : 'service/aws/rds/reservedinstance/reservedinstance_vo'
        'reservedinstance_parser'    : 'service/aws/rds/reservedinstance/reservedinstance_parser'
        'reservedinstance_service'   : 'service/aws/rds/reservedinstance/reservedinstance_service'

        #securitygroup service
        'securitygroup_vo'        : 'service/aws/rds/securitygroup/securitygroup_vo'
        'securitygroup_parser'    : 'service/aws/rds/securitygroup/securitygroup_parser'
        'securitygroup_service'   : 'service/aws/rds/securitygroup/securitygroup_service'

        #snapshot service
        'snapshot_vo'        : 'service/aws/rds/snapshot/snapshot_vo'
        'snapshot_parser'    : 'service/aws/rds/snapshot/snapshot_parser'
        'snapshot_service'   : 'service/aws/rds/snapshot/snapshot_service'

        #subnetgroup service
        'subnetgroup_vo'        : 'service/aws/rds/subnetgroup/subnetgroup_vo'
        'subnetgroup_parser'    : 'service/aws/rds/subnetgroup/subnetgroup_parser'
        'subnetgroup_service'   : 'service/aws/rds/subnetgroup/subnetgroup_service'
}#end
