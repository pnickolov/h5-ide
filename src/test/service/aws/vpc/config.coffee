#*************************************************************************************
#* Filename     : acl_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-28 15:59:20
#* Description  : qunit test config for acl_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

require.config {


    baseUrl         : '/'

    deps            : [ '/test/service/aws/vpc/testsuite.js' ]

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
}#end
