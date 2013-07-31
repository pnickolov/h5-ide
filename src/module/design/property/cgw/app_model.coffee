#############################
#  View Mode for design/property/cgw
#############################

define [ 'backbone', 'MC' ], () ->

    CGWAppModel = Backbone.Model.extend {

        defaults :
            cgw: null
            vpn: null

        init : ( cgw_uid )->

          # cgw assignment
          myCGWComponent = MC.canvas_data.component[ cgw_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          cgw = $.extend true, {}, appData[ myCGWComponent.resource.CustomerGatewayId ]
          cgw.name = myCGWComponent.name

          # cgw state color
          multiStateColorMap = {
            pending: 'yellow'
            available: 'green'
            deleting: 'red'
            deleted: 'red'
          }

          # cgw state color
          twoStateColorMap = {
            DOWN: 'red'
            UP: 'green'
          }

          cgw.stateColor = multiStateColorMap[cgw.state]

          # vpn assignment
          vpn_id = null
          # get vpn id
          _.each MC.canvas_data.component, ( c ) ->
            if c.type is 'AWS.VPC.VPNConnection' and \
            c.resource.CustomerGatewayId is "@#{cgw_uid}.resource.CustomerGatewayId"
              vpn_id = c.resource.VpnConnectionId
              return

          # get vpn
          vpn = _.extend {}, appData[ vpn_id ]

          # JSON detail
          vpn.detail = JSON.parse vpn.detail

          #set vpn available
          if vpn.state is 'available'
            vpn.available = true

          #set vpn routing
          if vpn.options.staticRoutesOnly is "true"
            vpn.routing = "Static"
          else
            vpn.routing = "Dynamic"


          if vpn.vgwTelemetry and vpn.vgwTelemetry.item
            vpn.vgwTelemetry.item = _.map vpn.vgwTelemetry.item, ( item ) ->
              item.stateColor = twoStateColorMap[item.status]
              item

          if vpn.routes and vpn.routes.item
            vpn.routes.item = _.map vpn.routes.item, ( item ) ->
              item.stateColor = multiStateColorMap[item.state]
              item

          this.set {
            cgw: cgw
            vpn: vpn
          }
    }

    new CGWAppModel()
