#*************************************************************************************
#* Filename     : aws_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-29 14:09:34
#* Description  : qunit test config for aws_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require.config {


    baseUrl         : '/'

    deps            : [ '/test/service/aws/aws/testsuite.js' ]

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



        'aws_service'   : 'service/aws/aws/aws_service'

        'ami_service'   : 'service/aws/ec2/ami/ami_service'

        'ebs_service'   : 'service/aws/ec2/ebs/ebs_service'

        'ec2_service'   : 'service/aws/ec2/ec2/ec2_service'

        'eip_service'   : 'service/aws/ec2/eip/eip_service'

        'instance_service'   : 'service/aws/ec2/instance/instance_service'

        'keypair_service'   : 'service/aws/ec2/keypair/keypair_service'

        'placementgroup_service'   : 'service/aws/ec2/placementgroup/placementgroup_service'

        'securitygroup_service'   : 'service/aws/ec2/securitygroup/securitygroup_service'

        'acl_service'   : 'service/aws/vpc/acl/acl_service'

        'customergateway_service'   : 'service/aws/vpc/customergateway/customergateway_service'

        'dhcp_service'   : 'service/aws/vpc/dhcp/dhcp_service'

        'eni_service'   : 'service/aws/vpc/eni/eni_service'

        'internetgateway_service'   : 'service/aws/vpc/internetgateway/internetgateway_service'

        'routetable_service'   : 'service/aws/vpc/routetable/routetable_service'

        'subnet_service'   : 'service/aws/vpc/subnet/subnet_service'

        'vpc_service'   : 'service/aws/vpc/vpc/vpc_service'

        'vpngateway_service'   : 'service/aws/vpc/vpngateway/vpngateway_service'

        'vpn_service'   : 'service/aws/vpc/vpn/vpn_service'

        'elb_service'   : 'service/aws/elb/elb/elb_service'

        'iam_service'   : 'service/aws/iam/iam/iam_service'
}#end
