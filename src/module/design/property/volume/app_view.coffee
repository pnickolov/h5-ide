#############################
#  View(UI logic) for design/property/volume(app)
#############################

define [ 'event', 'MC',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    ElbAppView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'


        render     : () ->
            console.log 'property:volume app render', this.model.attributes
            $( '.property-details' ).html this.template this.model.attributes


    }

    view = new ElbAppView()

    return view
