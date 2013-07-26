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

        setName : ( uid, name ) ->

            MC.canvas_data.component[uid].name = name

            MC.canvas.update uid, 'text', 'rt_name', name
            null

        setMainRT : ( uid ) ->

            #remove association
            $.each MC.canvas_data.component, ( comp_uid, comp ) ->

                if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable and comp.resource.AssociationSet.length != 0 and comp.resource.AssociationSet[0].Main == 'true'

                    comp.resource.AssociationSet.splice 0, 1

                    MC.canvas.update comp.uid, 'image', 'rt_status', MC.canvas.IMAGE.RT_CANVAS_NOT_MAIN
                    # add new association to not main rt
                    $.each MC.canvas_data.layout.connection, ( line_id, line_obj ) ->

                        map = {}

                        $.each line_obj.target, ( comp_uid, comp_type ) ->

                            map[comp_type] = comp_uid

                            null

                        if map['rtb-src']

                            rt_uid = map['rtb-src']

                            if rt_uid == comp.uid

                                asso = {}

                                asso.SubnetId = '@' + map['subnet-assoc-out'] + '.resource.SubnetId'

                                asso.Main = 'false'

                                asso.RouteTableId = ''

                                asso.RouteTableAssociationId = ''

                                comp.resource.AssociationSet.push asso

                    return false

            asso = {

                "Main": "true",
                "RouteTableId": "",
                "SubnetId": "",
                "RouteTableAssociationId": ""
            }

            # remove main association and add new association
            MC.canvas_data.component[uid].resource.AssociationSet = []
            MC.canvas_data.component[uid].resource.AssociationSet.push asso

            MC.canvas.update uid, 'image', 'rt_status', MC.canvas.IMAGE.RT_CANVAS_MAIN

            null


        getRoute : ( uid ) ->

            rt = $.extend true, {}, MC.canvas_data.component[uid]

            if rt.resource.AssociationSet.length != 0 and rt.resource.AssociationSet[0].Main == 'true'

                rt.isMain = true

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


        setRoutes : ( uid, data, routes ) ->

            # remove all routes
            delete_idx = []

            switch data.type

                when 'gateway'

                    $.each MC.canvas_data.component[uid].resource.RouteSet, ( idx, route ) ->

                        if route.GatewayId == data.ref

                            delete_idx.push idx

                when 'instance'

                    $.each MC.canvas_data.component[uid].resource.RouteSet, ( idx, route ) ->

                        if route.InstanceId == data.ref

                            delete_idx.push idx

                when 'eni'

                    $.each MC.canvas_data.component[uid].resource.RouteSet, ( idx, route ) ->

                        if route.NetworkInterfaceId == data.ref

                            delete_idx.push idx

            delete_idx.sort ( x, y )->

                if x <= y
                    return 1

                else
                    return -1

            $.each delete_idx, ( i, v ) ->

                MC.canvas_data.component[uid].resource.RouteSet.splice v, 1


            # add all routes
            $.each routes, ( idx, route ) ->

                if route.children[1].children[0].value != ''

                    route_tmpl = {
                        'DestinationCidrBlock'      :   route.children[1].children[0].value,
                        'GatewayId'                 :   '',
                        'InstanceId'                :   '',
                        'InstanceOwnerId'           :   '',
                        'NetworkInterfaceId'        :   '',
                        'State'                     :   '',
                        'Origin'                    :   ''
                    }

                    switch data.type

                        when 'gateway'

                            route_tmpl.GatewayId = data.ref

                        when 'instance'

                            route_tmpl.InstanceId = data.ref

                        when 'eni'

                            route_tmpl.NetworkInterfaceId = data.ref


                    MC.canvas_data.component[uid].resource.RouteSet.push route_tmpl






    }

    model = new RTBModel()

    return model