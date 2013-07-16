#############################
#  View(UI logic) for design/property/az
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    AZView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-az-tmpl' ).html()

        #events   :

        render     : ( attributes ) ->
            console.log 'property:az render'
            $( '.property-details' ).html this.template attributes

    }

    view = new AZView()

    return view