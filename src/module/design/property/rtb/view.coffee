#############################
#  View(UI logic) for design/property/rtb
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    RTBView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-rtb-tmpl' ).html()

        #events   :

        render     : ( attributes ) ->
            console.log 'property:rtb render'
            $( '.property-details' ).html this.template attributes

    }

    view = new RTBView()

    return view