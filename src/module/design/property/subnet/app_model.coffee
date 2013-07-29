#############################
#  View Mode for design/property/subnet
#############################

define [ 'backbone', 'MC' ], () ->

    SubnetAppModel = Backbone.Model.extend {

        ###
        defaults :

        ###

        init : ( subnet_uid )->

          mySubnetComponent = MC.canvas_data.component[ subnet_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          subnet = $.extend true, {}, appData[ mySubnetComponent.resource.SubnetId ]
          subnet.name = mySubnetComponent.name

          if subnet.state == "available"
            subnet.available = true

          this.set subnet

    }

    new SubnetAppModel()
