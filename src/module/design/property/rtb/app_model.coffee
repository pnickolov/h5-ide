#############################
#  View Mode for design/property/rtb
#############################

define [ 'backbone', 'MC' ], () ->

    RTBAppModel = Backbone.Model.extend {

        init : ( rtb_uid )->

          myRTBComponent = MC.canvas_data.component[ rtb_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          rtb = $.extend true, {}, appData[ myRTBComponent.resource.RouteTableId ]
          rtb.name = myRTBComponent.name

          if rtb.associationSet.item.main == "true"
            rtb.main = "Yes"
          else
            rtb.main = "No"

          for i in rtb.routeSet.item
            if i.state == "active"
              i.active = true

          this.set rtb
    }

    new RTBAppModel()
