#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model' ], ( PropertyModel ) ->

    CGWAppModel = PropertyModel.extend {

        init : ( cgw_uid )->

          # cgw assignment
          myCGWComponent = MC.canvas_data.component[ cgw_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          cgw = appData[ myCGWComponent.resource.CustomerGatewayId ]
          if not cgw
            return false

          cgw = $.extend true, {}, cgw
          cgw.name = myCGWComponent.name

          # vpn assignment
          vpn_id = null
          # get vpn id
          _.each MC.canvas_data.component, ( c ) ->
            if c.type is 'AWS.VPC.VPNConnection' and c.resource.CustomerGatewayId is "@#{cgw_uid}.resource.CustomerGatewayId"
              vpn_id = c.resource.VpnConnectionId
              return

          # get vpn
          if appData[ vpn_id ]

            vpn = _.extend {}, appData[ vpn_id ]

            # JSON detail
            config =
              name : "Download"
              type : "download_configuration"

            vpn.detail = JSON.parse MC.aws.vpn.generateDownload( [ config ], vpn )

            #set vpn available
            # if vpn.state is 'available'
            #   vpn.available = true

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

          this.set {
            name : cgw.name
            cgw  : cgw
            vpn  : vpn
          }
          null
    }

    new CGWAppModel()
