#############################
#  View Mode for design/property/rtb
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], ( constant ) ->

    RTBModel = Backbone.Model.extend {

        defaults :
            'route_table' : null
            'association' : null
            'title'       : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        setName : ( uid, name ) ->

            MC.canvas_data.component[uid].name = name

            MC.canvas.update uid, 'text', 'rt_name', name
            null

        setMainRT : ( uid ) ->


            for id, comp of MC.canvas_data.component
                if comp.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
                    continue

                if comp.resource.AssociationSet.length and "" + comp.resource.AssociationSet[0].Main is 'true'
                    comp.resource.AssociationSet.splice 0, 1
                    MC.canvas.update comp.uid, 'image', 'rt_status', MC.canvas.IMAGE.RT_CANVAS_NOT_MAIN


            asso =
                "Main"                    : "true"
                "RouteTableId"            : ""
                "SubnetId"                : ""
                "RouteTableAssociationId" : ""

            comp = MC.canvas_data.component[ uid ]
            comp.resource.AssociationSet.splice 0, 0, asso
            MC.canvas.update uid, 'image', 'rt_status', MC.canvas.IMAGE.RT_CANVAS_MAIN

            MC.aws.rtb.updateRT_SubnetLines()

            null

        getAppRoute : ( uid ) ->

            rt = MC.data.resource_list[MC.canvas_data.region][MC.canvas_data.component[uid].resource.RouteTableId]

            $.each MC.canvas_data.component, (comp_uid, comp) ->

                if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable and comp.resource.RouteTableId == rt.routeTableId

                    rt.name = comp.name

                    return false

            if rt.associationSet.item.length != 0 and rt.associationSet.item[0].main == 'true'

                rt.isMain = true

            $.each rt.routeSet.item, ( idx, route ) ->

                existing = false

                tmp_r = {}

                if route.state == 'active'

                    route.isActive = true

                else
                    route.isActive = false


                if route.gatewayId

                    if rt.propagatingVgwSet.item

                        $.each rt.propagatingVgwSet.item, ( i, prop ) ->

                            if prop.gatewayId == route.gatewayId

                                route.isProp = true

                                return false

            this.set 'route_table', rt



        getRoute : ( uid ) ->

            # uid might be a line connecting RTB and Subnet
            connection = MC.canvas_data.layout.connection[ uid ]
            if connection
                data = {}
                for uid, value of connection.target
                    component = MC.canvas_data.component[ uid ]
                    if component.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
                        data.subnet = component.name
                    else
                        data.rtb    = component.name

                this.set 'association', data
                this.set 'title', 'Subnet-RT Association'
                return


            # This is a route table component

            rt = $.extend true, {}, MC.canvas_data.component[uid]

            if rt.resource.AssociationSet.length != 0 and rt.resource.AssociationSet[0].Main == 'true'

                rt.isMain = true

            route_set = []

            $.each rt.resource.RouteSet, ( idx, route ) ->

                existing = false

                tmp_r = {}

                if route.state == 'active'

                    route.isActive = true

                else
                    route.isActive = false

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

                        if route.GatewayId is 'local'
                            route.name = "local"
                            route.isLocal = true
                        else
                            route.isLocal = false
                            route.name = MC.canvas_data.component[uid].name

                            if MC.canvas_data.component[route.GatewayId.split('.')[0][1...]].type == constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway

                                route.isVgw = true

                                route.vgw = route.GatewayId.split('.')[0][1...]

                                if route.GatewayId in rt.resource.PropagatingVgwSet

                                    route.isProp = true



                    route.cidr_set = [route.DestinationCidrBlock]

                    route_set.push route


            rt.route_disp = route_set

            if rt.resource.VpcId
                rt.local_cidr = MC.canvas_data.component[rt.resource.VpcId.split('.')[0][1...]].resource.CidrBlock
                rt.vpc_id = MC.canvas_data.component[rt.resource.VpcId.split('.')[0][1...]].resource.VpcId

            this.set 'route_table', rt
            this.set 'association', null
            this.set 'title', rt.name

        setPropagation : ( uid, value ) ->

            vgw_set = MC.canvas_data.component[uid].resource.PropagatingVgwSet

            vgw_ref = '@' + value + '.resource.VpnGatewayId'

            if vgw_set.length == 0

                vgw_set.push vgw_ref

            else
                MC.canvas_data.component[uid].resource.PropagatingVgwSet = []

            null

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
