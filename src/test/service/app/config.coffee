#*************************************************************************************
#* Filename     : app_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-29 14:09:29
#* Description  : qunit test config for app_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require.config {


    baseUrl         : '/'

    deps            : [ '/test/service/app/testsuite.js' ]

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



        #app service
        'app_vo'        : 'service/app/app_vo'
        'app_parser'    : 'service/app/app_parser'
        'app_service'   : 'service/app/app_service'

        'aws_vo'        : 'service/aws/aws/aws_vo'
        'aws_parser'    : 'service/aws/aws/aws_parser'
        'aws_service'   : 'service/aws/aws/aws_service'

        #ami service
        'ami_vo'        : 'service/aws/ec2/ami/ami_vo'
        'ami_parser'    : 'service/aws/ec2/ami/ami_parser'
        'ami_service'   : 'service/aws/ec2/ami/ami_service'

        #ebs service
        'ebs_vo'        : 'service/aws/ec2/ebs/ebs_vo'
        'ebs_parser'    : 'service/aws/ec2/ebs/ebs_parser'
        'ebs_service'   : 'service/aws/ec2/ebs/ebs_service'

        #ec2 service
        'ec2_vo'        : 'service/aws/ec2/ec2/ec2_vo'
        'ec2_parser'    : 'service/aws/ec2/ec2/ec2_parser'
        'ec2_service'   : 'service/aws/ec2/ec2/ec2_service'

        #eip service
        'eip_vo'        : 'service/aws/ec2/eip/eip_vo'
        'eip_parser'    : 'service/aws/ec2/eip/eip_parser'
        'eip_service'   : 'service/aws/ec2/eip/eip_service'

        #instance service
        'instance_vo'        : 'service/aws/ec2/instance/instance_vo'
        'instance_parser'    : 'service/aws/ec2/instance/instance_parser'
        'instance_service'   : 'service/aws/ec2/instance/instance_service'

        #keypair service
        'keypair_vo'        : 'service/aws/ec2/keypair/keypair_vo'
        'keypair_parser'    : 'service/aws/ec2/keypair/keypair_parser'
        'keypair_service'   : 'service/aws/ec2/keypair/keypair_service'

        #placementgroup service
        'placementgroup_vo'        : 'service/aws/ec2/placementgroup/placementgroup_vo'
        'placementgroup_parser'    : 'service/aws/ec2/placementgroup/placementgroup_parser'
        'placementgroup_service'   : 'service/aws/ec2/placementgroup/placementgroup_service'

        #securitygroup service
        'securitygroup_vo'        : 'service/aws/ec2/securitygroup/securitygroup_vo'
        'securitygroup_parser'    : 'service/aws/ec2/securitygroup/securitygroup_parser'
        'securitygroup_service'   : 'service/aws/ec2/securitygroup/securitygroup_service'

        #acl service
        'acl_vo'        : 'service/aws/vpc/acl/acl_vo'
        'acl_parser'    : 'service/aws/vpc/acl/acl_parser'
        'acl_service'   : 'service/aws/vpc/acl/acl_service'

        #customergateway service
        'customergateway_vo'        : 'service/aws/vpc/customergateway/customergateway_vo'
        'customergateway_parser'    : 'service/aws/vpc/customergateway/customergateway_parser'
        'customergateway_service'   : 'service/aws/vpc/customergateway/customergateway_service'

        #dhcp service
        'dhcp_vo'        : 'service/aws/vpc/dhcp/dhcp_vo'
        'dhcp_parser'    : 'service/aws/vpc/dhcp/dhcp_parser'
        'dhcp_service'   : 'service/aws/vpc/dhcp/dhcp_service'

        #eni service
        'eni_vo'        : 'service/aws/vpc/eni/eni_vo'
        'eni_parser'    : 'service/aws/vpc/eni/eni_parser'
        'eni_service'   : 'service/aws/vpc/eni/eni_service'

        #internetgateway service
        'internetgateway_vo'        : 'service/aws/vpc/internetgateway/internetgateway_vo'
        'internetgateway_parser'    : 'service/aws/vpc/internetgateway/internetgateway_parser'
        'internetgateway_service'   : 'service/aws/vpc/internetgateway/internetgateway_service'

        #routetable service
        'routetable_vo'        : 'service/aws/vpc/routetable/routetable_vo'
        'routetable_parser'    : 'service/aws/vpc/routetable/routetable_parser'
        'routetable_service'   : 'service/aws/vpc/routetable/routetable_service'

        #subnet service
        'subnet_vo'        : 'service/aws/vpc/subnet/subnet_vo'
        'subnet_parser'    : 'service/aws/vpc/subnet/subnet_parser'
        'subnet_service'   : 'service/aws/vpc/subnet/subnet_service'

        #vpc service
        'vpc_vo'        : 'service/aws/vpc/vpc/vpc_vo'
        'vpc_parser'    : 'service/aws/vpc/vpc/vpc_parser'
        'vpc_service'   : 'service/aws/vpc/vpc/vpc_service'

        #vpngateway service
        'vpngateway_vo'        : 'service/aws/vpc/vpngateway/vpngateway_vo'
        'vpngateway_parser'    : 'service/aws/vpc/vpngateway/vpngateway_parser'
        'vpngateway_service'   : 'service/aws/vpc/vpngateway/vpngateway_service'

        #vpn service
        'vpn_vo'        : 'service/aws/vpc/vpn/vpn_vo'
        'vpn_parser'    : 'service/aws/vpc/vpn/vpn_parser'
        'vpn_service'   : 'service/aws/vpc/vpn/vpn_service'

        #elb service
        'elb_vo'        : 'service/aws/elb/elb/elb_vo'
        'elb_parser'    : 'service/aws/elb/elb/elb_parser'
        'elb_service'   : 'service/aws/elb/elb/elb_service'

        #iam service
        'iam_vo'        : 'service/aws/iam/iam/iam_vo'
        'iam_parser'    : 'service/aws/iam/iam/iam_parser'
        'iam_service'   : 'service/aws/iam/iam/iam_service'
}#end
