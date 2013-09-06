#############################
#  View Mode for design/property/rtb
#############################

define [ 'backbone', 'MC' ], () ->

    RTBAppModel = Backbone.Model.extend {

        init : ( rtb_uid )->

          components = MC.canvas_data.component

          myRTBComponent = components[ rtb_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          rtb = $.extend true, {}, appData[ myRTBComponent.resource.RouteTableId ]
          rtb.name = myRTBComponent.name

          if rtb.associationSet.item && rtb.associationSet.item[0] && rtb.associationSet.item[0].main == "true"
            rtb.main = "Yes"
          else
            rtb.main = "No"

          for i in rtb.routeSet.item
            if i.state == "active"
              i.active = true

          propagate = {}

          # Find out which route is propagated.
          if rtb.propagatingVgwSet and rtb.propagatingVgwSet.item
            for i in rtb.propagatingVgwSet.item
              propagate[ i.gatewayId ] = true

          for value, key in rtb.routeSet.item
            if propagate[ value.gatewayId ]
              value.propagate = true

          this.set rtb
    }

    new RTBAppModel()
