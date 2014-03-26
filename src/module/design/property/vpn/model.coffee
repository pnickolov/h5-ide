#############################
#  View Mode for design/property/vpn
#############################

define [ '../base/model', "Design", "constant" ], ( PropertyModel, Design, constant ) ->

    VPNModel = PropertyModel.extend {

        init : ( uid ) ->

            vpn = Design.instance().component( uid )
            vgw = vpn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway )
            cgw = vpn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway )

            if @isApp or @isAppEdit
                @getAppData( vpn.get("appId") )

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

        getAppData : ( vpnAppId )->
            # get vpn
            appData = MC.data.resource_list[ Design.instance().region() ]

            vpn = $.extend true, {}, appData[ vpnAppId ]

            #temp
            if vpn
                vpncfg_str = MC.aws.vpn.generateDownload( [{"type":"download_configuration","name":"Download Configuration"}], vpn )
                vpncfg     = JSON.parse(vpncfg_str)
                if vpncfg and vpncfg.length>0
                    @set "vpncfg", vpncfg[0]

            # # JSON detail
            # config =
            #     name : "Download"
            #     type : "download_configuration"

            # vpn.detail = JSON.parse MC.aws.vpn.generateDownload( [ config ], vpn )

            if vpn.vgwTelemetry and vpn.vgwTelemetry.item
              vpn.vgwTelemetry = _.map vpn.vgwTelemetry.item, ( item, idx ) ->
                item = $.extend true, {}, item
                item.index = idx + 1
                item

            vpn.isApp = @isApp
            @set vpn
    }

    new VPNModel()
