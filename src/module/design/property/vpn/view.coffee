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

            $( '.property-details' ).html this.template this.model.attributes

    }

    view = new VPNView()

    return view
