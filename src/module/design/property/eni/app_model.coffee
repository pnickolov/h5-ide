#############################
#  View Mode for design/property/eni
#############################

define [ 'backbone', 'MC' ], () ->

    EniAppModel = Backbone.Model.extend {

        ###
        defaults :

        ###

        init : ( eni_uid )->

          myEniComponent = MC.canvas_data.component[ eni_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          eni = $.extend true, {}, appData[ myEniComponent.resource.NetworkInterfaceId || "eni-cbcc18a5" ]
          eni.name = myEniComponent.name

          if eni.status == "in-use"
            eni.isInUse = true

          eni.sourceDestCheck = if eni.sourceDestCheck is "true" then "enabled" else "disabled"

          for i in eni.privateIpAddressesSet.item
            i.primary = i.primary == "true"

          this.set eni
    }

    new EniAppModel()
