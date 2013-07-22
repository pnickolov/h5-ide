#############################
#  View Mode for design/property/rtb
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], ( constant ) ->

    RTBModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'route_table'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getRoute : ( uid ) ->

            rt = $.extend true, {}, MC.canvas_data.component[uid]

            route_set = []

            $.each rt.resource.RouteSet, ( idx, route ) ->

                existing = false

                tmp_r = {}

                $.each route_set, ( i, r ) ->

                    if (r.InstanceId and r.InstanceId == route.InstanceId) or (r.NetworkInterfaceId and r.NetworkInterfaceId == route.NetworkInterfaceId) or (r.GatewayId and r.GatewayId == route.GatewayId)
                        
                        existing = true

                        r.cidr_set.push route.DestinationCidrBlock

                        return false

                if not existing

                    if route.InstanceId

                        uid = route.InstanceId.split('.')[0][1...]

                        route.type = 'instance'

                        route.ref  = route.InstanceId

                        route.name = MC.canvas_data.component[uid].name

                    if route.NetworkInterfaceId

                        uid = route.NetworkInterfaceId.split('.')[0][1...]

                        route.type = 'eni'

                        route.ref  = route.NetworkInterfaceId

                        route.name = MC.canvas_data.component[uid].name

                    if route.GatewayId

                        uid = route.GatewayId.split('.')[0][1...]

                        route.type = 'gateway'

                        route.ref  = route.GatewayId

                        route.name = MC.canvas_data.component[uid].name

                        if MC.canvas_data.component[route.GatewayId.split('.')[0][1...]].type == constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway

                            route.isVgw = true

                            if route.GatewayId in rt.resource.PropagatingVgwSet

                                route.isProp = true



                    route.cidr_set = [route.DestinationCidrBlock]

                    route_set.push route


            rt.route_disp = route_set


            this.set 'route_table', rt
            
    }

    model = new RTBModel()

    return model