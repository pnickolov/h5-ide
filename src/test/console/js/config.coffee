
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
        'session_service'   : 'service/session/session_service'

        'session_model'     : 'model/session_model'


        #log service
        'log_service'   : 'service/log/log_service'


        #favorite service
        'favorite_service'   : 'service/favorite/favorite_service'


        #guest service
        'guest_service'   : 'service/guest/guest_service'


        #public service
        'public_service'   : 'service/public/public_service'


        #request service
        'request_service'   : 'service/request/request_service'

        #stack service
        'stack_service'   : 'service/stack/stack_service'

        #app service
        'app_service'   : 'service/app/app_service'



        #aws service
        'aws_service'   : 'service/aws/aws/aws_service'

        #ami service
        'ami_service'   : 'service/aws/ec2/ami/ami_service'

        #ebs service
        'ebs_service'   : 'service/aws/ec2/ebs/ebs_service'

        #ec2 service
        'ec2_service'   : 'service/aws/ec2/ec2/ec2_service'

        #eip service
        'eip_service'   : 'service/aws/ec2/eip/eip_service'

        #instance service
        'instance_service'   : 'service/aws/ec2/instance/instance_service'

        #keypair service
        'keypair_service'   : 'service/aws/ec2/keypair/keypair_service'

        #placementgroup service
        'placementgroup_service'   : 'service/aws/ec2/placementgroup/placementgroup_service'

        #securitygroup service
        'securitygroup_service'   : 'service/aws/ec2/securitygroup/securitygroup_service'

        #acl service
        'acl_service'   : 'service/aws/vpc/acl/acl_service'

        #customergateway service
        'customergateway_service'   : 'service/aws/vpc/customergateway/customergateway_service'

        #dhcp service
        'dhcp_service'   : 'service/aws/vpc/dhcp/dhcp_service'

        #eni service
        'eni_service'   : 'service/aws/vpc/eni/eni_service'

        #internetgateway service
        'internetgateway_service'   : 'service/aws/vpc/internetgateway/internetgateway_service'

        #routetable service
        'routetable_service'   : 'service/aws/vpc/routetable/routetable_service'

        #subnet service
        'subnet_service'   : 'service/aws/vpc/subnet/subnet_service'

        #vpc service
        'vpc_service'   : 'service/aws/vpc/vpc/vpc_service'

        #vpngateway service
        'vpngateway_service'   : 'service/aws/vpc/vpngateway/vpngateway_service'

        #vpn service
        'vpn_service'   : 'service/aws/vpc/vpn/vpn_service'

        #elb service
        'elb_service'   : 'service/aws/elb/elb/elb_service'

        #iam service
        'iam_service'   : 'service/aws/iam/iam/iam_service'


        #autoscaling
        'autoscaling_service'   : 'service/aws/autoscaling/autoscaling/autoscaling_service'

        #cloudwatch
        'cloudwatch_service'    : 'service/aws/cloudwatch/cloudwatch/cloudwatch_service'

        #sns
        'sns_service'           : 'service/aws/sns/sns/sns_service'



        ########## model ##########

        #base_model
        'base_model'             : 'model/base_model'


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
        'autoscaling_model'    : 'model/aws/autoscaling/autoscaling_model'

        #####cloudwatch#####
        'cloudwatch_model'    : 'model/aws/cloudwatch/cloudwatch_model'

        #####sns#####
        'sns_model'    : 'model/aws/sns/sns_model'

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