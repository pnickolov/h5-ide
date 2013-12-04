#############################
#  View Mode for component/unmanagedvpc
#############################

define [ 'aws_model', 'backbone', 'jquery', 'underscore', 'MC' ], ( aws_model ) ->

    UnmanagedVPCModel = Backbone.Model.extend {

        defaults :
            'resource_list'    : null

        initialize : ->

            #me = this

            @on 'AWS_STAT__RESOURCE_RETURN', ( result ) ->
                console.log 'AWS_STAT__RESOURCE_RETURN', result

        getStatResourceService : ->
            console.log 'getStatResourceService'

            # set resources
            resources =
                'AWS.EC2.Instance' : {}
                'AWS.ELB'          : {}
                'AWS.VPC.Subnet'   : {}
                'AWS.VPC.VPC'      : {}

            aws_model.stat_resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, resources

            null

    }

    return UnmanagedVPCModel