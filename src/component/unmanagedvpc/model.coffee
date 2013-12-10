#############################
#  View Mode for component/unmanagedvpc
#############################

define [ 'aws_model', 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], ( aws_model, constant ) ->

    UnmanagedVPCModel = Backbone.Model.extend {

        defaults :
            'resource_list'    : null

        initialize : ->

            me = this

            @on 'AWS_RESOURCE_RETURN', ( result ) ->
                console.log 'AWS_RESOURCE_RETURN', result

                if result and not result.is_error and result.resolved_data

                    # create resoruces
                    resources = me.createResources result.resolved_data

                    # set vo
                    me.set 'resource_list', $.extend true, {}, resources

                    null

        getStatResourceService : ->
            console.log 'getStatResourceService'

            # set resources
            resources =
                'AWS.VPC.VPC'           : {}
                'AWS.ELB'               : {}
                'AWS.EC2.Instance'      : {}
                'AWS.VPC.RouteTable'    : {}
                'AWS.VPC.Subnet'        : {}
                'AWS.VPC.VPNGateway'    : {}
                'AWS.VPC.VPNConnection' : {}
                'AWS.AutoScaling.Group' : {}

            aws_model.resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, resources, 'statistic', 1

            null

        createResources : ( data ) ->
            console.log 'createResources', data

            resources = {}

            try

                _.each data, ( obj, region ) ->

                    vpcs = {}
                    _.each obj, ( vpc_obj, vpc_id ) ->

                        l2_res = {
                            'AWS.VPC.VPC'                               : {'id':[vpc_id]},
                            'AWS.ELB'                                   : {'id':[]},
                            'AWS.EC2.Instance'                          : {'filter':{'vpc-id':vpc_id}},
                            'AWS.VPC.RouteTable'                        : {'filter':{'vpc-id':vpc_id}},
                            'AWS.VPC.Subnet'                            : {'filter':{'vpc-id':vpc_id}},
                            'AWS.VPC.VPNGateway'                        : {'filter':{'attachment.vpc-id':vpc_id}},
                            #'AWS.VPC.VPNConnection'                     : {'filter':{'vpn-gateway-id':''}},
                            'AWS.AutoScaling.Group'                     : {'id':[]},

                            'AWS.EC2.SecurityGroup'                     : {'filter':{'vpc-id':vpc_id}},
                            'AWS.VPC.NetworkAcl'                        : {'filter':{'vpc-id':vpc_id}},
                            'AWS.VPC.NetworkInterface'                  : {'filter':{'vpc-id':vpc_id}},
                            #'AWS.VPC.InternetGateway'                   : {'filter':{'attachment.vpc-id':vpc_id}},

                            'AWS.EC2.AvailabilityZone'                  : {'filter':{'region-name':region}},
                            #'AWS.EC2.EBS.Volume'                        : {'filter':{'attachment.instance-id':[]}},
                            #'AWS.EC2.EIP'                               : {'filter':{'instance-id':[]}},
                            'AWS.VPC.DhcpOptions'                       : {'id':[]},
                            'AWS.VPC.CustomerGateway'                   : {'id':[]},
                            #'AWS.AutoScaling.LaunchConfiguration'       : {'id':[]},
                            #'AWS.AutoScaling.NotificationConfiguration' : {'id':[]},
                            #'AWS.AutoScaling.ScalingPolicy'             : {'filter':{'AutoScalingGroupName':[]}},
                        }

                        new_value = {}

                        _.each l2_res, ( attrs, type ) ->
                            filter = attrs

                            if 'id' of filter and filter['id'].length == 0
                                if type of vpc_obj
                                    filter['id'] = _.keys(vpc_obj[type])
                                    new_value[type] = filter

                            else
                                new_value[type] = filter

                        # add vpc
                        new_value[ constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ] = { 'id' : [vpc_id] }
                        vpcs[ vpc_id ] = new_value

                    resources[ region ] = vpcs

                console.log 'new resources is ', resources

            catch error
                console.log 'createResources error', error, data

            resources
    }

    return UnmanagedVPCModel