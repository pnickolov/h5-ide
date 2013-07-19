#############################
#  View(UI logic) for design/property/vgw
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

   VGWView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-vgw-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:vgw render'
            $( '.property-details' ).html this.template

    }

    view = new VGWView()

    return view