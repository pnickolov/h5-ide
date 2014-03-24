#############################
#  View(UI logic) for design/property/vgw
#############################

define [ '../base/view', './template/stack' ], ( PropertyView, template ) ->

    StaticView = PropertyView.extend {
        render : () ->
            @$el.html template( @model.attributes )

            if @model.get "isIGW"
              return "Internet-gateway"
            else
              return "VPN-gateway"

    }

    new StaticView()
