#############################
#  View Mode for design/property/vpc (app)
#############################

define ['backbone', 'MC' ], () ->

    dashRegex = /-([\da-z])/gi
    camelCase = ( input ) ->
        input.replace dashRegex, ( a, letter ) -> letter.toUpperCase()


    VPCAppModel = Backbone.Model.extend {

        ###
            defaults :

        ###

        init : ( vpc_uid ) ->

          myVPCComponent = MC.canvas_data.component[ vpc_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          vpc = $.extend true, {}, appData[ myVPCComponent.resource.VpcId ]
          vpc.name = myVPCComponent.name

          if vpc.state == "available"
            vpc.available = true

          this.set vpc
    }

    new VPCAppModel()
