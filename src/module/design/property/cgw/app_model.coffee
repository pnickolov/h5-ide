#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model' ], ( PropertyModel ) ->

    CGWAppModel = PropertyModel.extend {

        init : ( uid )->

          # cgw assignment
          myCGWComponent = Design.instance().component( uid )

          appData = MC.data.resource_list[ Design.instance().region() ]

          cgw = appData[ myCGWComponent.get 'CustomerGatewayId' ]
          if not cgw
            return false

          cgw = $.extend true, {}, cgw
          cgw.name = myCGWComponent.get 'name'

          # vpn assignment
          vpn_id = null
          # get vpn id
          allVpn = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection ).allObjects()

          for vpn in allVpn
            if vpn.get 'CustomerGatewayId' is "@#{uid}.resource.CustomerGatewayId"
              vpn_id = vpn.get 'VpnConnectionId'
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

          this.set
            name : cgw.name
            cgw  : cgw
            vpn  : vpn

          null
    }

    new CGWAppModel()
