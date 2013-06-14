
require.config {

    baseUrl         : '/'

    deps            : [ '/test/console/js/main.js' ]

    paths           :

        #vender
        'jquery'    : 'vender/jquery/jquery'
        'underscore'   : 'vender/underscore/underscore'
        'backbone'     : 'vender/backbone/backbone'

        #core lib
        'MC'        : 'lib/MC.core'

        #common lib
        'constant'  : 'lib/constant'

        #result_vo
        'result_vo'         : 'service/result_vo'

        #service
        'session_vo'        : 'service/session/session_vo'
        'session_parser'    : 'service/session/session_parser'
        'session_service'   : 'service/session/session_service'

        'session_model'     : 'model/session_model'


        #log service
        'log_vo'        : 'service/log/log_vo'
        'log_parser'    : 'service/log/log_parser'
        'log_service'   : 'service/log/log_service'


        #favorite service
        'favorite_vo'        : 'service/favorite/favorite_vo'
        'favorite_parser'    : 'service/favorite/favorite_parser'
        'favorite_service'   : 'service/favorite/favorite_service'


        #guest service
        'guest_vo'        : 'service/guest/guest_vo'
        'guest_parser'    : 'service/guest/guest_parser'
        'guest_service'   : 'service/guest/guest_service'



        #public service
        'public_vo'        : 'service/public/public_vo'
        'public_parser'    : 'service/public/public_parser'
        'public_service'   : 'service/public/public_service'


        #request service
        'request_vo'        : 'service/request/request_vo'
        'request_parser'    : 'service/request/request_parser'
        'request_service'   : 'service/request/request_service'

        #stack service
        'stack_vo'        : 'service/stack/stack_vo'
        'stack_parser'    : 'service/stack/stack_parser'
        'stack_service'   : 'service/stack/stack_service'

        #app service
        'app_vo'        : 'service/app/app_vo'
        'app_parser'    : 'service/app/app_parser'
        'app_service'   : 'service/app/app_service'



        #aws service
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



        ########## model ##########

        #####forge#####
        'log_model'         : 'model/log_model'
        'public_model'      : 'model/public_model'
        'request_model'     : 'model/request_model'
        'app_model'         : 'model/app_model'
        'favorite_model'    : 'model/favorite_model'
        'guest_model'       : 'model/guest_model'
        'stack_model'       : 'model/stack_model'


        'aws_model'             : 'model/aws/aws_model'

        #####ec2#####
        'ami_model'             : 'model/aws/ec2/ami_model'
        'ebs_model'             : 'model/aws/ec2/ebs_model'
        'ec2_model'             : 'model/aws/ec2/ec2_model'
        'eip_model'             : 'model/aws/ec2/eip_model'
        'instance_model'        : 'model/aws/ec2/instance_model'
        'keypair_model'         : 'model/aws/ec2/keypair_model'
        'placementgroup_model'  : 'model/aws/ec2/placementgroup_model'
        'securitygroup_model'   : 'model/aws/ec2/securitygroup_model'

        #####elb#####
        'elb_model'             : 'model/aws/elb/elb_model'

        #####iam#####
        'iam_model'             : 'model/aws/iam/iam_model'

        #####vpc#####
        'acl_model'             : 'model/aws/vpc/acl_model'
        'customergateway_model' : 'model/aws/vpc/customergateway_model'
        'dhcp_model'            : 'model/aws/vpc/dhcp_model'
        'eni_model'             : 'model/aws/vpc/eni_model'
        'internetgateway_model' : 'model/aws/vpc/internetgateway_model'
        'routetable_model'      : 'model/aws/vpc/routetable_model'
        'subnet_model'          : 'model/aws/vpc/subnet_model'
        'vpc_model'             : 'model/aws/vpc/vpc_model'
        'vpngateway_model'      : 'model/aws/vpc/vpngateway_model'
        'vpn_model'             : 'model/aws/vpc/vpn_model'


        #####autoscaling#####
        #'autoscaling_model'    : 'model/aws/autoscaling/autoscaling_model'

        #####cloudwatch#####
        #'cloudwatch_model'    : 'model/aws/cloudwatch/cloudwatch_model'

        #####opsworks#####
        #'opsworks_model'    : 'model/aws/opsworks/opsworks_model'

        #####rds#####
        # 'rds_instance_model'    : 'model/aws/rds/instance_model'
        # 'optiongroup_model'    : 'model/aws/rds/optiongroup_model'
        # 'parametergroup_model'    : 'model/aws/rds/parametergroup_model'
        # 'rds_model'    : 'model/aws/rds/rds_model'
        # 'reservedinstance_model'    : 'model/aws/rds/reservedinstance_model'
        # 'rds_securitygroup_model'    : 'model/aws/rds/securitygroup_model'
        # 'snapshot_model'    : 'model/aws/rds/snapshot_model'
        # 'subnetgroup_model'    : 'model/aws/rds/subnetgroup_model'

        #####sdb#####
        #'sdb_model'    : 'model/aws/sdb/sdb_model'



        #testsuite
        'testsuite'             : '/test/console/js/testsuite'

        'apiList'           : '/test/console/apiList'

    shim            :

        'jquery'    :
            exports : '$'

        'underscore'   :
            exports    : '_'

        'backbone'     :
            deps       : [ 'underscore', 'jquery' ]
            exports    : 'Backbone'

        'MC'        :
            deps    : [ 'jquery','constant' ]
            exports : 'MC'

        'testsuite'     :
            deps      : [ 'apiList' ]
}