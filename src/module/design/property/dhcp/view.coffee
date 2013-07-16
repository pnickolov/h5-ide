#############################
#  View(UI logic) for design/property/dhcp
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    DHCPView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-dhcp-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:dhcp render'

    }

    view = new DHCPView()

    return view