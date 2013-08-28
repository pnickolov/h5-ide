#############################
#  View Mode for design/property/vpn
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    VPNModel = Backbone.Model.extend {

        defaults :
            'vpn_detail'    : null
            'cgw_uid'       : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getVPN : (line_option) ->
            me = this

            vpn_detail = {}

            cgw_uid = node.uid for node in line_option when node.port == 'cgw-vpn'
            vgw_uid = node.uid for node in line_option when node.port == 'vgw-vpn'

            if cgw_uid and vgw_uid
                vpn_detail.is_dynamic = if !!MC.canvas_data.component[cgw_uid].resource.BgpAsn then true else false
                vpn_detail.cgw_name = MC.canvas_data.component[ cgw_uid ].name

                vgw_ref = '@' + vgw_uid + '.resource.VpnGatewayId'
                cgw_ref = '@' + cgw_uid + '.resource.CustomerGatewayId'

                _.map MC.canvas_data.component, (item) ->

                    if item.type == 'AWS.VPC.VPNConnection' and item.resource.VpnGatewayId == vgw_ref and item.resource.CustomerGatewayId == cgw_ref

                        vpn_detail.uid = item.uid

                        vpn_detail.name = item.name

                        vpn_detail.ips = []

                        vpn_detail.ips.push route.DestinationCidrBlock for route in item.resource.Routes

                        vpn_detail.is_del = if vpn_detail.ips.length > 1 then true else false

                        null

            me.set 'vpn_detail', vpn_detail
            me.set 'cgw_uid', cgw_uid

        delIP : (ip) ->
            me = this

            vpn_detail = me.get 'vpn_detail'

            if ip in vpn_detail.ips
                vpn_detail.ips.splice vpn_detail.ips.indexOf(ip), 1

                #update vpn component
                routes = MC.canvas_data.component[ vpn_detail.uid ].resource.Routes

                for route in routes
                    if route.DestinationCidrBlock == ip
                        MC.canvas_data.component[ vpn_detail.uid ].resource.Routes.splice(routes.indexOf(route), 1)
                        break

                me.set 'vpn_detail', vpn_detail

                me.trigger 'UPDATE_VPN_DATA'

            null

        updateIps : ( ipset ) ->

            vpn_detail = this.get 'vpn_detail'

            routes = []
            for i in ipset
                routes.push { 'Source' : '', 'State' : '', 'DestinationCidrBlock' : i }

            MC.canvas_data.component[ vpn_detail.uid ].resource.Routes = routes
            null

    }

    model = new VPNModel()

    return model
