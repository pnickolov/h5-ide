#############################
#  View(UI logic) for design/property/eni(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    EniAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template  : Handlebars.compile $( '#property-eni-app-tmpl' ).html()

        render     : () ->
            console.log 'property:eni app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes


    }

    view = new EniAppView()

    return view
