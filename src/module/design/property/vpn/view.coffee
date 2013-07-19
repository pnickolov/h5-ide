#############################
#  View(UI logic) for design/property/vpn
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

   VPNView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-vpn-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:vpn render'

            attributes =
                connectedCGW   : "customer-gateway-1"
                dynamicRouting : true
                ips            : [
                    "72.21.209.225/24" ,
                    "72.21.209.100/24" ,
                    "72.21.209.101/24" ,
                    "72.21.209.102/24"
                ]

            $( '.property-details' ).html this.template attributes

    }

    view = new VPNView()

    return view
