#*************************************************************************************
#* Filename     : ami_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 17:15:03
#* Description  : qunit test config for ami_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require.config {


    baseUrl         : '/'

    deps            : [ '/test/service/aws/ec2/testsuite.js' ]

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



        'ami_service'   : 'service/aws/ec2/ami/ami_service'

        'ebs_service'   : 'service/aws/ec2/ebs/ebs_service'

        'ec2_service'   : 'service/aws/ec2/ec2/ec2_service'

        'eip_service'   : 'service/aws/ec2/eip/eip_service'

        'instance_service'   : 'service/aws/ec2/instance/instance_service'

        'keypair_service'   : 'service/aws/ec2/keypair/keypair_service'

        'placementgroup_service'   : 'service/aws/ec2/placementgroup/placementgroup_service'

        'securitygroup_service'   : 'service/aws/ec2/securitygroup/securitygroup_service'
}#end
