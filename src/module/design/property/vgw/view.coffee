#############################
#  View(UI logic) for design/property/vgw
#############################

define [ '../base/view', 'text!./template/stack.html' ], ( PropertyView, template ) ->

    VGWView = PropertyView.extend {
        render     : () ->
            console.log 'property:vgw render'
            @$el.html template
            "VPN-gateway"

    }

    new VGWView()
