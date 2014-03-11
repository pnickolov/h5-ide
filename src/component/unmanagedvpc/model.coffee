#############################
#  View Mode for component/unmanagedvpc
#############################

define [ 'aws_model', 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], ( aws_model, constant ) ->

    UnmanagedVPCModel = Backbone.Model.extend {

        defaults :
            'resource_list'    : null

        delay    : null

        initialize : ->

            me = this

            # count time out
            @setTimeout()

            # api callback
            @on 'AWS_RESOURCE_RETURN', ( result ) ->
                console.log 'AWS_RESOURCE_RETURN', result

                # test
                #result.return_code = -1

                if result and result.return_code is 0
                    console.log 'import succcess'
                else
                    console.log 'import error'
                    @set 'resource_list', 'service_error'

        reload : ->
            console.log 'reload'

            @set 'resource_list', null
            @setTimeout()
            @getStatResourceService()

        setTimeout : ->
            console.log 'setTimeout'

            me = this

            @delay = setTimeout () ->
                console.log 'resource import setTimeout'
                me.set 'resource_list', 'service_error'
            , 1000 * 60 * 10

        getResource : ( result ) ->
            console.log 'getResource', result

            # clear time out
            if @delay
                clearTimeout @delay

            # delete unnecessary item
            delete result._id
            delete result.timestamp
            delete result.username

            # create resoruces
            resources = @createResources result

            # set vo
            @set 'resource_list', $.extend true, {}, resources

            # set global resource list
            MC.common.other.addUnmanaged $.extend true, {}, resources

        getStatResourceService : ->
            console.log 'getStatResourceService'

            # get resource list by cache
            obj = MC.common.other.listUnmanaged()

            if not _.isEmpty obj

                # set vo
                @set 'resource_list', $.extend true, {}, obj

            else

                # set resources
                resources =
                    'AWS.VPC.VPC'           : {}
                    'AWS.ELB'               : {}
                    'AWS.EC2.Instance'      : {
                        'filter' : {
                            'instance-state-name' : [ 'pending', 'running', 'stopping', 'stopped' ]     # filter terminating and terminated instances
                        }
                    }
                    'AWS.VPC.RouteTable'    : {}
                    'AWS.VPC.Subnet'        : {}
                    'AWS.VPC.VPNGateway'    : {
                        'filter' : {
                            'state' : [ 'pending', 'available' ]    # filter deleting and deleted vgw
                        }
                    }
                    'AWS.VPC.VPNConnection' : {
                        'filter' : {
                            'state' : [ 'pending', 'available' ]    # filter deleting and deleted vpn
                        }
                    }
                    'AWS.AutoScaling.Group' : {}
                    'AWS.VPC.NetworkInterface' : {}

                aws_model.resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), null, resources, 'statistic', 1

            null

        createResources : ( data ) ->
            console.log 'createResources', data

            resource_map = {}

            try

                _.each data, ( obj, region ) ->

                    vpcs = {}
                    _.each obj, ( vpc_obj, vpc_id ) ->

                        new_vpc_obj = {}
                        _.each vpc_obj, ( value, key ) ->
                            new_key = key.replace /\|/igm, '.'
                            new_vpc_obj[ new_key ] = value
                        vpc_obj = new_vpc_obj

                        # filter default vpc
                        if vpc_id isnt MC.data.account_attribute[region].default_vpc

                            l2_res = {
                                'AWS.VPC.VPC'                               : {'id':[vpc_id]},

                                'AWS.AutoScaling.Group'                     : {'id':[]},
                                'AWS.ELB'                                   : {'id':[]},
                                'AWS.VPC.DhcpOptions'                       : {'id':[]},
                                'AWS.VPC.CustomerGateway'                   : {'id':[]},
                                'AWS.AutoScaling.LaunchConfiguration'       : {'id':[]},    # asg name
                                'AWS.AutoScaling.NotificationConfiguration' : {'id':[]},    # asg name

                                'AWS.EC2.Instance'                          : {'filter':{'vpc-id':vpc_id}},
                                'AWS.VPC.RouteTable'                        : {'filter':{'vpc-id':vpc_id}},
                                'AWS.VPC.Subnet'                            : {'filter':{'vpc-id':vpc_id}},
                                'AWS.VPC.VPNGateway'                        : {'filter':{'attachment.vpc-id':vpc_id}},
                                'AWS.EC2.SecurityGroup'                     : {'filter':{'vpc-id':vpc_id}},
                                'AWS.VPC.NetworkAcl'                        : {'filter':{'vpc-id':vpc_id}},
                                'AWS.VPC.NetworkInterface'                  : {'filter':{'vpc-id':vpc_id}},
                                'AWS.VPC.InternetGateway'                   : {'filter':{'attachment.vpc-id':vpc_id}},
                                'AWS.EC2.AvailabilityZone'                  : {'filter':{'region-name':region}},

                                'AWS.EC2.EBS.Volume'                        : {'filter':{'attachment.instance-id':[]}},
                                'AWS.EC2.EIP'                               : {'filter':{'instance-id':[]}},
                                'AWS.VPC.VPNConnection'                     : {'filter':{'vpn-gateway-id':''}},
                                'AWS.AutoScaling.ScalingPolicy'             : {'filter':{'AutoScalingGroupName':[]}},
                            }

                            new_value = {}

                            _.each l2_res, ( attrs, type ) ->
                                resources = {}

                                # set id
                                if 'id' of attrs
                                    if attrs.id.length == 0
                                        # filter 'default' dhcpOptionsId
                                        if type is 'AWS.VPC.DhcpOptions' and type of vpc_obj and 'default' of vpc_obj[type]
                                            dhcp_ids = ( id for id in vpc_obj[type] when id isnt 'default' )
                                            if dhcp_ids.length > 0
                                                resources.id = dhcp_ids

                                        else if type is 'AWS.VPC.CustomerGateway' and 'AWS.VPC.VPNConnection' of vpc_obj
                                            resources.id = (vpc_obj['AWS.VPC.VPNConnection'][vpn_id].customerGatewayId for vpn_id in _.keys(vpc_obj['AWS.VPC.VPNConnection']) when 'customerGatewayId' of vpc_obj['AWS.VPC.VPNConnection'][vpn_id])

                                        else if type is 'AWS.AutoScaling.NotificationConfiguration' and 'AWS.AutoScaling.Group' of vpc_obj
                                            resources.id = _.keys(vpc_obj['AWS.AutoScaling.Group'])

                                        else if type is 'AWS.AutoScaling.LaunchConfiguration' and 'AWS.AutoScaling.Group' of vpc_obj
                                            resources.id = (vpc_obj['AWS.AutoScaling.Group'][asg_id].LaunchConfigurationName for asg_id in _.keys(vpc_obj['AWS.AutoScaling.Group']) when 'LaunchConfigurationName' of vpc_obj['AWS.AutoScaling.Group'][asg_id])

                                        else if type of vpc_obj
                                            resources.id = _.keys(vpc_obj[type])

                                    else
                                        resources.id = attrs.id

                                # set filter
                                if 'filter' of attrs
                                    for k, v of attrs.filter
                                        filter = {}
                                        if not v or v.length == 0
                                            if k in ['instance-id', 'attachment.instance-id'] and 'AWS.EC2.Instance' of vpc_obj
                                                instances = _.keys(vpc_obj['AWS.EC2.Instance'])
                                                if instances.length > 0
                                                    filter[k] = instances

                                            if k is 'vpn-gateway-id' and 'AWS.VPC.VPNGateway' of vpc_obj
                                                filter[k] = _.keys(vpc_obj['AWS.VPC.VPNGateway'])[0]

                                            if k is 'AutoScalingGroupName' and 'AWS.AutoScaling.Group' of vpc_obj
                                                asgs = _.keys(vpc_obj['AWS.AutoScaling.Group'])
                                                if asgs.length > 0
                                                    filter[k] = asgs

                                        else
                                            filter[k] = attrs.filter[k]

                                        if _.keys(filter).length > 0
                                            if not ('filter' of resources)
                                                resources.filter = {}

                                            for k, v of filter
                                                resources.filter[k] = v

                                if _.keys(resources).length > 0
                                    new_value[type] = resources

                            if _.keys(new_value).length > 0
                                vpcs[ vpc_id ] = new_value

                            # add origin item
                            vpcs[ vpc_id ].origin = vpc_obj

                            # add resource_map
                            resource_map[ region ] = vpcs

                console.log 'new resources is ', resource_map

            catch error
                console.log 'createResources error', error, data

            resource_map
    }

    return UnmanagedVPCModel
