#############################
#  View(UI logic) for design/property/cgw(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    CGWAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-cgw-app-tmpl' ).html()

        render     : () ->
            console.log 'property:cgw app render'
            $( '.property-details' ).html this.template this.model.attributes
    }

    view = new CGWAppView()

    return view