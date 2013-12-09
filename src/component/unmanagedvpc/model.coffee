#############################
#  View Mode for component/unmanagedvpc
#############################

define [ 'aws_model', 'backbone', 'jquery', 'underscore', 'MC' ], ( aws_model ) ->

    UnmanagedVPCModel = Backbone.Model.extend {

        defaults :
            'resource_list'    : null

        initialize : ->

            me = this

            @on 'AWS_RESOURCE_RETURN', ( result ) ->
                console.log 'AWS_RESOURCE_RETURN', result

                if result and not result.is_error and result.resolved_data

                	me.set 'resource_list', $.extend true, {}, result.resolved_data

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

    }

    return UnmanagedVPCModel