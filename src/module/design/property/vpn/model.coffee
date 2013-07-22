#############################
#  View Mode for design/property/vpn
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    VPNModel = Backbone.Model.extend {

        defaults :
            'vpn_detail'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getVPN : (line_option) ->
            me = this

            vpn_detail = me.get 'vpn_detail'

            if not vpn_detail
                cgw_uid = node.uid for node in line_option when node.port == 'cgw-vpn'
                vgw_uid = node.uid for node in line_option when node.port == 'vgw-vpn'

                if cgw_uid and vgw_uid
                    vpn_detail.is_dynamic = if MC.canvas_data.component[ cgw_uid ].BgpAsn then true else false
                    vpn_detail.cgw_name = MC.canvas_data.component[ cgw_uid ].name

                    _.map MC.canvas_data.component, (item) ->
                        cgw_ref = '@' + cgw_uid + '.resource.VpnGatewayId'
                        vgw_ref = '@' + vgw_uid + '.resource.CustomerGatewayId'

                        if item.type == 'AWS.VPC.VPNConnection' and item.resource.VpnGatewayId == cgw_ref and item.resource.CustomerGatewayId == vgw_ref
                           
                            vpn_detail.uid = item.uid
                            
                            vpn_detail.name = item.name

                            vpn_detail.ips = []
                            
                            vpn_detail.ips.push route.DestinationCidrBlock for route in item.resource.Routes

                            vpn_detail.is_del = if vpn_detail.ips.length > 1 then true else false

                            null

                me.set 'vpn_detail', vpn_detail
            
        delIP : (ip) ->
            me = this

            vpn_detail = me.get 'vpn_detail'

            if ip in vpn_detail.ips
                delete vpn_detail.ips[vpn_detail.ips.indexOf(ip)]

                #update vpn component
                routes = MC.canvas_data.component[ vpn_detail.uid ].resource.Routes

                delete MC.canvas_data.component[ vpn_detail.uid ].resource.Routes[ routes.indexOf(route) ] for route in routes when route.DestinationCidrBlock == ip

                me.set 'vpn_detail', vpn_detail

            null

        addIP : (new_ip) ->
            me = this

            vpn_detail = me.get 'vpn_detail'

            if new_ip not in vpn_detail.ips
                vpn_detail.ips.push new_ip

                #update vpn component
                route = { 'Source' : '', 'State' : '', 'DestinationCidrBlock' : new_ip }

                MC.canvas_data.component[ vpn_detail.uid ].resource.Routes.push route

                me.set 'vpn_detail', vpn_detail

            null

    }

    model = new VPNModel()

    return model