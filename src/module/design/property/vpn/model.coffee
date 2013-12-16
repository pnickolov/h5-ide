#############################
#  View Mode for design/property/vpn
#############################

define [ '../base/model', "Design", "constant" ], ( PropertyModel, Design, constant ) ->

    VPNModel = PropertyModel.extend {

        init : ( uid ) ->

            vpn = Design.instance().component( uid )
            vgw = vpn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway )
            cgw = vpn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway )

            if @isApp
                @getAppData( cgw, vgw )

            else
                @set {
                    uid     : uid
                    name    : "vpn:#{cgw.get('name')}"
                    ips     : vpn.get("routes")
                    dynamic : cgw.isDynamic()
                }

            null

        updateIps : ( ipset ) ->
            Design.instance().component( @get("uid") ).set("routes", ipset)
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
