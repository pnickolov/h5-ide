#############################
#  View Mode for design/property/vpn
#############################

define [ '../base/model' ], ( PropertyModel ) ->

    VPNModel = PropertyModel.extend {

        init : ( uid ) ->

            vpn_detail  = {}
            line_option = MC.canvas.lineTarget uid

            line_option_map = {}
            line_option_map[ line_option[0].port ] = line_option[0].uid
            line_option_map[ line_option[1].port ] = line_option[1].uid

            cgw_uid = line_option_map[ 'cgw-vpn' ]
            vgw_uid = line_option_map[ 'vgw-vpn' ]

            if @isApp
                @getAppData cgw_uid, vgw_uid

            else if cgw_uid and vgw_uid
                vpn_detail.is_dynamic = if !!MC.canvas_data.component[cgw_uid].resource.BgpAsn then true else false

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

            @set 'vpn_detail', vpn_detail
            @set 'cgw_uid', cgw_uid
            @set 'cgw_name', MC.canvas_data.component[ cgw_uid ].name

        delIP : (ip) ->

            vpn_detail = @get 'vpn_detail'

            if ip in vpn_detail.ips
                vpn_detail.ips.splice vpn_detail.ips.indexOf(ip), 1

                #update vpn component
                routes = MC.canvas_data.component[ vpn_detail.uid ].resource.Routes

                for route in routes
                    if route.DestinationCidrBlock == ip
                        MC.canvas_data.component[ vpn_detail.uid ].resource.Routes.splice(routes.indexOf(route), 1)
                        break

                @set 'vpn_detail', vpn_detail

                @trigger 'UPDATE_VPN_DATA'

            null

        updateIps : ( ipset ) ->

            vpn_detail = this.get 'vpn_detail'

            routes = []
            for i in ipset
                routes.push { 'Source' : '', 'State' : '', 'DestinationCidrBlock' : i }

            MC.canvas_data.component[ vpn_detail.uid ].resource.Routes = routes
            null

        getAppData : ( cgw_uid, vgw_uid )->
            # vpn assignment
            vpn_id = null
            # get vpn id
            for uid, comp of MC.canvas_data.component
                if comp.type is 'AWS.VPC.VPNConnection' and comp.resource.CustomerGatewayId is "@#{cgw_uid}.resource.CustomerGatewayId"
                    vpn_id = comp.resource.VpnConnectionId
                    break

            # get vpn
            appData = MC.data.resource_list[ MC.canvas_data.region ]

            vpn = _.extend {}, appData[ vpn_id ]

            # # JSON detail
            # config =
            #     name : "Download"
            #     type : "download_configuration"

            # vpn.detail = JSON.parse MC.aws.vpn.generateDownload( [ config ], vpn )

            #set vpn routing
            if vpn.options.staticRoutesOnly is "true"
                vpn.routing = "Static"
            else
                vpn.routing = "Dynamic"

            # cgw state color
            twoStateColorMap =
                DOWN : 'red'
                UP   : 'green'

            if vpn.vgwTelemetry and vpn.vgwTelemetry.item
              vpn.vgwTelemetry.item = _.map vpn.vgwTelemetry.item, ( item, idx ) ->
                item.index = idx + 1
                item.stateColor = twoStateColorMap[item.status]
                item

            vpn.isApp = @isApp
            @set vpn
    }

    new VPNModel()
