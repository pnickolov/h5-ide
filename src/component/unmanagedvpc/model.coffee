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
                    _.each obj, ( vpc_obj, vpc ) ->

                        new_value = {}
                        _.each vpc_obj, ( value, key ) ->

                            switch key
                                when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC
                                    new_value[ key ] = { 'id' : vpc }
                                when constant.AWS_RESOURCE_TYPE.AWS_ELB
                                    new_value[ key ] = { 'id' : [] }
                                    console.log 'key is ' + vpc + ' AWS_ELB is ', value
                                when constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance, constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable, constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
                                    new_value[ key ] = { 'filter' : 'vpc-id' : vpc }
                                when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway
                                    new_value[ key ] = { 'filter' : { 'attachment.vpc-id' : vpc }}
                                when constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection
                                    #console.log 'key is ' + vpc + ' AWS_VPC_VPNConnection is ', value
                                    new_value[ key ] = { 'filter' : { 'vpn-gateway-id' : value[ 'vpnGatewayId' ] }}
                                when constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
                                    new_value[ key ] = { 'id' : [] }
                                    console.log 'key is ' + vpc + ' AWS_AutoScaling_Group is ', value

                        vpcs[ vpc ] = new_value

                    resources[ region ] = vpcs

                console.log 'new resources is ', resources

            catch error
                console.log 'createResources error', error, data

            resources
    }

    return UnmanagedVPCModel