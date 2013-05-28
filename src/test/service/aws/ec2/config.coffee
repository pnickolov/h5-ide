#*************************************************************************************
#* Filename     : ami_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 11:35:42
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
        'session_vo'        : 'service/session/session_vo'
        'session_parser'    : 'service/session/session_parser'
        'session_service'   : 'service/session/session_service'

        #test_util(for qunit test)
        'test_util'         : 'test/service/test_util'



        #ami service
        'ami_vo'        : 'service/aws/ec2\/ami/ami_vo'
        'ami_parser'    : 'service/aws/ec2\/ami/ami_parser'
        'ami_service'   : 'service/aws/ec2\/ami/ami_service'

        #ebs service
        'ebs_vo'        : 'service/aws/ec2\/ebs/ebs_vo'
        'ebs_parser'    : 'service/aws/ec2\/ebs/ebs_parser'
        'ebs_service'   : 'service/aws/ec2\/ebs/ebs_service'

        #ec2 service
        'ec2_vo'        : 'service/aws/ec2/ec2_vo'
        'ec2_parser'    : 'service/aws/ec2/ec2_parser'
        'ec2_service'   : 'service/aws/ec2/ec2_service'

        #eip service
        'eip_vo'        : 'service/aws/ec2\/eip/eip_vo'
        'eip_parser'    : 'service/aws/ec2\/eip/eip_parser'
        'eip_service'   : 'service/aws/ec2\/eip/eip_service'

        #instance service
        'instance_vo'        : 'service/aws/ec2\/instance/instance_vo'
        'instance_parser'    : 'service/aws/ec2\/instance/instance_parser'
        'instance_service'   : 'service/aws/ec2\/instance/instance_service'

        #keypair service
        'keypair_vo'        : 'service/aws/ec2\/keypair/keypair_vo'
        'keypair_parser'    : 'service/aws/ec2\/keypair/keypair_parser'
        'keypair_service'   : 'service/aws/ec2\/keypair/keypair_service'

        #placementgroup service
        'placementgroup_vo'        : 'service/aws/ec2\/placementgroup/placementgroup_vo'
        'placementgroup_parser'    : 'service/aws/ec2\/placementgroup/placementgroup_parser'
        'placementgroup_service'   : 'service/aws/ec2\/placementgroup/placementgroup_service'

        #securitygroup service
        'securitygroup_vo'        : 'service/aws/ec2\/securitygroup/securitygroup_vo'
        'securitygroup_parser'    : 'service/aws/ec2\/securitygroup/securitygroup_parser'
        'securitygroup_service'   : 'service/aws/ec2\/securitygroup/securitygroup_service'
}#end
