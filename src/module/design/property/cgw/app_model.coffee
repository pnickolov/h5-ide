#############################
#  View Mode for design/property/cgw
#############################

define [ 'backbone', 'MC' ], () ->

    CGWAppModel = Backbone.Model.extend {

        init : ( cgw_uid )->

          myCGWComponent = MC.canvas_data.component[ cgw_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          cgw = $.extend true, {}, appData[ myCGWComponent.resource.CustomerGatewayId ]
          cgw.name = myCGWComponent.name

          if cgw.state == "available"
            cgw.available = true

          cgw.state = MC.capitalize cgw.state

          console.log cgw

          this.set cgw
    }

    new CGWAppModel()
